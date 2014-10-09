string.tohex = function(str, spacer)
	return (
		string.gsub(str,"(.)",
			function (c)
				return string.format("%02X%s", string.byte(c), spacer or "")
			end)
	)
end

string.trim = function(str)
	return string.gsub(str, "^%s*(.-)%s*$", "%1")
end
string.trimbegin = function(str)
	return string.gsub(str, "^%s*(.-)$", "%1")
end
string.trimend = function(str)
	return string.gsub(str, "^(.-)%s*$", "%1")
end

string.split = function(szFullString, szSeparator, ignoreBlank)
	if ignoreBlank == nil then ignoreBlank = true end
	local FindStartIndex = 1
	local SplitArray = {}
	local SubStr;
	while true do
		local FindLastIndex = string.find(szFullString, szSeparator, FindStartIndex)
		if not FindLastIndex then
			SubStr = string.sub(szFullString, FindStartIndex, string.len(szFullString));
			if string.len(SubStr) > 0 or not ignoreBlank then table.insert(SplitArray, SubStr) end
			break
		end
		SubStr = string.sub(szFullString, FindStartIndex, FindLastIndex-1);
		if string.len(SubStr) > 0 or not ignoreBlank then table.insert(SplitArray, SubStr) end
		FindStartIndex = FindLastIndex + string.len(szSeparator)
	end
	return SplitArray
end

string.startWith = function(src, substr)
	local s,e = string.find(src, substr);
	if s == nil or s ~= 1 then return false end
	return true;
end

string.endWith = function(src, substr)
	local s,e = string.find(src, substr);
	if s == nil or e ~= #src then return false end
	return true;
end

table.find = function(this, value)
	for k,v in pairs(this) do
		if v == value then return k end
	end
end

table.tostring = function(data)
	local visited = {}
	function dump(data, prefix)
		local str = tostring(data)
		if table.find(visited, data) ~= nil then return str end
		table.insert(visited, data)
		
		local prefix_next = prefix .. "  "
		str = str .. "\n" .. prefix .. "{"
		for k,v in pairs(data) do
			str = str .. "\n" .. prefix_next .. tostring(k) .. " = "
			if type(v) == "table" then
				str = str .. dump(v, prefix_next)
			else
				str = str .. tostring(v)
			end
		end
		str = str .. "\n" .. prefix .. "}"
		return str
	end
	return dump(data, "")
end

table.merge = function(base, delta)
	if type(delta) ~= "table" then return end
	for k,v in pairs(delta) do
		base[k] = v
	end
end

local _concat = table.concat
table.concat = function(tbl, sep, i, j)
	if type(sep) == "table" then
		for i,v in pairs(sep) do
			table.insert(tbl, v)
		end
	else
		_concat(tbl, sep, i, j)
	end
end

table.len = function(tbl)
	if type(tbl) ~= "table" then return 0 end
	local n = 0
	for k,v in pairs(tbl) do n = n + 1 end
	return n
end