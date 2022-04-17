local hud = {}


function hud.printGameMode()
    -- sets the text to be displayed on screen
    -- note has to be upper case because custom font only supports upper case
    local text = ""
    if GAME_MODE == enum.gamemodePlanning then
        text = "PLANNING MODE"
    elseif GAME_MODE == enum.gamemodeMoving then
        text = "MOVING MODE"
    elseif GAME_MODE == enum.gamemodeTargeting then
        text = "TARGETING MODE"
    elseif GAME_MODE == enum.gamemodeCombat then
        text = "COMBAT MODE"
    end

    love.graphics.setFont(font[enum.fontHeavyMetalLarge])
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(text, 50, 50)

    -- draw which player has control
    if GAME_MODE == enum.gamemodeMoving or GAME_MODE == enum.gamemodeCombat then
        text = ""
    else
        if PLAYER_TURN == 1 then
            text = "BRITIAN"
        else
            text = "GERMANY"
        end
    end

    love.graphics.setFont(font[enum.fontHeavyMetalSmall])
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(text, 50, 75)
end
return hud
