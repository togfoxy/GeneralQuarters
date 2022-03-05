local armyalpha = {}

local function initaliseMarker(flot, form, m)
    -- sets some routine default values that are generic to all markers
    -- these values might be overwritten in the calling function
    m.isFlagship = false
    m.columnNumber = love.math.random(1, flotilla[flot].formation[form].numOfColumns)
    m.sequenceInColumn = nextsequence[m.columnNumber]
    nextsequence[m.columnNumber] = nextsequence[m.columnNumber] + 1
    m.length = 48  -- mm
    m.isSelected = false
    m.isTarget = false
    m.missileFactor = 0
    m.missileCount = 0
    m.initialHeading = love.math.random(0, 359)
    m.topedoHitsSustained = 0
    m.isSunk = false
    m.heading = m.initialHeading
    m.positionX = love.math.random(100, 1800)
    m.positionY = love.math.random(100, 900)
    m.targetID = "" -- flotilla, formation, marker
    m.planningstep = {}     -- holds future moves determined during the planning stage
end

local function addKaiser(flot, form)
    local mymarker = {}
    initaliseMarker(flot, form, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Kaiser"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 12
    mymarker.markerType = "BB"

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Bow"
    mymarker.structure[2].fireDirections[2] = "Starboard"
    mymarker.structure[2].fireDirections[3] = "Stern"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Port"
    mymarker.structure[3].fireDirections[2] = "Starboard"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Port"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "Bow"
    mymarker.structure[4].fireDirections[2] = "Port"
    mymarker.structure[4].fireDirections[3] = "Stern"

    -- for each structure ...
    for i = 1, 4 do
        mymarker.structure[i].turret = {}
    end
    -- add turrets on each structure
    for i = 1,3 do
        fun.AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,5 do
        fun.AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[4].turret, 1, 0)
    end
    table.insert(flotilla[flot].formation[form].marker, mymarker)
end

local function addHelgoland(flot, form)
    local mymarker = {}
    initaliseMarker(flot, form, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Helgoland"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 12
    mymarker.markerType = "BB"

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Bow starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Bow"
    mymarker.structure[2].fireDirections[2] = "Starboard"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern starboard"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Starboard"
    mymarker.structure[3].fireDirections[2] = "Stern"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "Stern"
    mymarker.structure[4].fireDirections[2] = "Port"
    mymarker.structure[4].fireDirections[3] = "Starboard"

    mymarker.structure[5] = {}
    mymarker.structure[5].location = "Stern port"        -- location of the structure on the marker
    mymarker.structure[5].fireDirections = {}
    mymarker.structure[5].fireDirections[1] = "Port"
    mymarker.structure[5].fireDirections[2] = "Stern"

    mymarker.structure[6] = {}
    mymarker.structure[6].location = "Bow port"        -- location of the structure on the marker
    mymarker.structure[6].fireDirections = {}
    mymarker.structure[6].fireDirections[1] = "Bow"
    mymarker.structure[6].fireDirections[2] = "Port"

    for i = 1, 6 do
        mymarker.structure[i].turret = {}
    end
    for i = 1,3 do
        fun.AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[3].turret, 1, 0)
    end
    for i = 1,3 do
        fun.AddTurret(mymarker.structure[4].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[5].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[6].turret, 1, 0)
    end
    table.insert(flotilla[flot].formation[form].marker, mymarker)

end

local function addFriedrichDerGrosse(flot, form)
    -- adds the Friederich to the provided flotilla and formation
    -- input: flotilla number, form number   (not objects/tables!)

    local mymarker = {}
    initaliseMarker(flot, form, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Friederich Der Grosse"
    mymarker.isFlagship = true
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 12
    mymarker.markerType = "BB"

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Starboard"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Bow"
    mymarker.structure[2].fireDirections[2] = "Starboard"
    mymarker.structure[2].fireDirections[3] = "Stern"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Port"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Bow"
    mymarker.structure[3].fireDirections[2] = "Port"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[4] = {}
    mymarker.structure[4].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[4].fireDirections = {}
    mymarker.structure[4].fireDirections[1] = "Stern"
    mymarker.structure[4].fireDirections[2] = "Port"
    mymarker.structure[4].fireDirections[3] = "Starboard"

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
    initaliseMarker(flot, form, mymarker)   -- sets up some boring generic default values
    mymarker.markerName = "Grosser Kerflirst"
    mymarker.movementFactor = 8
    mymarker.protectionFactor = 14
    mymarker.markerType = "BB"

    mymarker.structure = {}
    mymarker.structure[1] = {}
    mymarker.structure[1].location = "Bow"        -- location of the structure on the marker
    mymarker.structure[1].fireDirections = {}
    mymarker.structure[1].fireDirections[1] = "Bow"
    mymarker.structure[1].fireDirections[2] = "Port"
    mymarker.structure[1].fireDirections[3] = "Starboard"

    mymarker.structure[2] = {}
    mymarker.structure[2].location = "Midships"        -- location of the structure on the marker
    mymarker.structure[2].fireDirections = {}
    mymarker.structure[2].fireDirections[1] = "Port"
    mymarker.structure[2].fireDirections[2] = "Starboard"

    mymarker.structure[3] = {}
    mymarker.structure[3].location = "Stern"        -- location of the structure on the marker
    mymarker.structure[3].fireDirections = {}
    mymarker.structure[3].fireDirections[1] = "Starboard"
    mymarker.structure[3].fireDirections[2] = "Port"
    mymarker.structure[3].fireDirections[3] = "Stern"

    mymarker.structure[1].turret = {}
    mymarker.structure[2].turret = {}
    mymarker.structure[3].turret = {}


    for i = 1,5 do
        fun.AddTurret(mymarker.structure[1].turret, 1, 0)
    end
    for i = 1,2 do
        fun.AddTurret(mymarker.structure[2].turret, 1, 0)
    end
    for i = 1,5 do
        fun.AddTurret(mymarker.structure[3].turret, 1, 0)
    end

    table.insert(flotilla[flot].formation[form].marker, mymarker)
end

function armyalpha.Initialise()

    newflotilla = fun.createNewFlotilla("Alpha")
    newflotilla.formation = {}

    newformation = fun.createNewFormation()
    table.insert(newflotilla.formation, newformation)

    newformation.marker = {}
    addFriedrichDerGrosse(1, 1) -- flotilla and formation
    addGrosserKerflirst(1, 1)
    addHelgoland(1,1)
    addKaiser(1,1)

    for i = 1, love.math.random(3, 15) do
        -- fun.addGenericMarker(1, 1)
    end

    -- nominate one random marker as the flagship
    -- local numofmarkers = #flotilla[1].formation[1].marker
    -- local rndnum = love.math.random(1,numofmarkers)

    -- make this fs sale east for testing
    -- flotilla[1].formation[1].marker[rndnum].heading = 90
    --flotilla[1].formation[1].marker[rndnum].positionX = 150
    --flotilla[1].formation[1].marker[rndnum].positiony = 750
    flotilla[1].formation[1].heading = 90

    -- print(inspect(flotilla[1].formation[1].marker[1]))

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
