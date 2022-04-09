local functions = {}

function functions.LoadImages()
    -- called during love.load() to pre-load images

    image[enum.markerBattleship] = love.graphics.newImage("assets/images/ShipBattleshipHull.png")
	image[enum.markerBattleshipGun] = love.graphics.newImage("assets/images/WeaponBattleshipStandardGun.png")
    image[enum.mainmenu] = love.graphics.newImage("assets/images/HMS_Nelson_during_gunnery_trials.jpg")
    image[enum.britishflag] = love.graphics.newImage("assets/images/British-Navy-Flags_173_F.jpg")
    image[enum.germanflag] = love.graphics.newImage("assets/images/warflag2a.jpg")
end

function functions.LoadFonts()
    font[enum.fontHeavyMetalLarge] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf")
    font[enum.fontHeavyMetalSmall] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf",10)
end

function functions.changeCameraPosition()
    -- determines where the camera should focus on depending on game_mode and phase
    -- input: nothing
    -- output: nothing. Operates directly on TRANSLATEX/TRANSLATEY

    -- get the flotilla position
    local britishx, britishy = flot.getAveragePosition("British")
    local germanx, germany = flot.getAveragePosition("German")

    local camx, camy
    if GAME_MODE == enum.gamemodePlanning then
        if PLAYER_TURN == 1 then
            -- focus on player 1 flotilla
            camx = britishx
            camy = britishy
        else
            -- focus on player 2 flotilla
            camx = germanx
            camy = germany
        end
    elseif GAME_MODE == enum.gamemodeMoving then
        -- zoom out and focus on centre
        camx = MAP_CENTRE
        camy = MAP_CENTRE
    elseif GAME_MODE == enum.gamemodeTargeting then
        if PLAYER_TURN == 1 then
            -- focus on player 1 flotilla
            camx = britishx
            camy = britishy
        else
            -- focus on player 2 flotilla
            camx = germanx
            camy = germany
        end
    elseif GAME_MODE == enum.gamemodeCombat then
        -- zoom out and focus on centre
        camx = MAP_CENTRE
        camy = MAP_CENTRE
    end

    TRANSLATEX = camx
    TRANSLATEY = camy
    cam:setPos(TRANSLATEX, TRANSLATEY)
end

function functions.advanceMode()
    -- advances the phase to the next phase and if necessary, the mode as well
    if PLAYER_TURN == 1 then
        if GAME_MODE == enum.gamemodeMoving or GAME_MODE == enum.gamemodeCombat then
            -- changing from Moving/Combat into planning/targeting for player 1
            GAME_MODE = GAME_MODE + 1
            PLAYER_TURN = 1
            ZOOMFACTOR = PREFERRED_ZOOM_BRITISH
        else
            --moving from planning/targetting for player 1 into planning/targeting for player 2
            PREFERRED_ZOOM_BRITISH = ZOOMFACTOR
            PLAYER_TURN = 2
            ZOOMFACTOR = PREFERRED_ZOOM_GERMAN
        end
    else
        -- moving from planning/targetting for player 2 into moving/combat mode (both players)
        PREFERRED_ZOOM_GERMAN = ZOOMFACTOR
        ZOOMFACTOR = 0.1		-- most zoomed out possible
        GAME_MODE = GAME_MODE + 1
        if GAME_MODE == enum.gamemodeMoving then
            -- add planned steps/ghosts to markers that are not flagships. Applies to all flotilla's
            mark.addOneStepsToMarkers()
            -- prep the timer to move markers during the update loop
            GAME_TIMER = enum.timerMovingMode
        end
        PLAYER_TURN = 1
    end
    if GAME_MODE > enum.NumGameModes then
        GAME_MODE = 1
    end

    form.unselectAll()
    mark.unselectAll()

    fun.changeCameraPosition()		-- will set TRANSLATEX/TRANSLATEY to the formation position
end

return functions
