local ocean = {}

local function DrawWater()
    love.graphics.setBackgroundColor( 46/255, 53/255, 252/255, 1 )
end

local function PrintGameMode()
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

    love.graphics.setFont(font[enum.fontHeavyMetal])
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(text, 50, 50)
end

function ocean.Draw()
    -- called during the game loop to draw the ocean

    DrawWater()
    PrintGameMode()


end


return ocean
