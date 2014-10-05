require("ActionEngine")
require("Common")

Node = classlite()

function Node:ctor()
	self._node = nil
end

function Node:node()
	return self._node
end

function Node:clear(removeActions)
	if removeActions == nil then removeActions = true end
	if self._node ~= nil then
		if removeActions then ActionEngine.removeAllActionsFromTarget(self) end
		Task_kill(self._node)
		self._node = nil
	end
end

function Node:setVisible(visible)
	local prop = TASK_getProperty(self._node)
	prop.visible = visible
	TASK_setProperty(self._node, prop)
end

function Node:getVisible()
	return TASK_getProperty(self._node).visible
end

function Node:setScaleX(scaleX)
	local prop = TASK_getProperty(self._node)
	prop.scaleX = scaleX
	TASK_setProperty(self._node, prop)
end

function Node:getScaleX()
	return TASK_getProperty(self._node).scaleX
end

function Node:setScaleY(scaleY)
	local prop = TASK_getProperty(self._node)
	prop.scaleY = scaleY
	TASK_setProperty(self._node, prop)
end

function Node:getScaleY()
	return TASK_getProperty(self._node).scaleY
end

function Node:getScale()
	local prop = TASK_getProperty(self._node)
	return prop.scaleX, prop.scaleY
end

function Node:setScale(sx, sy)
	local prop = TASK_getProperty(self._node)
	prop.scaleX = sx
	prop.scaleY = sy
	TASK_setProperty(self._node, prop)
end

function Node:getAlpha()
	return TASK_getProperty(self._node).alpha
end

function Node:setAlpha(alpha)
	local prop = TASK_getProperty(self._node)
	prop.alpha = alpha
	TASK_setProperty(self._node, prop)
end

function Node:getColor()
	return TASK_getProperty(self._node).color
end

function Node:setColor(color)
	local prop = TASK_getProperty(self._node)
	prop.color = color
	TASK_setProperty(self._node, prop)
end

function Node:getOrder()
	return TASK_getProperty(self._node).order
end

function Node:setOrder(order)
	local prop = TASK_getProperty(self._node)
	prop.order = order
	TASK_setProperty(self._node, prop)
end

function Node:runAction(action, stopFirst)
	if stopFirst == nil then stopFirst = true end
	if stopFirst then self:stopAllActions() end
	return ActionEngine.addAction(action, self)
end

function Node:stopAllActions()
	ActionEngine.removeAllActionsFromTarget(self)
end

function Node:stopAction(action)
	ActionEngine.removeAction(action)
end

function Node:stopActionByTag(tag)
	ActionEngine.removeActionByTag(tag, self)
end

function Node:getActionByTag(tag)
	return ActionEngine.getActionByTag(tag, self)
end

function Node:setUserData(userData)
	self._userdata = userData
end

function Node:getUserData()
	return self._userdata
end

function Node:setPos(x, y)
	local prop = TASK_getProperty(self._node)
	prop.x = x
	prop.y = y
	TASK_setProperty(self._node, prop)
end

function Node:getPos()
	local prop = TASK_getProperty(self._node)
	return {prop.x, prop.y}
end

UINode = classlite(Node)

function UINode:ctor(ui)
	self._node = ui
end

function UINode:setNode(ui)
	self._node = ui
end