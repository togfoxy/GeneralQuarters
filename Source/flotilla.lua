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
    return myformation
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
    newformation = createNewFormation()
    -- add this generic formation to the flotila
    table.insert(newflotilla.formation, newformation)
    -- prep this new formation to accept one or more markers
    newformation.marker = {}

    qualitycheck.distanceBetweenColumns()
    qualitycheck.columnNumber()
end

return flot
