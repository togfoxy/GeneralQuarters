local armyalpha = {}

local function AddTurret(struct, gf, mf)
    local myturret = {}
    myturret.active = true
    myturret.gunfactor = gf
    myturret.missileFactor = mf
    table.insert(struct, myturret)
end

function armyalpha.addFriedrichDerGrosse()



end


function armyalpha.Initialise()


        flotilla[1] = {}
        flotilla[1].nation = "Alpha"

        flotilla[1].formation = {}
        flotilla[1].formation[1] = {}
        flotilla[1].formation[1].numOfColumns = 1
        flotilla[1].formation[1].distanceBetweenColumns = nil


        flotilla[1].formation[1].heading = love.math.random(0, 359)
        flotilla[1].formation[1].currentManeuver = ""
        flotilla[1].formation[1].pivotpointx = nil
        flotilla[1].formation[1].pivotpointy = nil
        flotilla[1].formation[1].undoStackX = {}
        flotilla[1].formation[1].undoStackY = {}
        -- flotilla[1].formation[1].undoStackX[1] = 300
        -- flotilla[1].formation[1].undoStackY[1] = 300

        flotilla[1].formation[1].marker = {}
        flotilla[1].formation[1].marker[1] = {}
        flotilla[1].formation[1].marker[1].markerName = "Friederich Der Grosse"
        flotilla[1].formation[1].marker[1].columnNumber = 1


        flotilla[1].formation[1].marker[1].sequenceInColumn = 1
        flotilla[1].formation[1].marker[1].movementFactor = 8
        flotilla[1].formation[1].marker[1].protectionFactor = 12

        flotilla[1].formation[1].marker[1].undoPositionX = {}
        --flotilla[1].formation[1].marker[1].undoPositionX[1] =
        flotilla[1].formation[1].marker[1].undoPositionY = {}
        --flotilla[1].formation[1].marker[1].undoPositionY[1] = 300
        flotilla[1].formation[1].marker[1].isSelected = false
        flotilla[1].formation[1].marker[1].isTarget = false
        flotilla[1].formation[1].marker[1].markerType = "BB"
        flotilla[1].formation[1].marker[1].missileFactor = 0
        flotilla[1].formation[1].marker[1].missileCount = 0
        flotilla[1].formation[1].marker[1].initialHeading = love.math.random(0, 359)
        flotilla[1].formation[1].marker[1].topedoHitsSustained = 0
        flotilla[1].formation[1].marker[1].isSunk = false
        flotilla[1].formation[1].marker[1].heading = flotilla[1].formation[1].marker[1].initialHeading
        flotilla[1].formation[1].marker[1].positionX = 400
        flotilla[1].formation[1].marker[1].positionY = 400
        flotilla[1].formation[1].marker[1].length = 48  -- mm
        flotilla[1].formation[1].marker[1].targetID = "" -- flotilla, formation, marker

        flotilla[1].formation[1].marker[1].structure = {}
        flotilla[1].formation[1].marker[1].structure[1] = {}
        flotilla[1].formation[1].marker[1].structure[1].location = "Bow"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[1].structure[1].fireDirections = {}
        flotilla[1].formation[1].marker[1].structure[1].fireDirections[1] = "North"
        flotilla[1].formation[1].marker[1].structure[1].fireDirections[2] = "West"
        flotilla[1].formation[1].marker[1].structure[1].fireDirections[3] = "South"

        flotilla[1].formation[1].marker[1].structure[2] = {}
        flotilla[1].formation[1].marker[1].structure[2].location = "Starboard"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[1].structure[2].fireDirections = {}
        flotilla[1].formation[1].marker[1].structure[2].fireDirections[1] = "North"
        flotilla[1].formation[1].marker[1].structure[2].fireDirections[2] = "West"
        flotilla[1].formation[1].marker[1].structure[2].fireDirections[3] = "East"

        flotilla[1].formation[1].marker[1].structure[3] = {}
        flotilla[1].formation[1].marker[1].structure[3].location = "Port"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[1].structure[3].fireDirections = {}
        flotilla[1].formation[1].marker[1].structure[3].fireDirections[1] = "East"
        flotilla[1].formation[1].marker[1].structure[3].fireDirections[2] = "West"
        flotilla[1].formation[1].marker[1].structure[3].fireDirections[3] = "South"

        flotilla[1].formation[1].marker[1].structure[4] = {}
        flotilla[1].formation[1].marker[1].structure[4].location = "Astern"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[1].structure[4].fireDirections = {}
        flotilla[1].formation[1].marker[1].structure[4].fireDirections[1] = "North"
        flotilla[1].formation[1].marker[1].structure[4].fireDirections[2] = "East"
        flotilla[1].formation[1].marker[1].structure[4].fireDirections[3] = "South"

        flotilla[1].formation[1].marker[1].structure[1].turret = {}
        flotilla[1].formation[1].marker[1].structure[2].turret = {}
        flotilla[1].formation[1].marker[1].structure[3].turret = {}
        flotilla[1].formation[1].marker[1].structure[4].turret = {}

        for i = 1,3 do
            AddTurret(flotilla[1].formation[1].marker[1].structure[1].turret, 1, 0)
        end
        for i = 1,2 do
            AddTurret(flotilla[1].formation[1].marker[1].structure[2].turret, 1, 0)
        end
        for i = 1,2 do
            AddTurret(flotilla[1].formation[1].marker[1].structure[3].turret, 1, 0)
        end
        for i = 1,5 do
            AddTurret(flotilla[1].formation[1].marker[1].structure[4].turret, 1, 0)
        end

-- *******************************************

        flotilla[1].formation[1].marker[2] = {}
        flotilla[1].formation[1].marker[2].markerName = "Grosser Kerflirst"
        flotilla[1].formation[1].marker[2].columnNumber = 1

        for k,flot in pairs(flotilla) do
            for q,form in pairs(flot.formation) do
                for w,mark in pairs(form.marker) do
                    assert(mark.columnNumber <= form.numOfColumns)
                end
            end
        end

        flotilla[1].formation[1].marker[2].sequenceInColumn = 1
        flotilla[1].formation[1].marker[2].movementFactor = 8
        flotilla[1].formation[1].marker[2].protectionFactor = 14

        flotilla[1].formation[1].marker[2].undoPositionX = {}
        --flotilla[1].formation[1].marker[2].undoPositionX[1] =
        flotilla[1].formation[1].marker[2].undoPositionY = {}
        --flotilla[1].formation[1].marker[2].undoPositionY[1] = 300
        flotilla[1].formation[1].marker[2].isSelected = false
        flotilla[1].formation[1].marker[2].isTarget = false
        flotilla[1].formation[1].marker[2].markerType = "BB"
        flotilla[1].formation[1].marker[2].missileFactor = 0
        flotilla[1].formation[1].marker[2].missileCount = 0
        flotilla[1].formation[1].marker[2].initialHeading = love.math.random(0, 359)
        flotilla[1].formation[1].marker[2].topedoHitsSustained = 0
        flotilla[1].formation[1].marker[2].isSunk = false
        flotilla[1].formation[1].marker[2].heading = flotilla[1].formation[1].marker[2].initialHeading
        flotilla[1].formation[1].marker[2].positionX = 500
        flotilla[1].formation[1].marker[2].positionY = 500
        flotilla[1].formation[1].marker[2].length = 48  -- mm

        flotilla[1].formation[1].marker[2].targetID = "" -- flotilla, formation, marker

        flotilla[1].formation[1].marker[2].structure = {}
        flotilla[1].formation[1].marker[2].structure[1] = {}
        flotilla[1].formation[1].marker[2].structure[1].location = "Bow"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[2].structure[1].fireDirections = {}
        flotilla[1].formation[1].marker[2].structure[1].fireDirections[1] = "North"
        flotilla[1].formation[1].marker[2].structure[1].fireDirections[2] = "West"
        flotilla[1].formation[1].marker[2].structure[1].fireDirections[3] = "South"

        flotilla[1].formation[1].marker[2].structure[2] = {}
        flotilla[1].formation[1].marker[2].structure[2].location = "Starboard"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[2].structure[2].fireDirections = {}
        flotilla[1].formation[1].marker[2].structure[2].fireDirections[1] = "North"
        flotilla[1].formation[1].marker[2].structure[2].fireDirections[2] = "West"
        flotilla[1].formation[1].marker[2].structure[2].fireDirections[3] = "East"

        flotilla[1].formation[1].marker[2].structure[3] = {}
        flotilla[1].formation[1].marker[2].structure[3].location = "Port"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[2].structure[3].fireDirections = {}
        flotilla[1].formation[1].marker[2].structure[3].fireDirections[1] = "East"
        flotilla[1].formation[1].marker[2].structure[3].fireDirections[2] = "West"
        flotilla[1].formation[1].marker[2].structure[3].fireDirections[3] = "South"

        flotilla[1].formation[1].marker[2].structure[4] = {}
        flotilla[1].formation[1].marker[2].structure[4].location = "Astern"        -- location of the structure on the marker
        flotilla[1].formation[1].marker[2].structure[4].fireDirections = {}
        flotilla[1].formation[1].marker[2].structure[4].fireDirections[1] = "North"
        flotilla[1].formation[1].marker[2].structure[4].fireDirections[2] = "East"
        flotilla[1].formation[1].marker[2].structure[4].fireDirections[3] = "South"

        flotilla[1].formation[1].marker[2].structure[1].turret = {}
        flotilla[1].formation[1].marker[2].structure[2].turret = {}
        flotilla[1].formation[1].marker[2].structure[3].turret = {}
        flotilla[1].formation[1].marker[2].structure[4].turret = {}

        for i = 1,3 do
            AddTurret(flotilla[1].formation[1].marker[2].structure[1].turret, 1, 0)
        end
        for i = 1,2 do
            AddTurret(flotilla[1].formation[1].marker[2].structure[2].turret, 1, 0)
        end
        for i = 1,2 do
            AddTurret(flotilla[1].formation[1].marker[2].structure[3].turret, 1, 0)
        end
        for i = 1,5 do
            AddTurret(flotilla[1].formation[1].marker[2].structure[4].turret, 1, 0)
        end

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
