require("Soldier")

local sideSoldiers 		= {}
local sideAtkIndices  	= {1, 1}
local leftTurn = true

local function sortStandList(standList, leftSide)
	return standList
end

local function newSideSoldiers(units, posList, court, firstOrder)
	local soldierList = {}
	for idx,unit in ipairs(units) do
		local pos = posList[idx]
		local soldier = Soldier.new(nil, firstOrder + idx, pos.x, pos.y, unit.type, court, unit.params)
		soldier:doIdle()
		soldierList[idx] = soldier
	end
	return soldierList
end

local function isSoldiersAllDead(soldiers)
	for _,soldier in ipairs(soldiers) do
		if not soldier:isDead() then return false end
	end
	return true
end

local function doFight()
	if isSoldiersAllDead(sideSoldiers[2]) then
		syslog("You Win")
		return 
	end

	if isSoldiersAllDead(sideSoldiers[1]) then
		syslog("You Lose")
		return
	end

	local attackerIdx = leftTurn and 1 or 2
	local victimIdx = leftTurn and 2 or 1
	local attacker, victim
	for _,s in ipairs(sideSoldiers[victimIdx]) do
		if not s:isDead() then
			victim = s
			break
		end
	end

	attackers = sideSoldiers[attackerIdx]
	attacker = attackers[sideAtkIndices[attackerIdx]]
	while attacker:isDead() do
		sideAtkIndices[attackerIdx] = sideAtkIndices[attackerIdx] + 1
		if sideAtkIndices[attackerIdx] > #attackers then
			sideAtkIndices[attackerIdx] = 1
		end
		attacker = attackers[sideAtkIndices[attackerIdx]]
	end
	sideAtkIndices[attackerIdx] = sideAtkIndices[attackerIdx] + 1
	if sideAtkIndices[attackerIdx] > #attackers then
		sideAtkIndices[attackerIdx] = 1
	end
	local dmg = attacker:getUserData().atk - victim:getUserData().def
	if dmg <= 0 then dmg = 1 end
	leftTurn = not leftTurn
	attacker:playAtk(victim, dmg, doFight)
end

function setup()
	AnimationCache.addAnimationFromFile("asset://spr_apple.json")
	AnimationCache.addAnimationFromFile("asset://spr_hetao.json")

	-- background
	local screenSize = sysInfo()
	syslog(table.tostring(screenSize))
	local bgWidth, bgHeight = ASSET_getImageSize("asset://bj.png.imag")
	local bgSprite = Sprite.new(nil, 6999, 0, 0, "asset://bj.png.imag")
	bgSprite:setScale(screenSize.width / bgWidth, screenSize.height / bgHeight)

	local leftStandPosList = {{x=295, y=500, scale=1}, {x=240, y=630, scale=0.96}, {x=96, y=630, scale=1}, {x=124, y=520, scale=0.96}, {x=171, y=440, scale=1}}
	local rightStandPosList = {}
	for k,v in ipairs(leftStandPosList) do
		rightStandPosList[k] = {x = screenSize.width - v.x, y = v.y, scale=v.scale}
	end

	local leftUnits = { 
		{ type="apple", params={atk=100, def=20, hp=120, longRange=false}},
	 	{ type="hetao", params={atk=130, def=40, hp=100, longRange=false}},
	 	{ type="hetao", params={atk=130, def=40, hp=100, longRange=false}}
	}

	local rightUnits = { 
		{ type="apple", params={atk=100, def=20, hp=120, longRange=false}},
	 	{ type="hetao", params={atk=130, def=40, hp=100, longRange=false}},
	 	{ type="apple", params={atk=110, def=30, hp=130, longRange=false}}
	}

	sideSoldiers[1] 	= newSideSoldiers(leftUnits, leftStandPosList, 1, 7000)
	sideSoldiers[2] 	= newSideSoldiers(rightUnits, rightStandPosList, -1, 8000)
	doFight()
	do return end

	local assetFiles, firstOffset = AnimationCache.getAnimationAssetFiles("apple")
	local idleAct = AnimationCache.getAnimationAct("apple", "stand")
	syslog(table.tostring(firstOffset))
	local sprite = Sprite.new(nil, 7000, 518.15, 503.6, assetFiles, firstOffset)
	--[[
	local assetFiles, firstOffset = AnimationCache.getAnimationAssetFiles("hetao")
	local idleAct = AnimationCache.getAnimationAct("hetao", "stand")
	local atkAct = AnimationCache.getAnimationAct("hetao", "attack")
	sprite = Sprite.new(nil, 7000, 200, 200, assetFiles, firstOffset)
	local seq = Sequence.new({Repeat.new(Animate.new(idleAct, 0.125, false), 2),
		DelayTime.new(2), Callback.new(function() syslog("log") end),
		--RepeatForever.new(Animate.new(atkAct, 0.125, false))
		Callback.new(function() sprite:runAction(RepeatForever.new(Animate.new(atkAct, 0.125, false))) end) 
		})
	sprite:runAction(seq)
	--sprite:runAction(Repeat.new(Animate.new(idleAct, 0.125, false), 10))
	--sprite:runAction(Repeat.new(Animate.new(idleAct, 0.125, false), 10))

	sprite2 = Sprite.new(nil, 7000, 200, 300, assetFiles, firstOffset)
	--sprite2:setScaleX(-1)
	sprite2:runAction(RepeatForever.new(Animate.new(atkAct, 0.125, false)))
	--]]
end

function execute(deltaT)
	ActionEngine.update(0.001 * deltaT)
end

function leave()
end