local marker = {}

local function initaliseMarker(thisform, m)
    -- sets some routine default values that are generic to all markers
    -- these values might be overwritten in the calling function
    m.isFlagship = false
    m.columnNumber = love.math.random(1, thisform.numOfColumns)

    local colsize = form.getSizeOfColumn(thisform, m.columnNumber)
    m.sequenceInColumn = colsize + 1

    m.length = 209  -- pixels
    m.isSelected = false
    m.isTarget = false
    m.missileFactor = 0
    m.torpedoCount = 0
    m.topedoHitsSustained = 0
    m.isSunk = false
    m.targetID = "" -- flotilla, formation, marker
    m.planningstep = {}     -- holds future moves determined during the planning stage
    m.frontGunPosition = 20     -- draws the front gun image 20 pixels from the centre of the marker
    m.damageSustained = 0       -- tracks damage taken each combat round

end

local function AddTurret(struct, gf, tf)
    -- input: structure (object/table)
    -- input: gunfactor (number)
    -- input: torpedofactor (number)
    -- output: none. Operates directly on structure (object/table)

    local myturret = {}
    myturret.active = true
    myturret.gunfactor = gf
    myturret.torpedoFactor = tf
    table.insert(struct, myturret)
end

function marker.getCorrectPositionInFormation(thismarker)
    -- determine the correct x/y position for this marker by determining the formation, the flagship and the column the marker belongs to
    -- input: a marker object
    -- output: the x/y reflecting the preferred location with in the formation
    local thisform, flagship
    local fsheading, fsX, fsY   -- key flagship attributes

    -- determine which formation the marker is in and get the flagship for that formation
    for q,flot in pairs(flotilla) do
        for w,frm in pairs(flot.formation) do
            for e, mrk in pairs(frm.marker) do
                if mrk == thismarker then
                    -- found the correct marker so capture the formation
                    thisform = frm
                end
            end
        end
    end
    assert(thisform ~= nil)

    -- get the flagship for the captured formation
    flagship = form.getFlagship(thisform)
    assert(flagship ~= nil)

    -- determine if thismarker should be left or right of the flagship by checking numOfColumns
    local columndelta = thismarker.columnNumber - flagship.columnNumber    -- a negative number means m should be left of flagship
    local laststepnumber = #flagship.planningstep

    -- determine the flagship x/y
    if laststepnumber == 0 then
        -- no planned moves
        -- the first time this is called for a marker during initialising, the posx/y will be null so fall back to the formation x/y
        if flagship.positionX == nil then
            fsX = thisform.positionX
            fsY = thisform.positionY
            fsheading = thisform.heading
        else
            fsX = flagship.positionX
            fsY = flagship.positionY
            fsheading = flagship.heading
        end
    else
        -- use the future position
        fsX = flagship.planningstep[laststepnumber].newx
        fsY = flagship.planningstep[laststepnumber].newy
        fsheading = flagship.planningstep[laststepnumber].newheading
    end

    assert(fsX ~= nil and fsY ~= nil)

    -- determine position in formation based on flagship x/y and the column number for the marker
    if columndelta < 0 then
        -- left side of the flagship
        -- determine head position of this column
        -- assumes columns are 45 degrees behind flagship
        -- using trigonometry and knowledge of distance between columns:

        -- cos = adj / hyp
        -- hyp = adj / cos
        local hyp = (thisform.distanceBetweenColumns) / math.cos(45) -- gives the hypotenuse/distance for the marker leading the adjacent column
        -- multipy this hypotenuse for each column away from teh fs column
        hyp = hyp * math.abs(columndelta)
        -- determine x/y for the lead marker for this column
        -- it is known that the angle is fs heading - 135 degrees relative
        local relativeheadingfromfs = fsheading - 135
        if relativeheadingfromfs < 0 then relativeheadingfromfs = 360 + relativeheadingfromfs end       -- this is a + because the value is a negative
        local colheadx, colheady = cf.AddVectorToPoint(fsX,fsY,relativeheadingfromfs,hyp)

        -- move back through the column to find correct position in sequence
        if thismarker.sequenceInColumn == 1 then
            return colheadx, colheady
        else
            -- marker is not at head of column so need to work out how far back to place it
            -- determine the reverse direction (i.e. fs - 180 relative)
            -- from the head of the column, move backwards length * sequenceInColumn
            local direction = fsheading + 180
            if direction > 359 then direction = direction - 360 end
            local dist = thismarker.length * 1.5 * thismarker.sequenceInColumn
            local x, y = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            return x, y
        end
    elseif columndelta > 0 then -- it is in a column to the right of the fs
        local hyp = (thisform.distanceBetweenColumns) / math.cos(45) -- gives the hypotenuse/distance for the marker leading the adjacent column
        hyp = hyp * math.abs(columndelta)
        local relativeheadingfromfs = fsheading + 135
        if relativeheadingfromfs > 359 then relativeheadingfromfs = relativeheadingfromfs - 360 end
        local colheadx, colheady = cf.AddVectorToPoint(fsX,fsY,relativeheadingfromfs,hyp)

        -- move back through the column to find correct position in sequence
        if thismarker.sequenceInColumn == 1 then
            return colheadx, colheady
        else
            -- marker is not at head of column so need to work out how far back to place it
            -- determine the reverse direction (i.e. fs - 180 relative)
            -- from the head of the column, move backwards length * sequenceInColumn
            local direction = fsheading + 180
            if direction > 359 then direction = direction - 360 end
            local dist = thismarker.length * 1.5 * thismarker.sequenceInColumn
            local x,y = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            return x, y
        end
    elseif columndelta == 0 then        -- same column as fs (in line)
        local colheadx, colheady = fsX, fsY

        -- move back through the column to find correct position in sequence
        if thismarker.sequenceInColumn == 1 then
            return colheadx, colheady
        else
            -- marker is not at head of column so need to work out how far back to place it
            -- determine the reverse direction (i.e. fs - 180 relative)
            -- from the head of the column, move backwards length * sequenceInColumn
            local direction = fsheading + 180
            if direction > 359 then direction = direction - 360 end
            local dist = thismarker.length * 1.5 * thismarker.sequenceInColumn
            local x, y = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            return x, y
        end
    else
        error("Unexpected program flow")
    end
end

function marker.getMarkerPoints(m)
    -- given a marker (m) return two x/y pairs that describe the start of the marker to the end of the marker, i.e. the length of the marker.
    -- this is determined by the centre point and the heading that is stored inside m
    -- output: two xy pairs (x1, y1, x2, y2)
    local xcentre = (m.positionX)
    local ycentre = (m.positionY)
    local heading = (m.heading)
    local headingrad = math.rad(heading)
    local dist = (m.length)
    local x1, y1 = cf.AddVectorToPoint(xcentre,ycentre,heading, (dist/2))		-- front
    local x2, y2 = cf.AddVectorToPoint(xcentre,ycentre,heading, (dist/2) * -1)	-- rear
    return x1, y1, x2, y2
end

local function getDrawingCentre(thismarker)
    -- Gets the correct centre of the marker for drawing purposes noting that love.graphics.draw origin is the top left corner of each image.
    -- input: a marker table (could also be a planned step/ghost table)
    -- output: an x/y pair that will correctly draw the marker in the right spot

    -- need to determine if thismarker is a real marker or a planned step/ghost
    -- this is done by checking for nil values
    local drawingheading
    local markerheading
    local drawingcentrex
    local drawingcentrey
    local offset, frontoffset

    if thismarker.newx == nil then
        -- real marker
        offset = 15         -- Move left this much. Negatives don't work. See 'drawingheadng' below. Correct number depends on image
        frontoffset = 110       -- larger number moves image forward of centre. Correct number depends on image
        drawingheading = cf.adjustHeading(thismarker.heading, -90)  -- points left (-90) to move the image left
        markerheading = thismarker.heading          -- direction to shift the image when adjusting forward
        drawingcentrex = thismarker.positionX
        drawingcentrey = thismarker.positionY
    elseif thismarker.newx ~= nil then
        offset = 15       -- larger numbers move the image left of centre. Correct number depends on image
        frontoffset = 110       -- larger number moves image forward of centre. Correct number depends on image
        drawingheading = cf.adjustHeading(thismarker.newheading, -90)  -- points left (-90) to move the image left
        markerheading = thismarker.newheading
        drawingcentrex = thismarker.newx
        drawingcentrey = thismarker.newy
    else
        error("Unexpected ELSE statement")
    end

    -- this moves the image left/right by 'offset' amount
    drawingcentrex, drawingcentrey = cf.AddVectorToPoint(drawingcentrex,drawingcentrey,drawingheading,offset)	-- the centre for drawing purposes is a little to the 'left'
    -- this moves the image forward/back by frontoffset amount
    drawingcentrex, drawingcentrey = cf.AddVectorToPoint(drawingcentrex, drawingcentrey, markerheading, frontoffset)	-- this nudges the image forward to align with the centre of the marker

    return drawingcentrex, drawingcentrey
end

function marker.unselectAll()
    -- cycles through every marker and clears all 'selection' flags
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                -- mark.isTarget = false
                mark.isSelected = false
			end
		end
	end
end

function marker.getClosest(x,y, ...)
    -- scans every marker and returns the one closest to x/y.
    -- if optional parameter is sent (string) then it will look for the closest marker matching that nation
    -- input: the x/y of interest
    -- input: optional string for nation of interest
    -- output: a marker object/table

    local arg = {...}   -- [1] is an optional string noting the nation of interest
    local bestdistance = -1
	local closestmarker    -- this is returned by this function

    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                if arg[1] == nil or flot.nation == arg[1] then
     		        local disttomarker = cf.GetDistance(x, y, mark.positionX, mark.positionY)
        			if (disttomarker < bestdistance) or (bestdistance < 0) then
        				bestdistance = disttomarker
        				closestmarker = mark		-- this is an object/table
                	end
                end
            end
		end
	end
	-- print("***")
	return closestmarker	-- an object/table
end

function marker.getSelected()
    -- cycles through every marker looking for the one that is selected.
    -- output: the marker that is selected (object/table) or nil
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                if mark.isSelected then
                    return mark
                end
            end
        end
    end
    return nil
end

local function updateIsTarget()
    -- cycles through every marker and correctly updates it's 'isTarget' boolean status
    -- first wipe all isTarget values
    for k,flot in pairs(flotilla) do
		for q,frm in pairs(flot.formation) do
            for w,mrk in pairs(frm.marker) do
                mrk.isTarget = false
            end
        end
    end
    -- now reset isTarget to correct values
    for k,flot in pairs(flotilla) do
		for q,frm in pairs(flot.formation) do
            for w,mrk in pairs(frm.marker) do
                if mrk.targetMarker ~= nil then
                    mrk.targetMarker.isTarget = true
                end
            end
        end
    end
end

function marker.clearTarget(thismarker)
    -- clears the target for the provided marker
    -- clears the target for the marker and also sets the target as not target (.isTarget = false)
    -- each 'shooter' stores the marker they have targeted in 'targetMarker' (object)
    -- need to be careful because two shooters might have the same target. Removing one target must not remove both

    local targetmarker = thismarker.targetMarker
    if targetmarker ~= nil then
        thismarker.targetMarker = nil
    end
    updateIsTarget()    -- updates the 'isTarget' boolean status for every marker
end

local function getNewFlagshipHeading(m, desiredheading)
    -- returns the new/future heading for the marker. Usually only applies to flagships
    -- input: m = marker (object/table). Usually a flagship
    -- input: desiredheading = number between 0 -> 359 inclusive
    -- output: the new/future heading for m

    -- determine the original heading.
    -- if no steps are planned then use m.heading
    -- if steps are planned then use that heading instead
    local currentheading
    local laststepnumber = #m.planningstep
    if laststepnumber == 0 then
        currentheading = m.heading
    else
        currentheading = m.planningstep[laststepnumber].newheading
    end

    local newheading
    local steeringamount = 15   -- this is the steering amount. Increase it to permit larger turns
    local angledelta = desiredheading - currentheading
    local adjsteeringamount = math.min(math.abs(angledelta), steeringamount)

    -- determine if cheaper to turn left or right
    local leftdistance = currentheading - desiredheading
    if leftdistance < 0 then leftdistance = 360 + leftdistance end      -- this is '+' because leftdistance is a negative value

    local rightdistance = desiredheading - currentheading
    if rightdistance < 0 then rightdistance = 360 + rightdistance end   -- this is '+' because leftdistance is a negative value

    -- print(currentheading, desiredheading, leftdistance, rightdistance)

    if leftdistance < rightdistance then
        -- print("turning left " .. adjsteeringamount)
        newheading = currentheading - (adjsteeringamount)
    else
       -- print("turning right " .. adjsteeringamount)
        newheading = currentheading + (adjsteeringamount)
    end
    if newheading < 0 then newheading = 360 + newheading end
    if newheading > 359 then newheading = newheading - 360 end
    return newheading
end

local function getNewMarkerPosition(mymarker)
    -- determines the new/future marker position based on current direction
    -- new marker is based off last planned step i.e not always from current position
    -- input: a marker object
    -- output: a new x/y pair

    local xcentre
    local ycentre
    local heading
    local dist
    local laststepnumber = #mymarker.planningstep
    if laststepnumber == 0 then
        -- no steps are planned. Just move from current position
        xcentre = (mymarker.positionX)
        ycentre = (mymarker.positionY)
        heading = (mymarker.heading)
    else
        -- get the latest planned step and calculate from that
        xcentre = (mymarker.planningstep[laststepnumber].newx)
        ycentre = (mymarker.planningstep[laststepnumber].newy)
        heading = (mymarker.planningstep[laststepnumber].newheading)
    end
    if mymarker.isFlagship then
        dist = mymarker.length
    else
        dist = mymarker.length
        -- get distance to correct position then ensure it is not overshot
        local dist2 = cf.GetDistance(xcentre,ycentre, mymarker.correctX, mymarker.correctY)
        dist = math.min(dist,dist2)
    end

    local newx, newy = cf.AddVectorToPoint(xcentre,ycentre,heading, dist)
    return newx, newy
end

local function getTargetQuadrant(x1, y1, x2, y2)
    -- returns the quadrant the target is in relative to the viewer/shooter
    -- the 'target' might not be a marker but an area of space/ocean
    -- Relative to north/0 degrees so north east is quadrant 1 and south east is quadrant 2 etc
    -- Note: a target on an axis (x/y) will still return a quadrant
    -- input: a marker object
    -- input: the x/y of the target
    -- output: a number between 0 and 4 inclusive. Returns zero if target is on smae location as marker
    if x1 == x2 and y1 == y2 then return 0 end
    if x2 >= x1 and y2 <= y1 then return 1 end
    if x2 > x1 and y2 > y1 then return 2 end
    if x2 <= x1 and y2 >= y1 then return 3 end
    if x2 < x1 and y2 < y1 then return 4 end
    -- this next error should never haqppen
    print("alpha", x1,y1,x2,y2)  -- keep this print for error debugging
    error("Unexpected program flow")
end

local function getAbsoluteHeadingToTarget(x1,y1, x2,y2)
    -- return the absoluting heading. 0 - north and 90 = east etc
    -- input: m = marker table
    -- input: target x,y
    -- output: number representing compass direction

    -- if there is an imaginary triangle from the positionx/y to the correctx/y then calculate opp/adj/hyp
    local targetqudrant = getTargetQuadrant(x1, y1, x2, y2)

    if targetqudrant == 0 then
        return 0    -- just face north I guess
    elseif targetqudrant == 1 then
        -- tan(angle) = opp / adj
        -- angle = atan(opp/adj)
        local adj = x2 - x1
        local opp = y1 - y2
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(90 - angletocorrectposition)
    elseif targetqudrant == 2 then
        local adj = x2 - x1
        local opp = y2 - y1
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(90 + angletocorrectposition)
    elseif targetqudrant == 3 then
        local adj = x1 - x2
        local opp = y2 - y1
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(270 - angletocorrectposition)
    elseif targetqudrant == 4 then
        local adj = x1 - x2
        local opp = y1 - y2
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(270 + angletocorrectposition)
    end
end

local function getNewMarkerHeading(m)
    -- turns the marker towards the correct position within the formation without breaking turning rules
    -- assumes m.correctX/Y has been previously set
    -- input: m = marker object/table
    -- output: number reflecting the desired heading without breaking turning rules

    assert(m.correctX ~= nil)
    assert(m.correctY ~= nil)

    local steeringamount = 15   -- max turn rate
    local newheading

    local laststepnumber = #m.planningstep
    if laststepnumber == 0 then
        currentx = m.positionX
        currenty = m.positionY
        correctx = m.correctX
        correcty = m.correctY
        currentheading = m.heading

    else
        currentx = m.planningstep[laststepnumber].newx
        currenty = m.planningstep[laststepnumber].newy
        correctx = m.correctX
        correcty = m.correctY
        currentheading = m.planningstep[laststepnumber].newheading
    end
    local desiredheading = getAbsoluteHeadingToTarget(currentx, currenty, correctx, correcty)
    local angledelta = desiredheading - currentheading
    local adjsteeringamount = math.min(math.abs(angledelta), steeringamount)

    -- print("adjsteeringamount = " .. adjsteeringamount)

    -- determine if cheaper to turn left or right
    local leftdistance = currentheading - desiredheading
    if leftdistance < 0 then leftdistance = 360 + leftdistance end      -- this is '+' because leftdistance is a negative value

    local rightdistance = desiredheading - currentheading
    if rightdistance < 0 then rightdistance = 360 + rightdistance end   -- this is '+' because leftdistance is a negative value

    if leftdistance < rightdistance then
        -- print("turning left " .. adjsteeringamount)
        newheading = currentheading - (adjsteeringamount)
    else
        -- print("turning right " .. adjsteeringamount)
        newheading = currentheading + (adjsteeringamount)
    end
    if newheading < 0 then newheading = 360 + newheading end
    if newheading > 359 then newheading = newheading - 360 end
    return newheading
end

local function getFlagShip(thisform)
    -- scans the provided flotilla/formation for the marker ID (index) that is the flagship
    -- input: flotilla (number/index)
    -- input: formation (number/index)
    -- output: a marker object that is the flagship
    for w,mrk in pairs(thisform.marker) do
        if mrk.isFlagship then
            return mrk
        end
    end
    error("Unexpected program flow")
end

function marker.addOneStepToFlagship()
    -- adds one step (ghost) to the flagship planned moves if the formation is selected. This is determined by the formation facing/direction

    -- get the selected formation
    for k,flot in pairs(flotilla) do
		for q,frm in pairs(flot.formation) do
            if frm.isSelected then
                local flagship = getFlagShip(frm)
                for w,mrk in pairs(frm.marker) do
                    if #mrk.planningstep < mrk.movementFactor then    -- ensure marker hasn't expended all steps/movement
                        if mrk.isFlagship then  -- can also say if mrk == flagship
                            -- get future heading x, y and heading
                            local newheading = getNewFlagshipHeading(mrk, frm.heading)    -- provide the marker and desired heading and get the future heading
                            local newx, newy = getNewMarkerPosition(mrk)   -- takes the last planned step + desired heading and adds marker.length to get that x/y

                            local newplan = {}
                            newplan.newx = newx
                            newplan.newy = newy
                            newplan.newheading = newheading
                            table.insert(mrk.planningstep, newplan)
                        else

                        end
                    else
                        -- all ghosts exahausted. Do nothing.
                    end
                end
            end
        end
    end
end

function marker.moveOneStep()
    -- moves all markers just one step. Returns FALSE if no markers moved (all moves exhausted)
    -- input: nothing. Operates on every marker
    -- output: a boolean. True means at least one marker moved.
    local markermoved = false
    for q,flot in pairs(flotilla) do
        for w,frm in pairs(flot.formation) do
            local flagshipmarker = form.getFlagship(frm)    -- returns the flagship for this formation
            for w,mrk in pairs(frm.marker) do
                if mrk.planningstep[1] ~= nil then
                    mrk.positionX = mrk.planningstep[1].newx
                    mrk.positionY = mrk.planningstep[1].newy
                    mrk.heading = mrk.planningstep[1].newheading
                    table.remove(mrk.planningstep, 1)
                    markermoved = true
                end
            end
        end
    end
    return markermoved      -- calling function can know if all moves are exhausted
end

function marker.addOneStepsToMarkers()
    -- add planned steps/ghosts to markers that are not flagships. Applies to all flotilla's
    -- called after all formations have moved but before movement is resolved
    for q,flot in pairs(flotilla) do
        for w,frm in pairs(flot.formation) do
            for w,mrk in pairs(frm.marker) do
                if not mrk.isFlagship then
                    if mrk.planningstep ~= nil then
                        local stepsleft = mrk.movementFactor - #mrk.planningstep
                        if stepsleft > 0 then
                            for i = 1,stepsleft do
                                -- not a flagship so need to determine the correct place in formation
                                --      this uses the dot product to detect if the marker is in front or behind the correct position within the formation.
                                --      if it is in front - then don't move. Stay still and wait for the formation to catch up
                                --      if it is behind the correct position, then it is free to move with the formation

                                -- get the correct position within the formation and save that inside the marker table
                                mrk.correctX, mrk.correctY = mark.getCorrectPositionInFormation(mrk) -- sets marker.correctX and marker.correctY

                                --      add a planned step/ghost in that direction
                                local newheading = getNewMarkerHeading(mrk) -- gets preferred heading based on correct position in formation
                                local newplan = {}
                                newplan.newx = mrk.positionX       -- this is set here as a default value
                                newplan.newy = mrk.positionY       -- and might be updated down below if marker actually moves
                                newplan.newheading = newheading

                                -- get the new marker x,y pair. The length is an arbitrary number to create the vector
                                local markernewx, markernewy = cf.AddVectorToPoint(mrk.positionX,mrk.positionY, mrk.heading, mrk.length)    -- creates a vector reflecting facting

                                -- get the delta for use in the dot product
                                local facingdeltax = markernewx - mrk.positionX
                                local facingdeltay = markernewy - mrk.positionY

                                -- determine the position of corrextx/y relative to the marker
                                local correctxdelta = mrk.correctX - mrk.positionX
                                local correctydelta = mrk.correctY - mrk.positionY

                                -- see if correct position is ahead or behind marker
                                -- x1/y1 vector is facing/looking
                                -- x2/y2 is the position relative to the object doing the looking
                                local dotproduct = cf.dotVectors(facingdeltax,facingdeltay,correctxdelta,correctydelta)
                                if dotproduct > 0 then
                                    -- marker is behind the correct position so allowed to move
                                    local newx, newy = getNewMarkerPosition(mrk)
                                    newplan.newx = newx
                                    newplan.newy = newy
                                end
                                table.insert(mrk.planningstep, newplan)
                            end
                        end
                    end
                end
            end
        end
    end
end

function marker.undoOneStepFromFlagship()
    -- removes one ghost from the flagship for the currently selected formation
    for q,flot in pairs(flotilla) do
        for w,frm in pairs(flot.formation) do
            if frm.isSelected then
                for w,mrk in pairs(frm.marker) do
                    if mrk.isFlagship then
                        if mrk.planningstep ~= nil then
                            local stepsplanned = #mrk.planningstep
                            if stepsplanned > 0 then
                                table.remove(mrk.planningstep, stepsplanned)
                            end
                        end
                    end
                end
            end
        end
    end
end

function marker.getNation(m)
    -- returns the nation for the marker
    for q,flot in pairs(flotilla) do
        local nation = flot.nation
        for w,frm in pairs(flot.formation) do
            for w,mrk in pairs(frm.marker) do
                if mrk == m then
                    return nation
                end
            end
        end
    end
end

function marker.targetInLoS(targetx, targety)
    -- checks if the targeted x/y is in line of sight of the selected marker
    -- assumes a marker is selected
    -- uses the global ray1.point.x/y to understand where LoS is blocked

    -- see how far away the mouse is from the ray1 point
    if ray1.point ~= nil then   -- no points = no ray collision = LoS is true
        local xdelta = math.abs(targetx - ray1.point.x)     --ray1.point.x/y stores the first point where LoS is blocked
        local ydelta = math.abs(targety - ray1.point.y)
        if xdelta <= 100 and ydelta <= 100 then
            return true
        else
            return false
        end
    else
        return true
    end
end

function marker.getGunsInArc(thismarker, arc)
    -- for the provided marker, return the number of guns that can shoot in the provided arc
    -- does not account for battle damage
    -- input: thismarker - marker (object/table)
    -- input: arc - the arc of interest. A string "Bow", "Stern", "Port", "Starbourd"
    -- output: number - the number of guns that can fire

    -- NOTE: does not return torpedo's in arc (but can be easily modified)
    --! needs to be adjusted to account for damaged turrets

    local gf, tf = 0,0  -- gun factor, torpedo factor
    for k, struct in pairs(thismarker.structure) do
        for q, firedirection in pairs(struct.fireDirections) do
            if firedirection == arc then
                for w, tur in pairs(struct.turret) do
                    gf = gf + tur.gunfactor
                    tf = tf + tur.torpedoFactor
                end
            end
        end
    end
    return gf
end

function marker.getDistanceToTarget(thismarker)
    -- provde a marker and get the distance to it's nominated target
    -- input: marker object
    -- output: number or nil
    local result = nil
    if thismarker.targetMarker ~= nil then
        result = cf.GetDistance(thismarker.positionX, thismarker.positionY, thismarker.targetMarker.positionX, thismarker.targetMarker.positionY)
    end
    return result
end

local function determineMouseText(mrk)
    -- mousetext is a glboal value that holds the text to draw on the LoS ray
    -- this function determines what that text needs to be
    -- input: marker (object)
    -- output: none. Operates directly on the global: mousetext
    -- do some ray stuff for later use

    local xcentre = (mrk.positionX)
    local ycentre = (mrk.positionY)
    local heading = (mrk.heading)
    local mousex, mousey = love.mouse.getPosition()
    local wx,wy = cam:toWorld(mousex, mousey)	-- converts screen x/y to world x/y
    mousearc = fun.getArc(xcentre, ycentre, heading, wx,wy)    -- returns a string
    local gunsdownrange = mark.getGunsInArc(mrk, mousearc)
    mousetext = "Angle: " .. degangle .. "\nArc: " .. mousearc .. "\nGuns: " .. gunsdownrange
end

local function drawEveryGhost(nation)
    love.graphics.setColor(1, 1, 1, 0.5)

    for k,flot in pairs(flotilla) do
        if flot.nation == nation then
    		for q,form in pairs(flot.formation) do
                for w,mark in pairs(form.marker) do
                    for e,step in pairs(mark.planningstep) do
                        local headingrad = math.rad(step.newheading)
                        local drawingcentrex, drawingcentrey = getDrawingCentre(step)   -- get the correct x/y value (with offsets) for the provided marker
                        love.graphics.draw(image[enum.markerBattleship], drawingcentrex, drawingcentrey, headingrad, 1, 1)
                    end
                end
            end
        end
    end
end

local function drawEveryMarker()
	-- draw every marker

	local degangle = ""
	mousetext = ""
	local alphavalue = 1
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do

			if form.isSelected then
				alphavalue = 1
			else
				alphavalue = 0.33
			end

			for w,mrk in pairs(form.marker) do
				local xcentre = (mrk.positionX)
				local ycentre = (mrk.positionY)
				local heading = (mrk.heading)
				local headingrad = math.rad(heading)
                local markerstartx, markerstarty, markerstopx, markerstopy = mark.getMarkerPoints(mrk)  -- get the x/y pairs that describe the line the marker creates

				local red,green,blue = 1,1,1

				if mrk.isFlagship then
					blue = 0
				end
				if mrk.isTarget then
					green = green / 2
					blue = blue / 2
					--alphavalue = 1
				elseif mrk.isSelected then
                    -- adjust colour
					red = red / 2
					blue = blue / 2

                    determineMouseText(mrk)
				else
					-- nothing to do. Accept default rgb values of (1,1,1)
				end

				-- draw line and circle
				-- love.graphics.line(x1,y1,x2,y2)
				-- love.graphics.circle("fill", x2, y2, 3)

				-- draw marker image
				-- the image needs to be shifted left and forward. These next two lines will do that.
                local drawingcentrex, drawingcentrey = getDrawingCentre(mrk)   -- get the correct x/y value (with offsets) for the provided marker
                love.graphics.setColor(red,green,blue,1)
                love.graphics.draw(image[enum.markerBattleship], drawingcentrex, drawingcentrey, headingrad, 1, 1)

				-- draw the guns
				-- local drawingheading = cf.adjustHeading(heading, -90)
				-- local drawingcentrex, drawingcentrey = cf.AddVectorToPoint(xcentre,ycentre,drawingheading,3)	-- the centre for drawing purposes is a little to the 'left'
				-- local drawingcentrex, drawingcentrey = cf.AddVectorToPoint(drawingcentrex, drawingcentrey, heading, mrk.frontGunPosition)	-- this nudges the image forward to align with the centre of the marker
				-- love.graphics.draw(image[enum.markerBattleshipGun], drawingcentrex, drawingcentrey, headingrad, 1, 1)

                -- draw centre of marker
				-- love.graphics.circle("fill", xcentre, ycentre, 3)

				-- draw correct position
				-- if mrk.correctX ~= nil then
				-- 	love.graphics.circle("fill", mrk.correctX, mrk.correctY, 3)
				-- end

				-- debugging
				-- draw tempx/tempy if that has been set anywhere
				if tempx ~= nil then
					love.graphics.setColor(1, 0, 0, alphavalue)
					love.graphics.circle("fill", tempx, tempy, 5)
				end

			end
		end
	end
end

function marker.draw()
    drawEveryMarker()
    if GAME_MODE == enum.gamemodePlanning then
        if PLAYER_TURN == 1 then
            drawEveryGhost("British")    -- planned steps
        else
            drawEveryGhost("German")
        end
    elseif GAME_MODE == enum.gamemodeTargeting then
        if ray1.position ~= nil and ray1.target ~= nil then  -- target is set by ray1:update() when a target is specified. Don't draw a ray if no target
            ray1:draw(true, mousetext)	-- requires ray:update(to be invoked with start/stop x/y pairs) (moustext is a global value)
        end
    end
end

-- ******************************** British makers ******************************
function marker.addAgincourt(form)
    -- adds a marker to the provided formation
    -- input: the formation this marker will be assigned to
    -- output: the marker, noting it will already be a part of the formation
    local mymarker = {}
    initaliseMarker(form, mymarker)   -- sets up some boring generic default values

    mymarker.markerName = "Agincourt"
    mymarker.movementFactor = 9
    mymarker.protectionFactor = 8
    mymarker.markerType = "BB"
    mymarker.initialHeading = form.heading
    mymarker.heading = form.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Midships"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Port"
    mymarker.structure[2].fireDirections[2] = "Starboard"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Starboard"
    mymarker.structure[3].fireDirections[2] = "Port"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}

    -- for each structure defined above, describe the turrets linked to each structure
    for i = 1,4 do
    AddTurret(mymarker.structure[1].turret, 1, 0)   -- struct, gunfactor, torpedo factor. Normally 1 gf for BB.
    end
    for i = 1,6 do
    AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,4 do
    AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    table.insert (form.marker, mymarker)
    return mymarker
end

function marker.addAjax(thisform)
    local mymarker = {}
    initaliseMarker(thisform, mymarker)   -- sets up some boring generic default values

    mymarker.markerName = "Ajax"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 8
    mymarker.markerType = "BB"
    mymarker.initialHeading = thisform.heading
    mymarker.heading = thisform.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Midships"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Port"
    mymarker.structure[2].fireDirections[2] = "Starboard"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Starboard"
    mymarker.structure[3].fireDirections[2] = "Port"
    mymarker.structure[3].fireDirections[3] = "Stern"

    -- initialse a table of turrets for each structure
    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}

    -- for each structure defined above, describe the turrets linked to each structure
    for i = 1, 5 do
    AddTurret(mymarker.structure[1].turret, 1, 0)   -- struct, gunfactor, torpedo factor. Normally 1 gf for BB.
    end
    for i = 1, 2 do
    AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1, 5 do
    AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    table.insert (thisform.marker, mymarker)
    return mymarker
end

function marker.addBarham(thisform)
    local mymarker = {}
    initaliseMarker(thisform, mymarker)   -- sets up some boring generic default values

    mymarker.markerName = "Barham"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 8
    mymarker.markerType = "BB"
    mymarker.initialHeading = thisform.heading
    mymarker.heading = thisform.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    -- mymarker.structure[2] = {}
    -- mymarker.structure[2].location = "Port midships"        -- location of the structure on the marker
    -- mymarker.structure[2].fireDirections = {}
    -- mymarker.structure[2].fireDirections[1] = "Port"
    -- mymarker.structure[2].fireDirections[2] = "Bow"
    -- mymarker.structure[2].fireDirections[2] = "Stern"

    -- mymarker.structure[3] = {}
    -- mymarker.structure[3].location = "Starboard midships"        -- location of the structure on the marker
    -- mymarker.structure[3].fireDirections = {}
    -- mymarker.structure[3].fireDirections[1] = "Starboard"
    -- mymarker.structure[3].fireDirections[2] = "Bow"
    -- mymarker.structure[3].fireDirections[3] = "Stern"

    -- mymarker.structure[2] = {}
    -- mymarker.structure[2].location = "midships"        -- location of the structure on the marker
    -- mymarker.structure[2].fireDirections[1] = "Port"
    -- mymarker.structure[2].fireDirections[2] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Starboard"
    mymarker.structure[2].fireDirections[2] = "Port"
    mymarker.structure[2].fireDirections[3] = "Stern"


    -- initialse a table of turrets for each structure
    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    -- mymarker.structure[3].turret = {}
    -- mymarker.structure[4].turret = {}
    -- mymarker.structure[5].turret = {}

    -- for each structure defined above, describe the turrets linked to each structure
    for i = 1, 5 do
    AddTurret(mymarker.structure[1].turret, 1, 0)   -- struct, gunfactor, torpedo factor. Normally 1 gf for BB.
    end
    for i = 1, 5 do
    AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    -- for i = 1, 2 do
    -- AddTurret(mymarker.structure[3].turret, 1, 0)
    -- end
    -- for i = 1, 2 do
    -- AddTurret(mymarker.structure[4].turret, 1, 0)
    -- end
    -- for i = 1, 2 do
    -- AddTurret(mymarker.structure[5].turret, 1, 0)
    -- end
    table.insert (thisform.marker, mymarker)
    return mymarker
end

function marker.addBellerophon(thisform)
    local mymarker = {}
    initaliseMarker(thisform, mymarker)   -- sets up some boring generic default values

    mymarker.markerName = "Bellerophon"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 8
    mymarker.markerType = "BB"
    mymarker.initialHeading = thisform.heading
    mymarker.heading = thisform.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Port midships"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Port"
    mymarker.structure[2].fireDirections[2] = "Bow"
    mymarker.structure[2].fireDirections[2] = "Stern"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Starboard midships"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Starboard"
    mymarker.structure[3].fireDirections[2] = "Bow"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "midships"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "Port"
    mymarker.structure[4].fireDirections[2] = "Starboard"

    mymarker.structure[5] = {}
    mymarker.structure[5].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[5].fireDirections = {}
    mymarker.structure[5].fireDirections[1] = "Starboard"
    mymarker.structure[5].fireDirections[2] = "Port"
    mymarker.structure[5].fireDirections[3] = "Stern"


    -- initialse a table of turrets for each structure
    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}
    mymarker.structure[4].turret = {}
    mymarker.structure[5].turret = {}

    -- for each structure defined above, describe the turrets linked to each structure
    for i = 1, 2 do
    AddTurret(mymarker.structure[1].turret, 1, 0)   -- struct, gunfactor, torpedo factor. Normally 1 gf for BB.
    end
    for i = 1, 2 do
    AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1, 2 do
    AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1, 2 do
    AddTurret(mymarker.structure[4].turret, 1, 0)
    end
    for i = 1, 2 do
    AddTurret(mymarker.structure[5].turret, 1, 0)
    end
    table.insert (thisform.marker, mymarker)
    return mymarker
end



-- ******************************** German makers ******************************
function marker.addFriedrichDerGrosse(thisform)
    -- adds the Friederich to the provided flotilla and formation
    -- input: flotilla number, form number   (not objects/tables!)

    local mymarker = {}
    initaliseMarker(thisform, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Friederich Der Grosse"
    mymarker.isFlagship = true
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 12
    mymarker.markerType = "BB"
    mymarker.initialHeading = thisform.heading
    mymarker.heading = thisform.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Bow"
    mymarker.structure[2].fireDirections[2] = "Starboard"
    mymarker.structure[2].fireDirections[3] = "Stern"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Port"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Bow"
    mymarker.structure[3].fireDirections[2] = "Port"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "Stern"
    mymarker.structure[4].fireDirections[2] = "Port"
    mymarker.structure[4].fireDirections[3] = "Starboard"

    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}
    mymarker.structure[4].turret = {}

    for i = 1,3 do
        AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,5 do
        AddTurret(mymarker.structure[4].turret, 1, 0)
    end
    table.insert (thisform.marker, mymarker)
    return mymarker
end

function marker.addGrosserKurfurst(thisform)
    -- flot and form are numnbers (index)
    local mymarker = {}
    initaliseMarker(thisform, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Grosser Kerflirst"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 14
    mymarker.markerType = "BB"
    mymarker.initialHeading = thisform.heading
    mymarker.heading = thisform.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Midships"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Port"
    mymarker.structure[2].fireDirections[2] = "Starboard"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Starboard"
    mymarker.structure[3].fireDirections[2] = "Port"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}


    for i = 1,5 do
        AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,5 do
        AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    table.insert (thisform.marker, mymarker)
    return mymarker
end

function marker.addHelgoland(thisform)
    local mymarker = {}
    initaliseMarker(thisform, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Helgoland"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 12
    mymarker.markerType = "BB"
    mymarker.initialHeading = thisform.heading
    mymarker.heading = thisform.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Bow starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Bow"
    mymarker.structure[2].fireDirections[2] = "Starboard"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern starboard"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Starboard"
    mymarker.structure[3].fireDirections[2] = "Stern"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "Stern"
    mymarker.structure[4].fireDirections[2] = "Port"
    mymarker.structure[4].fireDirections[3] = "Starboard"

    mymarker.structure[5] = {}
    mymarker.structure[5].location = "Stern port"        -- location of the structure on the marker
    mymarker.structure[5].fireDirections = {}
    mymarker.structure[5].fireDirections[1] = "Port"
    mymarker.structure[5].fireDirections[2] = "Stern"

    mymarker.structure[6] = {}
    mymarker.structure[6].location = "Bow port"        -- location of the structure on the marker
    mymarker.structure[6].fireDirections = {}
    mymarker.structure[6].fireDirections[1] = "Bow"
    mymarker.structure[6].fireDirections[2] = "Port"

    for i = 1, 6 do
        mymarker.structure[i].turret = {}
    end
    for i = 1,3 do
        AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,3 do
        AddTurret(mymarker.structure[4].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[5].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[6].turret, 1, 0)
    end
    table.insert (thisform.marker, mymarker)
    return mymarker
end

function marker.addKaiser(thisform)
    local mymarker = {}
    initaliseMarker(thisform, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Kaiser"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 12
    mymarker.markerType = "BB"
    mymarker.initialHeading = thisform.heading
    mymarker.heading = thisform.heading

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Bow"
    mymarker.structure[2].fireDirections[2] = "Starboard"
    mymarker.structure[2].fireDirections[3] = "Stern"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Port"
    mymarker.structure[3].fireDirections[2] = "Starboard"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Port"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "Bow"
    mymarker.structure[4].fireDirections[2] = "Port"
    mymarker.structure[4].fireDirections[3] = "Stern"

    -- for each structure ...
    for i = 1, 4 do
        mymarker.structure[i].turret = {}
    end
    -- add turrets on each structure
    for i = 1,3 do
        AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,5 do
        AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,2 do
        AddTurret(mymarker.structure[4].turret, 1, 0)
    end
    table.insert (thisform.marker, mymarker)
    return mymarker
end

return marker
