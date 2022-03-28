local formation = {}

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

-- function formation.getFormationCentre(thisform)
--     -- gets the centre of a formation by doing vector things
--     -- returns a single x/y
--     -- input: thisform = object/table
--     -- output: x/y pair (number)
--
--     local xcentre, ycentre, count = 0,0,0
--     for k, mark in pairs(thisform.marker) do
--         xcentre = xcentre + mark.positionX
--         ycentre = ycentre + mark.positionY
--         count = count + 1
--     end
--     return cf.round(xcentre / count), cf.round(ycentre / count)
-- end

function formation.draw()
    -- draw every formation
    mark.draw()
end


return formation
