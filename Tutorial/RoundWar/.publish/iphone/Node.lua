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
		syslog("Task_kill node=" .. type(self._node))
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

function Node:setPropPos(x, y)
	local prop = TASK_getProperty(self._node)
	prop.x = x
	prop.y = y
	TASK_setProperty(self._node, prop)
end

function Node:getPropPos()
	local prop = TASK_getProperty(self._node)
	return {prop.x, prop.y}
end

function Node:setPos(x, y)
	self:setPropPos(x, y)
end

function Node:getPos()
	return self:getPropPos()
end

UINode = classlite(Node)

local function updateUINodePos(self)
	local prop = TASK_getProperty(self._node)
	prop.x 	   = self._pt[1] - prop.scaleX * self._anchor[1]
	prop.y     = self._pt[2] - prop.scaleY * self._anchor[2]
	TASK_setProperty(self._node, prop)
end

local function setUINodeWith(self, ui, anchorPt)
	if anchorPt == nil then anchorPt = {0, 0} end
	self._node     	= ui
	self._anchor	= anchorPt

	syslog("type(anchorPt)=" .. type(anchorPt))
	syslog(table.tostring(anchorPt))

	local prop = TASK_getProperty(ui)
	self._pt 		= { prop.x, prop.y }
	updateUINodePos(self)
end

function UINode:ctor(ui, anchorPt)
	setUINodeWith(self, ui, anchorPt)
end

function UINode:setNode(ui, anchorPt)
	setUINodeWith(self, ui, anchorPt)
end

function UINode:setPos(x, y)
	self._pt = { x, y }
	updateUINodePos(self)
end

function UINode:getPos()
	return self._pt
end

function UINode:setScaleX(scaleX)
	local prop = TASK_getProperty(self._node)
	prop.scaleX = scaleX
	TASK_setProperty(self._node, prop)
	updateUINodePos(self)
end

function UINode:setScaleY(scaleY)
	local prop = TASK_getProperty(self._node)
	prop.scaleY = scaleY
	TASK_setProperty(self._node, prop)
	updateUINodePos(self)
end

function UINode:setScale(sx, sy)
	local prop = TASK_getProperty(self._node)
	prop.scaleX = sx
	prop.scaleY = sy
	TASK_setProperty(self._node, prop)
	updateUINodePos(self)
end

