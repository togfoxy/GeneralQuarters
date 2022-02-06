local functions = {}

function functions.InitialiseData()

    currentHour = 0
    currentMinutes = 0

    maximumSightRangeDay = 10000
    maximumSightRangeNight = 6000



    flotilla = {}
    flotilla[1] = {}
    flotilla[1].nation = "British"

    flotilla[1].formation = {}
    flotilla[1].formation[1] = {}
    flotilla[1].formation[1].numOfColumns = 1
    flotilla[1].formation[1].distanceBetweenColumns = 1
    flotilla[1].formation[1].currentManeuver = "a"
    flotilla[1].formation[1].pivotpointx = 400
    flotilla[1].formation[1].pivotpointy = 400
    -- flotilla[1].formation[1].undoStackX = {}
    -- flotilla[1].formation[1].undoStackY = {}
    -- flotilla[1].formation[1].undoStackX[1] = 300
    -- flotilla[1].formation[1].undoStackY[1] = 300

    flotilla[1].formation[1].marker = {}
    flotilla[1].formation[1].marker[1] = {}

    flotilla[1].formation[1].marker[1].structure = {}
    flotilla[1].formation[1].marker[1].columnNumber = 1
    flotilla[1].formation[1].marker[1].sequenceInColumn = 1
    flotilla[1].formation[1].marker[1].movementFactor = 1
    flotilla[1].formation[1].marker[1].protectionFactor = 1
    flotilla[1].formation[1].marker[1].markerName = "Bismark"
    flotilla[1].formation[1].marker[1].undoPositionX = {}
    flotilla[1].formation[1].marker[1].undoPositionX[1] = 300
    flotilla[1].formation[1].marker[1].undoPositionY = {}
    flotilla[1].formation[1].marker[1].undoPositionY[1] = 300
    flotilla[1].formation[1].marker[1].isSelected = false
    flotilla[1].formation[1].marker[1].isTarget = false
    flotilla[1].formation[1].marker[1].markerType = "BB"
    flotilla[1].formation[1].marker[1].missileFactor = 5
    flotilla[1].formation[1].marker[1].missileCount = 5
    flotilla[1].formation[1].marker[1].initialHeading = 215
    flotilla[1].formation[1].marker[1].topedoHitsSustained = 0
    flotilla[1].formation[1].marker[1].isSunk = false
    flotilla[1].formation[1].marker[1].heading = 108
    flotilla[1].formation[1].marker[1].positionX = 400
    flotilla[1].formation[1].marker[1].positionY = 400
    flotilla[1].formation[1].marker[1].targetID = "111" -- flotilla, formation, marker

    flotilla[1].formation[1].marker[1].structure = {}
    flotilla[1].formation[1].marker[1].structure[1] = {}
    flotilla[1].formation[1].marker[1].structure[1].location = "Bow"        -- location of the structure on the marker
    flotilla[1].formation[1].marker[1].structure[1].fireDirections = {}
    flotilla[1].formation[1].marker[1].structure[1].fireDirections[1] = "North"

    flotilla[1].formation[1].marker[1].structure[1].turret = {}
    flotilla[1].formation[1].marker[1].structure[1].turret[1] = {}
    flotilla[1].formation[1].marker[1].structure[1].turret[1].active = true
    flotilla[1].formation[1].marker[1].structure[1].turret[1].gunfactor = 1
    flotilla[1].formation[1].marker[1].structure[1].turret[1].missileFactor = 2

    missile = {}
    missile[1] = {}
    missile[1].heading = 143
    missile[1].positionX = 350
    missile[1].positionY = 350
    missile[1].targetID = "222" -- flotilla, formation, marker


end








return functions
