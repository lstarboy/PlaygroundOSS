require("classlite")

A = classlite()

function A:ctor()
	--self._t = 0
end

function A:update()
	syslog("A:update")
end

function A:step()
	self:update()
end

B = classlite(A)

function B:ctor()
end

function B:update()
	--superClass(B).update(self)
	superClass(B):update()
	thisClass(A).update(self)
	syslog("B:update")
end

function B:callback(f)
	f()
end

C = classlite()

function C:ctor()
	self.tag = 0
end

function C:f()
	syslog("C:f")
end

function C:test()
	local b = B.new()
	b:callback(function() self:f() end)
	--self:f()
end