include("asset://classlite.lua")
include("asset://test.lua")
include("asset://Action.lua")
include("asset://ActionInterval.lua")
include("asset://AnimationCache.lua")
include("asset://ActionInstant.lua")
include("asset://ActionEase.lua")
include("asset://ActionEngine.lua")
include("asset://Common.lua")
include("asset://Node.lua")
include("asset://Sprite.lua")
include("asset://Soldier.lua")

function setup()
	local c = C.new()
	local b = B.new()
	b:update()
	c:test()
end

function execute(deltaT)
	sysLoad("asset://BattleField.lua")	
end

function leave()

end
