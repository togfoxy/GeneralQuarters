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

function functions.allMarkersAlignTowardsFormation()
    -- move ships closer formation
	-- for every marker:
	-- draw every marker
    local steeringamount = 15
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mark in pairs(form.marker) do
				if mark.heading ~= form.heading then
					-- turn left or right?
					if form.heading > mark.heading and form.heading < (mark.heading + 180) then
						-- turn right
						mark.heading = mark.heading + steeringamount
						-- cancel oversteer
						if mark.heading > form.heading then mark.heading = form.heading end
					else
						-- turn right
						mark.heading = mark.heading - steeringamount
						-- cancel oversteer
						if mark.heading < form.heading then mark.heading = form.heading end
					end
				end
			end
		end
	end
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
    local newx, newy = cf.AddVectorToPoint(xcentre,ycentre,heading, 16)
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
print(fs.heading, relativeheadingfromfs)
        if relativeheadingfromfs < 0 then relativeheadingfromfs = 360 + relativeheadingfromfs end       -- this is a + because the value is a negative
print(fs.heading, relativeheadingfromfs)
        -- now determine x/y from relative heading + distance/hypotenuse
        m.correctX, m.correctY = cf.AddVectorToPoint(fs.positionX,fs.positionY,relativeheadingfromfs,hyp)
    elseif columndelta == 0 then
        --!
        m.correctX, m.correctY = nil, nil
    elseif columndelta > 0 then
        --!
        m.correctX, m.correctY = nil, nil
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
                    moveMarkerOnce(mark)
                else
                    -- this uses the dot product to detect if the marker is in front or behind the flagship.
                    -- if it is in front - then don't move. Stay still and wait for FS to catch up
                    -- if it is behind the FS, then it is free to move with the formation

                    setCorrectPositionInFormation(form, flagship, mark)

                    -- get the direction the flagship is "looking"
                    local fsX = flagship.positionX
                    local fsY = flagship.positionY
                    local fsHeading = flagship.heading
                    local fsnewx, fsnewy = cf.AddVectorToPoint(fsX,fsY,fsHeading, 16)
                    local fsxdelta = fsnewx - fsX   -- this is the direction the flagship is looking
                    local fsydelta = fsnewy - fsY   -- this is the direction the flagship is looking

                    -- get delta between marker and flagship
                    local xcentre = (mark.positionX)
                    local ycentre = (mark.positionY)
                    local deltax = xcentre - fsX
                    local deltay = ycentre - fsY

                    -- now see if the marker is in front or behind the FS
                    local dotproduct = cf.dotVectors(fsxdelta,fsydelta,deltax,deltay)

                    if dotproduct <= 0 then
                        -- marker is behind the flagship so allowed to move
                        moveMarkerOnce(mark)
                    end
                end
            end
        end
    end


end


return functions
