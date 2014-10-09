local M = {}
local _animations = {}

function M.addAnimation(name, animation)
	_animations[name] = animation
end

function M.addAnimationFromFile(file)
	local spr = CONV_JsonFile2Lua(file)
	if type(spr) == "table" then
		spr.assests = {}
		spr.actions = {}
		--spr.offset  = {-0.5 * spr.width, -0.5 * spr.height}
		spr.firstOffset = nil
		for _, act in ipairs(spr.acts) do
			local action = { offset={}, size={}, start=#spr.assests, frameCnt=#act.frames }
			for _, frame in ipairs(act.frames) do
				local curOffset = {frame.offset[1] - 0.5 * spr.width, frame.offset[2] - 0.5 * spr.height}
				spr.assests[#spr.assests + 1] = "asset://" .. spr.name .. "/" .. frame.file .. ".imag"
				action.offset[#action.offset + 1] = curOffset
				action.size[#action.size + 1] = frame.size
				if spr.firstOffset == nil then spr.firstOffset = curOffset end
			end
			--action.poffset = spr.offset
			spr.actions[act.name] = action
		end
		spr.acts = nil
		_animations[spr.name] = spr
	end
end

function M.removeAnimation(name)
	_animations[name]= nil
end

function M.getAnimation(name)
	return _animations[name]
end

function M.getAnimationAssetFiles(name)
	local a = _animations[name]
	if a == nil then return nil end
	--return a.assests, { a.offset[1] + a.firstOffset[1], a.offset[2] + a.firstOffset[2] }
	return a.assests, a.firstOffset
end

function M.getAnimationAct(name, act)
	local a = _animations[name]
	if a == nil then return nil end
	return a.actions[act]	
end

function M.getAnimationActFrameInfo(name, act, idxInAct)
	local act = M.getAnimationAct(name, act)
	if act ~= nil then
		if idxInAct < 0 then idxInAct = act.frameCnt + 1 + idxInAct end
		if idxInAct > 0 and idxInAct <= act.frameCnt then
			return (act.start + idxInAct - 1), act.offset[idxInAct] 
		end
	end
	return nil, nil
end

function M.getFrameInfoFromAnimationAct(act, idxInAct)
	if idxInAct < 0 then idxInAct = act.frameCnt + 1 + idxInAct end
	if idxInAct > 0 and idxInAct <= act.frameCnt then
		return (act.start + idxInAct - 1), act.offset[idxInAct] 
	end
	return nil, nil	
end

local modname = "AnimationCache"
local proxy = {}
local mt    = {
    __index = M,
    __newindex =  function (t ,k ,v)
        print("attemp to update a read-only table")
    end
} 
setmetatable(proxy, mt)
_G[modname] = proxy
package.loaded[modname] = proxy