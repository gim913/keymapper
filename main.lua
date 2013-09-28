local ffi = require('ffi')
ffi.cdef[[
int32_t RegOpenKeyExA(void* hKey, const char* lpSubKey, uint32_t reserved, uint32_t samDesired, void** phkResult);
int32_t RegQueryValueExA(void* hKey, const char* lpValueName, uint32_t* reserved, uint32_t* type, uint8_t* outData, uint32_t* outDataSize);
]]

local Hkey = {
	Local_Machine = ffi.cast("void*", 0x80000002)
}

local Access = {
	Key_Write = 0x0020006
	,Key_Read = 0x0020019
	,Key_RW = 0x002001f 
}

local Error = {
	Access_Denied = 5
}

local function parseData(buf, bufSize)
end

local k = ffi.new("void*[1]", nil)
local ret = ffi.C.RegOpenKeyExA(Hkey.Local_Machine, "SYSTEM\\CurrentControlSet\\Control\\Keyboard Layout", 0, Access.Key_RW, k)
if ret == 5 then
	print ('You need administrator privileges to alter scancode map')
	return 2
end

if ret ~= 0 then
	print("couldn't open key, quitting")
	return 3
end

local dataSize = ffi.new("uint32_t[1]", 0)

-- query for the number of bytes we'll need to allocate
ret = ffi.C.RegQueryValueExA(k[0], "Scancode Map", nil, nil, nil, dataSize)
if ret == 0 then
	local temp == dataSize[0]
	local buf = ffi.new('uint8_t[?]', dataSize[0])
	ret = ffi.C.RegQueryValueExA(k[0], "Scancode Map", nil, nil, buf, dataSize)
	if ret == 0 and dataSize[0] == temp then
		parseData(buf, dataSize[0])
	end
end

