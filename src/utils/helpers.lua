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
function helpers.scandir(path)
    local files = {}
    local lfs = require("lfs")
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            table.insert(files, file)
        end
    end
    return files
end

return helpers
