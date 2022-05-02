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
        -- position between the two formations
        camx = (britishx + germanx) / 2
        camy = (britishy + germany) / 2

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
    combataction[1] = {}
    combataction[2] = {}
    combataction[3] = {}
    combataction[4] = {}
    combataction[5] = {}
    combataction[6] = {}
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

    --! remove the / 2
    if thismarker.damageSustained >= thismarker.protectionFactor / 2 then
        return true
    else
        return false
    end
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

local function determineAllActions(dt)

    -- combataction = {}
    -- combataction[1] = {}		-- Player 1 shooting
    -- combataction[2] = {}		-- Player 2 getting shot/splash
    -- combataction[3] = {}		-- Player 2 shooting
    -- combataction[4] = {}		-- Player 1 getting shot
    -- combataction[5] = {}		-- Player 1 sinking
    -- combataction[6] = {}		-- Player 2 sinking

    for k,flt in pairs(flotilla) do
		for q,frm in pairs(flt.formation) do
			for w,mrk in pairs(frm.marker) do
                if mrk.targetMarker ~= nil then
                    local shooter = mrk                 -- shooting marker
                    local target = mrk.targetMarker     -- target marker
                    local playerqueue = {}

                    local nation = mark.getNation(mrk)

                    local actionitem = {}
                    local timestart = love.math.random(0, 10) / 10   -- start the muzzle flash at a random time
                    local timestop = timestart + 1
                    actionitem.action = "muzzleflash"
                    actionitem.timestart = timestart
                    actionitem.timestop = timestop
                    actionitem.positionX = shooter.positionX
                    actionitem.positionY = shooter.positionY
                    actionitem.targetbearing = mark.getAbsoluteHeadingToTarget(shooter.positionX, shooter.positionY, target.positionX, target.positionY)
					actionitem.targetbearing = actionitem.targetbearing - 90		-- this now means '0' is now point to the north (90 degrees to the right)
					if actionitem.targetbearing < 0 then actionitem.targetbearing = 360 + actionitem.targetbearing end

                    if nation == "British" then
                        playerqueue = combataction[1]
                    else
                        playerqueue = combataction[3]
                    end
                    table.insert(playerqueue, actionitem)

                    actionitem = {}
                    actionitem.action = "gunsound"
                    actionitem.timestart = timestart
                    actionitem.timestop = timestop    -- timestop is a required attribute but has no meaning for audio
                    actionitem.started = false
                    if nation == "British" then
                        playerqueue = combataction[1]
                    else
                        playerqueue = combataction[3]
                    end
                    table.insert(playerqueue, actionitem)

                    -- after adding muzzle flash and gun sound, determine damage
                    local damageinflicted = getDamageInflicted(shooter.gunsDownrange)
                    target.damageSustained = target.damageSustained + damageinflicted

                    -- target animations. Put the animation right inside the table for later playback
                    local timestart = 0.5 + love.math.random(0, 10) / 10   -- start this action at a random time
                    local timestop = timestart + 1

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
                    actionitem.timestart = timestart
                    actionitem.timestop = timestop
                    actionitem.started = false
                    actionitem.positionX = target.positionX
                    actionitem.positionY = target.positionY
                    if nation == "British" then
                        playerqueue = combataction[2]
                    else
                        playerqueue = combataction[4]
                    end
                    table.insert(playerqueue, actionitem)

                    -- queue damage audio or splash audio
                    actionitem = {}
                    actionitem.timestart = timestart
                    actionitem.timestop = timestop    -- timestop is a required attribute but has no meaning for audio
                    actionitem.started = false
                    if damageinflicted <= 0 then
                        actionitem.action = "splashsound"
                    else
                        actionitem.action = "damagesound"
                    end
                    if nation == "British" then
                        playerqueue = combataction[2]
                    else
                        playerqueue = combataction[4]
                    end
                    table.insert(playerqueue, actionitem)

                    mrk.targetMarker = nil  -- erase this so the shooting is calculated just once
                end
            end
        end
    end
end

local function playAudioFile(audioObject, action)
	-- play audio
	local newaudio = audioObject:clone()
	newaudio:play()

	action.started = true
	action.timestop = -1	-- this will 'clean up' this action and remove it later
end

local function playSounds()
    -- play any sounds that are queued

    local abort = false     -- controls the moving between phases

    if #combataction[1] > 0 then
        abort = true
        for i = 1, #combataction[1] do
            -- play gunshots if any are queued

            if combataction[1][i].action == "gunsound" then
    			if combataction[1][i].timestart <= 0 and combataction[1][i].started == false then
                    playAudioFile(audio[enum.audiogunfire1], combataction[1][i])
    			end
            end
        end
    end
    if abort then return end

    if #combataction[2] > 0 then
        abort = true
        for i = 1, #combataction[2] do
            -- play gunshots if any are queued

            if combataction[2][i].action == "splashsound" then
                if combataction[2][i].timestart <= 0 and combataction[2][i].started == false then
                    playAudioFile(audio[enum.audiosplash1], combataction[2][i])
                end
            end
        end
        for i = 1, #combataction[2] do
            -- play gunshots if any are queued

            if combataction[2][i].action == "damagesound" then
                if combataction[2][i].timestart <= 0 and combataction[2][i].started == false then
                    playAudioFile(audio[enum.audiodamage1], combataction[2][i])
                end
            end
        end
    end
    if abort then return end

    if #combataction[3] > 0 then
        abort = true
        for i = 1, #combataction[3] do
            -- play gunshots if any are queued

            if combataction[3][i].action == "gunsound" then
                if combataction[3][i].timestart <= 0 and combataction[3][i].started == false then
                    playAudioFile(audio[enum.audiogunfire1], combataction[3][i])
                end
            end
        end
    end
    if abort then return end

    if #combataction[4] > 0 then
        abort = true
        for i = 1, #combataction[4] do
            -- play gunshots if any are queued

            if combataction[4][i].action == "splashsound" then
                if combataction[4][i].timestart <= 0 and combataction[4][i].started == false then
                    playAudioFile(audio[enum.audiosplash1], combataction[4][i])
                end
            end
        end
        for i = 1, #combataction[4] do
            -- play gunshots if any are queued

            if combataction[4][i].action == "damagesound" then
                if combataction[4][i].timestart <= 0 and combataction[4][i].started == false then
                    playAudioFile(audio[enum.audiodamage1], combataction[4][i])
                end
            end
        end
    end
    if abort then return end
end

local function updateActionTimer(action, dt)
	action.timestart = action.timestart - dt
	action.timestop = action.timestop - dt
	if action.animation ~= nil then action.animation:update(dt) end
end

function functions.resolveCombat(dt)
    -- called during love.update()
    -- determine all the sounds, images and animations that need to be queued up

    determineAllActions(dt)

    playSounds()

    -- check for sinkages
    for k,flot in pairs(flotilla) do
		for q,form in pairs(flot.formation) do
			for w,mrk in pairs(form.marker) do
                if willBeSunk(mrk) then
                    actionitem = {}
                    actionitem.action = "sinkingimage"
                    local newanim = anim8.newAnimation(frames[enum.sinking], 0.1, "pauseAtEnd")        -- frames is the variable above and duration
                    actionitem.animation = newanim
                    actionitem.timestart = (love.math.random(0, 20) / 10)
                    actionitem.timestop = actionitem.timestart + 3
                    actionitem.started = false
                    actionitem.positionX = mrk.positionX
                    actionitem.positionY = mrk.positionY
                    actionitem.heading = mrk.heading
                    actionitem.marker = mrk

                    -- add the sinking animation to the correct action queue
                    if mark.getNation(mrk) == "British" then
                        table.insert(combataction[5], actionitem)
                    else
                        table.insert(combataction[6], actionitem)
                    end

                    mrk.damageSustained = 0 -- stops the animation playing multiple times
                end
            end
        end
    end

    -- each queued item has a time that needs to run down
    -- the timer for each image/animtation/sound is stored in the action queue
    local abort = false     -- controls the flow between phases
    for i = #combataction[1], 1, -1 do
        abort = true
        updateActionTimer(combataction[1][i], dt)
        if combataction[1][i].timestop <= 0 then
            table.remove(combataction[1], i)
        end
    end

    if not abort then
        for i = #combataction[2], 1, -1 do
            abort = true
            updateActionTimer(combataction[2][i], dt)
            if combataction[2][i].timestop <= 0 then
                table.remove(combataction[2], i)
            end
        end
    end

    if not abort then
        for i = #combataction[3], 1, -1 do
            abort = true
            updateActionTimer(combataction[3][i], dt)
            if combataction[3][i].timestop <= 0 then
                table.remove(combataction[3], i)
            end
        end
    end

    if not abort then
        for i = #combataction[4], 1, -1 do
            abort = true
            updateActionTimer(combataction[4][i], dt)
            if combataction[4][i].timestop <= 0 then
                table.remove(combataction[4], i)
            end
        end
    end
    if not abort then
        for i = #combataction[5], 1, -1 do
            abort = true
            combataction[5][i].timestart = combataction[5][i].timestart - dt
            combataction[5][i].timestop = combataction[5][i].timestop - dt

            if combataction[5][i].action == "sinkingimage" and combataction[5][i].timestart <= 0 then
                combataction[5][i].marker.drawImage = false

                if combataction[5][i].animation ~= nil then combataction[5][i].animation:update(dt) end
            end

            if combataction[5][i].timestop <= 0 then
                if combataction[5][i].marker ~= nil then
                    mark.remove(combataction[5][i].marker)      -- destroy the marker when the animation stops
                end
                table.remove(combataction[5], i)
            end
        end
    end
    if not abort then
        for i = #combataction[6], 1, -1 do
            abort = true
            combataction[6][i].timestart = combataction[6][i].timestart - dt
            combataction[6][i].timestop = combataction[6][i].timestop - dt

            if combataction[6][i].action == "sinkingimage" and combataction[6][i].timestart <= 0 then
                combataction[6][i].marker.drawImage = false

                if combataction[6][i].animation ~= nil then combataction[6][i].animation:update(dt) end
            end

            if combataction[6][i].timestop <= 0 then
                if combataction[6][i].marker ~= nil then
                    mark.remove(combataction[6][i].marker)     -- destroy the marker when the animation stops
                end
                table.remove(combataction[6], i)
            end
        end
    end
end

return functions
