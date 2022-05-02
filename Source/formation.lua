local formation = {}

function formation.createNewFormation()
    -- creates a new formation with default settings
    -- there is normally two flotilla's (two sides) and each has multiple formations
    -- output = a new formation. This will need to be added to a flotilla in the calling routine

    local myformation = {}
    myformation.numOfColumns = love.math.random(1,4)

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
    myformation.planningstep = {}
    return myformation
end

function formation.getSizeOfColumn(thisform, thiscol)
    -- return how many markers are in the nominated formation/column
    -- input: formation (table)
    -- input: thiscol (number)
    -- output: number of markers in the formation/column

    -- initialise colsize to be the the same as the number of columns in the formation
    local colsize = {}
    for i = 1, thisform.numOfColumns do
        colsize[i] = 0
    end

    for e, mark in pairs(thisform.marker) do
        markercol = mark.columnNumber
        colsize[markercol] = colsize[markercol] + 1
    end

    return colsize[thiscol]
end

function drawCentre()
    -- draw centre of formations
    -- this is a flag

    if GAME_MODE ~= enum.gamemodeCombat then
    	for k,flot in pairs(flotilla) do
    		for q,frm in pairs(flot.formation) do
    			local frmx, frmy = form.getCentre(frm)
                if frm.isSelected then
    	            love.graphics.setColor(0, 1, 0, 1)
                else
                    love.graphics.setColor(1, 1, 1, 1)
                end
    			--love.graphics.circle("line", frmx, frmy, 75)
    			-- draw line out from circle to show heading of formation
    			x1, y1 = frmx, frmy
    			x2, y2 = cf.AddVectorToPoint(x1,y1,frm.heading, 175)
                love.graphics.setLineWidth(3)
    			love.graphics.line(x1,y1,x2,y2)

                local img
                if flot.nation == "British" then
                    img = image[enum.britishflag]
                else
                    img = image[enum.germanflag]
                end
                local imgwidth = img:getWidth()
                local imgheight = img:getHeight()
                love.graphics.setColor(1,1,1,0.5)
                love.graphics.draw(img,(frmx - imgwidth / 2),(frmy - imgheight / 2))
    		end
    	end
    end
end

function formation.unselectAll()
	-- cycles through all formations and clears the 'isSelected' flag
	-- often called right before a mouse click/selection of a new formation

    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			form.isSelected = false
		end
	end
end

function formation.getClosest(x, y)
	-- scans all formations and returns the one closest to x/y. Checks that formation is on the same side
    -- output: a formation object/table
	local bestdistance = -1
	local closestformation

    for k,flot in pairs(flotilla) do
		for q,frm in pairs(flot.formation) do
            if (PLAYER_TURN == 1 and flot.nation == "British") or (PLAYER_TURN == 2 and flot.nation == "German") then
    			local frmx, frmy = form.getCentre(frm)
    			local disttoformation = cf.GetDistance(x, y, frmx, frmy)
    			if (disttoformation < bestdistance) or (bestdistance < 0) then
    				bestdistance = disttoformation
    				closestformation = frm		-- this is an object/table
    			end
            end
		end
	end
	return closestformation	-- an object/table
end

function formation.getCentre(thisform)
    -- gets the centre of a formation by doing vector things
    -- returns a single x/y
    -- input: thisform = object/table
    -- output: x/y pair (number)

    local xcentre, ycentre, count = 0,0,0
    for k, mark in pairs(thisform.marker) do
        xcentre = xcentre + mark.positionX
        ycentre = ycentre + mark.positionY
        count = count + 1
    end
    return cf.round(xcentre / count), cf.round(ycentre / count)
end

function formation.changeFacing(value)
    -- turns the currently selected formation by the provided value.
    -- if no formation is selected then there is nothing to do
	-- input: value = degrees to turn. A negative value turns left.
	-- output: none. Operates directly on the selected formation
    if GAME_MODE == enum.gamemodePlanning then
        for k,flot in pairs(flotilla) do
    		for q,form in pairs(flot.formation) do
                if form.isSelected then
                	form.heading = form.heading + value
                	if form.heading < 0 then form.heading = 360 + form.heading end 	-- this is '+' because the heading is negative
                	if form.heading > 359 then form.heading = form.heading - 360 end
                end
            end
        end
    end
end

local function determineNewFlagship(thisform)
    -- determine the fastest marker in the formation and make that marker the new flagship
    local fastestspeed = -1
    local fastestmarker = {}

    for w,mrk in pairs(thisform.marker) do
        if mrk.movementFactor > fastestspeed then
            fastestspeed = mrk.movementFactor
            fastestmarker = mrk
        end
    end
    fastestmarker.isFlagship = true
    return mrk
end

function formation.getFlagship(thisform)
    -- scans the provided flotilla/formation for the marker that is the flagship
    -- if there is no flagship (it might have sunk) then determine new flagship
    -- input: formation (number/index)
    -- output: a marker object that is the flagship
    for w,mrk in pairs(thisform.marker) do
        if mrk.isFlagship then
            return mrk
        end
    end
    -- if this code is reached then there is no flagship. Nominate a new flagship
    return determineNewFlagship(thisform)

end

function formation.draw()
    -- draw every formation
    mark.draw()
    drawCentre()    -- draw formation centre AFTER all the markers are drawn
end

return formation
