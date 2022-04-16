local functions = {}

function functions.LoadImages()
    -- called during love.load() to pre-load images

    image[enum.markerBattleship] = love.graphics.newImage("assets/images/ShipBattleshipHull.png")
	image[enum.markerBattleshipGun] = love.graphics.newImage("assets/images/WeaponBattleshipStandardGun.png")
    image[enum.mainmenu] = love.graphics.newImage("assets/images/HMS_Nelson_during_gunnery_trials.jpg")
    image[enum.britishflag] = love.graphics.newImage("assets/images/British-Navy-Flags_173_F.jpg")
    image[enum.germanflag] = love.graphics.newImage("assets/images/warflag2a.jpg")
end

function functions.LoadFonts()
    font[enum.fontHeavyMetalLarge] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf")
    font[enum.fontHeavyMetalSmall] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf",10)
    font[enum.fontDefault] = love.graphics.newFont("assets/fonts/Vera.ttf", 12)
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

    if thismarker.damageSustained >= thismarker.protectionFactor then
print(thismarker.markerName .. " is sunk!")
        return true

    else
        return false
    end
end

local function removeMarker()

end

local function doActions(que)
    -- cycles through actionqueue and applies animations/actions etc

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

function functions.resolveCombat()
    -- resolves combat by crunching numbers and then adding 'actions' to a queue (table). This is for animations and sounds etc that
    -- will need to be played simultaneously

    local actionqueue = {}  -- a non-specific table to hold actions/animations/sounds
    local actionitem = {}
    local numofbritshooters = getNumberOfShooters("British")     -- count how many markers have a target. Used for timing animations
    local numofgermshooters = getNumberOfShooters("German")

    local britTimeScale = numofbritshooters / 2 -- used to sequeence animations inside this time frame/sequence
    local germTimeScale = britTimeScale + numofgermshooters / 2 -- german sequence happens after british sequence

    -- cycle through every marker in every flotilla and see if that marker has a target
    for k,flot in pairs(flotilla) do
		for q,frm in pairs(flot.formation) do
			for w,mrk in pairs(frm.marker) do
                if mrk.targetMarker ~= nil then
                    local disttomarker = mark.getDistanceToTarget(mrk)  -- used to get meaning sequencing of animations
                    -- add gunfire animation to queue
                    actionitem = {}
                    actionitem.action = "gunfire animation"
                    actionitem.value = mrk
                    table.insert(actionqueue, actionitem)

                    local targetIsHit = determineHitMiss()
                    if not targetIsHit then
                        actionitem = {}
                        actionitem.action = "miss animation"
                        actionitem.value = mrk.targetMarker     -- object
                        table.insert(actionqueue, actionitem)
                    else
                        actionitem = {}
                        actionitem.action = "hit animation"
                        actionitem.value = mrk.targetMarker     -- object
                        table.insert(actionqueue, actionitem)
                        local damageinflicted = getDamageInflicted(mrk.gunsDownrange)
                        mrk.targetMarker.damageSustained = mrk.targetMarker.damageSustained + damageinflicted
    print(mrk.targetMarker.markerName .. " has sustained ".. mrk.targetMarker.damageSustained .. " damage. PF = " .. mrk.targetMarker.protectionFactor)
                        actionitem = {}
                        actionitem.action = "apply damage"
                        actionitem.value = mrk.targetMarker     -- object
                        actionitem.value2 = damageinflicted
                        table.insert(actionqueue, actionitem)

                        local targetIsSunk = willBeSunk(mrk.targetMarker, damageinflicted)
                        if targetIsSunk then
                            removeMarker(mrk.targetMarker)
                            actionitem = {}
                            actionitem.action = "sunk animation"
                            actionitem.value = mrk.targetMarker     -- object
                            table.insert(actionqueue, actionitem)
                        end
                    end
                    mrk.targetMarker = nil
                end
            end
        end
    end
    doActions(actionqueue)     -- apply all the actions stored in the action queue

end

return functions
