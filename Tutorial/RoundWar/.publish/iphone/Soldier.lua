local AnimationInterval = 0.125
local AtkMoveTime = 0.5

local function updateHP(self, time)
	if time == nil then time = 500 end
	local node = self._hpBar:node()
	local prop = TASK_getProperty(node)
	prop.t_anim = time
	prop.value = self._hp / self._maxHp
	TASK_setProperty(node, prop)
end

Soldier = classlite()
-- userData={ atk=30, def=15, hp=100, longRange=true|false, atkEffect="" }
function Soldier:ctor(parent, order, x, y, assetType, court, userData)
	local assetFiles, firstOffset = AnimationCache.getAnimationAssetFiles(assetType)
	self._assetType = assetType 
	self._atkAct 	= AnimationCache.getAnimationAct(assetType, "attack")
	self._dieAct 	= AnimationCache.getAnimationAct(assetType, "die")
	self._defAct 	= AnimationCache.getAnimationAct(assetType, "hit")
	self._idleAct	= AnimationCache.getAnimationAct(assetType, "stand")
	self._order 	= order
	self._court		= court
	self._userData 	= userData
	self._hp		= userData.hp
	self._maxHp		= userData.hp
	self._sprite 	= Sprite.new(parent, order, x, y, assetFiles, firstOffset)
	self._sprite:setScaleX(court)
	self._bodyWidth = self._idleAct.size[1][1]
	self._bodyHeight= self._idleAct.size[1][2]

	self._hpBar		= UINode.new(UI_ProgressBar(self._sprite:node(), order + 1, 0.5 * self._bodyWidth, -0.5 * self._bodyHeight, 400, 80,
							"asset://ui/prog_h_full.png.imag",
							"asset://ui/prog_h_empty.png.imag",
							16, 381, 1000, false), 
						{200, 40})
	self._hpBar:setScale(0.2, 0.2)
	updateHP(self, 0)
end

function Soldier:getUserData()
	return self._userData
end

function Soldier:getSprite()
	return self._sprite
end

function Soldier:getBodyWidth()
	return self._bodyWidth
end

function Soldier:isDead()
	return self._hp <= 0
end

function Soldier:playAtk(target, dmg, onAtkPlayCompleted)
	self:atkMove(target, dmg, onAtkPlayCompleted)
end

function Soldier:playDef(dmg)
	local callback
	if dmg >= self._hp then
		self._hp = 0
		callback = function() self:doDie() end
	else
		self._hp = self._hp - dmg
		callback = function() self:doIdle() end
	end
	updateHP(self)
	local act1 = Sequence.new({Animate.new(self._defAct, AnimationInterval), Callback.new(callback)})
	local act2 = Sequence.new({DelayTime.new(2 * AnimationInterval), 
		Callback.new(function() self:showDmg(dmg) end)})
	self._sprite:runAction(Spawn.new({act1, act2}))
end

function Soldier:atkMove(target, dmg, onAtkPlayCompleted)
	--syslog("atkMove begin")
	self._atkTarget = target
	self._atkDmg = dmg
	self._onAtkPlayCompleted = onAtkPlayCompleted
	if self._userData.longRange then

	else
		self._savedPos = self._sprite:getPos()
		local targetPos = target:getSprite():getPos()
		local toX = targetPos[1] - 0.5 * (target:getBodyWidth() + self._bodyWidth) * self._court
		local toY = targetPos[2]
		local dindex, doffset = AnimationCache.getFrameInfoFromAnimationAct(self._atkAct, 1)
		self._sprite:stopAllActions()
		self._sprite:setDisplay(dindex, doffset)
		local act1 = Sequence.new({EaseCircleInOut.new(MoveTo.new(AtkMoveTime, toX, toY)),
			Callback.new(function() self:onAtkMoveCompleted() end)})
		local act2 = Sequence.new({DelayTime.new(0.8 * AtkMoveTime), Callback.new(function() self:changeOrder() end)})
		self._sprite:runAction(Spawn.new({act1, act2}))
	end
	--syslog("atkMove end")
end

function Soldier:atkBack()
	--syslog("atkBack begin")
	if self._userData.longRange then
		self:onAtkBackCompleted()
	else
		local act1 = Sequence.new({EaseCircleOut.new(MoveTo.new(AtkMoveTime, self._savedPos[1], self._savedPos[2])),
			Callback.new(function() self:onAtkBackCompleted() end)})
		local act2 = Sequence.new({DelayTime.new(0.5 * AtkMoveTime), 
			Callback.new(function() self:changeOrder() end)})
		self._sprite:runAction(Spawn.new({act1, act2}))
	end
	--syslog("atkBack begin")
end

function Soldier:doDie()
	self._sprite:runAction(Sequence.new({ Animate.new(self._dieAct, AnimationInterval, false), 
		Callback.new(function() self._hpBar:setVisible(false) end),
		FadeOut.new(2), 
		Callback.new(function() self._sprite:setVisible(false) end)
	}))
end

function Soldier:doIdle()
	self._atkTarget = nil
	self._atkDmg 	= nil
	self._onAtkPlayCompleted = nil
	self._sprite:runAction(RepeatForever.new(Animate.new(self._idleAct, AnimationInterval)))
end

function Soldier:showDmg(dmg)
	syslog("dmg=" .. dmg)
	--[[
	local x, y = 0.5 * self._bodyWidth, -0.5 * self._bodyHeight
	local texTable = {
		"asset://ui/role_harm_num_0.png.imag",
		"asset://ui/role_harm_num_1.png.imag",
		"asset://ui/role_harm_num_2.png.imag",
		"asset://ui/role_harm_num_3.png.imag",
		"asset://ui/role_harm_num_4.png.imag",
		"asset://ui/role_harm_num_5.png.imag",
		"asset://ui/role_harm_num_6.png.imag",
		"asset://ui/role_harm_num_7.png.imag",
		"asset://ui/role_harm_num_8.png.imag",
		"asset://ui/role_harm_num_9.png.imag"
	}
	local dmgNode = UINode.new(UI_Score(self._sprite:node(), self._order, 10,
						x, y, texTable,	30, 0, 4, false, false))
	--dmgNode:runAction()
	--]]
end

--[[
function Soldier:showAtkEffect(atkEffect)
end
--]]

function Soldier:changeOrder()
	if self._atkTarget ~= nil then
		local order1 = self._sprite:getOrder()
		local order2 = self._atkTarget:getSprite():getOrder()
		self._sprite:setOrder(order2)
		self._atkTarget:getSprite():setOrder(order1) 
	end
end

function Soldier:onAtkMoveCompleted()
	local act1 = Sequence.new({ Animate.new(self._atkAct, AnimationInterval, true), 
		Callback.new(function() self:atkBack() end)})
	local act2 = Sequence.new({ DelayTime.new(4 * AnimationInterval),
		--Callback.new(function() self._atkTarget:showAtkEffect(self._userData.atkEffect) end),
		Callback.new(function() self._atkTarget:playDef(self._atkDmg) end)	
		})
	self._sprite:runAction(Spawn.new({act1, act2}))
end

function Soldier:onAtkBackCompleted()
	if self._onAtkPlayCompleted ~= nil then
		self._onAtkPlayCompleted()
	end
	self:doIdle()
end