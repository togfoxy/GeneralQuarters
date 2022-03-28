local ocean = {}

local function DrawWater()
    love.graphics.setBackgroundColor( 46/255, 53/255, 252/255, 1 )
end



function ocean.Draw()
    -- called during the game loop to draw the ocean

    DrawWater()

end


return ocean
