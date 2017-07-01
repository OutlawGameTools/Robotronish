-- Automagically Generated using Desperado - http://OutlawGameTools.com
--^Desperado:Asset Name play
local composer = require( "composer" )

local scene = composer.newScene()

local physics = require("physics")
physics.start()
physics.setGravity( 0, 0 )
physics.setDrawMode("normal") -- normal, debug, hybrid

local fin = require("follow")

local ogt = require("ogtlib")

local G = require("globals")

--[[---------------------------------------------------------
	From: https://github.com/garrynewman/garrysmod/blob/ead2b4d7f05681e577935fef657d4a4d962091e6/garrysmod/lua/includes/extensions/math.lua
   Name: Clamp( in, low, high )
   Desc: Clamp value between 2 values
------------------------------------------------------------]]
function math.Clamp( _in, low, high )
	if (_in < low ) then return low end
	if (_in > high ) then return high end
	return _in
end
--^Desperado:Libraries

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- forward references for local functions
local borderHit
local buildLevel
local closeToPatrol
local closeToSniper
local ditchEnemies
local ditchHostages
local enemyHit
local enemyMovement
local fadeIn
local killBullet
local killPlayer
local levelOver
local mainLogic
local makeEnemies
local makeHostages
local makePlayer
local movePlayer
local playerHit
local prnt
local resetStuff
local shootAtPlayer
local shootBullet
local showTitle
local showWinLoseMessage
local shuffleEnemies
local startAction
local startHostagesWandering
local stopAction
local stopHostages
local stopPlayer
local transportPlayer
local updateScore
local wander


-- variables

local playerCollisionFilter = { categoryBits = 1, maskBits = 94 }
local enemyCollisionFilter = { categoryBits = 2, maskBits = 33 }
local sniperAreaCollisionFilter = { categoryBits = 4, maskBits = 1 }
local borderCollisionFilter = { categoryBits = 8, maskBits = 113 }
local hostageCollisionFilter = { categoryBits = 16, maskBits = 9 }
local playerBulletCollisionFilter = { categoryBits = 32, maskBits = 74 }
local enemyBulletCollisionFilter = { categoryBits = 64, maskBits = 41 }

local pSpeed = 3
local xForce = 0
local yForce = 0

-- use the numbers from the table to multiple against the pSpeed to change directions
local xSpeed = {0, 1, 1, 1, 0, 1, 1, 1, 0}
local ySpeed = {1, 1, 0, 1, 1, 1, 0, 1, 1}

local m = {
	abs = math.abs,
	atan = math.atan,
	atan2 = math.atan2,
	ceil = math.ceil,
	cos = math.cos,
	deg = math.deg,
	floor = math.floor,
	pi = math.pi,
	rad = math.rad,
	random = math.random,
	sin = math.sin,
	sqrt = math.sqrt,
	rad2deg = 180/math.pi,
	deg2rad = math.pi/180
}

local MAXBULLETS = 1

centerX = display.contentCenterX
centerY = display.contentCenterY
screenLeft = display.screenOriginX
screenWidth = display.viewableContentWidth - screenLeft * 2
screenRight = screenLeft + screenWidth
screenTop = display.screenOriginY
screenHeight = display.viewableContentHeight - screenTop * 2
screenBottom = screenTop + screenHeight

local mRandom = math.random

local topMargin = 32

local levelTxt

local showMessage
local myCircle
local debugTxt = ""
local scoreTxt
local score = 0

local bumperGrp
local bumpers = {}
local hostages = {}
local enemies = {}
local player

local action = false

local bulletsOnScreen = 0

--== for swipe controls

local bDoingTouch
local mAbs = math.abs
local xDistance
local yDistance
local totalSwipeDistanceLeft
local beginX
local beginY
local minSwipeDistance = 20


--== different enemies

local enemyTypes = {
	{name="soldier", speed=.3, action="follow", weapon=nil, color={1, 0, 0}, score=5},
	{name="soldier", speed=.3, action="follow", weapon=nil, color={1, 0, 0}, score=5},
	{name="sniper", speed=0, action=nil, weapon="rifle", color={1, 0, 0.41}, score=1},
	{name="patrol", speed=.5, action="patrol", weapon=nil, color={1, 0.38, 0.02}, score=3},
	--{name="zapper", speed=0, action=nil, weapon="zaps", color={0.79, 0, 0}, score=1},
}

local sniperShootDelay = 60

local enemiesPerLevel = {5, 8, 12, 17, 23, 30, 38, 48, 58, 68 }
local hostagesPerLevel = {1, 2, 3, 4, 5}
	
local levelEnemies = {
	{	}
}

local numHostages
local numSaved = 0

local gameState = "waiting" -- play, win, lose, pause
--^Desperado:Variables

-- functions
--^Desperado:borderHit
function borderHit(event)

	local obj = event.other
	local border = event.target
	
	--print("border hit by ", obj.objType)
	if obj.objType == "player" then
		timer.performWithDelay(10, transportPlayer, 1)
		
	elseif obj.objType == "bullet" then
		killBullet(obj)
		
	elseif obj.objType == "hostage" then
		local gotoX = obj.x
		local gotoY = obj.y
		transition.cancel ( obj.wanderTrans )
		--local function moveAway()
			if border.which == "top" then
				gotoY = obj.y + 40
			elseif border.which == "bottom" then
				gotoY = obj.y - 40	
			elseif border.which == "left" then
				gotoX = obj.x + 40	
			elseif border.which == "right" then
				gotoX = obj.x - 40		
			end
		--end
		--timer.performWithDelay ( 10, moveAway )
		obj.wanderTrans = transition.to(obj, {delay=15, time=1000+mRandom(1000), x=gotoX, y=gotoY, onComplete=wander})
	
	elseif obj.objType == "enemy" then
	
	end
	
	return true
	
end
--^Desperado:borderHit

--^Desperado:buildLevel
function buildLevel(lvlNum)

	local lvl = lvlNum or G.currLevel
	
	levelTxt.text = "Level: " .. lvl
	
	ditchEnemies()
	ditchHostages()
	
	numHostages = hostagesPerLevel[lvl] or hostagesPerLevel[#hostagesPerLevel]
	makeHostages(numHostages)
	
	local numEnemies = enemiesPerLevel[lvl] or enemiesPerLevel[#enemiesPerLevel]
	makeEnemies(numEnemies)
	
	local startMsg
	local tapBG
	
	local function startNow(event)
		print("inside startNow")
		display.remove( tapBG )
		display.remove( startMsg )
		startAction()
		return true
	end
	
	startMsg = display.newText( scene.view, "Tap to Start", centerX, screenBottom - 50, "Robotron", 48 )
	
	tapBG = display.newRect( scene.view, centerX, centerY, screenWidth, screenHeight )
	tapBG.alpha = .01
	tapBG:addEventListener ( "tap", startNow )
	
end
--^Desperado:buildLevel

--^Desperado:closeToPatrol
function closeToPatrol(event)

	
	--print("Close To Sniper.")
	
	if event.other and event.other.name then
		print("Close To Patrol " .. event.other.name)
	else
		print("Close To Patrol.")	
	end
	
	local hitObj = event.target
	local otherHit = event.other
	
	if event.phase == "began" then
		if hitObj.name == "triggerArea" then
			hitObj.parentObj.action = "follow"
			display.remove(hitObj)
		end
		return true
	elseif event.phase == "ended" then
		if hitObj.name == "triggerArea" then
	
		end
		return true
	end
	
end
--^Desperado:closeToPatrol

--^Desperado:closeToSniper
function closeToSniper(event)

	--print("Close To Sniper.")
	
	if event.other and event.other.name then
		print("Close To Sniper " .. event.other.name)
	else
		print("Close To Sniper.")	
	end
	
	local hitObj = event.target
	local otherHit = event.other
	
	if event.phase == "began" then
		if hitObj.name == "triggerArea" then
			--print("hitObj.parentObj.shoot = true")
			hitObj.parentObj.shoot = true
		end
		return true
	elseif event.phase == "ended" then
		if hitObj.name == "triggerArea" then
			hitObj.parentObj.shoot = false
			hitObj.parentObj.shootTimer = 0 -- shoot immediately when they come back in 
		end
		return true
	end
	
end
--^Desperado:closeToSniper

--^Desperado:ditchEnemies
function ditchEnemies()

	for x = 1, #enemies do
		-- minus points for enemies you don't kill?
		display.remove( enemies[x].triggerArea )
		display.remove( enemies[x] )
	end
	
	enemies = {}
end
--^Desperado:ditchEnemies

--^Desperado:ditchHostages
function ditchHostages()

	for x = 1, #hostages do
		transition.cancel ( hostages[x].wanderTrans )
	end
	
end
--^Desperado:ditchHostages

--^Desperado:enemyHit
function enemyHit(event)

	print("collide", event.target.name, event.other.objType)
	
	if event.phase == "began" then
		local hitObj = event.target
		local otherHit = event.other
		prnt(event.target.objType)
		if otherHit.objType == "bullet" then
			otherHit.usedUp = true
			--timer.performWithDelay(5, function() otherHit.isBodyActive = false end )
			updateScore(hitObj.score * 100)
			ogt.makeDriftingText(hitObj.score * 100, {t=500, x=hitObj.x, y=hitObj.y, yVal=10, fontSize=12})
			local function killTarget() 
				hitObj.alpha=0 
				hitObj.isBodyActive = false
				-- take care of extra stuff for sniper
				--if hitObj.triggerArea then
					display.remove(hitObj.triggerArea)
				--end
				--if not otherHit.isBodyActive then
					--killBullet(otherHit) 
					bulletsOnScreen = bulletsOnScreen - 1
					if bulletsOnScreen < 0 then
						bulletsOnScreen = 0
					end
					display.remove(otherHit)
					display.remove(hitObj)
				--end
			end
			timer.performWithDelay(10, killTarget, 1) -- wait so collision can settle down.
			return true
		elseif otherHit.objType == "player" then
			-- we caught the player!
			updateScore(hitObj.score * 100)
			ogt.makeDriftingText(hitObj.score * 100, {t=500, x=hitObj.x, y=hitObj.y, yVal=10, fontSize=12})
			local function killTarget() 
				hitObj.alpha=0 
				hitObj.isBodyActive = false
				killPlayer() 
			end
			timer.performWithDelay(10, killTarget, 1)
			gameState = "killed"
			levelOver(false)
			return true
		end
	end
	
end
--^Desperado:enemyHit

--^Desperado:enemyMovement
function enemyMovement(onOrOff)

	for x = 1, #enemies do
		--enemies[x].isBodyActive = onOrOff
	end
	
end
--^Desperado:enemyMovement

--^Desperado:fadeIn
function fadeIn(obj)

	local function fadeOut(obj)
		obj.trans = transition.to( obj, {time=500, alpha=.5, transition=easing.inOutExpo, onComplete=fadeIn} )
	end
	obj.trans = transition.to( obj, {time=500, alpha=1, transition=easing.inOutExpo, onComplete=fadeOut} )
end
--^Desperado:fadeIn

--^Desperado:killBullet
function killBullet(obj)

	bulletsOnScreen = bulletsOnScreen - 1
	
	if bulletsOnScreen < 0 then
		bulletsOnScreen = 0
	end
	
	--print("bulletsOnScreen", bulletsOnScreen)
	
	display.remove(obj)
end
--^Desperado:killBullet

--^Desperado:killPlayer
function killPlayer()

	player.alpha = 0
	player.x = centerX
	player.y = centerY
	player:setLinearVelocity(0, 0)
	
end
--^Desperado:killPlayer

--^Desperado:levelOver
function levelOver(won)

	-- pass in true if the level was won, false if lost
	
	Runtime:removeEventListener( "enterFrame", mainLogic )
	
	player.alpha = 0
	enemyMovement(false)
	stopHostages()
	
	showWinLoseMessage(won)
	
	
	
end
--^Desperado:levelOver

--^Desperado:mainLogic
function mainLogic()

	
	--local z = m.atan2 ( (player.y - follower.y), (player.x - follower.x) ) * (m.rad2deg - 90)
	--follower.rotation = (math.atan2(follower.moveY, follower.moveX) * radians)+180;
	    
	if gameState == "play" then
	
		if not player then
			print("NOT PLAYER IN MAINLOGIC")
		end
	
	    for x = 1, #enemies do
	    	if enemies[x].shoot ~= null then
		    	--print(tostring(enemies[x].isBodyActive) .. " " .. enemies[x].name .. " " .. tostring(enemies[x].shoot))
	    	end
	    	if enemies[x].isBodyActive and enemies[x].action == "follow" then
		    	fin.doFollow (enemies[x], player, enemies[x].speed, 1, false, false)
			elseif enemies[x].isBodyActive and enemies[x].action == "patrol" then
				-- patrol enemies walk back and forth in straight lines and turn into soldiers if you get too close
	
			elseif enemies[x].name == "sniper" and enemies[x].shoot then
				--print ("SHOOT")
				if enemies[x].shootTimer <= 0 then
					shootAtPlayer(enemies[x])
					enemies[x].shootTimer = sniperShootDelay;
				else
					enemies[x].shootTimer = enemies[x].shootTimer - 1;
				end
			else
				-- snipers shoot and zappers zap...
	    	end
	    end
	
	elseif gameState == "win" then
		--gameState = "waiting"
		levelOver(true)
	end
	
end
--^Desperado:mainLogic

--^Desperado:makeEnemies
function makeEnemies(numE)

	local numE = numE or 20
	local xPos, yPos
	for x = 1, numE do
		local enemyIdx = mRandom(#enemyTypes)
		local enemyInfo = enemyTypes[enemyIdx]
		local enemy = display.newRect(scene.view, 0, 0, 15, 20)
		physics.addBody(enemy, {filter=enemyCollisionFilter})
		if enemyInfo.name == "sniper" then
			enemy.triggerArea = display.newRect(scene.view, enemy.x, enemy.y, enemy.width, enemy.height)
			enemy.triggerArea.alpha = .1
			physics.addBody(enemy.triggerArea, {radius=200, filter=sniperAreaCollisionFilter})
			enemy.triggerArea.isSensor = true
			enemy.triggerArea.name = "triggerArea"
			enemy.triggerArea.parentObj = enemy
			enemy.triggerArea:addEventListener("collision", closeToSniper)
			enemy.shoot = false
			enemy.shootDelay = 0 -- shoot immediately first time
			enemy.shootTimer = 0
		end
		if enemyInfo.name == "patrol" then
			enemy.triggerArea = display.newRect(scene.view, enemy.x, enemy.y, enemy.width, enemy.height)
			enemy.triggerArea.alpha = .01
			physics.addBody(enemy.triggerArea, {radius=100, filter=sniperAreaCollisionFilter})
			enemy.triggerArea.isSensor = true
			enemy.triggerArea.name = "triggerArea"
			enemy.triggerArea.parentObj = enemy
			enemy.triggerArea:addEventListener("collision", closeToPatrol)
		end
		enemy.isSensor = true
		enemy:setFillColor(enemyInfo.color[1],enemyInfo.color[2],enemyInfo.color[3])
		enemy.objType = "enemy"
		enemy.enemyInfo = enemyInfo
		enemy.name = enemyInfo.name
		enemy.score = enemyInfo.score
		enemy.moveX = enemyInfo.speed
		enemy.moveY = enemyInfo.speed
		enemy.speed = enemyInfo.speed
		enemy.action = enemyInfo.action
		enemies[#enemies+1] = enemy
		enemy:addEventListener("collision", enemyHit)
	end
	shuffleEnemies()
end
--^Desperado:makeEnemies

--^Desperado:makeHostages
function makeHostages(numH)

	local numH = numH or 5
	local xPos, yPos
	for x = 1, numH do
		xPos = mRandom(screenLeft+30, screenWidth-60)
		yPos = mRandom(screenTop+30+topMargin, screenHeight-60-topMargin)
		local hostage = display.newCircle(xPos, yPos, 8)
		physics.addBody(hostage, {filter=hostageCollisionFilter})
		hostage.isSensor = true
		hostage:setFillColor(0, 1, 0)
		hostage.objType = "hostage"
		hostages[#hostages+1] = hostage
		scene.view:insert(hostage)
		--wander(hostages[#hostages])
	end
end
--^Desperado:makeHostages

--^Desperado:makePlayer
function makePlayer()

	player = display.newCircle(centerX, centerY, 10)
	player:setFillColor(1,1,1)
	physics.addBody(player, { density=0, friction=0, bounce=0, filter=playerCollisionFilter })
	player.isSensor = true
	player.objType = "player"
	player.name = "player"
	player.canMove = true
	player:addEventListener("collision", playerHit)
	
	player.numLives = 3
	player.alpha = 0
	
	scene.view:insert(player)
end
--^Desperado:makePlayer

--^Desperado:movePlayer
function movePlayer(dir)

	if not player.canMove then return end
	
	if dir == "left" then
		xForce = -pSpeed
	elseif dir == "right" then
		xForce = pSpeed
	elseif dir == "up" then
		yForce = -pSpeed
	elseif dir == "down" then
		yForce = pSpeed
	end
	player:setLinearVelocity(xForce, yForce)
end
--^Desperado:movePlayer

--^Desperado:playerHit
function playerHit(event)

	if event.phase == "began" then
		local other = event.other
		if other.objType == "hostage" then
			updateScore(1000)
			ogt.makeDriftingText("1000", {t=500, x=other.x, y=other.y, yVal=10, fontSize=16})
			other.alpha = 0
			timer.performWithDelay ( 1, function() display.remove(other) end )
			numSaved = numSaved + 1
			if numSaved == numHostages then
				gameState = "win"
				killPlayer()
			end
			return true
		end
	end
	
end
--^Desperado:playerHit

--^Desperado:prnt
function prnt(msg)

	--debugTxt.text = msg or "..."
end
--^Desperado:prnt

--^Desperado:resetStuff
function resetStuff()

	-- reset stuff
	
	player.numLives = 3
	player.x = centerX
	player.y = centerY
	player:setLinearVelocity(0, 0)
	
	numSaved = 0 -- number of hostages saved on this level
	
end
--^Desperado:resetStuff

--^Desperado:scene:resumeFromScore
function scene:resumeFromScore(event)

	if gameState == "win" then
		G.currLevel = G.currLevel + 1
	end
	
	numSaved = 0
	
	gameState = "waiting"
	buildLevel()
	
	
end
--^Desperado:scene:resumeFromScore

--^Desperado:shootAtPlayer
function shootAtPlayer(obj)

	-- passing in the sniper that's shooting
	
	-- no shooting if we're not in play mode
	if gameState ~= "play" then return true end
		
	local startX, startY = obj.x, obj.y
	local endX, endY = player.x, player.y
	
	-- if enemy just got killed, don't shoot again
	if not startX or not startY then return true end
		
	local bullet = display.newCircle( startX, startY, 4 )
	bullet.objType = "bullet"
	physics.addBody( bullet, {filter = enemyBulletCollisionFilter} )
	bullet:setFillColor(1,1,1)
	bullet.isBullet = true
	bullet.isSensor = true
	bullet.usedUp = false
	--bullet.trans = transition.to(bullet, {time=1000, x=endX, y=endY, onComplete=function() display.remove(bullet) end})
	--bullet:setLinearVelocity( 400, 380 )
	bullet.x = startX
	bullet.y = startY
	scene.view:insert(bullet)
	
	local maxSpeed = 700
	
	local xValAlt = startX - player.x
	local yValAlt = startY - player.y
	
	if ( math.abs(yValAlt) < maxSpeed ) then
	  local factor = maxSpeed / math.abs(yValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	elseif ( math.abs(xValAlt) < maxSpeed ) then
	  local factor = maxSpeed / math.abs(xValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	end
	if ( math.abs(yValAlt) > maxSpeed ) then
	  local factor = maxSpeed / math.abs(yValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	elseif ( math.abs(xValAlt) > maxSpeed ) then
	  local factor = maxSpeed / math.abs(xValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	end
	
	bullet:setLinearVelocity( -xValAlt, -yValAlt )
	
end
--^Desperado:shootAtPlayer

--^Desperado:shootBullet
function shootBullet(event)
print("player should shoot a bullet #1")
	if bulletsOnScreen >= MAXBULLETS then return true end
	print("player should shoot a bullet #2")
	
	-- no shooting if we're not in play mode
	if gameState ~= "play" then return true end
		
	bulletsOnScreen = bulletsOnScreen + 1
		 
	print("player shot a bullet")
	
	local startX, startY = player.x, player.y
	local endX, endY = event.x, event.y
	
	local bullet = display.newCircle( startX, startY, 4 )
	bullet.objType = "bullet"
	physics.addBody( bullet, {filter = playerBulletCollisionFilter} )
	bullet:setFillColor(1,1,1)
	bullet.isBullet = true
	bullet.isSensor = true
	bullet.usedUp = false
	--bullet.trans = transition.to(bullet, {time=1000, x=endX, y=endY, onComplete=function() display.remove(bullet) end})
	--bullet:setLinearVelocity( 400, 380 )
	bullet.x = startX
	bullet.y = startY
	scene.view:insert(bullet)
	
	local maxSpeed = 700
	
	local xValAlt = startX - event.x
	local yValAlt = startY - event.y
	
	if ( math.abs(yValAlt) < maxSpeed ) then
	  local factor = maxSpeed / math.abs(yValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	elseif ( math.abs(xValAlt) < maxSpeed ) then
	  local factor = maxSpeed / math.abs(xValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	end
	if ( math.abs(yValAlt) > maxSpeed ) then
	  local factor = maxSpeed / math.abs(yValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	elseif ( math.abs(xValAlt) > maxSpeed ) then
	  local factor = maxSpeed / math.abs(xValAlt)
	  xValAlt = xValAlt * factor
	  yValAlt = yValAlt * factor
	end
	
	bullet:setLinearVelocity( -xValAlt, -yValAlt )
end
--^Desperado:shootBullet

--^Desperado:showTitle
function showTitle()

	
	local msg = display.newText(scene.view, "Robotronish", screenRight-2, screenTop, "Robotron", 24)
	msg.anchorX = 1
	msg.anchorY = 0
	msg.alpha=1
	msg:setFillColor(0,1,0)
	--transition.to(msg, {time=2003, alpha=1})
	--transition.to(myCircle, {time=1000, y=160})
	
	
	
end
--^Desperado:showTitle

--^Desperado:showWinLoseMessage
function showWinLoseMessage(won)

	composer.showOverlay("score", {isModal=true})
	
end
--^Desperado:showWinLoseMessage

--^Desperado:shuffleEnemies
function shuffleEnemies(enable)

	local buffer = 40
	local makeActive = enable or true
	local pX = centerX
	local pY = centerY
	--if player then
	--	pX = player.x or centerX
	--	pY = player.y or centerY
	--end
	print("pX, pY", pX, pY)
	
	local xPos, yPos
	for idx = 1, #enemies do
		if makeActive then
			enemies[idx].alpha=1
			enemies[idx].isBodyActive = true
		end
		repeat
			xPos = mRandom(screenLeft+30, screenWidth-60)
			yPos = mRandom(screenTop+30+topMargin, screenHeight-60-topMargin)		
		until (xPos < pX-buffer or xPos > pX+buffer) and (yPos < pY-buffer or yPos > pY+buffer)
		enemies[idx].x = xPos
		enemies[idx].y = yPos
		if enemies[idx].triggerArea then
			enemies[idx].triggerArea.x = enemies[idx].x
			enemies[idx].triggerArea.y = enemies[idx].y
		end
	end
end
--^Desperado:shuffleEnemies

--^Desperado:startAction
function startAction()

	
	player.alpha = 1
	player.x = centerX
	player.y = centerY
	
	gameState = "play"
	action = true
	
	startHostagesWandering()
	
	Runtime:addEventListener( "enterFrame", mainLogic )
	
	
end
--^Desperado:startAction

--^Desperado:startHostagesWandering
function startHostagesWandering()

	for x = 1, #hostages do
		wander(hostages[x])
	end
	
end
--^Desperado:startHostagesWandering

--^Desperado:stopAction
function stopAction()

	action = false
	
	Runtime:removeEventListener( "enterFrame", mainLogic )
	
	Runtime:removeEventListener("touch", swipe)
	
	gameState = "wait"
	
end
--^Desperado:stopAction

--^Desperado:stopHostages
function stopHostages()

	for x = 1, #hostages do
		transition.cancel ( hostages[x].wanderTrans )
		display.remove( hostages[x] )
	end
	
	hostages = {}
end
--^Desperado:stopHostages

--^Desperado:stopPlayer
function stopPlayer()

	player:setLinearVelocity(0, 0)
end
--^Desperado:stopPlayer

--^Desperado:swipe
function swipe(event)

	local dir = "none"
	
	if event.phase == "began" then
		bDoingTouch = true
		beginX = event.x
		beginY = event.y
	end
	
	--if event.phase == "moved" then	
	--	if bDoingTouch == true then
	--		endX = event.x
	--		endY = event.y
	--		if mAbs(beginX-endX) > minSwipeDistance or mAbs(beginY-endY) > minSwipeDistance then
	--			xDistance =  endX - beginX
	--			yDistance =  endY - beginY
	--			print("xDistance, yDistance", xDistance, yDistance)
	--			player:setLinearVelocity(xDistance*5, yDistance*5)
	--			bDoingTouch = false
	--		end
	--	end	
	--end
	
	if event.phase == "ended" then
		endX = event.x
		endY = event.y
		local horz = m.abs(beginX-endX)
		local vert = m.abs(beginY-endY)
		-- if not really a swipe, it's a tap.
		if horz < minSwipeDistance and vert < minSwipeDistance then
			-- what about a tap?
			shootBullet(event)
		else
			if mAbs(beginX-endX) > minSwipeDistance or mAbs(beginY-endY) > minSwipeDistance then
				xDistance =  endX - beginX
				yDistance =  endY - beginY
				xDistance = math.Clamp(xDistance, -15, 15)
				yDistance = math.Clamp(yDistance, -15, 15)
				print("xDistance, yDistance", xDistance, yDistance)
				bDoingTouch = false
				local angleBetween = math.ceil(math.atan2( (beginY - endY), (beginX - endX) ) * 180 /  math.pi ) + 90
				if (angleBetween < 0) then
					angleBetween = 360 + angleBetween -- subtracting a negative number
				end
				local aSeg = round(angleBetween/45) + 1 -- so we're 1-based instead of 0
				--player:setLinearVelocity(xDistance*pSpeed , yDistance*pSpeed)
				print("Angle of swipe, angle: " .. angleBetween .. ", " .. round(angleBetween/45))
				print("aSeg: " .. aSeg )
				print("xSpeed, ySpeed: " .. xSpeed[aSeg] .. ", " .. ySpeed[aSeg])
				player:setLinearVelocity(xSpeed[aSeg]*(xDistance*pSpeed), ySpeed[aSeg]*(yDistance*pSpeed) )
			end
		end
		bDoingTouch = false
		--end
	end
end
--^Desperado:swipe

--^Desperado:transportPlayer
function transportPlayer(xPos,  yPos)

	local xPos
	local yPos
	if type(xPos) == "table" then
		xPos = centerX
		yPos = centerY
	else
		xPos = xPos or centerX
		yPos = yPos or centerY
	end
	
	player.isBodyActive = false
	player.canMove = false
	stopPlayer()
	
	local function reactivatePlayer()
		player.canMove = true
		player.isBodyActive = true
	end
	local function showPlayer(obj)
		player.x = xPos
		player.y = yPos
		transition.to(player, {time=200, xScale=1, yScale=1, onComplete=reactivatePlayer})
	end
	transition.to(player, {time=200, xScale=0.01, yScale=0.01, onComplete=showPlayer})
end
--^Desperado:transportPlayer

--^Desperado:updateScore
function updateScore(num)

	score = score + num
	scoreTxt.text = "Score: " .. score
end
--^Desperado:updateScore

--^Desperado:wander
function wander(obj,  minDist,  maxDist,  minSpeed,  maxSpeed)

	if not obj then return end
		
	if obj.wanderTrans then
		transition.cancel ( obj.wanderTrans )
	end
	
	local minDist = minDist or 10
	local maxDist = maxDist or 40
	
	local t = mRandom() * 1000 + 1000
	local gotoX = obj.x
	local gotoY = obj.y
	
	if gameState == "play" then
		if mRandom() > .5 then
			gotoX = gotoX + mRandom(-maxDist, maxDist)
		else
			gotoY = gotoY + mRandom(-maxDist, maxDist)
		end
		obj.wanderTrans = transition.to(obj, {time=t, x=gotoX, y=gotoY, onComplete=wander})
	end
	
end
--^Desperado:wander



-- -------------------------------------------------------------------------------


function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    --^Desperado:create scene

    	
scoreTxt = display.newText("Score: 0", screenLeft + 5, screenTop + 5, "Robotron", 18)
scoreTxt.anchorX = 0
scoreTxt.anchorY = 0
scoreTxt:setFillColor(.5,1,.5)
scene.view:insert(scoreTxt)

levelTxt = display.newText("Level: " .. G.currLevel, centerX-30, screenTop + 5, "Robotron", 18)
levelTxt.anchorY = 0
levelTxt:setFillColor(0,1,0)
scene.view:insert(levelTxt)

local sWidth = 4
bumperGrp = display.newGroup( )

local bumperTop = display.newRect(bumperGrp, centerX, screenTop+topMargin+(sWidth/2), screenWidth, sWidth )
bumperTop:setFillColor(0,0,1)
bumperTop.objType = "bumper"
bumperTop.which = "top"
physics.addBody( bumperTop, "static", {filter=borderCollisionFilter} )
bumperTop:addEventListener("collision", borderHit)
bumpers[#bumpers+1] = bumperTop

local bumperBottom = display.newRect(bumperGrp, centerX, screenBottom-(sWidth/2), screenWidth, sWidth )
bumperBottom:setFillColor(0,0,1)
bumperBottom.objType = "bumper"
bumperBottom.which = "bottom"
physics.addBody( bumperBottom, "static", {filter=borderCollisionFilter} )
bumperBottom:addEventListener("collision", borderHit)
bumpers[#bumpers+1] = bumperBottom

local bumperLeft = display.newRect(bumperGrp, screenLeft+(sWidth/2), centerY+(topMargin/2), sWidth, screenHeight-topMargin )
bumperLeft:setFillColor(0,0,1)
bumperLeft.objType = "bumper"
bumperLeft.which = "left"
physics.addBody( bumperLeft, "static", {filter=borderCollisionFilter} )
bumperLeft:addEventListener("collision", borderHit)
bumpers[#bumpers+1] = bumperLeft

local bumperRight = display.newRect(bumperGrp, screenRight-(sWidth/2), centerY+(topMargin/2), sWidth, screenHeight-topMargin )
bumperRight:setFillColor(0,0,1)
bumperRight.objType = "bumper"
bumperRight.which = "right"
physics.addBody( bumperRight, "static", {filter=borderCollisionFilter} )
bumperRight:addEventListener("collision", borderHit)
bumpers[#bumpers+1] = bumperRight

scene.view:insert(bumperGrp)

local msg = display.newText(scene.view, "Robotronish", screenRight-2, screenTop, "Robotron", 24)
msg.anchorX = 1
msg.anchorY = 0
msg.alpha=1
msg:setFillColor(0,1,0)

buildLevel()

makePlayer()
	--^Desperado:create scene

end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    --^Desperado:show scene

    	
	--^Desperado:show scene

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        
        --^Desperado:will show phase
        --^will show scene
        	
print("will show")

fadeIn(bumperGrp)

	--^Desperado:will show phase

    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.

        --^Desperado:did show phase
        --^did show scene
        	
Runtime:addEventListener("touch", swipe)

	--^Desperado:did show phase

    end
end


function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    --^Desperado:hide scene
    
    	
	--^Desperado:hide scene

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        
        --^Desperado:will hide phase
        --^will hide scene
        	
for x = 1, #bumpers do
	transition.cancel( bumpers[x].trans )
end
	--^Desperado:will hide phase

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.

        --^Desperado:did hide phase
        --^did hide scene
        	
stopAction()
	--^Desperado:did hide phase

    end
end


function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.

    --^Desperado:destroy scene
    	
	--^Desperado:destroy scene
    
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )


-- -------------------------------------------------------------------------------

return scene
