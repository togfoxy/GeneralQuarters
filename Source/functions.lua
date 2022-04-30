local functions = {}

function functions.LoadImages()
    -- called during love.load() to pre-load images

    -- static images
    image[enum.markerBattleship] = love.graphics.newImage("assets/images/ShipBattleshipHull.png")
	image[enum.markerBattleshipGun] = love.graphics.newImage("assets/images/WeaponBattleshipStandardGun.png")
    image[enum.mainmenu] = love.graphics.newImage("assets/images/HMS_Nelson_during_gunnery_trials.jpg")
    image[enum.britishflag] = love.graphics.newImage("assets/images/British-Navy-Flags_173_F.jpg")
    image[enum.germanflag] = love.graphics.newImage("assets/images/warflag2a.jpg")
    image[enum.muzzle1] = love.graphics.newImage("assets/images/m_1.png")
    image[enum.muzzle2] = love.graphics.newImage("assets/images/m_2.png")
    image[enum.muzzle3] = love.graphics.newImage("assets/images/m_3.png")
    image[enum.muzzle4] = love.graphics.newImage("assets/images/m_4.png")
    image[enum.muzzle5] = love.graphics.newImage("assets/images/m_6.png")
    image[enum.muzzle6] = love.graphics.newImage("assets/images/m_7.png")
    image[enum.muzzle7] = love.graphics.newImage("assets/images/m_8.png")
    image[enum.muzzle8] = love.graphics.newImage("assets/images/m_9.png")
    image[enum.muzzle9] = love.graphics.newImage("assets/images/m_11.png")

    -- quads for animations
    image[enum.smokefire] = love.graphics.newImage("assets/images/SmokeFireQuads.png")      -- used by anim8
    image[enum.splash] = love.graphics.newImage("assets/images/splash.png")      -- used by anim8
    image[enum.sinking] = love.graphics.newImage("assets/images/ShipBattleshipHullSinkingQuad.png")      -- used by anim8

    -- animations
    grid[enum.smokefire] = anim8.newGrid(16, 16, 64, 64)             -- specify the whole quad. tiles size and image size
    frames[enum.smokefire] = grid[enum.smokefire]:getFrames(1,3,2,3,3,3,4,3,1,4,2,4,3,4,4,4)   -- each pair is col/row within the quad/grid

    grid[enum.splash] = anim8.newGrid(62,33,image[enum.splash]:getWidth(), image[enum.splash]:getHeight())    -- tile width, height, image width, height
    frames[enum.splash] = grid[enum.splash]:getFrames(1,1,2,1,3,1,4,1,1,2,2,2,3,2,4,2)   -- col/row pairs

    grid[enum.sinking] = anim8.newGrid(31, 209, image[enum.sinking]:getWidth(), image[enum.sinking]:getHeight())
    frames[enum.sinking] = grid[enum.sinking]:getFrames(1,1,2,1,3,1,4,1,5,1,6,1,7,1,8,1,9,1,9,1,9,1)   -- col/row pairs

end

function functions.LoadFonts()
    font[enum.fontHeavyMetalLarge] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf")
    font[enum.fontHeavyMetalSmall] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf",10)
    font[enum.fontDefault] = love.graphics.newFont("assets/fonts/Vera.ttf", 12)
end

function functions.LoadAudio()
    audio[enum.audiogunfire1] = love.audio.newSource("assets/audio/cannon_fire.ogg", "static")
    audio[enum.audiosplash1] = love.audio.newSource("assets/audio/splash1.ogg", "static")
    audio[enum.audiodamage1] = love.audio.newSource("assets/audio/cannon_hit.ogg", "static")
end

function functions.changeCameraPosition()
    -- determines where the camera should focus on depending on game_mode and phase
    -- input: nothing
    -- output: nothing. Operates directly on TRANSLATEX/TRANSLATEY

    -- get the flotilla position
    local britishx, britishy = flot.getAveragePosition("British")
    local germanx, germany = flot.getAveragePosition("German")

    local camx, camy
    if GAME_MODE == enum.gamemodePlanning then
        if PLAYER_TURN == 1 then
            -- focus on player 1 flotilla
            camx = britishx
            camy = britishy
        else
            -- focus on player 2 flotilla
            camx = germanx
            camy = germany
        end
    elseif GAME_MODE == enum.gamemodeMoving then
        -- zoom out and focus on centre
        camx = (britishx + germanx) / 2
        camy = (britishy + germany) / 2

    elseif GAME_MODE == enum.gamemodeTargeting then
        if PLAYER_TURN == 1 then
            -- focus on player 1 flotilla
            camx = britishx
            camy = britishy
        else
            -- focus on player 2 flotilla
            camx = germanx
            camy = germany
        end
    elseif GAME_MODE == enum.gamemodeCombat then
        -- zoom out and focus on centre
        camx = MAP_CENTRE
        camy = MAP_CENTRE
    end

    TRANSLATEX = camx
    TRANSLATEY = camy
    cam:setPos(TRANSLATEX, TRANSLATEY)
end

function functions.setCameraPosition(nation)
    -- moves the camera to the provded nation
    -- similar to changeCameraPosition but this lets you determine the nation
    TRANSLATEX, TRANSLATEY = flot.getAveragePosition(nation)
    cam:setPos(TRANSLATEX, TRANSLATEY)
    ZOOMFACTOR = 0.5
end

local function cleanUpAfterCombat()
    -- resets the damage taken this turn. Should be called after each combat phase
    -- clears targets
    for k,flot in pairs(flotilla) do
		for q,frm in pairs(flot.formation) do
			for w,mrk in pairs(frm.marker) do
                mrk.damageSustained = 0
                mrk.targetMarker = nil
                mrk.isTarget = nil
            end
        end
    end
end

function functions.advanceMode()
    -- advances the phase to the next phase and if necessary, the mode as well
    if PLAYER_TURN == 1 then
        if GAME_MODE == enum.gamemodeMoving or GAME_MODE == enum.gamemodeCombat then
            -- changing from Moving/Combat into planning/targeting for player 1
            cleanUpAfterCombat()      -- removes the 'damage taken this turn' tracker
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
        if GAME_MODE == enum.gamemodeMoving then
            -- add planned steps/ghosts to markers that are not flagships. Applies to all flotilla's
            mark.addOneStepsToMarkers()
            -- prep the timer to move markers during the update loop
            GAME_TIMER = enum.timerMovingMode
            if not love.filesystem.isFused( ) then      -- to save sanity during debugging
                GAME_TIMER = GAME_TIMER / 2
            end
        end
        PLAYER_TURN = 1
    end
    if GAME_MODE > enum.NumGameModes then
        GAME_MODE = 1
    end

    form.unselectAll()
    mark.unselectAll()

    ray1.position = nil	-- no marker is selected - clear the ray x/y

    fun.changeCameraPosition()		-- will set TRANSLATEX/TRANSLATEY to the formation position
end

function functions.updateLoSRay()
    -- cylce through every marker in every flotilla, determine the 'line' each marker creates from bow to stern, then add that to the 'lines' table
    -- send that lines table to ray1:update so the ray can correctly detect collisions

    local lines = {}
	for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mrk in pairs(form.marker) do
				if GAME_MODE == enum.gamemodeTargeting and mrk.isSelected then
                    if ray1.position ~= nil then
                        local x, y = love.mouse.getPosition()
                    	local wx,wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y
                    	ray1.angle = math.atan2(wy-ray1.position.y, wx-ray1.position.x)
                    end
				else
					local x1,y1,x2,y2 = mark.getMarkerPoints(mrk)
					local myline = {x1,y1,x2,y2}
					table.insert(lines, myline)
				end
			end
		end
	end

    if ray1.position ~= nil then    -- position will be nill if a marker is not selected
        ray1:update (lines)    -- ray1 is a global set in love.load()
    end
end

local function determineHitMiss()
    -- turns out that there is no such thing as hit/miss!
    return true
end

local function getDamageInflicted(gf)
    -- looks up table for rndom number and gunfactor. Lower rndnum is better
    -- input: gunfactor or gunsDownrange
    -- output: integer for damage inflicted
    local hittable = {}
    hittable[1] = {1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,5}
    hittable[2] = {1,1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4}
    hittable[3] = {0,0,0,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4}
    hittable[4] = {0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4}
    hittable[5] = {0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3}

    local rndnum = love.math.random(1, 5)
    local result = hittable[rndnum][gf]
    return result
end

local function willBeSunk(thismarker)
    -- a marker is sunk if the damage sustained in one combat turn >= that marker's protectionFactor
    -- input: marker object
    -- output: yes/no boolean

    -- if thismarker.damageSustained >  0 then print(thismarker.damageSustained .. " / " .. thismarker.protectionFactor) end

    if thismarker.damageSustained >= thismarker.protectionFactor / 2 then
        return true
    else
        return false
    end
end

local function removeMarker(thismarker)
    --!move to the marker module
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
            for i = 1, #form.marker do
                if form.marker[i] == thismarker then
                    -- delete marker
                    table.remove(form.marker, i)
                end
            end
        end
    end

    --! if flagship is sunk then need to determine new flagship
end

local function getNumberOfShooters(nation)
    -- determine how many markers will shoot. Used for animations and timing
    -- input: nation. String
    -- output: integer
    local result = 0
    for k,flot in pairs(flotilla) do
        if flot.nation == nation then
    		for q,frm in pairs(flot.formation) do
    			for w,mrk in pairs(frm.marker) do
                    if mrk.targetMarker ~= nil then
                        result = result + 1
                    end
                end
            end
        end
    end
    return result
end

function functions.getArc(x1, y1, heading, x2, y2)
    -- gets the arc or quadrant x2/y2 is relative to x1/y1
    -- input: x1,y1,heading of first point.
    -- input: x2,y2 of second point (heading irrelevant)
    -- output: string.
    local result
    degangle = cf.getBearing(x1,y1,x2,y2)
    -- degangle is the angle assuming 0 = north.
    -- it needs to be adjusted to be relative to the ship heading
    -- degangle == 0 means directly ahead of the marker
    -- degangle == 90 means directly off starboard
    degangle = cf.adjustHeading(degangle, heading * -1)
    -- +/- 15 degree = front of marker (345 -> 15)
    if degangle >= 345 or degangle <= 15 then
        result = "Bow"
    elseif degangle >= 165 and degangle <= 195 then
        result = "Stern"
    elseif degangle > 165 and degangle < 345 then
        result = "Port"
    elseif degangle > 15 and degangle < 165 then
        result = "Starboard"
    else
        error(degangle)
    end
    return result
end

local function determineShootingAnimations(nation)
    for k,flt in pairs(flotilla) do
        if flt.nation == nation then
    		for q,frm in pairs(flt.formation) do
    			for w,mrk in pairs(frm.marker) do
                    if mrk.targetMarker ~= nil then
                        local queue = {}        -- a temporary pointer to the queue for this nation
                        local otherqueue = {}   -- a temporary pointer to the queue for the other nation
                        if nation == "British" then
                            queue = actionqueue[1]
                            otherqueue = actionqueue[2]
                        elseif nation == "German" then
                            queue = actionqueue[2]
                            otherqueue = actionqueue[1]
                        else
                            error()
                        end

                        local timestart = love.math.random(0, 10) / 10   -- start the muzzle flash at a random time
                        local timestop = timestart + 1
                        actionitem = {}
                        actionitem.action = "muzzleflash"
                        actionitem.marker = mrk
                        actionitem.target = mrk.targetMarker        -- capture this here before it is deleted down below
                        actionitem.timestart = timestart
                        actionitem.timestop = timestop
                        actionitem.started = false
                        table.insert(queue, actionitem)

                        actionitem = {}
                        actionitem.action = "gunsound"
                        actionitem.timestart = timestart
                        actionitem.timestop = timestop    -- timestop is a required attribute but has no meaning for audio
                        actionitem.started = false
                        table.insert(queue, actionitem)

                        local damageinflicted = getDamageInflicted(mrk.gunsDownrange)
                        mrk.targetMarker.damageSustained = mrk.targetMarker.damageSustained + damageinflicted

                        timestart = timestart + 1.5 + (love.math.random(0, 10) / 10)
                        timestop = timestart + 1

                        actionitem = {}
                        if damageinflicted <= 0 then
                            actionitem.action = "splashsound"
                        else
                            actionitem.action = "damagesound"
                        end
                        actionitem.marker = mrk
                        actionitem.target = mrk.targetMarker
                        actionitem.timestart = timestart
                        actionitem.timestop = timestop
                        actionitem.started = false
                        table.insert(otherqueue, actionitem)

                        actionitem = {}
                        if damageinflicted <= 0 then
                            actionitem.action = "splashimage"
                            local newanim = anim8.newAnimation(frames[enum.splash], 0.1)
                            actionitem.animation = newanim
                        else
                            actionitem.action = "damageimage"
                            local newanim = anim8.newAnimation(frames[enum.smokefire], 0.1)        -- frames is the variable above and duration
                            actionitem.animation = newanim                          -- create the animation and put it into the action queue
                        end
                        actionitem.marker = mrk
                        actionitem.target = mrk.targetMarker
                        actionitem.timestart = timestart
                        actionitem.timestop = timestop
                        actionitem.started = false
                        table.insert(otherqueue, actionitem)

                        mrk.targetMarker = nil  -- erase this so the shooting is calculated just once
                    end
                end
            end
        end
    end
end

function functions.resolveCombat(dt)
    -- called during love.update()

    -- determine all the sounds, images and animations that need to be queued up
    determineShootingAnimations("British")   -- 2nd parameter describes the EARLIEST timeframe to do animations
    determineShootingAnimations("German")

    -- each queued item has a time that needs to run down
    -- the timer for each image/animtation/sound is stored in the action queue
    if #actionqueue[1] > 0 then     -- process the britsh queue OR the german queue but not both at the same time
        for k,action in pairs(actionqueue[1]) do
            action.timestart = action.timestart - dt
            action.timestop = action.timestop - dt

            if action.action == "damageimage" or action.action == "splashimage" or action.action == "sinkingimage" then
                -- advance animation
                action.animation:update(dt)
            end

            if action.timestop <= 0 then
               
    print(action.timestop)
                if action.action == "sinkingimage" then
                    -- destroy marker
    print(action.marker.markerName .. " is destroyed")
                    removeMarker(action.marker)
                end
                table.remove(actionqueue[1], k)
            end
        end
    else
        for k,action in pairs(actionqueue[2]) do
            action.timestart = action.timestart - dt
            action.timestop = action.timestop - dt

            if action.action == "damageimage" or action.action == "splashimage" or action.action == "sinkingimage" then
                -- advance animation
                action.animation:update(dt)
            end

            if action.timestop <= 0 then
                if action.action == "sinkingimage" then
                    -- destroy marker
                    removeMarker(action.marker)
                end
                table.remove(actionqueue[2], k)
            end
        end
    end

    -- check for sinkages
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mrk in pairs(form.marker) do
                if willBeSunk(mrk) then
                    print(mrk.markerName .. "is sunk")
                    --!
                    actionitem = {}
                    actionitem.action = "sinkingimage"
                    local newanim = anim8.newAnimation(frames[enum.sinking], 0.1, "pauseAtEnd")        -- frames is the variable above and duration
                    actionitem.animation = newanim
                    actionitem.marker = mrk
                    actionitem.target = nil
                    actionitem.timestart = 3 + (love.math.random(0, 20) / 10)
                    actionitem.timestop = actionitem.timestart + 3
                    actionitem.started = false

                    -- add the sinking animation to the correct action queue
                    if mark.getNation(mrk) == "British" then
                        table.insert(actionqueue[1], actionitem)
                    else
                        table.insert(actionqueue[2], actionitem)
                    end

                    mrk.damageSustained = 0 -- stops the animation playing multiple times
                end
            end
        end
    end
end

return functions
