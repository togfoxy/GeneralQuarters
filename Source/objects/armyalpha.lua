local armyalpha = {}

local function addFriedrichDerGrosse(flot, form)
    -- adds the Friederich to the provided flotilla and formation
    -- input: flotilla number, form number   (not objects/tables!)

    local mymarker = {}
    mymarker.markerName = "Friederich Der Grosse"
    mymarker.isFlagship = true

    mymarker.columnNumber = love.math.random(1, flotilla[flot].formation[form].numOfColumns)
    -- mymarker.columnNumber = 2
    mymarker.sequenceInColumn = nextsequence[mymarker.columnNumber]
    nextsequence[mymarker.columnNumber] = nextsequence[mymarker.columnNumber] + 1
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 12

    mymarker.undoPositionX = {}
    --mymarker.undoPositionX[1] =
    mymarker.undoPositionY = {}
    --mymarker.undoPositionY[1] = 300
    mymarker.isSelected = false
    mymarker.isTarget = false
    mymarker.markerType = "BB"
    mymarker.missileFactor = 0
    mymarker.missileCount = 0
    mymarker.initialHeading = love.math.random(0, 359)
    mymarker.topedoHitsSustained = 0
    mymarker.isSunk = false
    mymarker.heading = mymarker.initialHeading
    mymarker.positionX = 400
    mymarker.positionY = 400
    mymarker.length = 48  -- mm
    mymarker.targetID = "" -- flotilla, formation, marker

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "North"
    mymarker.structure[1].fireDirections[2] = "West"
    mymarker.structure[1].fireDirections[3] = "South"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "North"
    mymarker.structure[2].fireDirections[2] = "West"
    mymarker.structure[2].fireDirections[3] = "East"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Port"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "East"
    mymarker.structure[3].fireDirections[2] = "West"
    mymarker.structure[3].fireDirections[3] = "South"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Astern"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "North"
    mymarker.structure[4].fireDirections[2] = "East"
    mymarker.structure[4].fireDirections[3] = "South"

    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}
    mymarker.structure[4].turret = {}

    for i = 1,3 do
        fun.AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,5 do
        fun.AddTurret(mymarker.structure[4].turret, 1, 0)
    end

    table.insert(flotilla[flot].formation[form].marker, mymarker)
end

local function addGrosserKerflirst(flot, form)
    -- flot and form are numnbers (index)
    local mymarker = {}
    mymarker.markerName = "Grosser Kerflirst"
        mymarker.columnNumber = love.math.random(1, flotilla[flot].formation[form].numOfColumns)
    -- mymarker.columnNumber = 2

    mymarker.sequenceInColumn = nextsequence[mymarker.columnNumber]
    nextsequence[mymarker.columnNumber] = nextsequence[mymarker.columnNumber] + 1
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 14

    mymarker.undoPositionX = {}
    --mymarker.undoPositionX[1] =
    mymarker.undoPositionY = {}
    --mymarker.undoPositionY[1] = 300
    mymarker.isSelected = false
    mymarker.isTarget = false
    mymarker.markerType = "BB"
    mymarker.missileFactor = 0
    mymarker.missileCount = 0
    mymarker.initialHeading = love.math.random(0, 359)
    mymarker.topedoHitsSustained = 0
    mymarker.isSunk = false
    mymarker.heading = mymarker.initialHeading
    mymarker.positionX = 500
    mymarker.positionY = 500
    mymarker.length = 48  -- mm

    mymarker.targetID = "" -- flotilla, formation, marker

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "North"
    mymarker.structure[1].fireDirections[2] = "West"
    mymarker.structure[1].fireDirections[3] = "South"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "North"
    mymarker.structure[2].fireDirections[2] = "West"
    mymarker.structure[2].fireDirections[3] = "East"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Port"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "East"
    mymarker.structure[3].fireDirections[2] = "West"
    mymarker.structure[3].fireDirections[3] = "South"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Astern"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "North"
    mymarker.structure[4].fireDirections[2] = "East"
    mymarker.structure[4].fireDirections[3] = "South"

    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}
    mymarker.structure[4].turret = {}

    for i = 1,3 do
        fun.AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,5 do
        fun.AddTurret(mymarker.structure[4].turret, 1, 0)
    end

    table.insert(flotilla[flot].formation[form].marker, mymarker)
end

function armyalpha.Initialise()

    newflotilla = fun.createNewFlotilla("Alpha")
    newflotilla.formation = {}

    newformation = fun.createNewFormation()
    table.insert(newflotilla.formation, newformation)

    newformation.marker = {}
    addFriedrichDerGrosse(1, 1)
    addGrosserKerflirst(1, 1)
    for i = 1, love.math.random(3, 15) do
        fun.addGenericMarker(1, 1)
    end

    -- nominate one random marker as the flagship
    -- local numofmarkers = #flotilla[1].formation[1].marker
    -- local rndnum = love.math.random(1,numofmarkers)


    -- make this fs sale east for testing
    -- flotilla[1].formation[1].marker[rndnum].heading = 90
    --flotilla[1].formation[1].marker[rndnum].positionX = 150
    --flotilla[1].formation[1].marker[rndnum].positiony = 750
    flotilla[1].formation[1].heading = 90


-- *******************************************

    -- flotilla[1].formation[1].marker[2] = {}

    -- quality check
    for k,flot in pairs(flotilla) do
        for q,form in pairs(flot.formation) do
            if form.numOfColumns == 1 then
                assert(form.distanceBetweenColumns == nil)
            else
                assert(form.distanceBetweenColumns ~= nil)
            end
        end
    end

    -- quality check
    for k,flot in pairs(flotilla) do
        for q,form in pairs(flot.formation) do
            for w,mark in pairs(form.marker) do
                assert(mark.columnNumber <= form.numOfColumns)
            end
        end
    end








end















return armyalpha
