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
enum = require "enum"

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

ZOOMFACTOR = 1
TRANSLATEX = 0
TRANSLATEY = 0

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

	elseif button == 2 then
		-- set selected marker as a target

		-- clear all targets
		fun.unselectAllMarkers()
		-- determine marker closest to the mouse click
		local closestmarker = fun.getClosestMarker(wx,wy)
		local dist = cf.GetDistance(wx,wy,closestmarker.positionX, closestmarker.positionY)
		if dist <= 25 then
			closestmarker.isTarget = true
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

	--! determine random hour/minute
end

function love.draw()

	local alphavalue

    res.start()
	cam:attach()

	-- draw every marker
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
				local dist = (mark.length)
				local x1, y1 = cf.AddVectorToPoint(xcentre,ycentre,heading, (dist/2))		-- front
				local x2, y2 = cf.AddVectorToPoint(xcentre,ycentre,heading, (dist/2) * -1)	-- rear

				local red,green,blue = 1,1,1

				if mark.isFlagship then
					blue = 0
				end
				if mark.isTarget then
					green = green / 2
					blue = blue / 2
					--alphavalue = 1
				else

				end
				love.graphics.setColor(red, green, blue, alphavalue)

				-- draw line and circle
				--love.graphics.line(x1,y1,x2,y2)
				--love.graphics.circle("fill", x2, y2, 3)

				-- draw image
				local xoffset, yoffset = 0,0
				love.graphics.draw(image[1], xcentre - xoffset, ycentre - yoffset, headingrad, 0.23, 0.23)		-- -24 & -15 centres the image and 0.23 scales the image down to 48 pixels
				love.graphics.draw(image[1], x1, y1, headingrad, 0.23, 0.23)		-- -24 & -15 centres the image and 0.23 scales the image down to 48 pixels

				-- local txt = mark.sequenceInColumn
				-- love.graphics.print(txt, x2, y2 - 20)

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

	cam:detach()
	res.stop()
end

function love.update(dt)

	res.update()	-- put at start of love.update

	cam:setPos(TRANSLATEX, TRANSLATEY)
	cam:setZoom(ZOOMFACTOR)

	--! army alpha plans moves
	--! army brava plans moves
	--! move all flotilla's
	--! resolve torpedo attacks
	--! army alpha plans combat
	--! army bravo plans combat
	--! simultaneous combat resolution
	--! add 10 minutes to clock
	--! if armyalpha == gone then
		--! armybravo wins
	--! end
	--! if armybravo = gone then
		--! armyalpha wins
	--! end



end
