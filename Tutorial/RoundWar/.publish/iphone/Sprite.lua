require("Node")

Sprite = classlite(Node)

local function updateDisplay(self)
	local prop = TASK_getProperty(self._node)
	prop.index = self._index
	prop.x 	   = self._pt[1] + prop.scaleX * self._offset[1]
	prop.y     = self._pt[2] + prop.scaleY * self._offset[2]
	--syslog("updateDisplay:pt={" .. self._pt[1] .. "," .. self._pt[2] .. "}")
	--syslog("updateDisplay:offset={" .. self._offset[1] .. "," .. self._offset[2] .. "}")
	--syslog("updateDisplay:scale={" .. prop.scaleX .. "," .. prop.scaleY .. "}")
	--syslog("updateDisplay:x,y={" .. prop.x .. "," .. prop.y .. "}")	
	TASK_setProperty(self._node, prop)
end

local function setDisplayFrame(self, index, offset)
	self._index 	= index
	self._offset	= offset
	updateDisplay(self)
end

function Sprite:ctor(parent, zorder, x, y, assetFile, firstOffset)
	self._pt = {x, y}
	local assetList
	if type(assetFile) == "string" then assetList = { assetFile }
	else assetList = assetFile end
	if firstOffset == nil then firstOffset = {0, 0} end
	self._node = UI_MultiImgItem(parent, zorder, x, y, assetList, 0)
	setDisplayFrame(self, 0, firstOffset)
end

function Sprite:setScaleX(scaleX)
	local prop = TASK_getProperty(self._node)
	prop.scaleX = scaleX
	TASK_setProperty(self._node, prop)
	updateDisplay(self)
end

function Sprite:setScaleY(scaleY)
	local prop = TASK_getProperty(self._node)
	prop.scaleY = scaleY
	TASK_setProperty(self._node, prop)
	updateDisplay(self)
end

function Sprite:setScale(sx, sy)
	local prop = TASK_getProperty(self._node)
	prop.scaleX = sx
	prop.scaleY = sy
	TASK_setProperty(self._node, prop)
	updateDisplay(self)
end

function Sprite:getDisplay()
	return self._index, self._offset 
end

function Sprite:setDisplay(index, offset)
	setDisplayFrame(self, index, offset)
end

function Sprite:setPos(x, y)
	self._pt = {x, y}
	updateDisplay(self)
end

function Sprite:getPos()
	return self._pt
end

