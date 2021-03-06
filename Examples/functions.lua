local functions = {}

function functions.InitialiseData()

    currentHour = 0
    currentMinutes = 0

    maximumSightRangeDay = 10000
    maximumSightRangeNight = 6000

    flotilla = {}

    armyalpha.Initialise()
    -- armybravo.Initialise()
end

function functions.allMarkersForwardOnce()
    -- moves all markers forward one 'step'

    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mark in pairs(form.marker) do
				local xcentre = (mark.positionX)
				local ycentre = (mark.positionY)
				local heading = (mark.heading)
				local newx, newy = cf.AddVectorToPoint(xcentre,ycentre,heading, 16)
                mark.positionX = newx
                mark.positionY = newy
			end
		end
	end
end

function functions.getFormationCentre(formation)
    -- gets the centre of a formation by doing vector things
    -- returns a single x/y
    -- input: formation = object/table
    -- output: x/y pair (number)

    local xcentre, ycentre, count = 0,0,0
    for k, mark in pairs(formation.marker) do
        xcentre = xcentre + mark.positionX
        ycentre = ycentre + mark.positionY
        count = count + 1
    end
    return cf.round(xcentre / count), cf.round(ycentre / count)
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
    local angledelta = desiredheading - m.heading
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

local function getTargetQuadrant(x1, y1, x2, y2)
    -- returns the quadrant the target is in relative to the viewer/shooter
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
    print(x1,y1,x2,y2)
    error("Unexpected program flow")
end

local function getAbsoluteHeadingToTarget(x1,y1, x2,y2)
    -- return the absoluting heading. 0 - north and 90 = east
    -- input: m = marker table
    -- input: target x,y
    -- output: number

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
    -- output: none. Operaties directly on m (marker)
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

    -- print(currentx, currenty, correctx, correcty, desiredheading, currentheading)

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

local function getFlagShip(flot, form)
    -- scans the provided flotilla/formation for the marker ID (index) that is the flagship
    -- input: flotilla (number/index)
    -- input: formation (number/index)
    -- output: a marker object that is the flagship
    for w,mark in pairs(flotilla[flot].formation[form].marker) do
        if mark.isFlagship then
            return mark
        end
    end
end

function functions.getSelectedMarker()
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

local function getCorrectPositionInFormation(formobj, fs, m)
    -- determine the correct x/y position within the formation
    -- input: formobj = (object/table)
    -- input: fs = flagship (object/table)
    -- input: m = marker (object/table)
    -- output: returns an x, y pair

    -- determine if m is left or right of FS by checking both numOfColumns
    local columndelta = m.columnNumber - fs.columnNumber    -- a negative number means m should be left of fs
    local fsheading, fsX, fsY
    local laststepnumber = #fs.planningstep
    if  laststepnumber == 0 then
        -- there is no plan so far so just use real position
        fsheading = fs.heading
        fsX = fs.positionX
        fsY = fs.positionY
    else
        -- flagship has a plan so use the last position in the plan
        fsheading = fs.planningstep[laststepnumber].newheading
        fsX = fs.planningstep[laststepnumber].newx
        fsY = fs.planningstep[laststepnumber].newy
    end


    if columndelta < 0 then
        -- left side of the flagship
        -- determine head position of this column
        -- assumes columns are 45 degrees behind flagship
        -- using trigonometry and knowledge of distance between columns:

        -- cos = adj / hyp
        -- hyp = adj / cos
        local hyp = (formobj.distanceBetweenColumns) / math.cos(45) -- gives the hypotenuse/distance for the marker leading the adjacent column
        -- multipy this hypotenuse for each column away from teh fs column
        hyp = hyp * math.abs(columndelta)
        -- determine x/y for the lead marker for this column
        -- it is known that the angle is fs heading - 135 degrees relative
        local relativeheadingfromfs = fsheading - 135
        if relativeheadingfromfs < 0 then relativeheadingfromfs = 360 + relativeheadingfromfs end       -- this is a + because the value is a negative
        local colheadx, colheady = cf.AddVectorToPoint(fsX,fsY,relativeheadingfromfs,hyp)

        -- move back through the column to find correct position in sequence
        if m.sequenceInColumn == 1 then
            -- m.correctX, m.correctY = colheadx, colheady
            return colheadx, colheady
        else
            -- marker is not at head of column so need to work out how far back to place it
            -- determine the reverse direction (i.e. fs - 180 relative)
            -- from the head of the column, move backwards length * sequenceInColumn
            local direction = fsheading + 180
            if direction > 359 then direction = direction - 360 end
            local dist = m.length * 1.5 * m.sequenceInColumn
            -- m.correctX, m.correctY = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            local x, y = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            return x, y
        end
    elseif columndelta > 0 then -- it is in a column to the right of the fs
        local hyp = (formobj.distanceBetweenColumns) / math.cos(45) -- gives the hypotenuse/distance for the marker leading the adjacent column
        hyp = hyp * math.abs(columndelta)
        local relativeheadingfromfs = fsheading + 135
        if relativeheadingfromfs > 359 then relativeheadingfromfs = relativeheadingfromfs - 360 end
        local colheadx, colheady = cf.AddVectorToPoint(fsX,fsY,relativeheadingfromfs,hyp)

        -- move back through the column to find correct position in sequence
        if m.sequenceInColumn == 1 then
            -- m.correctX, m.correctY = colheadx, colheady
            return colheadx, colheady
        else
            -- marker is not at head of column so need to work out how far back to place it
            -- determine the reverse direction (i.e. fs - 180 relative)
            -- from the head of the column, move backwards length * sequenceInColumn
            local direction = fsheading + 180
            if direction > 359 then direction = direction - 360 end
            local dist = m.length * 1.5 * m.sequenceInColumn

            -- m.correctX, m.correctY = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            local x,y = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            return x, y
        end
    elseif columndelta == 0 then        -- same column as fs (in line)
        local colheadx, colheady = fsX, fsY

    -- print(m.sequenceInColumn)

        -- move back through the column to find correct position in sequence
        if m.sequenceInColumn == 1 then
            -- m.correctX, m.correctY = colheadx, colheady
            return colheadx, colheady
        else
            -- marker is not at head of column so need to work out how far back to place it
            -- determine the reverse direction (i.e. fs - 180 relative)
            -- from the head of the column, move backwards length * sequenceInColumn
            local direction = fsheading + 180
            if direction > 359 then direction = direction - 360 end
            local dist = m.length * 1.5 * m.sequenceInColumn
            -- m.correctX, m.correctY = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            local x, y = cf.AddVectorToPoint(colheadx, colheady, direction, dist)
            return x, y
        end
    else
        error("Unexpected program flow")
    end
end

function functions.moveAllMarkers()
    -- moves all markers as a part of the formation or towards the formation

    if GAME_MODE == enum.gamemodePlanning then

    -- ipairs is important because we're using table index  --! is this an old and incorrect comment?
        for k,flot in ipairs(flotilla) do
    		for q,form in ipairs(flot.formation) do
                if form.isSelected then
                    local flagship = getFlagShip(k, q)

        			for w,mark in pairs(form.marker) do
                        -- see if marker is out of moves
                        if #mark.planningstep <= mark.movementFactor then
                            if mark == flagship then
                                -- flagship = flagship so move the flagship

                                -- get future heading x, y and heading
                                local newheading = getNewFlagshipHeading(mark, form.heading)
                                local newx, newy = getNewMarkerPosition(mark)
                                local newplan = {}
                                newplan.newx = newx
                                newplan.newy = newy
                                newplan.newheading = newheading
                                table.insert(mark.planningstep, newplan)
                                -- print(mark.positionX, mark.positionY, newplan.newx, newplan.newy, mark.heading, newplan.newheading)
                            else
                                -- this uses the dot product to detect if the marker is in front or behind the correct position within the formation.
                                -- if it is in front - then don't move. Stay still and wait for the formation to catch up
                                -- if it is behind the correct position, then it is free to move with the formation

                                -- get the correct position within the formation and save that inside the marker table
                                mark.correctX, mark.correctY = getCorrectPositionInFormation(form, flagship, mark) -- sets marker.correctX and marker.correctY

                                local newheading = getNewMarkerHeading(mark)
                                local newplan = {}
                                newplan.newx = mark.positionX       -- this is set here as a default value
                                newplan.newy = mark.positionY       -- and might be updated down below if marker actually moves
                                newplan.newheading = newheading

                                -- get the new marker x,y pair. The length is an arbitrary number to create the vector
                                local markernewx, markernewy = cf.AddVectorToPoint(mark.positionX,mark.positionY, mark.heading, mark.length)    -- creates a vector reflecting facting

                                -- get the delta for use in the dot product
                                local facingdeltax = markernewx - mark.positionX
                                local facingdeltay = markernewy - mark.positionY

                                -- determine the position of corrextx/y relative to the marker
                                local correctxdelta = mark.correctX - mark.positionX
                                local correctydelta = mark.correctY - mark.positionY

                                -- see if correct position is ahead or behind marker
                                -- x1/y1 vector is facing/looking
                                -- x2/y2 is the position relative to the object doing the looking
                                local dotproduct = cf.dotVectors(facingdeltax,facingdeltay,correctxdelta,correctydelta)
                                if dotproduct > 0 then
                                    -- marker is behind the correct position so allowed to move
                                    local newx, newy = getNewMarkerPosition(mark)
                                    newplan.newx = newx
                                    newplan.newy = newy

                                end
                                table.insert(mark.planningstep, newplan)
                            end
                        end
                    end
                end
            end
        end
    end
end

function functions.addGenericMarker(flot, form)
    -- input: flotilla number (index), form number (index)
    local mymarker = {}
    mymarker.markerName = "Generic"
    mymarker.columnNumber = love.math.random(1, flotilla[flot].formation[form].numOfColumns)
    -- mymarker.columnNumber = 1

    -- mymarker.sequenceInColumn = love.math.random(1,5)
    mymarker.sequenceInColumn = nextsequence[mymarker.columnNumber]
    nextsequence[mymarker.columnNumber] = nextsequence[mymarker.columnNumber] + 1

    mymarker.movementFactor = 8
    mymarker.protectionFactor = 14

    mymarker.undoPositionX = {}
    --mymarker.undoPositionX[1] =
    mymarker.undoPositionY = {}
    --mymarker.undoPositionY[1] = 300
    mymarker.isSelected = false
    mymarker.isTarget = false
    mymarker.markerType = "BB"
    mymarker.missileFactor = 0
    mymarker.missileCount = 0
    mymarker.initialHeading = love.math.random(0, 359)
    mymarker.topedoHitsSustained = 0
    mymarker.isSunk = false
    mymarker.heading = mymarker.initialHeading
    mymarker.positionX = love.math.random(100, 1800)
    mymarker.positionY = love.math.random(100, 900)
    mymarker.length = 48  -- millimetres / pixels

    mymarker.targetMarker = nil -- marker

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "North"
    mymarker.structure[1].fireDirections[2] = "West"
    mymarker.structure[1].fireDirections[3] = "South"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "North"
    mymarker.structure[2].fireDirections[2] = "West"
    mymarker.structure[2].fireDirections[3] = "East"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Port"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "East"
    mymarker.structure[3].fireDirections[2] = "West"
    mymarker.structure[3].fireDirections[3] = "South"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Astern"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "North"
    mymarker.structure[4].fireDirections[2] = "East"
    mymarker.structure[4].fireDirections[3] = "South"

    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}
    mymarker.structure[4].turret = {}

    for i = 1,3 do
        fun.AddTurret(mymarker.structure[1].turret, 1, 0)   -- gun factor, missile factor
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,5 do
        fun.AddTurret(mymarker.structure[4].turret, 1, 0)
    end

    table.insert(flotilla[flot].formation[form].marker, mymarker)
end

function functions.createNewFlotilla(nation)
    -- creates a new flotilla. There is likely two and only two on each map.
    -- doesn't add things like formations and markers
    -- input: nation (string)
    -- output: the flotilla that was created (object/table)

    local myflotilla = {}
    myflotilla.nation = nation
    myflotilla.formation = {}
    table.insert(flotilla, myflotilla)
    return myflotilla
end

function functions.createNewFormation()
    -- creates a new formation
    -- there is normally two flotilla's (two sides) and each has multiple formations
    -- output = a new formation. This will need to be added to a flotilla in the calling routine

    local myformation = {}
    myformation.numOfColumns = love.math.random(1,4)

    -- myformation.numOfColumns = 1

    nextsequence = {}    -- for testing only
    for i = 1, myformation.numOfColumns do
        nextsequence[i] = {}
        nextsequence[i] = 1
    end

    if myformation.numOfColumns > 1 then
        myformation.distanceBetweenColumns = love.math.random(50, 100)
    else
        myformation.distanceBetweenColumns = nil
    end
    myformation.heading = love.math.random(0, 359)
    myformation.currentManeuver = ""
	myformation.isSelected = false
    myformation.pivotpointx = nil
    myformation.pivotpointy = nil
    myformation.undoStackX = {}
    myformation.undoStackY = {}
    return myformation
end

function functions.AddTurret(struct, gf, mf)
    -- input: structure (object/table)
    -- input: gunfactor (numbner)
    -- input: missileFactor (number)
    -- output: none. Operates directly on structure (object/table)

    local myturret = {}
    myturret.active = true
    myturret.gunfactor = gf
    myturret.missileFactor = mf
    table.insert(struct, myturret)
end

function functions.unselectAllFormations()
	-- cycles through all formations and clears the 'isSelected' flag
	-- often called right before a mouse click/selection of a new formation

    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			form.isSelected = false
		end
	end
end

function functions.unselectAllMarkers()
    -- cycles through every marker and clears all 'selection' flags
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                mark.isTarget = false
                mark.isSelected = false
			end
		end
	end
end

function functions.unselectAllSelectedMarkers()
    -- cycles through every marker and clears the isSelected flag
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                if mark.isSelected then
                    mark.isSelected = false
                end
			end
		end
	end
end

function functions.unselectAllTargettedMarkers()
    -- cycles through every marker and clears the isTargetted flag
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                if mark.isTarget then
                    mark.isTarget = false
                end
			end
		end
	end
end

function functions.getClosestFormation(x, y)
	-- scans all formations and returns the one closest to x/y
    -- output: a formation object/table
	local bestdistance = -1
	local closestformation

    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			local formx, formy = fun.getFormationCentre(form)
			local disttoformation = cf.GetDistance(x, y, formx, formy)
	-- print(disttoformation, bestdistance)
	-- print(x, y, formx, formy)
			if (disttoformation < bestdistance) or (bestdistance < 0) then
				bestdistance = disttoformation
				closestformation = form		-- this is an object/table
			end
		end
	end
	-- print("***")
	return closestformation	-- an object/table
end

function functions.getClosestMarker(x,y)
    -- scans every marker and returns the one closest to x/y
    -- output: a marker object/table
    local bestdistance = -1
	local closestmarker    -- this is returned by this function

    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
		        local disttomarker = cf.GetDistance(x, y, mark.positionX, mark.positionY)
	-- print(disttoformation, bestdistance)
	-- print(x, y, mark.positionX, mark.positionY)
    			if (disttomarker < bestdistance) or (bestdistance < 0) then
    				bestdistance = disttomarker
    				closestmarker = mark		-- this is an object/table
            	end
            end
		end
	end
	-- print("***")
	return closestmarker	-- an object/table
end

function functions.turnSelectedFormation(value)
	-- turns the currently selected formation by the provided value.
    -- if no formation is selected then there is nothing to do
	-- input: f = formation (object/table)
	-- input: value = degrees to turn. A negative value turns left.
	-- output: none. Operates directly on f
    if GAME_MODE == enum.gamemodePlanning then
        for k,flot in pairs(flotilla) do
    		for q,form in pairs(flot.formation) do
                if form.isSelected then
                	form.heading = form.heading + value
                	if form.heading < 0 then form.heading = 360 + form.heading end 	-- this is '+' because the heading is negative
                	if form.heading > 459 then form.heading = form.heading - 360 end
                end
            end
        end
    end
end

function functions.getMarkerPoints(m)
    -- given a marker (m) return the xy that starts the line and the xy that ends the line
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

function functions.adjustHeading(heading, amount)
    -- adjusts HEADING by AMOUNT. A positive moves the heading right/clockwise. A negative value moves left/anti-clockwise
    -- will adjust if moves past north/zero/360
    -- output: new heading
    local newheading = heading + amount
    if newheading > 359 then newheading = newheading - 360 end
    if newheading < 0 then newheading = 360 + newheading end     -- heading is a negative value so '+' it and 360
    return newheading
end

function functions.getGunsInArc(m, arc)
    -- for the provided marker, return the number of guns that can shoot in the provided arc
    -- does not account for battle damage
    -- input: m - marker (object/table)
    -- output: number - the number of guns that can fire

    local gf, mf = 0,0
    for k, struct in pairs(m.structure) do
        for q, firedirection in pairs(struct.fireDirections) do
            if firedirection == arc then
                -- print(inspect(struct))
                for w, tur in pairs(struct.turret) do
                    -- print(inspect(tur))
                    gf = gf + tur.gunfactor
                    mf = mf + tur.missileFactor
                end
            end
        end
    end
    return gf
end

return functions
