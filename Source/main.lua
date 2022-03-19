gstrGameVersion = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'	-- Returns the Camera class.
-- https://notabug.org/pgimeno/cam11

cf = require 'lib.commonfunctions'
enum = require 'enum'
rays = require 'lib.rays'
-- fun = require 'functions'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

ZOOMFACTOR = 1
TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels

-- used to control game flow. Move and Combat modes are opposites and should never be the same
GAME_MODE = enum.gamemodePlanning
TIMER_MOVEMODE = 0	-- used in conjunction with dt to control the game loop speed

image = {}		-- table that holds the images
flotilla = {}

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
end

function love.load()
    if love.filesystem.isFused( ) then
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
        gbolDebug = false
    else
        void = love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT,{fullscreen=false,display=1,resizable=true, borderless=false})	-- display = monitor number (1 or 2)
    end

	res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.window.setTitle("General quarters! " .. gstrGameVersion)
	love.keyboard.setKeyRepeat(true)
	cf.AddScreen("MainMenu", SCREEN_STACK)

    image[enum.markerBattleship] = love.graphics.newImage("assets/ShipBattleshipHull.png")
	image[enum.markerBattleshipGun] = love.graphics.newImage("assets/WeaponBattleshipStandardGun.png")

    cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
end

function love.draw()

    res.start()
	cam:attach()




	cam:detach()
	res.stop()
end

function love.update(dt)

	res.update()	-- put at start of love.update

	cam:setPos(TRANSLATEX, TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)



    assert(GAME_MODE > 0)
	assert(GAME_MODE <= enum.NumGameModes)
end






















--
