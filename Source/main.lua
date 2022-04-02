GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'	-- Returns the Camera class.
-- https://notabug.org/pgimeno/cam11

Slab = require 'lib.Slab.Slab'
-- https://github.com/coding-jackalope/Slab/wiki

cf = require 'lib.commonfunctions'
enum = require 'enum'
rays = require 'lib.rays'
menus = require 'menus'
ocean = require 'ocean'
hud = require 'hud'
flot = require 'flotilla'
form = require 'formation'
mark = require 'marker'
qualitycheck = require 'qualitycheck'

fun = require 'functions'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

MAP_CENTRE = 7511	-- the x/y of the centre of the map. X = 7511 and Y = 7511

ZOOMFACTOR = 1
PREFERRED_ZOOM_BRITISH = 1		-- glabals to capture the zoom the camera should return to between modes
PREFERRED_ZOOM_GERMAN = 1
TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels

-- used to control game flow. Move and Combat modes are opposites and should never be the same
GAME_MODE = 0
PLAYER_TURN = 1		-- which player is in control - 1 or 2?
TIMER_MOVEMODE = 0	-- used in conjunction with dt to control the game loop speed

image = {}		-- table that holds the images
flotilla = {}
font = {}		-- table to hold different fonts

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
end

function love.keypressed( key, scancode, isrepeat )

	local translatefactor = 500 * (ZOOMFACTOR * 2)		-- screen moves faster when zoomed in

	local leftpressed = love.keyboard.isDown("left")
	local rightpressed = love.keyboard.isDown("right")
	local uppressed = love.keyboard.isDown("up")
	local downpressed = love.keyboard.isDown("down")
	local shiftpressed = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")	-- either shift key will work

	-- adjust translatex/y based on keypress combinations
	if shiftpressed then translatefactor = translatefactor * 2 end	-- ensure this line is above the lines below
	if leftpressed then TRANSLATEX = TRANSLATEX - translatefactor end
	if rightpressed then TRANSLATEX = TRANSLATEX + translatefactor end
	if uppressed then TRANSLATEY = TRANSLATEY - translatefactor end
	if downpressed then TRANSLATEY = TRANSLATEY + translatefactor end
	if key == "kp5" then
		-- cyle to the next player and then the next game mode
		-- noting that gthe MOVING and COMBAT modes are resolved simultaneously and don't have a player 2 component
		if PLAYER_TURN == 1 then
			if GAME_MODE == enum.gamemodeMoving or GAME_MODE == enum.gamemodeCombat then
				-- changing from Moving/Comnat into planning/targeting for player 1
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
			PLAYER_TURN = 1
		end
		if GAME_MODE > enum.NumGameModes then
			GAME_MODE = 1
		end

		form.unselectAll()
		mark.unselectAll()

		fun.changeCameraPosition()		-- will set TRANSLATEX/TRANSLATEY to the formation position

	end
end

function love.mousepressed( x, y, button, istouch )
	local wx,wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	if button == 1 then
		if GAME_MODE == enum.gamemodePlanning then
			-- clear all formations
			form.unselectAll()

			-- determine formation closest to the mouse click
			local closestformation = form.getClosest(wx, wy)	-- returns a formation object/table

			-- get the distance between the mouse click and the closest formation
			local formx, formy = form.getCentre(closestformation)
			local dist = cf.GetDistance(wx, wy, formx, formy)
			if dist <= 25 then
				-- set selection flag for that formation
				closestformation.isSelected = true
			end
		elseif GAME_MODE == enum.gamemodeTargeting then
			-- select the closest marker
			mark.unselectAll()
			local closestmarker
			if PLAYER_TURN == 1 then
				closestmarker = mark.getClosest(wx,wy, "British")
			else
				closestmarker = mark.getClosest(wx,wy, "German")
			end
			local dist = cf.GetDistance(wx,wy,closestmarker.positionX, closestmarker.positionY)
			if dist <= 25 then
				closestmarker.isSelected = true
				-- ray1.position = {x=closestmarker.positionX, y=closestmarker.positionY}
			end
		elseif GAME_MODE == enum.gamemodeMoving then

		elseif GAME_MODE == enum.gamemodeTargeting then

		elseif GAME_MODE == 0 then 	-- main menu
		else
			error("mouse pressed during an unknown game mode")
		end
	elseif button == 2 then
		-- set selected marker as a target
		if GAME_MODE == enum.gamemodeTargeting then
			local selectedMarker = mark.getSelected()
			if selectedMarker ~= nil then
				-- clear all targets
				mark.unselectAllTargetedMarkers()
				-- determine marker closest to the mouse click
				local closestmarker = mark.getClosest(wx,wy)
				local dist = cf.GetDistance(wx,wy,closestmarker.positionX, closestmarker.positionY)
				if dist <= 25 then
					closestmarker.isTarget = true
					selectedMarker.targetMarker = closestmarker
				end
			end
		end
	else
		error("Unexpected button pressed")
	end
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

	res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.window.setTitle("General quarters! " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)
	cf.AddScreen("MainMenu", SCREEN_STACK)

    fun.LoadImages()
	fun.LoadFonts()

    cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	-- cam:setPos(7960, 7440)	-- puts cam approximately in centre of battle map
	TRANSLATEX = 7960
	TRANSLATEY = 7440

    Slab.Initialize()
end

function love.draw()

    res.start()
	cam:attach()

	local currentscreen = cf.CurrentScreenName(SCREEN_STACK)
    if currentscreen == "MainMenu" then
		love.graphics.setBackgroundColor( 0, 0, 0, 1 )
		menus.DrawMainMenu()
	end
	if currentscreen == "GameLoop" then
		-- menus.DrawMainMenu()
		ocean.draw()
		flot.draw()

		love.graphics.circle("fill", MAP_CENTRE, MAP_CENTRE, 40)
	end

	if currentscreen == "Credits" then
		menus.DrawCredits()
	end


    Slab.Draw()
	cam:detach()

	-- do hud stuff after cam:detach because we don't want that to zoom/scale/pan etc.
	if currentscreen == "GameLoop" then
		hud.printGameMode()	-- ensure this is drawn towards the end so that it draws over other things
	end

	res.stop()
end

function love.update(dt)

	res.update()	-- put at start of love.update

	local strCurrentScreen = cf.CurrentScreenName(SCREEN_STACK)

	if strCurrentScreen == "GameLoop" then
	else

	end

	cam:setPos(TRANSLATEX,	TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)
    Slab.Update(dt)

    assert(GAME_MODE >= 0)
	assert(GAME_MODE <= enum.NumGameModes)
end






















--
