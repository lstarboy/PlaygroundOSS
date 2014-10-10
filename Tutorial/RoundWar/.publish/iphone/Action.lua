-- Action Definition Begin
Action = classlite()

Action.InvalidTag = -1

function Action:ctor()
	self._target 		= nil
	self._originTarget 	= nil
	self._tag 	 		= Action.InvalidTag
end

function Action:isDone()
	return true
end

function Action:startWithTarget(node)
	self._originTarget = node
	self._target = node
end

function Action:stop()
	self._target = nil
end

function Action:step(dt)
end

function Action:update(ratio)
end

function Action:getTarget()
	return self._target
end

function Action:getOriginTarget()
	return self._originTarget
end

function Action:setTarget(target)
	self._target = target
end

function Action:getTag()
	return self._tag
end

function Action:setTag(tag)
	self._tag = tag
end
-- Action Definition End

-- FiniteTimeAction Definition Begin
FiniteTimeAction = classlite(Action)

function FiniteTimeAction:ctor()
	self._duration = 0
	self._isInstance = true
end

function FiniteTimeAction:isInstance()
	return self._isInstance
end

function FiniteTimeAction:getDuration()
	return self._duration
end

function FiniteTimeAction:setDuration(duration)
	self._duration = duration
end
-- FiniteTimeAction Definition End

-- Speed Definition Begin
Speed = classlite(Action)

function Speed:ctor(action, speed)
	self._action = action
	self._speed  = speed
end

function Speed:getSpeed()
	return self._speed
end

function Speed:getAction()
	return self._action
end

function Speed:startWithTarget(node)
	--superCallLite(self, Speed, "startWithTarget", node)
	self._target = node
	self._action:startWithTarget(node)
end

function Speed:stop()
	self._action:stop()
	self._target = nil
end

function Speed:step(dt)
	self._action:step(dt * self._speed)
end

function Speed:isDone()
	return self._action:isDone()
end
-- Speed Definition End

-- ActionManager Definition Begin


-- ActionManager Definition End


















