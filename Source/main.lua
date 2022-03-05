gstrGameVersion = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'	-- Returns the Camera class.
-- https://notabug.org/pgimeno/cam11

cf = require 'lib.commonfunctions'
fun = require 'functions'
armyalpha = require 'objects.armyalpha'
armybravo = require 'objects.armybravo'
enum = require 'enum'
rays = require 'lib.rays'

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

function love.keypressed( key, scancode, isrepeat )
	local translatefactor = 10 * (ZOOMFACTOR * 2)		-- screen moves faster when zoomed in
	if key == "left" then TRANSLATEX = TRANSLATEX - translatefactor end
	if key == "right" then TRANSLATEX = TRANSLATEX + translatefactor end
	if key == "up" then TRANSLATEY = TRANSLATEY - translatefactor end
	if key == "down" then TRANSLATEY = TRANSLATEY + translatefactor end

	if key == "kp5" then
		-- cyle to the next game mode
		GAME_MODE = GAME_MODE + 1
		if GAME_MODE > enum.NumGameModes then
			GAME_MODE = 1
		end

	end

	if key == "kp8" then
		fun.moveAllMarkers()		-- actually only moves the selected formation
	end

	if key == "q" then
		fun.turnSelectedFormation(-45)
	end
	if key == "w" then
		fun.turnSelectedFormation(-15)
	end
	if key == "r" then
		fun.turnSelectedFormation(15)
	end
	if key == "t" then
		fun.turnSelectedFormation(45)
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

function love.mousepressed( x, y, button, istouch )
	local wx,wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	if button == 1 then
		if GAME_MODE == enum.gamemodePlanning then
			-- clear all selections
			fun.unselectAllFormations()

			-- determine formation closest to the mouse click
			local closestformation = fun.getClosestFormation(wx, wy)	-- returns a formation object/table

			-- get the distance between the mouse click and the closest formation
			local formx, formy = fun.getFormationCentre(closestformation)
			local dist = cf.GetDistance(wx, wy, formx, formy)
			if dist <= 25 then
				-- set selection flag for that formation
				closestformation.isSelected = true
			end
		elseif GAME_MODE == enum.gamemodeTargeting then
			-- select the closest marker

			fun.unselectAllSelectedMarkers()
			local closestmarker = fun.getClosestMarker(wx,wy)
			local dist = cf.GetDistance(wx,wy,closestmarker.positionX, closestmarker.positionY)
			if dist <= 25 then
				closestmarker.isSelected = true

				-- ray1.position = {x=wx, y=wy}
				ray1.position = {x=closestmarker.positionX, y=closestmarker.positionY}
			end
		elseif GAME_MODE == enum.gamemodeMoving then

		else
			error("mouse pressed during an unknown game mode")
		end
	elseif button == 2 then
		-- set selected marker as a target
		if GAME_MODE == enum.gamemodeTargeting then
			local selectedMarker = fun.getSelectedMarker()
			if selectedMarker ~= nil then
				-- clear all targets
				fun.unselectAllTargettedMarkers()
				-- determine marker closest to the mouse click
				local closestmarker = fun.getClosestMarker(wx,wy)
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

	-- print(inspect(flotilla))

	for k,flot in pairs(flotilla) do
		-- determine starting locale
		--! determine which of six hex sides to start
		for q,form in pairs(flot.formation) do
			for w,mark in pairs(form.marker) do
				--! determine heading based on hex entry
				--! mark.heading =
			end
		end
	end
	-- load images
    image[enum.markerBattleship] = love.graphics.newImage("assets/ShipBattleshipHull.png")

	cam = Camera.new(960, 540, 1)

	ray1 = rays:new({name = "ray1", color = {0,1,0}})		-- green

	--! determine random hour/minute
end

local function drawEveryMarker()
	-- draw every marker
	local degangle = ""
	local mousetext = ""
	local alphavalue = 1
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do

			if form.isSelected then
				alphavalue = 1
			else
				alphavalue = 0.33
			end

			for w,mark in pairs(form.marker) do
				local xcentre = (mark.positionX)
				local ycentre = (mark.positionY)
				local heading = (mark.heading)
				local headingrad = math.rad(heading)
				local x1,y1,x2,y2 = fun.getMarkerPoints(mark)

				local red,green,blue = 1,1,1

				if mark.isFlagship then
					blue = 0
				end
				if mark.isTarget then
					green = green / 2
					blue = blue / 2
					--alphavalue = 1
				elseif mark.isSelected then
					red = red / 2
					blue = blue / 2

					local mousex, mousey = love.mouse.getPosition()
					local wx,wy = cam:toWorld(mousex, mousey)	-- converts screen x/y to world x/y
					degangle = cf.getBearing(xcentre,ycentre,wx,wy)
					-- degangle is the angle assuming 0 = north.
					-- it needs to be adjusted to be relative to the ship heading
					-- degangle == 0 means directly ahead of the marker
					-- degangle == 90 means directly off starboard

					-- print(degangle, mark.heading)
					degangle = fun.adjustHeading(degangle, mark.heading * -1)

					local mousearc

					-- +/- 15 degree = front of marker (345 -> 15)
					if degangle >= 345 or degangle <= 15 then
						mousearc = "Bow"
					elseif degangle >= 165 and degangle <= 195 then
						mousearc = "Stern"
					elseif degangle > 165 and degangle < 345 then
						mousearc = "Port"
					elseif degangle > 15 and degangle < 165 then
						mousearc = "Starboard"
					else
						error(degangle)
					end

					local gunsdownrange = fun.getGunsInArc(mark, mousearc)
					-- print(gunsdownrange)
					mousetext = "Angle: " .. degangle .. "\nArc: " .. mousearc .. "\nGuns: " .. gunsdownrange

				else
					-- nothing to do
				end
				love.graphics.setColor(red, green, blue, alphavalue)

				-- draw line and circle
				-- love.graphics.line(x1,y1,x2,y2)
				-- love.graphics.circle("fill", x2, y2, 3)

				-- draw centre
				-- love.graphics.circle("fill", xcentre, ycentre, 3)

				-- draw image
				-- the image needs to be shifted left and forward. These next two lines will do that.
				local drawingheading = fun.adjustHeading(heading, -90)
				local drawingcentrex, drawingcentrey = cf.AddVectorToPoint(xcentre,ycentre,drawingheading,4)	-- the centre for drawing purposes is a little to the 'left'
				local drawingcentrex, drawingcentrey = cf.AddVectorToPoint(drawingcentrex, drawingcentrey, heading, 25)	-- this nudges the image forward to align with the centre of the marker
				love.graphics.draw(image[1], drawingcentrex, drawingcentrey, headingrad, 0.23, 0.23)		-- -24 & -15 centres the image and 0.15 scales the image down to 48 pixels

				-- draw correct position
				if mark.correctX ~= nil then
					-- love.graphics.circle("fill", mark.correctX, mark.correctY, 3)
				end

				-- debugging
				-- draw tempx/tempy if that has been set anywhere
				if tempx ~= nil then
					love.graphics.setColor(1, 0, 0, alphavalue)
					love.graphics.circle("fill", tempx, tempy, 5)
				end

			end
		end
	end
end

local function drawEveryStep()
	-- draws future steps that have been planned out
	local red,green,blue = 1,1,1
	local alphavalue = 0.33

	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mark in pairs(form.marker) do
				for e,step in pairs(mark.planningstep) do

	-- print(inspect(step))

					local xcentre = (step.newx)
					local ycentre = (step.newy)
					local heading = (step.newheading)
					local headingrad = math.rad(heading)
					-- the image needs to be shifted left and forward. These next two lines will do that.
					local drawingheading = fun.adjustHeading(heading, -90)
					local drawingcentrex, drawingcentrey = cf.AddVectorToPoint(xcentre,ycentre,drawingheading,4)	-- the centre for drawing purposes is a little to the 'left'

					local drawingcentrex, drawingcentrey = cf.AddVectorToPoint(drawingcentrex, drawingcentrey, heading, 25)	-- this nudges the image forward to align with the centre of the marker

					love.graphics.setColor(red, green, blue, alphavalue)
					love.graphics.draw(image[1], drawingcentrex, drawingcentrey, headingrad, 0.23, 0.23)		-- -24 & -15 centres the image and 0.15 scales the image down to 48 pixels
				end
			end
		end
	end
end

function love.draw()

    res.start()
	cam:attach()

	-- draw game mode
	love.graphics.setColor(1, 1, 1, 1)
	if GAME_MODE == enum.gamemodePlanning then
		love.graphics.print("Planning mode", 100, 100)
	elseif GAME_MODE == enum.gamemodeMoving then
		love.graphics.print("Move mode", 100, 100)
	elseif GAME_MODE == enum.gamemodeTargeting then
		love.graphics.print("Targeting mode", 100, 100)
	else
		error()
	end

	drawEveryMarker()
	if GAME_MODE == enum.gamemodePlanning then
		drawEveryStep()
	end

	-- draw targeting lines between ships
	if GAME_MODE == enum.gamemodeTargeting then
		for k,flot in pairs(flotilla) do
			for q,form in pairs(flot.formation) do
				for w,mark in pairs(form.marker) do
					if mark.targetMarker ~= nil then
						local x1 = mark.positionX
						local y1 = mark.positionY
						local x2 = mark.targetMarker.positionX
						local y2 = mark.targetMarker.positionY
						love.graphics.setColor(1, 0, 0, 0.5)
						love.graphics.line(x1,y1,x2,y2)
					end
				end
			end
		end
	end

	-- draw centre of formations
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			local formx, formy = fun.getFormationCentre(form)
			love.graphics.setColor(1, 1, 1, alphavalue)
			love.graphics.circle("line", formx, formy, 5)
			-- draw line out from circle to show heading of formation
			x1, y1 = formx, formy
			x2, y2 = cf.AddVectorToPoint(x1,y1,form.heading, 8)
			love.graphics.line(x1,y1,x2,y2)
		end
	end

	if mousetext == nil then mousetext = "" end
	ray1:draw(true, mousetext)
	-- ray1:draw(true, "")

	-- -- draw mouse point numbers
	-- local mousex, mousey = love.mouse.getPosition()
	-- local wx,wy = cam:toWorld(mousex, mousey)	-- converts screen x/y to world x/y
	-- love.graphics.print(degangle,wx + 10, wy)


	cam:detach()
	res.stop()
end

function love.update(dt)

	res.update()	-- put at start of love.update

	cam:setPos(TRANSLATEX, TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)

	-- do line-of-sight stuff
	local x, y = love.mouse.getPosition()
	local wx,wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y
	ray1.angle = math.atan2(wy-ray1.position.y, wx-ray1.position.x)
	local lines = {}
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mark in pairs(form.marker) do
				if GAME_MODE == enum.gamemodeTargeting and mark.isSelected then
					-- do nothing
				else
					local x1,y1,x2,y2 = fun.getMarkerPoints(mark)
					local myline = {x1,y1,x2,y2}
					table.insert(lines, myline)
				end
			end
		end
	end
	ray1:update (lines)

	if GAME_MODE == enum.gamemodeMoving then
		TIMER_MOVEMODE = TIMER_MOVEMODE + dt
		if TIMER_MOVEMODE > enum.timerMoveMode then
			TIMER_MOVEMODE = 0
			-- move markers as per planned steps
			for k,flot in pairs(flotilla) do
				for q,form in pairs(flot.formation) do
					for w,mark in pairs(form.marker) do
						if #mark.planningstep > 0 then
							-- move to next step
							mark.positionX = mark.planningstep[1].newx
							mark.positionY = mark.planningstep[1].newy
							mark.heading = mark.planningstep[1].newheading
							table.remove(mark.planningstep, 1)
							movecomplete = false
						end
					end
				end
			end
		end
	end

	assert(GAME_MODE > 0)
	assert(GAME_MODE <= enum.NumGameModes)


end
