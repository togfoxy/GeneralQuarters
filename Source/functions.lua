local functions = {}

function functions.InitialiseData()

    currentHour = 0
    currentMinutes = 0

    maximumSightRangeDay = 10000
    maximumSightRangeNight = 6000

    flotilla = {}

    armyalpha.Initialise()
end

function functions.allMarkersForwardOnce()
    -- moves all markers forward one (16 pixels)

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
    local xcentre, ycentre, count = 0,0,0
    for k, mark in pairs(formation.marker) do
        xcentre = xcentre + mark.positionX
        ycentre = ycentre + mark.positionY
        count = count + 1
    end
    return cf.round(xcentre / count), cf.round(ycentre / count)
end

local function alignMarkerTowardsHeading(mark, heading)
    -- move ships closer formation
	-- for every marker:
	-- draw every marker
    local steeringamount = 15

	if mark.heading ~= heading then
		-- turn left or right?
		if heading > mark.heading and heading < (mark.heading + 180) then
			-- turn right
			mark.heading = mark.heading + steeringamount
			-- cancel oversteer
			if mark.heading > heading then mark.heading = heading end
		else
			-- turn right
			mark.heading = mark.heading - steeringamount
			-- cancel oversteer
			if mark.heading < heading then mark.heading = heading end
		end
	end
end

local function getTargetQuadrant(m, x2, y2)
    -- returns the quadrant the target is in relative to the viewer/shooter
    -- Relative to north/0 degrees so north east is quadrant 1 and south east is quadrant 2 etc
    -- Note: a target on an axis (x/y) will still return a quadrant
    -- input: a marker object
    -- input: the x/y of the target
    -- output: a number between 0 and 4 inclusive. Returns zero if target is on smae location as marker

    local x1 = m.positionX
    local y1 = m.positionY

    if x1 == x2 and y1 == y2 then return 0 end
    if x2 >= x1 and y2 <= y1 then return 1 end
    if x2 > x1 and y2 > y1 then return 2 end
    if x2 <= x1 and y2 >= y1 then return 3 end
    if x2 < x1 and y2 < y1 then return 4 end
    -- this next error should never haqppen
    print(x1,y1,x2,y2)
    error("Unexpected program flow")
end

local function getAbsoluteHeadingToTarget(m, x2,y2)
    -- return the absoluting heading. 0 - north and 90 = east
    -- input: m = marker table
    -- input: target x,y

    -- if there is an imaginary triangle from the positionx/y to the correctx/y then calculate opp/adj/hyp
    local targetqudrant = getTargetQuadrant(m, x2, y2)
    if targetqudrant == 0 then
        return 0    -- just face north I guess
    elseif targetqudrant == 1 then
        -- tan(angle) = opp / adj
        -- angle = atan(opp/adj)
        local adj = x2 - m.positionX
        local opp = m.positionY - y2
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(90 - angletocorrectposition)
    elseif targetqudrant == 2 then
        local adj = x2 - m.positionX
        local opp = y2 - m.positionY
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(90 + angletocorrectposition)
    elseif targetqudrant == 3 then
        local adj = m.positionX - x2
        local opp = y2 - m.positionY
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(270 - angletocorrectposition)
    elseif targetqudrant == 4 then
        local adj = m.positionX - x2
        local opp = m.positionY - y2
        local angletocorrectposition = math.deg( math.atan(opp/adj) )   -- atan returns radians. Convert to degrees from east (90 degrees)
        -- convert so it is relative to zero/north
        return cf.round(270 + angletocorrectposition)
    end
 end

local function alignMarkerTowardsCorrectPosition(m)
    -- turns the marker towards the correct position within the formation without breaking turning rules
    -- input: m = marker object/table
    local steeringamount = 15   -- max turn rate

    local desiredheading = getAbsoluteHeadingToTarget(m, m.correctX, m.correctY)
    local angledelta = desiredheading - m.heading
    local adjsteeringamount = math.min(math.abs(angledelta), steeringamount)

    -- determine if cheaper to turn left or right
    local leftdistance = m.heading - desiredheading
    if leftdistance < 0 then leftdistance = 360 + leftdistance end      -- this is '+' because leftdistance is a negative value

    local rightdistance = desiredheading - m.heading
    if rightdistance < 0 then rightdistance = 360 + rightdistance end   -- this is '+' because leftdistance is a negative value

    -- print(m.heading, desiredheading, leftdistance, rightdistance)

    if leftdistance < rightdistance then
        -- print("turning left " .. adjsteeringamount)
        m.heading = m.heading - (adjsteeringamount)
    else
        -- print("turning right " .. adjsteeringamount)
        m.heading = m.heading + (adjsteeringamount)
    end
    if m.heading < 0 then m.heading = 360 + m.heading end
    if m.heading > 359 then m.heading = m.heading - 360 end
end

local function getFlagShip(flot, form)
    -- scans the provided flotilla/formation for the marker ID (index) that is the flagship
    -- returns the marker object
    for w,mark in pairs(flotilla[flot].formation[form].marker) do
        if mark.isFlagship then
            return mark
        end
    end
end

local function moveMarkerOnce(mymarker)
    -- input: a marker object
    -- moves one marker just once (in direction of heading)
    local xcentre = (mymarker.positionX)
    local ycentre = (mymarker.positionY)
    local heading = (mymarker.heading)
    local dist
    if mymarker.isFlagship then
        dist = 10
    else
        dist = 16
    end
    local newx, newy = cf.AddVectorToPoint(xcentre,ycentre,heading, dist)
    mymarker.positionX = newx
    mymarker.positionY = newy
end

local function setCorrectPositionInFormation(formobj, fs, m)
    -- determine the correct x/y position within the formation
    -- input: formobj = (object/table)
    -- input: fs = flagship (object/table)
    -- input: m = marker (object/table)
    -- output: sets m.correctX and m.correctY

    -- determine if m is left or right of FS by checking both numOfColumns
    local columndelta = m.columnNumber - fs.columnNumber    -- a negative number means m should be left of fs

    if columndelta < 0 then
        -- determine head position of this column
        -- assumes columns are 45 degrees behind flagship
        -- using trigonometry and knowledge of distance between columns:

        -- cos = adj / hyp
        -- hyp = adj / cos
        local hyp = (formobj.distanceBetweenColumns) / math.cos(45) -- gives the hypotenuse/distance for the marker leading the adjacent column
        -- multipy this hypotenuse for each column away from teh fs column
        hyp = hyp * math.abs(columndelta)
        -- determine x/y for the lead marker for this column
        -- it is known that the angle is fs heading - 135 degrees
        local relativeheadingfromfs = fs.heading - 135
    --print(fs.heading, relativeheadingfromfs)
        if relativeheadingfromfs < 0 then relativeheadingfromfs = 360 + relativeheadingfromfs end       -- this is a + because the value is a negative
    --print(fs.heading, relativeheadingfromfs)
        -- now determine x/y from relative heading + distance/hypotenuse
        m.correctX, m.correctY = cf.AddVectorToPoint(fs.positionX,fs.positionY,relativeheadingfromfs,hyp)
    elseif columndelta == 0 then
        local hyp = (formobj.distanceBetweenColumns) / math.cos(45) -- gives the hypotenuse/distance for the marker leading the adjacent column
        hyp = hyp * math.abs(columndelta)
        local relativeheadingfromfs = fs.heading + 135
        if relativeheadingfromfs > 359 then relativeheadingfromfs = relativeheadingfromfs - 360 end
        m.correctX, m.correctY = cf.AddVectorToPoint(fs.positionX,fs.positionY,relativeheadingfromfs,hyp)
    elseif columndelta > 0 then
        local relativeheadingfromfs = fs.heading + 180
        if relativeheadingfromfs > 359 then relativeheadingfromfs = relativeheadingfromfs - 360 end
        m.correctX, m.correctY = cf.AddVectorToPoint(fs.positionX,fs.positionY,relativeheadingfromfs,m.length)
    end
end

function functions.moveAllMarkers()
    -- moves all marks as a part of the formation or towards the formation

    -- ipairs is important because we're using table index
    for k,flot in ipairs(flotilla) do
		for q,form in ipairs(flot.formation) do

            local flagship = getFlagShip(k, q)

			for w,mark in pairs(form.marker) do
                if mark == flagship then
                    -- flagship = flagship so move the flagship
                    alignMarkerTowardsHeading(mark, form.heading)
                    moveMarkerOnce(mark)
                else
                    -- this uses the dot product to detect if the marker is in front or behind the correct position within the formation.
                    -- if it is in front - then don't move. Stay still and wait for the formation to catch up
                    -- if it is behind the correct position, then it is free to move with the formation

                    -- get the correct position within the formation and save that inside the marker table
                    setCorrectPositionInFormation(form, flagship, mark) -- sets marker.correctX and marker.correctY
                    assert(mark.correctX ~= nil)
                    assert(mark.correctY ~= nil)

                    alignMarkerTowardsCorrectPosition(mark)

                    -- get the marker location and facing. Will add an arbitary 'length' to it's current position/heading
                    local markernewx, markernewy = cf.AddVectorToPoint(mark.positionX,mark.positionY, mark.heading, mark.length)    -- creates a vector reflecting facting

                    -- determine the position of corrextx/y relative to the marker
                    local correctxdelta = mark.correctX - mark.positionX
                    local correctydelta = mark.correctY - mark.positionY

                    -- see if correct position is ahead or behind marker
                    -- x1/y1 vector is facing/looking
                    -- x2/y2 is the position relative to the object doing the looking
                    local dotproduct = cf.dotVectors(markernewx,markernewy,correctxdelta,correctydelta)
    -- print(markernewx, markernewy, correctxdelta, correctydelta, dotproduct)
                    if dotproduct > 0 then
                        -- marker is behind the correct position so allowed to move
                        moveMarkerOnce(mark)
                    end
                end
            end
        end
    end


end


return functions
