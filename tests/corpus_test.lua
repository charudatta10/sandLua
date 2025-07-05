
package.path = package.path .. ';./tests/?.lua;./src/?.lua'
package.cpath = package.cpath .. ';C:/Users/korde/scoop/apps/luarocks/current/rocks/lib/lua/5.4/?.dll'

local lu = require('luaunit')
local loader = require('core.loader')
local helpers = require('utils.helpers')

TestCorpus = {}

function TestCorpus:testCorpus()
    local corpus_dir = 'tests/elfs/bin/'
    local files = helpers.scandir(corpus_dir)

    for _, file in ipairs(files) do
        if file ~= "." and file ~= ".." then
            local filepath = corpus_dir .. file
            print("Testing: " .. filepath)
            local binary = loader.load(filepath)
            lu.assertNotIsNil(binary, "Failed to load: " .. filepath)
        end
    end
end

os.exit(lu.LuaUnit.run())
