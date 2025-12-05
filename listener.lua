-- this is the program that is run by the status project to find events that need updating, to be honest i think this code is garbage, atleast it will be easier to debug than having 2+ programs accessing the same file all the time....
-- im playing aroud with the idea that workers just write to json directly and having listener keep a json object that it updates instead... but im to inexperienced to know what is more optemised.


-- todo: see if element:onChange("x", function(self, newX) end) can be paired with os.pullevent("status") to make this easier. tradeoff is no default value. but i can live with that if the code becomes more optemised and easier to read.

local STATUS = {}
local default = {
            program = program or "N/A",
            state   = "idle ",
            message = "awaiting...",
            custom  = {},
        }
local defaultPath = fs.combine("status", "datastream.json")
local function readProgramStatus()
    path = defaultPath
    if not fs.exists(path) then
        os.queueEvent("debug", "no list found" .. path) -- see the data
        return default
    end

    local h = fs.open(path, "r")
    local content = h.readAll()
    h.close()
    
    local data = textutils.unserializeJSON(content) or {}
    data.custom = data.custom or {}
    os.queueEvent("debug", data) -- see the data
    return data
end

-- For now, just read the status of the cobble miner program:
function STATUS.read()
    return readProgramStatus()  -- or detect active program
end

function STATUS.reset()
    fs.delete(defaultPath)
end

return STATUS
