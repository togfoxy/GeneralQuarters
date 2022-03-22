local qualitycheck = {}

function qualitycheck.distanceBetweenColumns()
    -- ensures that the distance between columns is set appropriately
    for k,flot in pairs(flotilla) do
        for q,form in pairs(flot.formation) do
            if form.numOfColumns == 1 then
                assert(form.distanceBetweenColumns == nil)
            else
                assert(form.distanceBetweenColumns ~= nil)
            end
        end
    end
end

function qualitycheck.columnNumber()
    -- ensures the column number/index for each formation does not exceed the number of columns in the formation
    for k,flot in pairs(flotilla) do
        for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                assert(mark.columnNumber <= form.numOfColumns)
            end
        end
    end
end

return qualitycheck
