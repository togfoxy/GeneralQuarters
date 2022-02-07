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


return functions
