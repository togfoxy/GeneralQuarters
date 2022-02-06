gstrGameVersion = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'
fun = require 'functions'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

ZOOMFACTOR = 1
TRANSLATEX = 0
TRANSLATEY = 0

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end

end

function love.keypressed( key, scancode, isrepeat )
	local translatefactor = ZOOMFACTOR		-- screen moves faster when zoomed in
	if key == "left" then TRANSLATEX = TRANSLATEX + translatefactor end
	if key == "right" then TRANSLATEX = TRANSLATEX - translatefactor end
	if key == "up" then TRANSLATEY = TRANSLATEY + translatefactor end
	if key == "down" then TRANSLATEY = TRANSLATEY - translatefactor end
end

function love.wheelmoved(x, y)
	if y > 0 then
		-- wheel moved up. Zoom in
		ZOOMFACTOR = ZOOMFACTOR + 0.1
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.1
	end
	if ZOOMFACTOR < 0.1 then ZOOMFACTOR = 0.1 end
end

function love.load()


    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

	res.setGame(1920, 1080)
	love.window.setTitle("General quarters! " .. gstrGameVersion)

	love.keyboard.setKeyRepeat(true)

	cf.AddScreen("Ocean", SCREEN_STACK)

	fun.InitialiseData()

end


function love.draw()

    res.start()

	love.graphics.scale( ZOOMFACTOR, ZOOMFACTOR )
	love.graphics.translate(TRANSLATEX, TRANSLATEY)

	local x = (flotilla[1].formation[1].marker[1].positionX)
	local y = (flotilla[1].formation[1].marker[1].positionY)


	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.circle("fill", x, y, 10)



    res.stop()
end


function love.update(dt)

	res.update()


end
