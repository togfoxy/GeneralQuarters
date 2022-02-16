gstrGameVersion = "0.01"

inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'
fun = require 'functions'
armyalpha = require 'objects.armyalpha'
armybravo = require 'objects.armybravo'

SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
SCREEN_STACK = {}

ZOOMFACTOR = 1
TRANSLATEX = 0
TRANSLATEY = 0

flotilla = {}

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
end

function love.keypressed( key, scancode, isrepeat )
	local translatefactor = 10 * (ZOOMFACTOR * 2)		-- screen moves faster when zoomed in
	if key == "left" then TRANSLATEX = TRANSLATEX + translatefactor end
	if key == "right" then TRANSLATEX = TRANSLATEX - translatefactor end
	if key == "up" then TRANSLATEY = TRANSLATEY + translatefactor end
	if key == "down" then TRANSLATEY = TRANSLATEY - translatefactor end

	if key == "kp8" then
		-- fun.allMarkersAlignTowardsFormation()

		-- fun.allMarkersForwardOnce()
		fun.moveAllMarkers()
	end
	if key == "q" then
		flotilla[1].formation[1].heading = flotilla[1].formation[1].heading - 45
		if flotilla[1].formation[1].heading < 0 then flotilla[1].formation[1].heading = 360 + flotilla[1].formation[1].heading end
	end
	if key == "w" then
		flotilla[1].formation[1].heading = flotilla[1].formation[1].heading - 15
		if flotilla[1].formation[1].heading < 0 then flotilla[1].formation[1].heading = 360 + flotilla[1].formation[1].heading end
	end
	if key == "r" then
		flotilla[1].formation[1].heading = flotilla[1].formation[1].heading + 15
		if flotilla[1].formation[1].heading > 359 then flotilla[1].formation[1].heading = flotilla[1].formation[1].heading - 360 end
	end
	if key == "t" then
		flotilla[1].formation[1].heading = flotilla[1].formation[1].heading + 45
		if flotilla[1].formation[1].heading > 359 then flotilla[1].formation[1].heading = flotilla[1].formation[1].heading - 360 end
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

	--! determine random hour/minute
end


function love.draw()

    res.start()

	love.graphics.scale( ZOOMFACTOR, ZOOMFACTOR )
	love.graphics.translate(TRANSLATEX, TRANSLATEY)

	-- draw every marker

	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mark in pairs(form.marker) do
				local xcentre = (mark.positionX)
				local ycentre = (mark.positionY)
				local heading = (mark.heading)
				local dist = (mark.length)
				local x1, y1 = cf.AddVectorToPoint(xcentre,ycentre,heading, (dist/2))		-- front
				local x2, y2 = cf.AddVectorToPoint(xcentre,ycentre,heading, (dist/2) * -1)	-- rear

				if mark.isFlagship then
					love.graphics.setColor(1, 1, 0, 1)
				else
					love.graphics.setColor(1, 1, 1, 1)
				end
				love.graphics.line(x1,y1,x2,y2)
				love.graphics.circle("fill", x2, y2, 3)
				local txt = mark.sequenceInColumn
				love.graphics.print(txt, x2, y2 - 20)

				-- draw correct position
				if mark.correctX ~= nil then
					-- love.graphics.circle("fill", mark.correctX, mark.correctY, 3)

				end

				-- debugging
				if tempx ~= nil then
					love.graphics.setColor(1, 0, 0, 0.5)
					love.graphics.circle("fill", tempx, tempy, 5)

				end

			end
		end
	end

	-- draw centre of formations
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			local formx, formy = fun.getFormationCentre(form)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.circle("line", formx, formy, 5)
			-- draw line out from circle to show heading of formation
			x1, y1 = formx, formy
			x2, y2 = cf.AddVectorToPoint(x1,y1,form.heading, 8)
			love.graphics.line(x1,y1,x2,y2)

		end
	end


	res.stop()
end


function love.update(dt)

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









	res.update()


end
