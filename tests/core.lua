
package.path = package.path .. ';./tests/?.lua;./src/?.lua'
local lu = require('luaunit')
require('src.core.loader')

TestLoader = {}

function TestLoader:testLoad()
    -- This is a placeholder test.
    -- We will add a real test once we have a sample ELF file.
    lu.assertEquals(true, true)
end

os.exit(lu.LuaUnit.run())
