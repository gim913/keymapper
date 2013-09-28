local ffi = require('ffi')
ffi.cdef[[
int32_t RegOpenKeyExA(void* hKey, const char* lpSubKey, uint32_t reserved, uint32_t samDesired, void** phkResult);
int32_t RegQueryValueExA(void* hKey, const char* lpValueName, uint32_t* reserved, uint32_t* type, uint8_t* outData, uint32_t* outDataSize);
#pragma pack(1)
typedef struct { uint16_t dst; uint16_t src; } ScancodeMapping;
typedef struct { uint32_t version, flags, count; } ScancodeHeader;
#pragma pack()
]]

require('scancode1')

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
	if bufSize < 12 then
		print("Invalid data in 'Scancode map'")
		return
	end
	local t = ffi.cast('ScancodeHeader*', buf)
	if t.version ~= 0 or t.flags ~= 0 or (bufSize-12)/4 ~= t.count then
		print("Invalid header in 'Scancode map'")
		return
	end

	-- +8 not +12 to make lua-like loop from 1,not from 0 :>
	local m = ffi.cast('ScancodeMapping*', buf+8)
	if m[t.count].src ~= 0 or m[t.count].dst ~= 0 then
		print("'Scancode map' doesn't have terminating entry")
		return
	end
	for i=1,t.count do
		print(("%d Pressing %04x will generate %04x"):format(i, m[i].src, m[i].dst))
	end
end

local function main()
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
		local temp = dataSize[0]
		local buf = ffi.new('uint8_t[?]', dataSize[0])
		ret = ffi.C.RegQueryValueExA(k[0], "Scancode Map", nil, nil, buf, dataSize)
		if ret == 0 and dataSize[0] == temp then
			parseData(buf, dataSize[0])
		end
	end
end

main()
