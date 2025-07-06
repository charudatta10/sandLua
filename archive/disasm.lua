-- unified_disasm_repl.lua
local ffi = require("ffi")
package.path = package.path .. ";C:/Users/korde/scoop/apps/luarocks/current/rocks/share/lua/5.4/?.lua"

local pe = require("pe-parser")


-- Capstone FFI bindings
ffi.cdef[[
typedef unsigned long long uint64_t;
typedef struct cs_insn {
  uint64_t address;
  char mnemonic[32];
  char op_str[160];
} cs_insn;

int cs_open(int arch, int mode, size_t* handle);
int cs_disasm(size_t handle, const uint8_t* code, size_t size,
              uint64_t addr, size_t count, cs_insn** insn);
void cs_free(cs_insn* insn, size_t count);
int cs_close(size_t* handle);
]]
local capstone = ffi.load("./capstone.dll")

-- Map architecture identifiers
local arch_map = { x86 = 0, arm = 1, arm64 = 2 }
local mode_map = { ["16"] = 1, ["32"] = 2, ["64"] = 3, arm = 0, thumb = 1, default = 0 }

-- Detect format (PE or ELF)
local function detect_format(path)
  local f = assert(io.open(path, "rb"))
  local magic = f:read(4)
  f:close()
  if magic:sub(1, 2) == "MZ" then return "pe" elseif magic == "\x7fELF" then return "elf"
  else return "unknown" end
end

-- Parse PE and list sections


local function parse_pe(path)
  local obj = pe.parse(path)
  if not obj then error("❌ Failed to parse PE file") end

  local arch, mode = "x86", "64"
  local entry = obj.optional_header and obj.optional_header.AddressOfEntryPoint or 0
  local sections = {}

  for _, s in ipairs(obj.sections or {}) do
  if s.characteristics and (s.characteristics and 0x20 ~= 0) then
    table.insert(sections, {
      name = s.name,
      addr = s.virtual_address,
      size = s.size_of_raw_data,
      data = s.data
    })
  end
  end
print("📚 Sections:")
for i, s in ipairs(sections) do
  print(string.format("[%d] %s @ 0x%x (%d bytes)", i, s.name, s.addr, s.size))
end
  return sections, entry, arch, mode
end


-- Parse ELF and list sections (minimal)
local function parse_elf(path)
  local f = assert(io.open(path, "rb"))
  local data = f:read("*all")
  f:close()

  local function u32(offset)
    local b = {data:byte(offset+1, offset+4)}
    return b[1] + b[2]*0x100 + b[3]*0x10000 + b[4]*0x1000000
  end

  local entry = u32(24)
  local e_machine = data:byte(19) + data:byte(20)*256
  local arch, mode = "x86", "32"
  if e_machine == 0x28 then arch, mode = "arm", "arm"
  elseif e_machine == 0x3e then arch, mode = "x86", "64"
  elseif e_machine == 0xb7 then arch, mode = "arm64", "default" end

  local shoff, entsize, count = u32(32), data:byte(46) + data:byte(47)*256, data:byte(48) + data:byte(49)*256
  local sections = {}
  for i = 0, count - 1 do
    local base = shoff + i * entsize
    local sh_type = u32(base + 4)
    local sh_flags = u32(base + 8)
    local addr, off, size = u32(base + 12), u32(base + 16), u32(base + 20)
    if size > 0 and addr ~= 0 and sh_flags and 0x4 ~= 0 then
      local seg = data:sub(off + 1, off + size)
      table.insert(sections, { name = string.format("sect_%d", i), data = seg, addr = addr, size = #seg })
    end
  end
  return sections, entry, arch, mode
end

-- Run Capstone disassembler
local function disasm(code, addr, arch, mode)
  local handle = ffi.new("size_t[1]")
  assert(capstone.cs_open(arch_map[arch], mode_map[mode], handle) == 0)
  local insn_ptr = ffi.new("cs_insn*[1]")
  local count = capstone.cs_disasm(handle[0], code, #code, addr, 0, insn_ptr)

  local lines = {}
  for i = 0, count - 1 do
    local insn = insn_ptr[0][i]
    table.insert(lines, string.format("0x%x:\t%s\t%s", tonumber(insn.address), ffi.string(insn.mnemonic), ffi.string(insn.op_str)))
  end
  capstone.cs_free(insn_ptr[0], count)
  capstone.cs_close(handle)
  return lines
end

-- Main REPL loop
print("🔬 Unified Capstone REPL — Supports PE + ELF + Android Binaries\n")
while true do
  io.write("file> ")
  local path = io.read()
  if not path or path == "exit" then break end

  local format = detect_format(path)
  local sections, entry, arch, mode

  local ok, err = pcall(function()
    if format == "pe" then
      sections, entry, arch, mode = parse_pe(path)
    elseif format == "elf" then
      sections, entry, arch, mode = parse_elf(path)
    else
      error("Unsupported or unrecognized format.")
    end
  end)
  if not ok then print("❌ Error: " .. err) goto continue end

  print(string.format("📦 Format: %s | Arch: %s/%s | Entry: 0x%x\n", format, arch, mode, entry))
  print("📚 Sections:")
  for i, s in ipairs(sections) do
    print(string.format("[%d] %s @ 0x%x (%d bytes)", i, s.name, s.addr, s.size))
  end

  io.write("section> ")
  local index = tonumber(io.read())
  if not index or not sections[index] then print("⚠️ Invalid section.") goto continue end

  local sec = sections[index]
  print(string.format("🧠 Disassembling section '%s' starting at 0x%x...\n", sec.name, sec.addr))
  local lines = disasm(ffi.cast("const uint8_t*", sec.data), sec.addr, arch, mode)
  for _, line in ipairs(lines) do print(line) end

  io.write("💾 Save output to file? (y/n): ")
  if io.read():lower() == "y" then
    io.write("filename> ")
    local fname = io.read()
    local f = assert(io.open(fname, "w"))
    for _, l in ipairs(lines) do f:write(l .. "\n") end
    f:close()
    print("✅ Saved to " .. fname)
  end

  ::continue::
end