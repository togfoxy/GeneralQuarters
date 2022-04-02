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

function getFormationCentre(thisform)
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

function drawCentre()
    -- draw centre of formations
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			local formx, formy = getFormationCentre(form)
			love.graphics.setColor(1, 1, 1, alphavalue)
			love.graphics.circle("line", formx, formy, 5)
			-- draw line out from circle to show heading of formation
			x1, y1 = formx, formy
			x2, y2 = cf.AddVectorToPoint(x1,y1,form.heading, 8)
			love.graphics.line(x1,y1,x2,y2)
		end
	end

end

function formation.draw()
    -- draw every formation
    drawCentre()
    mark.draw()
end


return formation
