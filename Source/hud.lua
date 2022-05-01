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

function hud.printKeyCommands()

    love.graphics.setFont(font[enum.fontDefault])
    love.graphics.setColor(1,1,1,1)

    local printy = 130
    local lineheight = 20

    if GAME_MODE == enum.gamemodePlanning then
        love.graphics.print("Movement", 20, printy)
        printy = printy + lineheight
        love.graphics.print("========", 20, printy)
        printy = printy + lineheight
        love.graphics.print("Mouse button 1 on flag = select a formation", 20, printy)
        printy = printy + lineheight
        love.graphics.print("kp7/kp9 = aim formation", 20, printy)
        printy = printy + lineheight
        love.graphics.print("kp8 = move formation forward", 20, printy)
        printy = printy + lineheight
        love.graphics.print("backspace = undo 1 step", 20, printy)
        printy = printy + lineheight

        printy = printy + lineheight
        love.graphics.print("Camera", 20, printy)
        printy = printy + lineheight
        love.graphics.print("======", 20, printy)
        printy = printy + lineheight
        love.graphics.print("arrow keys = pan camera", 20, printy)
        printy = printy + lineheight
        love.graphics.print("shift arrow keys = fast pan", 20, printy)
        printy = printy + lineheight
        love.graphics.print("mouse wheel = zoom in/out", 20, printy)
        printy = printy + lineheight

        printy = printy + lineheight
        love.graphics.print("KEYPAD 5 TO PROGRESS TO NEXT PHASE", 20, printy)
        printy = printy + lineheight

    elseif GAME_MODE == enum.gamemodeTargeting then
        love.graphics.print("left button = select a marker to shoot", 20, printy)
        printy = printy + lineheight
        love.graphics.print("right button = select marker to shoot at", 20, printy)
        printy = printy + lineheight

        printy = printy + lineheight
        love.graphics.print("Camera", 20, printy)
        printy = printy + lineheight
        love.graphics.print("======", 20, printy)
        printy = printy + lineheight
        love.graphics.print("arrow keys = pan camera", 20, printy)
        printy = printy + lineheight
        love.graphics.print("shift arrow keys = fast pan", 20, printy)
        printy = printy + lineheight
        love.graphics.print("mouse wheel = zoom in/out", 20, printy)
        printy = printy + lineheight

        printy = printy + lineheight
        love.graphics.print("KEYPAD 5 TO PROGRESS TO NEXT PHASE", 20, printy)
        printy = printy + lineheight
    end

end
return hud
