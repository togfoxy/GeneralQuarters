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

function qualitycheck.marker()
    -- ensures the column number/index for each formation does not exceed the number of columns in the formation
    for k,flot in pairs(flotilla) do
        for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                assert(mark.columnNumber <= form.numOfColumns)
                assert(mark.positionX ~= nil)
                assert(mark.positionY ~= nil)
            end
        end
    end
end

function qualitycheck.formationHasFlagship()
    -- ensures every formation has a flagship
    for k, flot in pairs(flotilla) do
        for q, form in pairs(flot.formation) do
            local hasFS = false
            for w, mark in pairs(form.marker) do
                if mark.isFlagship then
                    hasFS = true
                end
            end
            assert(hasFS == true)
        end
    end
end

return qualitycheck
