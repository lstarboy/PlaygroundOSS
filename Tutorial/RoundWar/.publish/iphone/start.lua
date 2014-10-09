require("test")

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
