local ocean = {}

local function DrawWater()
    love.graphics.setBackgroundColor( 2/255, 5/255, 71/255, 1 )

end

function ocean.draw()
    -- called during the game loop to draw the ocean

    DrawWater()

end


return ocean
