include("asset://Action.lua")

local AM = {}
local _elements = {}

function AM.addAction(action, target)
	if action == nil or target == nil then return end
	local elem = _elements[target]
	if elem == nil then
		elem = { actions={} }
		_elements[target] = elem
	end
	elem.paused = false
	elem.actions[#elem.actions + 1] = action
	action:startWithTarget(target)
end

function AM.removeAllActions()
	for target,elem in pairs(_elements) do
		AM.removeAllActionsFromTarget(target, false)
	end
	_elements = {}
end

function AM.removeAllActionsFromTarget(target, removeFromList)
	if target == nil then return end
	if removeFromList == nil then removeFromList = true end
	local elem = _elements[target]
	if elem ~= nil then
		for _,action in ipairs(elem.actions) do
			action:stop()
		end
		if removeFromList then
			_elements[target] = nil
		end
	end
end

function AM.removeAction(action)
	if action == nil then return end
	local target = action:getOriginTarget()
	if target == nil then return end
	local elem = _elements[target]
	if elem ~= nil then
		for idx,act in ipairs(elem.actions) do
			if act == action then
				table.remove(elem.actions, idx)
				action:stop()
				break
			end
		end
	end
end

function AM.removeActionByTag(tag, target)
	if target == nil or tag == Action.InvalidTag then return end
	local elem = _elements[target]
	if elem ~= nil then
		for idx,action in ipairs(elem.actions) do
			if action:getTag() == tag then
				table.remove(elem.actions, idx)
				action:stop()
				break
			end
		end
	end
end

function AM.getActionByTag(tag, target)
	if target == nil or tag == Action.InvalidTag then return nil end
	local elem = _elements[target]
	if elem ~= nil then
		for idx,action in ipairs(elem.actions) do
			if action:getTag() == tag then
				return action
			end
		end
	end

	return nil
end

function AM.pauseTarget(target)
	if target == nil then return end
	local elem = _elements[target]
	if elem ~= nil then
		elem.paused = true
	end
end

function AM.resumeTarget(target)
	if target == nil then return end
	local elem = _elements[target]
	if elem ~= nil then
		elem.paused = true
	end
end

function AM.update(dt)
	local removedTarget = {}
	for target,elem in pairs(_elements) do
		if not elem.paused then
			local removed = {}
			for idx, action in ipairs(elem.actions) do
				action:step(dt)
				if action:isDone() then
					action:stop()
					removed[#removed + 1] = idx
				end
			end

			for i=#removed,1,-1 do
				table.remove(elem.actions, removed[i])
			end

			if #elem.actions == 0 then
				removedTarget[#removedTarget + 1] = target
			end
		end
	end

	for _,target in ipairs(removedTarget) do
		_elements[target] = nil
	end
end

local modename = "ActionManager"
local proxy = {}
local mt    = {
    __index = AM,
    __newindex =  function (t ,k ,v)
        print("attemp to update a read-only table")
    end
} 
setmetatable(proxy, mt)
_G[modename] = proxy
package.loaded[modename] = proxy