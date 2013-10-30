local ffi = require('ffi')
ffi.cdef[[
int32_t RegOpenKeyExA(void* hKey, const char* lpSubKey, uint32_t reserved, uint32_t samDesired, void** phkResult);
int32_t RegQueryValueExA(void* hKey, const char* lpValueName, uint32_t* reserved, uint32_t* type, uint8_t* outData, uint32_t* outDataSize);
int32_t RegSetValueExA(void* hKey, const char* lpValueName, uint32_t reserved, uint32_t type, uint8_t* data, uint32_t dataSize);
#pragma pack(1)
typedef struct { uint16_t dst; uint16_t src; } ScancodeMapping;
typedef struct { uint32_t version, flags, count; } ScancodeHeader;
#pragma pack()
]]

require('scancode1')
-- if for some unknown reason, you have keyboard
-- that isn't even good enough to throw it to trash,
-- you might want to use scancode2, a.k.a. us set 2
--require('scancode2')
--
-- there is also us set 3 which seems a bif more sensible than us-2
-- but I'll probably add it later

require('mapping')

local Hkey = {
	Local_Machine = ffi.cast("void*", 0x80000002)
}

local ValType = {
	Binary = 3
}

local Access = {
	Key_Write = 0x0020006
	,Key_Read = 0x0020019
	,Key_RW = 0x002001f 
}

local Error = {
	Access_Denied = 5
}

scancode_rev = {}
scancode_longest = 0
local function buildReverseMap()
	for k, v in pairs(scancode) do
		scancode_rev[v] = k
		scancode_longest = math.max(scancode_longest, #k)
	end
end

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

	local m = ffi.cast('ScancodeMapping*', buf+12)
	if m[t.count-1].src ~= 0 or m[t.count-1].dst ~= 0 then
		print("'Scancode map' doesn't have terminating entry")
		return
	end
	
	-- not pretty, but who cares ;p
	local fmtString = ("%%d. Pressing %% %ds will generate %% %ds (%%04x -> %%04x)"):format(scancode_longest, scancode_longest)
	for i=0,t.count-2 do
		print(fmtString:format(i, scancode_rev[m[i].src], scancode_rev[m[i].dst], m[i].src, m[i].dst))
	end
end

local function saveMapping(k)
	local mapLen = 0
	for _ in pairs(mapSrc) do mapLen = mapLen + 1 end
	local l = 12 + 4*(1 + mapLen)
	local buf = ffi.new('uint8_t[?]', l)
	local t = ffi.cast('ScancodeHeader*', buf)
	local m = ffi.cast('ScancodeMapping*', buf+12)
	t.version = 0
	t.flags = 0

	local i = 0
	for mSrc,mDst in pairs(mapSrc) do
		print (mSrc, mDst)
		m[i].src = mSrc
		m[i].dst = mDst
		i = i + 1
	end
	m[i].src = 0
	m[i].dst = 0
	t.count = i + 1

	local ret = ffi.C.RegSetValueExA(k[0], "Scancode Map", 0, ValType.Binary, buf, l);
	if ret ~= 0 then
		print('Some error occured while saving data, you better check it by hand...')
		return
	else
		print('Mapping saved in registry, verifying...')
	end
end

local function main()
	buildReverseMap()

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

	saveMapping(k)

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
