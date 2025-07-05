-- src/core/hexview.lua
-- Placeholder for the hex viewer
-- src/core/hexview.lua
--
-- The core hex viewer module.
--
-- This module provides functionality to create a hex dump of binary data.

local hexview = {}

-- Dumps data in a classic hexdump format (offset, hex, ascii).
function hexview.dump(data, address)
    address = address or 0
    local bytes_per_line = 16

    for i = 1, #data, bytes_per_line do
        local chunk = data:sub(i, i + bytes_per_line - 1)
        local offset = address + i - 1

        -- Print the offset
        io.write(string.format("0x%08X: ", offset))

        -- Print the hex bytes
        local hex_part = ""
        for j = 1, #chunk do
            hex_part = hex_part .. string.format("%02X ", chunk:byte(j))
        end
        io.write(string.format("%-48s", hex_part))

        -- Print the ASCII representation
        local ascii_part = ""
        for j = 1, #chunk do
            local byte = chunk:byte(j)
            if byte >= 32 and byte <= 126 then
                ascii_part = ascii_part .. string.char(byte)
            else
                ascii_part = ascii_part .. "."
            end
        end
        io.write(ascii_part .. "\n")
    end
end

return hexview
