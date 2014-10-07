require("Soldier")

local sideSoldiers 		= {}
local sideAtkIndices  	= {1, 1}
local leftTurn = true
local pForm = nil

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

local function clearSideSoldiers(soldiers)
	if soldiers == nil then return end
	for _, soldier in ipairs(soldiers) do
		soldier:getSprite():clear()
	end
end

local function isSoldiersAllDead(soldiers)
	for _,soldier in ipairs(soldiers) do
		if not soldier:isDead() then return false end
	end
	return true
end

local function closeForm()
	--clearSideSoldiers(sideSoldiers[1])
	--clearSideSoldiers(sideSoldiers[2])
	TASK_StageClear()
	--[[
	if pForm ~= nil then
		Task_kill(pForm)
		pForm = nil
	end
	--]]
end

local function doFight()
	local win 	= isSoldiersAllDead(sideSoldiers[2])
	local lose  = isSoldiersAllDead(sideSoldiers[1])
	if win or lose then
		pForm = UI_Form(nil, 9000, 0, 0, "asset://ui_report.json", false)
		sysCommand(pForm, UI_FORM_UPDATE_NODE, "btnRetry", FORM_NODE_VISIBLE, false)
		sysCommand(pForm, UI_FORM_UPDATE_NODE, "lblRetry", FORM_NODE_VISIBLE, false)
		if win then
			sysCommand(pForm, UI_FORM_UPDATE_NODE, "failure", FORM_NODE_VISIBLE, false)
		else
			sysCommand(pForm, UI_FORM_UPDATE_NODE, "victory", FORM_NODE_VISIBLE, false)
			sysCommand(pForm, UI_FORM_UPDATE_NODE, "star", FORM_NODE_VISIBLE, false)
		end
		TASK_StageOnly(pForm)
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

function startFight()
	sideSoldiers 		= {}
	sideAtkIndices  	= {1, 1}
	leftTurn = true

	local screenSize = sysInfo()
	syslog(table.tostring(screenSize))

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
end

function OnRetry()
	closeForm()
	--startFight()
	sysLoad("asset://BattleField.lua")
end

function OnExit()
	syslog("OnExit")
	closeForm()
	sysExit()
end

function setup()
	FONT_load("Georgia","asset://AlexBrush-Regular-OTF.otf")
	AnimationCache.addAnimationFromFile("asset://spr_apple.json")
	AnimationCache.addAnimationFromFile("asset://spr_hetao.json")

	-- background
	local screenSize = sysInfo()
	syslog(table.tostring(screenSize))
	local bgWidth, bgHeight = ASSET_getImageSize("asset://ui/bj.png.imag")
	local bgSprite = Sprite.new(nil, 6999, 0, 0, "asset://ui/bj.png.imag")
	bgSprite:setScale(screenSize.width / bgWidth, screenSize.height / bgHeight)

	--[[
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
	--]]
	startFight()
end

function execute(deltaT)
	ActionEngine.update(0.001 * deltaT)
end

function leave()
end