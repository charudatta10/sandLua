-- src/utils/helpers.lua
-- Placeholder for utility functions
local helpers = {}
function helpers.is_readable(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end
return helpers
