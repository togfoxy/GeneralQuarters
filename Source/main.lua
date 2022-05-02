GAME_VERSION = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'	-- Returns the Camera class.
-- https://notabug.org/pgimeno/cam11

Slab = require 'lib.Slab.Slab'
-- https://github.com/coding-jackalope/Slab/wiki

anim8 = require 'lib.anim8'
-- https://github.com/kikito/anim8

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
quad = {}		-- quads for animations
animation = {}	-- anim8 animations
grid = {}		-- grids are used to load quads for anim8
frames = {}		-- frames within the grid. Used by anim8
flotilla = {}	-- flotilla[x].formation[x].marker[x]
font = {}		-- table to hold different fonts
audio = {}

combataction = {}
combataction[1] = {}		-- Player 1 shooting
combataction[2] = {}		-- Player 2 getting shot/splash
combataction[3] = {}		-- Player 2 shooting
combataction[4] = {}		-- Player 1 getting shot
combataction[5] = {}		-- Player 1 sinking
combataction[6] = {}		-- Player 2 sinking


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

	if key == "kp7" then
		form.changeFacing(-15)
	end

	if key == "kp8" then
		if GAME_MODE == enum.gamemodePlanning then
			mark.addOneStepToFlagship()	-- will add a ghost to flagship of selected formation
		end
	end

	if key == "kp9" then
		form.changeFacing(15)
	end

	if key == "backspace" then
		-- undo
		if GAME_MODE == enum.gamemodePlanning then
			mark.undoOneStepFromFlagship()
		end
	end

	if key == "kp5" then	-- end phase
		-- cyle to the next player and then the next game mode
		-- noting that gthe MOVING and COMBAT modes are resolved simultaneously and don't have a player 2 component

		if (GAME_MODE == enum.gamemodePlanning) or (GAME_MODE == enum.gamemodeTargeting) then
			fun.advanceMode()
		elseif (GAME_MODE == enum.gamemodeCombat)  then	-- disable kp5 if moving/combat is being resolved
			-- can advance mode only if all queues are empty
			if #combataction[1] < 1 and #combataction[2] < 1 and #combataction[3] < 1 and #combataction[4] < 1 and #combataction[5] < 1 and #combataction[6] < 1 then
				fun.advanceMode()
			else
			end
		else
			assert(error)
		end
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
			if dist <= 75 then
				-- set selection flag for that formation
				closestformation.isSelected = true
			end
		elseif GAME_MODE == enum.gamemodeTargeting then
			-- select the closest marker
			local closestmarker
			if PLAYER_TURN == 1 then
				closestmarker = mark.getClosest(wx,wy, "British")
			else
				closestmarker = mark.getClosest(wx,wy, "German")
			end
			local dist = cf.GetDistance(wx,wy,closestmarker.positionX, closestmarker.positionY)
			if dist <= 30 then
				mark.unselectAll()
				closestmarker.isSelected = true
				ray1.position = {x=closestmarker.positionX, y=closestmarker.positionY}
			else
				ray1.position = nil	-- no marker is selected - clear the ray x/y
			end
		elseif GAME_MODE == enum.gamemodeMoving then

		elseif GAME_MODE == enum.gamemodeCombat then

		elseif GAME_MODE == 0 then 	-- main menu
		else
			print("Game mode = ", GAME_MODE)		-- keep this print for debugging
			error("mouse pressed during an unknown game mode")
		end
	elseif button == 2 then
		-- set selected marker as a target
		if GAME_MODE == enum.gamemodeTargeting then
			local selectedMarker = mark.getSelected()
			if selectedMarker ~= nil then
				-- clear all targets
				mark.clearTarget(selectedMarker)
				selectedMarker.gunsDownrange = 0

				-- determine marker closest to the mouse click
				local closestmarker = mark.getClosest(wx,wy)
				local dist = cf.GetDistance(wx,wy,closestmarker.positionX, closestmarker.positionY)

				local selectednation = mark.getNation(selectedMarker)
				local targetnation = mark.getNation(closestmarker)
				if dist <= 30 and (selectednation ~= targetnation) then
					if mark.targetInLoS(wx, wy) then		-- use the current mouse click as parameters
						closestmarker.isTarget = true
						selectedMarker.targetMarker = closestmarker
						local arc = fun.getArc(selectedMarker.positionX, selectedMarker.positionY, selectedMarker.heading, closestmarker.positionX, closestmarker.positionY)    -- returns a string
						selectedMarker.gunsDownrange = mark.getGunsInArc(selectedMarker, arc)	-- object + arc (string)
						selectedMarker.isSelected = false	-- unselecting the shooting marker is a type of positive feedback that the target was selected
					end
				end
			end
		end
	elseif button == 3 then
		-- do nothing
	else
		error("Unexpected button pressed")
	end
end

function love.wheelmoved(x, y)
	if y > 0 then
		-- wheel moved up. Zoom in
		ZOOMFACTOR = ZOOMFACTOR + 0.05
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if ZOOMFACTOR < 0.1 then ZOOMFACTOR = 0.1 end

end



local function drawSinkingAnimation(action)
	local anim = action.animation
	local drawscale = 1
	local drawx = action.positionX
	local drawy = action.positionY

	-- calculate the drawing offset
	local offsetx = 0 -- (62 / 2)
	local offsety = 0 -- (40)

	local heading = action.heading
	local headingrad = math.rad(heading)
	anim:draw(image[enum.sinking], drawx, drawy, headingrad, drawscale, drawscale, offsetx, offsety)
end

local function drawSplashAnimation(action)
	local anim = action.animation
	local drawscale = 3		-- multiple image size by this number
	local drawx = action.positionX
	local drawy = action.positionY

	-- calculate the drawing offset
	local offsetx = (62 / 2)
	local offsety = (40)
	anim:draw(image[enum.splash], drawx, drawy, 0, drawscale, drawscale, offsetx, offsety)
end

local function drawDamageAnimation(action)
	local anim = action.animation
	local drawscale = 8		-- multiple image size by this number
	local drawx = action.positionX
	local drawy = action.positionY

	-- calculate the drawing offset
	local offsetx = (8)
	local offsety = (8)
	anim:draw(image[enum.smokefire], drawx, drawy, 0, drawscale, drawscale, offsetx, offsety)
end

local function drawFlashAnimation(action)
	-- the image needs to be offset towards the target bearing
	local muzzlex, muzzley = cf.AddVectorToPoint(action.positionX, action.positionY, action.targetbearing, 64)		-- x,y,heading, distance

	local rads = math.rad(action.targetbearing)	-- convert the degrees to radians because the draw function uses radians

	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(image[enum.muzzle1], muzzlex, muzzley, rads, 0.5, 0.5)  -- file, x, y, radians, scalex, scaley
end

local function drawActionImages()

    local abort = false     -- controls the moving between phases
	for i = 1, #combataction[1] do
		abort = true
		fun.setCameraPosition("British")

		if combataction[1][i].action == "muzzleflash" then
			if combataction[1][i].timestart <= 0 then	-- don't start this action until it is time to start this action
				drawFlashAnimation(combataction[1][i])
			end
		end
	end
	if abort then return end

	for i = 1, #combataction[2] do
		abort = true
		fun.setCameraPosition("German")

		if combataction[2][i].action == "splashimage" then
			if combataction[2][i].timestart <= 0 then	-- don't start this action until it is time to start this action
				drawSplashAnimation(combataction[2][i])
			end
		end
		if combataction[2][i].action == "damageimage" then
			if combataction[2][i].timestart <= 0 then	-- don't start this action until it is time to start this action
				drawDamageAnimation(combataction[2][i])
			end
		end
	end
	if abort then return end	-- this prevents moving onto the next phase prematurely

	for i = 1, #combataction[3] do
		abort = true
		fun.setCameraPosition("German")

		if combataction[3][i].action == "muzzleflash" then
			if combataction[3][i].timestart <= 0 then	-- don't start this action until it is time to start this action
				drawFlashAnimation(combataction[3][i])
			end
		end
	end
	if abort then return end	-- this prevents moving onto the next phase prematurely

	for i = 1, #combataction[4] do
		abort = true
		fun.setCameraPosition("British")

		if combataction[4][i].action == "splashimage" then
			if combataction[4][i].timestart <= 0 then	-- don't start this action until it is time to start this action
				drawSplashAnimation(combataction[4][i])
			end
		end

		if combataction[4][i].action == "damageimage" then
			if combataction[4][i].timestart <= 0 then	-- don't start this action until it is time to start this action
				drawDamageAnimation(combataction[4][i])
			end
		end
	end
	if abort then return end	-- this prevents moving onto the next phase prematurely

	-- British sinking animations
	for i = 1, #combataction[5] do
		abort = true
		fun.setCameraPosition("British")

		if combataction[5][i].timestart <= 0 then	-- don't start this action until it is time to start this action
			drawSinkingAnimation(combataction[5][i])
		end
	end
	if abort then return end	-- this prevents moving onto the next phase prematurely

	for i = 1, #combataction[6] do
		abort = true
		fun.setCameraPosition("German")

		if combataction[6][i].timestart <= 0 then	-- don't start this action until it is time to start this action
			drawSinkingAnimation(combataction[6][i])
		end
	end
	if abort then return end	-- this prevents moving onto the next phase prematurely
end

local function gameOver()
	local player1gameover = true
	local player2gameover = true

	for q,flot in pairs(flotilla) do
		if flot.nation == "British" then player1gameover = false end
		if flot.nation == "German" then player2gameover = false end
	end
	if player1gameover == true or player2gameover == true then
		return true
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
    love.window.setTitle("General quarters! " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)
	cf.AddScreen("MainMenu", SCREEN_STACK)

    fun.LoadImages()
	fun.LoadFonts()
	fun.LoadAudio()

    cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	-- cam:setPos(7960, 7440)	-- puts cam approximately in centre of battle map
	TRANSLATEX = 7960
	TRANSLATEY = 7440

	ray1 = rays:new({name = "ray1", color = {0,1,0}})		-- green

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
		ocean.draw()
		flot.draw()

		drawActionImages()

		love.graphics.setColor(1,1,1,1)
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
		hud.printKeyCommands()
	end

	if currentscreen == "GameOver" then
		love.graphics.print("Game over. Thanks for playing. Close this program.", 600, 400)
	end
	res.stop()
end

function love.update(dt)

	res.update()	-- put at start of love.update

	local strCurrentScreen = cf.CurrentScreenName(SCREEN_STACK)

	if strCurrentScreen == "GameLoop" then
		if GAME_MODE == enum.gamemodeMoving then
			-- move markers within formations
			GAME_TIMER = GAME_TIMER - dt
			if GAME_TIMER <= 0 then
				local markermoved = mark.moveOneStep()	-- returns FALSE if all moves exhausted
				GAME_TIMER = enum.timerMovingMode
				if not love.filesystem.isFused( ) then      -- to save sanity during debugging
					GAME_TIMER = GAME_TIMER / 2
				end
				if not markermoved then
					fun.advanceMode()		-- all moves exhausted so move to next mode
				end
			end
		elseif GAME_MODE == enum.gamemodeTargeting then
			fun.updateLoSRay()
		elseif GAME_MODE == enum.gamemodeCombat then
			fun.resolveCombat(dt)	-- adds actions to actionqueue[1] and actionqueue[2]
		end

		if gameOver() then
			cf.SwapScreen("GameOver", SCREEN_STACK)
		end
	else

	end

	cam:setPos(TRANSLATEX,	TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)
    Slab.Update(dt)

    assert(GAME_MODE >= 0)
	assert(GAME_MODE <= enum.NumGameModes)
end
