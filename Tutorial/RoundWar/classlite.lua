local _class={}
 
function classlite(super)
	local class_type={}
	class_type.ctor=false
	class_type.super=super
	if super ~= nil then
		class_type.superCall = function(c, funcName, ...)
			return _class[super][funcName](c, ...);
		end
	end
	class_type.thisCall = function(c, funcName, ...)
		return _class[class_type][funcName](c, ...);
	end
	class_type.new=function(...) 
		local obj={}
		do
			local create
			create = function(c,...)
				if c.super then
					create(c.super,...)
				end
				if c.ctor then
					c.ctor(obj,...)
				end
			end

			create(class_type,...)
		end
		setmetatable(obj,{ __index=_class[class_type] })
		return obj
	end

	local vtbl={}
	_class[class_type]=vtbl
 
	setmetatable(class_type, {__newindex=
		function(t,k,v)
			vtbl[k]=v
		end
	})
 
	if super then
		setmetatable(vtbl,{__index=
			function(t,k)
				local ret=_class[super][k]
				vtbl[k]=ret
				return ret
			end
		})
	end
 
	return class_type
end

function thisCallLite(self, classType, funcName, ...)
	return _class[classType][funcName](self, ...);
end

function superCallLite(self, classType, funcName, ...)
	if classType.super ~= nil then
		return _class[classType.super][funcName](self, ...);
	else
		return nil;
	end
end

function classInfo(classType)
	return _class[classType]
end

function dumpClasses()
	syslog(table.tostring(_class))
end

function superClass(classType)
	return (classType.super) and _class[classType.super] or nil
end

function thisClass(classType)
	return _class[classType]
end