local functions = {}

function functions.LoadImages()
    -- called during love.load() to pre-load images

    image[enum.markerBattleship] = love.graphics.newImage("assets/images/ShipBattleshipHull.png")
	image[enum.markerBattleshipGun] = love.graphics.newImage("assets/images/WeaponBattleshipStandardGun.png")
    image[enum.mainmenu] = love.graphics.newImage("assets/images/HMS_Nelson_during_gunnery_trials.jpg")
end

function functions.LoadFonts()
    font[enum.fontHeavyMetalLarge] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf")
    font[enum.fontHeavyMetalSmall] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf",10)
end

function functions.changeCameraPosition()
    -- determines where the camera should focus on depending on game_mode and phase
    -- input: nothing
    -- output: nothing. OPerators directly on cam object

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

    cam:setPos(camx, camy)
end

return functions
