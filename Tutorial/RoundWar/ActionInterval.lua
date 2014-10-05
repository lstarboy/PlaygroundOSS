--include("asset://Action.lua")
require("Action")
require("AnimationCache")

--/* smallest such that 1.0+FLT_EPSILON != 1.0 */
local FLT_EPSILON = 1.192092896e-07

-- ActionInterval Definition Begin
ActionInterval = classlite(FiniteTimeAction)

function initActionInterval(self, duration)
	if duration == 0 then duration = FLT_EPSILON end
	self._isInstance = false
	self._duration = duration
	self._elapsed = 0
	self._firstTick = true
end

function ActionInterval:ctor(duration)
	initActionInterval(self, duration)
end

function ActionInterval:isDone()
	return self._elapsed > self._duration
end

function ActionInterval:step(dt)
	if self._firstTick then
		self._firstTick = false
		self._elapsed = 0
	else
		self._elapsed = self._elapsed + dt
	end

	self:update(math.max(0, math.min(1, self._elapsed / math.max(self._duration, FLT_EPSILON))))
end

function ActionInterval:startWithTarget(node)
	superClass(ActionInterval).startWithTarget(self, node)
	self._elapsed = 0
	self._firstTick = true
end

function ActionInterval:getElapsed()
	return self._elapsed
end
-- ActionInterval Definition End

-- Sequence Definition Begin
ExtraAction = classlite(FiniteTimeAction)

function ExtraAction:ctor()
end

function ExtraAction:update(dt)
end

function ExtraAction:step(dt)
end

Sequence = classlite(ActionInterval)

local function initTwoActionsForSequence(self, action1, action2)
	initActionInterval(self, action1:getDuration() + action2:getDuration()) 
	self._actions = {}
	self._actions[1] = action1
	self._actions[2] = action2
end

function Sequence:ctor(finiteTimeActionList)
	--syslog("#finiteTimeActionList=" .. #finiteTimeActionList)
	--if #finiteTimeActionList == 0 then syslog(finiteTimeActionList[1].x); return end
	if #finiteTimeActionList == 0 then return end
	if #finiteTimeActionList == 1 then
		initTwoActionsForSequence(self, finiteTimeActionList[1], ExtraAction.new())
	elseif #finiteTimeActionList == 2 then
		initTwoActionsForSequence(self, finiteTimeActionList[1], finiteTimeActionList[2])
	else
		local prev = finiteTimeActionList[1]
		for i=2,#finiteTimeActionList - 1 do
			prev = Sequence.new({prev, finiteTimeActionList[i]})
		end
		initTwoActionsForSequence(self, prev, finiteTimeActionList[#finiteTimeActionList])
	end
end

function Sequence:startWithTarget(node)
	superClass(Sequence).startWithTarget(self, node)
	--syslog("Sequence:startWithTarget")
	--syslog(table.tostring(self))
	self._split = self._actions[1]:getDuration() / self._duration
	self._last  = 0
end

function Sequence:stop()
	if self._last ~= 0 then
		self._actions[self._last]:stop()
	end
end

function Sequence:update(t)
	local found = 1
	local new_t = 0

	if t < self._split then -- actions[1]
		found = 1
		if self._split ~= 0 then new_t = t / self._split
		else new_t = 1 end
	else -- actions[2]
		found = 2
		if self._split == 1 then new_t = 1
		else new_t = (t - self._split) / (1 - self._split) end
	end

	if found == 2 then
		if self._last == 0 then
			self._actions[1]:startWithTarget(self._target)
			self._actions[1]:update(1)
			self._actions[1]:stop()
		elseif self._last == 1 then
			self._actions[1]:update(1)
			self._actions[1]:stop()
		end
	elseif found == 1 and self._last == 2 then
		self._actions[2]:update(0)
		self._actions[2]:stop()	
	end

	if found == self._last and self._actions[found]:isDone() then return end

	if found ~= self._last then
		self._actions[found]:startWithTarget(self._target)
	end

	self._actions[found]:update(new_t)
	self._last = found
end
-- Sequence Definition End

-- Repeat Definition Begin
Repeat = classlite(ActionInterval)

function Repeat:ctor(finiteTimeAction, times)
	initActionInterval(self, finiteTimeAction:getDuration() * times)
	self._innerAction = finiteTimeAction
	self._times = times
	self._isInstance = finiteTimeAction:isInstance()
	if self._isInstance then self._times = self._times - 1 end
	self._total = 0
end

function Repeat:startWithTarget(node)
	self._total = 0
	self._nextDt = self._innerAction:getDuration() / self._duration
	superClass(Repeat).startWithTarget(self, node)
	self._innerAction:startWithTarget(node)
end

function Repeat:stop()
	self._innerAction:stop()
	superClass(Repeat).stop(self)
end

function Repeat:update(dt)
	if dt >= self._nextDt then
		while dt > self._nextDt and self._total < self._times do
			self._innerAction:update(1)
			self._total = self._total + 1
			self._innerAction:stop()
			self._innerAction:startWithTarget(self._target)
			self._nextDt = self._innerAction:getDuration() / self._duration * (self._total + 1)
		end

		if dt >= 1 and self._total < self._times then
			self._total = self._total + 1
		end

		if not self._isInstance then
			if self._total == self._times then
				self._innerAction:update(1)
				self._innerAction:stop()
			else
				self._innerAction:update(dt - (self._nextDt - self._innerAction:getDuration() / self._duration))
			end
		end
	else
		local _,t = math.modf(dt * self._times)
		self._innerAction:update(t)
	end
end

function Repeat:isDone()
	return self._total == self._times
end
-- Repeat Definition End

-- RepeatForever Definition Begin
RepeatForever = classlite(ActionInterval)

function RepeatForever:ctor(actionInterval)
	self._innerAction = actionInterval
	self._duration    = 0
end

function RepeatForever:startWithTarget(node)
	superClass(RepeatForever).startWithTarget(self, node)
	self._innerAction:startWithTarget(node)
end

function RepeatForever:step(dt)
	local target = self._target
	self._innerAction:step(dt)
	if self._innerAction:isDone() then
		local diff = self._innerAction:getElapsed() - self._innerAction:getDuration()
		if diff > self._innerAction:getDuration() then
			diff = math.fmod(diff, self._innerAction:getDuration())
		end
		self._innerAction:startWithTarget(target)
		self._innerAction:step(0) -- to prevent jerk
		self._innerAction:step(diff)
	end
end

function RepeatForever:isDone()
	return false
end
-- RepeatForever Definition End

-- DelayTime Definition Begin
DelayTime = classlite(ActionInterval)

function DelayTime:ctor(t)
	--initActionInterval(self, t)
end

function DelayTime:update(dt)
end
-- DelayTime Definition End

-- Spawn Definition Begin
Spawn = classlite(ActionInterval)

local function initTwoActionsForSpawn(self, ftAction1, ftAction2)
	local d1 = ftAction1:getDuration()
	local d2 = ftAction2:getDuration()
	initActionInterval(self, math.max(d1, d2))
	self._one = ftAction1
	self._two = ftAction2
	if d1 > d2 then
		self._two = Sequence.new({ftAction2, DelayTime.new(d1 - d2)})
	elseif d1 < d2 then
		self._one = Sequence.new({ftAction1, DelayTime.new(d2 - d1)})
	end
end

function Spawn:ctor(finiteTimeActionList)
	if #finiteTimeActionList == 0 then return end
	if #finiteTimeActionList == 1 then
		initTwoActionsForSpawn(self, finiteTimeActionList[1], ExtraAction.new())
	elseif #finiteTimeActionList == 2 then
		initTwoActionsForSpawn(self, finiteTimeActionList[1], finiteTimeActionList[2])
	else
		local prev = finiteTimeActionList[1]
		for i=2,#finiteTimeActionList-1 do 
			prev = Spawn.new({prev, finiteTimeActionList[i]})
		end
		initTwoActionsForSpawn(self, prev, finiteTimeActionList[#finiteTimeActionList])
	end
end

function Spawn:startWithTarget(node)
	superClass(Spawn).startWithTarget(self, node)
	self._one:startWithTarget(node)
	self._two:startWithTarget(node)
end

function Spawn:stop()
	self._one:stop()
	self._two:stop()
	superClass(Spawn).stop(self)
end

function Spawn:update(dt)
	self._one:update(dt)
	self._two:update(dt)
end
-- Spawn Definition End

-- MoveBy Definition Begin
MoveBy = classlite(ActionInterval)

function MoveBy:ctor(duration, dx, dy)
	initActionInterval(self, duration)
	self._deltaPos = {dx, dy}
end

function MoveBy:startWithTarget(node)
	superClass(MoveBy).startWithTarget(self, node)
	local pt = node:getPos()
	self._prevPos = {pt[1], pt[2]}
	self._startPos= {pt[1], pt[2]}
end

function MoveBy:update(dt)
	local pt = self._target:getPos()
	local diff = { pt[1] - self._prevPos[1], pt[2] - self._prevPos[2]}
	self._startPos[1] = self._startPos[1] + diff[1]
	self._startPos[2] = self._startPos[2] + diff[2]
	self._prevPos[1] = self._startPos[1] + dt * self._deltaPos[1]
	self._prevPos[2] = self._startPos[2] + dt * self._deltaPos[2]
	--syslog("updatePos={" .. self._prevPos[1] .. "," .. self._prevPos[2] .. "}")
	self._target:setPos(self._prevPos[1], self._prevPos[2])
end
-- MoveBy Definition End

-- MoveTo Definition Begin
MoveTo = classlite(MoveBy)

function  MoveTo:ctor(duration, x, y)
	initActionInterval(self, duration)
	self._endPos = {x, y}
	syslog("endPos={" .. x .. "," .. y .. "}")
end

function MoveTo:startWithTarget(node)
	superClass(MoveTo).startWithTarget(self, node)
	self._deltaPos = {self._endPos[1] - self._startPos[1], self._endPos[2] - self._startPos[2]}
end
-- MoveTo Definition End

-- JumpBy Definition Begin
JumpBy = classlite(ActionInterval)

function JumpBy:ctor(duration, dx, dy, height, jumps)
	initActionInterval(self, duration)
	self._deltaPos = {dx, dy}
	self._height = height
	self._jumps = jumps
end

function JumpBy:startWithTarget(node)
	superClass(JumpBy).startWithTarget(self, node)
	local pt = node:getPos()
	self._prevPos = {pt[1], pt[2]}
	self._startPos= {pt[1], pt[2]}
end

function JumpBy:update(dt)
	local _, frac = math.modf(dt * self._jumps)
	local y = self._height * 4 * frac * (1 - frac) + self._deltaPos[2] * dt
	local x = self._deltaPos[1] * dt
	local pt = self._target:getPos()
	local diff = {pt[1] - self._prevPos[1], pt[2] - self._prevPos[2]}
	self._startPos = {diff[1] + self._startPos[1], diff[2] + self._startPos[2]}
	self._prevPos = {self._startPos[1] + x, self._startPos[2] + y}
	self._target:setPos(self._prevPos[1], self._prevPos[2])
end
-- JumpBy Definition End

-- JumpTo Definition Begin
JumpTo = classlite(JumpBy)

function JumpTo:ctor(duration, x, y, height, jumps)
end

function JumpTo:startWithTarget(node)
	superClass(JumpTo).startWithTarget(self, node)
	self._deltaPos = {self._deltaPos[1] - self._startPos[1], self._deltaPos[2] - self._startPos[2]}
end
-- JumpTo Definition End

-- ScaleTo Definition Begin
ScaleTo = classlite(ActionInterval)

function ScaleTo:ctor(duration, sx, sy)
	initActionInterval(self, duration)
	self._endScale = {sx, sy}
end

function ScaleTo:startWithTarget(node)
	superClass(ScaleTo).startWithTarget(self, node)
	local sx, sy = node:getScale()
	self._startScale = {sx, sy}
	self._deltaScale = {self._endScale[1] - sx, self._endScale[2] - sy}
end

function ScaleTo:update(dt)
	local sx = self._startScale[1] + self._deltaScale[1] * dt
	local sy = self._startScale[2] + self._deltaScale[2] * dt
	self._target:setScale(sx, sy)
end
-- ScaleTo Definition End

-- ScaleBy Definition Begin
ScaleBy = classlite(ScaleTo)

function ScaleBy:ctor(duration, sx, sy)
end

function ScaleBy:startWithTarget(node)
	superClass(ScaleBy).startWithTarget(self, node)
	self._deltaScale = { self._startScale[1] * self._endScale[1] - self._startScale[1],
			self._startScale[2] * self._endScale[2] - self._startScale[2] }
end
-- ScaleBy Definition End

-- Blink Definition Begin
Blink = classlite(ActionInterval)

function Blink:ctor(duration, blinks)
	initActionInterval(self, duration)
	self._blinks = blinks
end

function Blink:update(dt)
	if not self:isDone() then
		local slice = 1.0 / self._blinks
		local m = math.fmodf(dt, slice)
		self._target:setVisible(m > 0.5 * slice)
	end
end

function Blink:startWithTarget(node)
	superClass(Blink).startWithTarget(self, node)
	self._savedState = node:getVisible()
end

function Blink:stop()
	self._target:setVisible(self._savedState)
	superClass(Blink).stop(self)
end
-- Blink Definition End

-- FadeTo Definition Begin
FadeTo = classlite(ActionInterval)

function FadeTo:ctor(duration, alpha)
	initActionInterval(self, duration)
	self._toAlpha = alpha
end

function FadeTo:startWithTarget(node)
	superClass(FadeTo).startWithTarget(self, node)
	self._fromAlpha = node:getAlpha()
end

function FadeTo:update(dt)
	self._target:setAlpha(math.floor(self._fromAlpha + dt * (self._toAlpha - self._fromAlpha)))
end
-- FadeTo Definition End

-- FadeIn Definition Begin
FadeIn = classlite(FadeTo)

function FadeIn:ctor(duration)
	self._toAlpha = 255
end

-- FadeIn Definition End

-- FadeOut Definition Begin
FadeOut = classlite(FadeTo)

function FadeOut:ctor(duration)
	self._toAlpha = 0
end
-- FadeOut Definition End

--[[
-- TintTo Definition Begin
TintTo = classlite(ActionInterval)

function TintTo:ctor(duration, color)
end

function TintTo:startWithTarget(node)
end

function TintTo:update(dt)
end
-- TintTo Definition End

-- TintBy Definition Begin
TintBy = classlite(ActionInterval)

function TintBy:ctor(duration, deltaColor)
end

function TintBy:startWithTarget(node)
end

function TintBy:update(dt)
end
-- TintBy Definition End
--]]

-- ReverseTime Definition Begin
ReverseTime = classlite(ActionInterval)

function ReverseTime:ctor(finiteTimeAction)
	initActionInterval(self, finiteTimeAction:getDuration())
	self._other = finiteTimeAction
end

function ReverseTime:startWithTarget(node)
	superClass(ReverseTime).startWithTarget(self, node)
	self._other:startWithTarget(node)
end

function ReverseTime:stop()
	self._other:stop()
	superClass(ReverseTime).stop(self)
end

function ReverseTime:update(dt)
	self._other:update(1 - dt)
end
-- ReverseTime Definition End

-- Animate Definition Begin
Animate = classlite(ActionInterval)

function Animate:ctor(animationAct, interval, resetIfCompleted)
	self._animationAct = animationAct
	self._interval = interval
	self._resetIfCompleted = (resetIfCompleted ~= nil) and resetIfCompleted or false
	local duration = animationAct.frameCnt * interval
	initActionInterval(self, duration)
end

local function getFrameOffset(self, idx)
	--syslog("poffset={" .. self._animationAct.poffset[1] .. "," .. self._animationAct.poffset[2] .. "}")
	--local x = self._animationAct.poffset[1] + self._animationAct.offset[idx][1]
	--local y = self._animationAct.poffset[2] + self._animationAct.offset[idx][2]
	local x = self._animationAct.offset[idx][1]
	local y = self._animationAct.offset[idx][2]
	return { x, y }
end

function Animate:startWithTarget(node)
	superClass(Animate).startWithTarget(self, node)
	self._playing   = true
	node:setDisplay(self._animationAct.start, getFrameOffset(self, 1))
end

function Animate:update(dt)
	if not self._playing then return end
	local frameCnt = self._animationAct.frameCnt
	actIdx = math.floor(frameCnt * dt)
	if actIdx >= frameCnt - 1 then
		if self._resetIfCompleted then
			actIdx = 0
		else
			actIdx = frameCnt - 1
		end
		self._playing = false
	end
	actIdx = actIdx + self._animationAct.start
	if actIdx ~= self._curIdx then
		self._curIdx = actIdx
		self._target:setDisplay(actIdx, getFrameOffset(self, actIdx - self._animationAct.start + 1))
	end
end
-- Animate Definition End

-- TargetedAction Definition Begin
TargetedAction = classlite(ActionInterval)

function TargetedAction:ctor(node, finiteTimeAction)
	initActionInterval(self, finiteTimeAction:getDuration())
	self._forcedTarget = node
	self._action = finiteTimeAction
end

function TargetedAction:startWithTarget(target)
	superClass(TargetedAction).startWithTarget(self, target)
	self._action:startWithTarget(self._forcedTarget)
end

function TargetedAction:stop()
	self._action:stop()
end

function TargetedAction:update(dt)
	self._action:update(dt)
end
-- TargetedAction Definition End

-- Shake Definition Begin
Shake = classlite(ActionInterval)

function Shake:ctor(duration, xStrength, yStrength)
	initActionInterval(self, duration)
	self._xs = xStrength
	self._ys = yStrength
end

function Shake:startWithTarget(target)
	superClass(Shake).startWithTarget(self, target)
	self._savedPt = target:getPos()
end

function Shake:update(dt)
	local rx = math.random(-self._xs, self._xs)
	local ry = math.random(-self._ys, self._ys)
	self._target:setPos(self._savedPt[1] + rx, self._savedPt[2] + ry)
end

function Shake:stop()
	self._target:setPos(self._savedPt[1], self._savedPt[2])
end
-- Shake Definition End
