-- statusLogic.lua
-- Pure logic; no UI code here. -- let the spaghetiicode flow!!!! >:)... from the other files... into here... they dont need to know.... you can show them the pretty code. not this one.... please...... :(

local M = {}
local listener  = require("listener")

-- Right-align to 4 chars
local function r4(txt)
    txt = tostring(txt)
    if #txt >= 4 then return txt end
    return string.rep(" ", 4 - #txt) .. txt
end

----------------------------------------------------------------
-- TURTLE NAME
----------------------------------------------------------------
function M.getTurtleName()
    return os.getComputerLabel() or "NoName"
end

----------------------------------------------------------------
-- ACTIVE PROGRAM NAME
----------------------------------------------------------------
function M.getProgramName()
    return M._programOverride or multishell.getTitle(1) or "Unknown"
end

function M.setProgramName(name)
    M._programOverride = name
end
--is this used anywhere?

----------------------------------------------------------------
-- FUEL FORMAT
----------------------------------------------------------------
function M.formatFuel(raw)
    if raw == "unlimited" then return "INF" end
    if type(raw) ~= "number" then return "???" end

    if raw < 1000 then
        return r4(raw)
    elseif raw < 10000 then
        return string.format("%4s", string.format("%.1fk", raw / 1000))
    elseif raw < 100000 then
        return r4(math.floor(raw / 1000) .. "k")
    else
        return "Full"
    end
end

----------------------------------------------------------------
-- FUEL
----------------------------------------------------------------
function M.getFuel()
    if not turtle then return nil, "N/A" end
    local level = turtle.getFuelLevel()
    return level, M.formatFuel(level)
end

----------------------------------------------------------------
-- strypy lists
----------------------------------------------------------------
function M.applyStripes(container, first, second)
    local line = container:getChildren()
    for i, child in pairs(line) do
        if i % 2 == 0 then
            child:setBackground(first)
        else
            child:setBackground(second)
        end
    end
end

----------------------------------------------------------------
-- constrain to height:
----------------------------------------------------------------


function M.autoHeight(container, pad)
    pad = pad or 0

    local children = container:getChildren()
    local maxBottom = 0

    for _, child in pairs(children) do
        local _, y = child:getPosition()
        local _, h = child:getSize()

        local bottom = y + h
        if bottom > maxBottom then
            maxBottom = bottom
        end
    end

    if maxBottom > 0 then
        container:setHeight(maxBottom+pad)
    end
end

function M.autoWidth(container, pad) -- pad = padding
    pad = pad or 0

    local children = container:getChildren() or 0
    local maxRight = 0

    for _, child in pairs(children) do
        local x, _ = child:getPosition()
        local w, _ = child:getSize()

        local right = x + w
        if right > maxRight then
            maxRight = right
        end
    end

    if maxRight > 0 then
        container:setWidth(maxRight+pad)
    end
end

function M.autosize(container, padW, padH)
    M.autoWidth(container, padW)
    M.autoHeight(container, padH)
end


----------------------------------------------------------------
-- Windowpacking
----------------------------------------------------------------


function M.windowPacking(container, windows, paddingX, paddingY)
    paddingX = paddingX or 1
    paddingY = paddingY or 1

    local contW, contH = container:getSize()

    -- if width is 0 for some reason, fall back to parent width
    if contW == 0 then
        local parent = container:getParent()
        if parent then
            contW, contH = parent:getSize()
        end
    end

    local x = 1
    local y = 1
    local rowMaxH = 0

    for _, win in ipairs(windows) do
        local w, h = win:getSize()

        -- wrap to next row if this window would overflow to the right
        if x + w - 1 > contW then
            x = 1
            y = y + rowMaxH + paddingY
            rowMaxH = 0
        end

        win:setPosition(x, y)

        if h > rowMaxH then
            rowMaxH = h
        end

        x = x + w + paddingX
    end

    -- required height to fit all rows
    local neededHeight = y + rowMaxH - 1

    local _, curH = container:getSize()
    if neededHeight > curH then
        container:setSize(contW, neededHeight)
    end
end



--------------------------
-- debug out:
--------------------------
-- looking to make 2 versions right now, 1 that just outputs to a file, and later 1 that outputs to a new tab, for now im happy with something that outputs to a file:

function M.debugDump(dump, name)
    fs.makeDir("debug") -- can be used to make sure debug was called
    -- default file name
    local fileName = name and fs.combine("debug", name) or "debug/debug.json"

    if fs.getFreeSpace("") > 10000 then
        local h = fs.open(fileName, "w+") -- w+ to not take up more space than needed.
        if not h then
            print("debugDump: Could not open file:", fileName)
            return
        end
        if pcall(textutils.serializeJSON, dump) then
            encoded = textutils.serialize(dump)
        else
            encoded = dump -- if stupid human passed me a object that dosent colapse in to a json object
        end

            --encoded = dump -- if stupid human passed me a object that dosent colapse in to a json object
        h.write(encoded)
        h.close()
    else
        print("Skipping dump: no disk space")
    end
end
----------------------------------------------------------------
-- Custom status window functions (a mixed bag of fun :D ) (needs to be sorted later) (all is used in M.customDataMain)
----------------------------------------------------------------


testdata = {
    state   = "done",
    program = "cobbleMiner.lua",
    message = "inventory full. stopping...",
    custom = {
        minedBlocks = 1,
        target = 128,
    },
}

function M.findOpenSpotInFrame(playfield, window)
    return 1, 1
    --[[
    i just realised how i want this to work:
    if playfield has no child: return 1 1
    for each child in playfield do
        get the width and height of window and see if i can put it right of child
            then return that cordinate
        if window would be out of bounds:

        2 options how to do the logic
        per child:
            se if window fits under    
        per line:
            for each vertical line in see if window fits if you put it in the lowest available value per line --

        update:
          this algorithm has problem. if the boxes has moved so that the 1, 1 position is open... returning to this later
    wanted functionality:
    find a open space,
    prioritise packing horizontal over vertical....
    wait... is it just:
    for x
        for y
            can it fit?
                return x, y 
    nooo therse nasty edge cases...
    ok new idea:
    try to 
    if child exists
        try putting right of existing child but still at vertical=1:
            if not overlap or out of bound horizontaly:
                return x, y
            else
                increase distance from top
    nope...... 
    ok.... assume that if you can put it at the top anywhere... then do
    if you can put the window anywhere that would not increse the vertical then do
    else put it as far to the left and then as far upp as you can,
    ]]--

end
function M.FormatListenData(inData) -- working

    if not inData or not inData.custom then
        return {}
    end
    local outData = {}
    for dataKey, dataValue in pairs(inData.custom) do
        if type(dataValue) ~= "table" then
            outData[dataKey] = {
                key = tostring(dataKey),
                title = tostring(dataKey),
                text = tostring(dataValue) -- i want this formatted as a normal list, the simple custom window will just 
            }
                --type = "simpleText"  -- functionality not added yet
        else
            M.debugDump({error = "unexpected data in M.FormatListenData", object = inData})
        end
    end
    return outData
end
local function IsCustomWindow(child)
    return child._isCustomWindow == true
end
local function RemoveWindow(Container, child) -- this is useless ctrl-f replace later
    Container:removeChild(child) 
end
local function HasValueChanged(window, newValue)
    return tostring(window._lastValue) ~= tostring(newValue)
end
local function needsToUpdate()
    return true
end



function M.customFieldLogic(parent)
    -- 1. Get all children of the *playfield* frame.
    local indata = parent:getChildren() or { fakeChild1, fakeChild2 }

    -- 2. Get the current custom data as a normalized table.
    local statusTable = M.FormatListenData(listener.read())
    local outData = {}
    local seenKeys = {}

    ----------------------------------------------------------------
    -- PASS 1: walk existing children (windows) and decide:
    --         - update (if key still exists, and value changed)
    --         - remove (if key no longer exists)
    --         - nothing (if key still exists and no change)
    ----------------------------------------------------------------
    for _, child in pairs(indata) do
        local key = child._customKey
        if key ~= nil then
            local entry = statusTable[key] 

            if entry ~= nil then
                -- makes logic not remove the child later
                seenKeys[key] = true
                local newValue = entry.text or entry.value

                if HasValueChanged and HasValueChanged(child, newValue) then
                    table.insert(outData, -- adds the order:
                        customFieldLogicCompilerHelper("update", child, entry, key) -- update the child  with "this new data"
                    )
                end
            else
                -- Key does NOT exist in statusTable. this window should be removed.
                
                table.insert(outData, -- adds the order:
                    customFieldLogicCompilerHelper("remove", child, nil, key) -- remove the child
                )
            end
        end
    end

    ----------------------------------------------------------------
    -- PASS 2: for any keys in statusTable we didn't "see" in children,
    --         we need to ADD new windows.
    ----------------------------------------------------------------
    for key, entry in pairs(statusTable) do
        if not seenKeys[key] then
            table.insert(outData, -- adds the order
                customFieldLogicCompilerHelper("add", key, entry, key) -- add a window with the name of key and give it the entry data (last key is location data)
            )
        end
    end

    ----------------------------------------------------------------
    -- RESULT
    -- outData is now a list of instructions like:
    --   {
    --     {<child1>, {action="update", key="minedBlocks", text="5" }},
    --     {<child2>, {action="remove", key="debug" }},
    --     {"target",      {action="add",    key="target", title="target", text="128" }}
    --   }
    -- The caller (customDataField) will apply these:
    --   - "add"    → create new window at some position
    --   - "update" → change text/value on existing window
    --   - "remove" → call RemoveWindow(parent, child)
    ----------------------------------------------------------------
    -- M.debugDump({error = "no error", data = outData})
    return outData
end
function customFieldLogicCompilerHelper(actionText, handle, objectReference, key)
    return {
        handle,  -- first element: child frame or key string
        {
            action = actionText,
            key    = key,
            title  = objectReference and objectReference.title,
            text   = objectReference and objectReference.text,
        }
    }
end

local fakeChild1 = { _customKey = "minedBlocks", _lastValue = "1" }
local fakeChild2 = { _customKey = "debugInfo",   _lastValue = "old debug" }

local fakeChildren = { fakeChild1, fakeChild2 }

local fakeParent = {
    getChildren = function()
        return fakeChildren
    end
}
local pretty = require "cc.pretty"
test = fakeParent:getChildren()

local instructions = M.customFieldLogic(fakeParent)



return M
