-- ActionEase Definition Begin
ActionEase = classlite(ActionInterval)

function ActionEase:ctor(actionInterval)
	initActionInterval(self, actionInterval:getDuration())
	self._innerAction = actionInterval
end

function ActionEase:startWithTarget(node)
	superClass(ActionEase).startWithTarget(self, node)
	self._innerAction:startWithTarget(node)
end

function ActionEase:stop()
	self._innerAction:stop()
	superClass(ActionEase).stop(self)
end

function ActionEase:update(dt)
	self._innerAction:update(dt)
end
-- ActionEase Definition End

-- EaseRateAction Definition Begin
EaseRateAction = classlite(ActionEase)

function EaseRateAction:ctor(action, rate)
	self._rate = rate
end
-- EaseRateAction Definition End

-- EaseIn Definition Begin
EaseIn = classlite(EaseRateAction)

function EaseIn:ctor(action, rate)
end

function EaseIn:update(dt)
	self._innerAction:update(math.pow(dt, self._rate))
end
-- EaseIn Definition End

-- EaseOut Definition Begin
EaseOut = classlite(EaseRateAction)

function EaseOut:ctor(action, rate)
end

function EaseOut:update(dt)
	self._innerAction:update(math.pow(dt, 1.0 / self._rate))
end
-- EaseOut Definition End

-- EaseInOut Definition Begin
EaseInOut = classlite(EaseRateAction)

function EaseInOut:ctor(action, rate)
end

function EaseInOut:update(dt)
	local new_t = 0
	local dt = 2 * dt
	if dt < 1 then new_t = 0.5 * math.pow(dt, self._rate)
	else new_t = (1.0 - 0.5 *math.pow(2 - dt, self._rate)) end
	self._innerAction:update(new_t)
end
-- EaseInOut Definition End

-- EaseExponentialIn Definition Begin
EaseExpIn = classlite(ActionEase)

function EaseExpIn:ctor(action)
end

function EaseExpIn:update(dt)
	local dt = (dt == 0) and 0 or (math.pow(2, 10 * (time - 1)) - 0.001)
	self._innerAction:update(dt)
end
-- EaseExponentialIn Definition End

-- EaseExpOut Definition Begin
EaseExpOut = classlite(ActionEase)

function EaseExpOut:ctor(action)
end

function EaseExpOut:update(dt)
	local dt = (dt == 1) and 1 or (-math.pow(2, -10 * dt) + 1)
	self._innerAction:update(dt)
end
-- EaseExpOut Definition End

-- EaseExpInOut Definition Begin
EaseExpInOut = classlite(ActionEase)

function EaseExpInOut:ctor(action)
end

function EaseExpInOut:update(dt)
	local new_t = 0
	local dt = 2 * dt
	if dt < 1 then new_t = 0.5 * math.pow(2, 10 * (dt - 1))
	else new_t = 0.5 * (-math.pow(2, -10 * (dt - 1)) + 2) end
	self._innerAction:update(new_t)
end
-- EaseExpInOut Definition End

local halfPI = 0.5 * math.pi
-- EaseSineIn Definition Begin
EaseSineIn = classlite(ActionEase)

function EaseSineIn:ctor(action)
end

function EaseSineIn:update(dt)
	self._innerAction:update(-1 * math.cos(dt * halfPI) + 1)
end
-- EaseSineIn Definition End

-- EaseSineOut Definition Begin
EaseSineOut = classlite(ActionEase)

function EaseSineOut:ctor(action)
end

function EaseSineOut:update(dt)
	self._innerAction:update(math.sin(dt * halfPI))
end
-- EaseSineOut Definition End

-- EaseSineInOut Definition Begin
EaseSineInOut = classlite(ActionEase)

function EaseSineInOut:ctor(action)
end

function EaseSineInOut:update(dt)
	self._innerAction:update(-0.5 * (math.cos(dt * math.pi) - 1))
end
-- EaseSineInOut Definition End

-- EaseElastic Definition Begin
EaseElastic = classlite(ActionEase)

function EaseElastic:ctor(action, period)
	self._period = period
end
-- EaseElastic Definition End

-- EaseElasticIn Definition Begin
EaseElasticIn = classlite(EaseElastic)

function EaseElasticIn:ctor(action, period)
end

function EaseElasticIn:update(dt)
	local newT = 0
    if dt == 0 or dt == 1 then
        newT = dt
    else
        local s = 0.25 * self._period
        dt = dt - 1;
        newT = -math.pow(2, 10 * dt) * math.sin((dt - s) * 2 * math.pi / self._period)
    end
	self._innerAction:update(newT)
end
-- EaseElasticIn Definition End

-- EaseElasticOut Definition Begin
EaseElasticOut = classlite(EaseElastic)

function EaseElasticOut:ctor(action, period)
end

function EaseElasticOut:update(time)
    local newT = 0
    if time == 0 or time == 1 then
        newT = time
    else
        local s = 0.25 * self._period
        newT = math.pow(2, -10 * time) * math.sin((time - s) * 2 * math.pi / self._period) + 1
    end
    self._innerAction:update(newT)
end
-- EaseElasticOut Definition End

-- EaseElasticInOut Definition Begin
EaseElasticInOut = classlite(EaseElastic)

function EaseElasticInOut:ctor(action, period)
end

function EaseElasticInOut:update(time)
    local newT = 0
    if time == 0 or time == 1 then
        newT = time
    else
        time = time * 2
        local period = (self._period == 0) and (0.3 * 1.5) or self._period
        local s = 0.25 * period
        time = time - 1
        if time < 0 then
            newT = -0.5 * math.pow(2, 10 * time) * math.sin((time -s) * 2 * math.pi / period)
        else
            newT = math.pow(2, -10 * time) * math.sin((time - s) * 2 * math.pi / period) * 0.5 + 1
        end
    end
    self._innerAction:update(newT)
end
-- EaseElasticInOut Definition End

-- EaseCircleIn Definition Begin
EaseCircleIn = classlite(ActionEase)

function EaseCircleIn:ctor(action)
end

function EaseCircleIn:update(dt)
	local newT = -1 * (math.sqrt(1 - dt * dt) - 1)
	self._innerAction:update(newT)
end
-- EaseCircleIn Definition End

-- EaseCircleOut Definition Begin
EaseCircleOut = classlite(ActionEase)

function EaseCircleOut:ctor(action)
end

function EaseCircleOut:update(dt)
	local dt = dt - 1
	self._innerAction:update(math.sqrt(1 - dt * dt))	
end
-- EaseCircleOut Definition End

-- EaseCircleInOut Definition Begin
EaseCircleInOut = classlite(ActionEase)

function EaseCircleInOut:ctor(action)
end

function EaseCircleInOut:update(time)
	local newT = 0
	time = time * 2
    if time < 1 then
        newT = -0.5 * (math.sqrt(1 - time * time) - 1)
    else
    	time = time - 2
    	newT = 0.5 * (math.sqrt(1 - time * time) + 1)
    end
    self._innerAction:update(newT)
end
-- EaseCircleInOut Definition End

-- EaseSineIn Definition Begin
-- EaseSineIn Definition End

-- EaseSineOut Definition Begin
-- EaseSineOut Definition End

-- EaseSineInOut Definition Begin
-- EaseSineInOut Definition End