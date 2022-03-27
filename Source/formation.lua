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




return formation
