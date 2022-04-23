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
flotilla = {}	-- flotilla[x].formation[x].marker[x]
font = {}		-- table to hold different fonts
actionqueue = {}	-- used to store animations etc during combat phase
audio = {}

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

		if GAME_MODE ~= enum.gamemodeMoving then	-- disable kp5 if moving/combat is being resolved
			--! will also need to do same for gamemodeCombat at some point
			fun.advanceMode()
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
		ZOOMFACTOR = ZOOMFACTOR + 0.1
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.1
	end
	if ZOOMFACTOR < 0.1 then ZOOMFACTOR = 0.1 end

	print("Zoom is now " .. ZOOMFACTOR)
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

local function drawMuzzleFlashes()
	-- do all the muzzle flashing display
    for i = 1, #actionqueue do
        if actionqueue[i].action == "muzzleflash" then
			if actionqueue[i].timestart <= 0 then	-- don't start this action until it is time to start this action
	            -- draw muzzle flash

				-- key data is stored in the action queue. Unpack that so clever things can be done
				local shooter = actionqueue[i].marker	-- object
				local target = actionqueue[i].target		-- object

				-- get orientation to target so the flash can be aligned correctly
				local targetbearing = mark.getAbsoluteHeadingToTarget(shooter.positionX, shooter.positionY, target.positionX, target.positionY)

				targetbearing = targetbearing - 90		-- this means '0' is now point to the east (90 degrees to the right)
				if targetbearing < 0 then targetbearing = 360 + targetbearing end

				-- the image needs to be offset towards the target bearing
				local muzzlex, muzzley = cf.AddVectorToPoint(shooter.positionX,shooter.positionY,targetbearing,64)		-- x,y,heading, distance


				local rads = math.rad(targetbearing)	-- convert the degrees to radians because the draw function uses radians

				-- next two lines are for debugging
	            -- love.graphics.setColor(1,1,1,0.5)
				-- love.graphics.draw(image[enum.muzzle1], shooter.positionX,shooter.positionY, rads, 0.5, 0.5)  -- file, x, y, radians, scalex, scaley

				love.graphics.setColor(1,1,1,1)
				love.graphics.draw(image[enum.muzzle1], muzzlex, muzzley, rads, 0.5, 0.5)  -- file, x, y, radians, scalex, scaley
			end
        end
    end
end

local function playAudioActions()

-- print(inspect(actionqueue))

	for i = 1, #actionqueue do
		for i, action in pairs(actionqueue) do
	        if action.action == "gunsound" then
				if action.timestart <= 0 and action.started == false then
					-- play audio
					local newaudio = audio[enum.audiogunfire1]:clone()
					newaudio:play()

					action.started = true
					action.timestop = -1	-- this will 'clean up' this action and remove it later
				end
			end
		end
	end
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

		drawMuzzleFlashes()


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
				if not markermoved then
					fun.advanceMode()		-- all moves exhausted so move to next mode
				end
			end
		elseif GAME_MODE == enum.gamemodeTargeting then
			fun.updateLoSRay()
		elseif GAME_MODE == enum.gamemodeCombat then
			fun.resolveCombat(dt)
			playAudioActions()
		end
	else

	end

	cam:setPos(TRANSLATEX,	TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)
    Slab.Update(dt)

    assert(GAME_MODE >= 0)
	assert(GAME_MODE <= enum.NumGameModes)
end
