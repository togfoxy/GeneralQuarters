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

local function createNewFormation()
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
    local newbritformation = createNewFormation()
    -- add this generic formation to the flotilla
    table.insert(newflotilla.formation, newbritformation)
    -- prep this new formation to accept one or more markers
    newbritformation.marker = {}

    -- do the same for the Germans
    newflotilla = {}
    newflotilla = createNewFlotilla("German")   -- adds a flotilla to the global flotilla and returns that new flotilla
    newflotilla.formation = {}

    local newgermformation = {}
    newgermformation = createNewFormation()           -- creates a newformation
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
