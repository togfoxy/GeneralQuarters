local flot = {}

local function createNewFlotilla(nation)
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


local function getAllFlotillaStartingPosition()
    -- called just once to set flotilla starting positions
    local bearingfromcentre
    for k, flot in pairs(flotilla) do
        for q, form in pairs(flot.formation) do
            -- orientation
            bearingfromcentre = love.math.random(0, 359)
            form.heading = cf.adjustHeading(bearingfromcentre, 180)

            -- location
            local distfromcentre = MAP_CENTRE
            form.positionX, form.positionY = cf.AddVectorToPoint(MAP_CENTRE, MAP_CENTRE, bearingfromcentre, distfromcentre)
        end
    end
end

function flot.getAveragePosition(nation)
    -- cycle thorugh all markers and determine the average x/y for the provided nation.
    -- used to know where the 'middle' of the flotilla is for positioning camera etc
    -- input: nation - string
    -- output: x, y - integer (pixels) reflecting the average x and average y for all markers of that nation

    -- cycle through, add totals, keep a count, then do an average (total/count)
    local totalx = 0
    local totaly = 0
    local markercount = 0

    for k,flot in pairs(flotilla) do
        if flot.nation == nation then
            for q,form in pairs(flot.formation) do
                for w,mark in pairs(form.marker) do
                    totalx = totalx + mark.positionX
                    totaly = totaly + mark.positionY
                    markercount = markercount + 1
                end
            end
        end
    end
    return cf.round(totalx/markercount), cf.round(totaly/markercount)       -- this is pixes so must round off
end

function flot.Initialise()
    -- initialises two flotillas and adds them to the flotilla table
    -- input: none
    -- output: none

    -- create a new flotilla and add that flotilla to the global table
    -- the 'nation' could be anything but for now it's hardcoded to 'British' and 'German'
    newflotilla = createNewFlotilla("British")
    -- prep the flotilla to accept one or more formations
    newflotilla.formation = {}
    -- create a generic formation with default Settings
    local newbritformation = form.createNewFormation()
    -- add this generic formation to the flotilla
    table.insert(newflotilla.formation, newbritformation)
    -- prep this new formation to accept one or more markers
    newbritformation.marker = {}

    -- do the same for the Germans
    newflotilla = {}
    newflotilla = createNewFlotilla("German")   -- adds a flotilla to the global flotilla and returns that new flotilla
    newflotilla.formation = {}

    local newgermformation = {}
    newgermformation = form.createNewFormation()           -- creates a newformation
    table.insert(newflotilla.formation, newgermformation)   -- adds the new formation to the new flotilla

    -- prep this new formation to accept one or more markers
    newgermformation.marker = {}    -- preps the formation to receive new markers

    -- determine starting location and orientation for each flotilla/formation
    getAllFlotillaStartingPosition()

    -- ********************************************************************************************
    -- neds to come after both flotilla's/formations are established
    -- load up markers on both flotillas

    local newmarker = mark.addAgincourt(newbritformation)
    newmarker.isFlagship = true
    newmarker.positionX, newmarker.positionY = mark.getCorrectPositionInFormation(newmarker)

    local newmarker = {}
    newmarker = mark.addFriedrichDerGrosse(newgermformation)
    newmarker.isFlagship = true
    newmarker.positionX, newmarker.positionY = mark.getCorrectPositionInFormation(newmarker)

    -- *************************************

    -- do some QA to make sure nothing broke
    qualitycheck.distanceBetweenColumns()
    qualitycheck.marker()
    qualitycheck.formationHasFlagship()
end

function flot.draw()
    -- draws every flotilla
    form.draw()
end

return flot
