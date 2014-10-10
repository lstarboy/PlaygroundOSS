--include("asset://Action.lua")

-- ActionInstant Definition Begin
ActionInstant = classlite(FiniteTimeAction)

function ActionInstant:ctor()
	self._isInstance = true
end

function ActionInstant:step(dt)
	self:update(1)
end

function ActionInstant:update(ratio)
end
-- ActionInstant Definition End

-- Show Definition Begin
Show = classlite(ActionInstant)

function Show:ctor()

end

function Show:update(dt)
	self._target:setVisible(true)
end
-- Show Definition End

-- Hide Definition Begin
Hide = classlite(ActionInstant)

function Hide:ctor()

end

function Hide:update(dt)
	self._target:setVisible(false)
end
-- Hide Definition End

-- ToggleVisibility Definition Begin
ToggleVisibility = classlite(ActionInstant)

function ToggleVisibility:ctor()

end

function ToggleVisibility:update(dt)
	self._target:setVisible(not self._target:getVisible())
end
-- ToggleVisibility Definition End

-- RemoveSelf Definition Begin
RemoveSelf = classlite(ActionInstant)

function RemoveSelf:ctor()
end

function RemoveSelf:update(dt)
	self._target:clear(false)
end
-- RemoveSelf Definition End

-- ScaleX Definition Begin
ScaleX = classlite(ActionInstant)

function ScaleX:ctor(scaleX)
	self._scaleX = scaleX
end

function ScaleX:update(dt)
	self._target:setScaleX(self._scaleX)
end
-- ScaleX Definition End

-- ScaleY Definition Begin
ScaleY = classlite(ActionInstant)

function ScaleY:ctor(scaleY)
	self._scaleY = scaleY
end

function ScaleY:update(dt)
	self._target:setScaleY(self._scaleY)
end
-- ScaleY Definition End

-- Place Definition Begin
Place = classlite(ActionInstant)

function Place:ctor(x, y)
	self._x = x
	self._y = y
end

function Place:update(dt)
	self._target:setPos(self._x, self._y)
end
-- Place Definition End

-- Callback Definition Begin
Callback = classlite(ActionInstant)

function Callback:ctor(func)
	self._func = func
end

function Callback:update(dt)
	if self._func ~= nil then
		self._func()
	end
end
-- Callback Definition End

-- CallbackN Definition Begin
CallbackN = classlite(ActionInstant)

function CallbackN:ctor(func)
	self._func = func
end

function CallbackN:update(dt)
	if self._func ~= nil then
		self._func(self._target)
	end
end
-- CallbackN Definition End