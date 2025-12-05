-- the idea here is that programs add to a list of "events" so that instead of the ui frezing because its waiting on a event that never comes. it can store the updates and go thrugh them before desplaying the data.
-- see listener.lua to see how the "event listener" works
-- quite honestly. this method does not have any advantage over just writing directly to a json file... exept that 2 programs will never read and write to the same file at the same time. no idea if thats acctually a dealbreaker... but why risk it?



local STATUS = {}

local function writeStatusSnapshot(field, value)
    local program = shell.getRunningProgram()
    local path = fs.combine("status", "datastream.json")
    -- make sure the "status" folder exists
    fs.makeDir("status")
    local data = {}
    if fs.exists(path) then
        local h = fs.open(path, "r")
        local content = h.readAll()
        h.close()
        data = textutils.unserializeJSON(content) or {}
    end

    data.program = program
    if field == "state" or field == "message" or field == "program" then
        data[field] = value
    else
        data.custom = data.custom or {}
        data.custom[field] = value
    end


    local outfile = fs.open(path, "w+")
    if not outfile then
        print("writeStatusSnapshot: fs.open FAILED for", path)
        return
    end

    outfile.write(textutils.serializeJSON(data))
    outfile.close()
end

function STATUS.set(field, value)
    writeStatusSnapshot(field, value)
end

function STATUS.state(val)   STATUS.set("state",   val) end
function STATUS.message(val) STATUS.set("message", val) end
function STATUS.program(val) STATUS.set("program", val) end

fs.delete(fs.combine("status", "datastream.json"))
return STATUS
