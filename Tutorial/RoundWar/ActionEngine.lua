local AM = {}
local _elements 	= {}
local _removedList	= {}

local function addToRemoveList(target, action)
	local elem = _removedList[target]
	if elem == nil then 
		elem = {}
		_removedList[target] = elem
	end

	for _,act in ipairs(elem) do
		if act == action then return end
	end

	--action:stop()
	elem[#elem + 1] = action
end

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
			--action:stop()
			addToRemoveList(target, action)
		end
		--[[
		if removeFromList then
			_elements[target] = nil
		end
		--]]
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
				--[[
				table.remove(elem.actions, idx)
				action:stop()
				--]]
				addToRemoveList(target, action)
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
				--[[
				table.remove(elem.actions, idx)
				action:stop()
				--]]
				addToRemoveList(target, action)
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
		elem.paused = false
	end
end

function AM.update(dt)
	-- remove
	for target, removed in pairs(_removedList) do
		local running = {}
		local elem = _elements[target]
		for _, action in ipairs(elem.actions) do
			local found = false
			for _, act in ipairs(removed) do
				if act == action then
					found = true
					action:stop()
					break
				end
			end

			if not found then
				running[#running + 1] = action
			end
		end

		if #running == 0 then
			_elements[target] = nil
		else
			_elements[target] = {paused=elem.paused, actions=running}
		end
	end
	_removedList = {}

	for target,elem in pairs(_elements) do
		if not elem.paused then
			for _, action in ipairs(elem.actions) do
				action:step(dt)
				if action:isDone() then
					addToRemoveList(target, action)
				end
			end
		end
	end
end

local modname = "ActionEngine"
local proxy = {}
local mt    = {
    __index = AM,
    __newindex =  function (t ,k ,v)
        print("attemp to update a read-only table")
    end
} 
setmetatable(proxy, mt)
_G[modname] = proxy
package.loaded[modname] = proxy