-- statusWidgets.lua
-- idea here is to have a file that makes "lego pices" trying to keep this as clean as possible with as much functions from basalt as possible and as little of other code as possible (ofloading it to statuslogic if possible)



local basalt = require("basalt")
local logic  = require("statusLogic")
local listener  = require("listener")

local M = {}

------------------------------------------------------------
-- FuelWidget (Frame + Label)
------------------------------------------------------------
function M.FuelWidget(parent)
    local root = parent:addFrame():setBackground(colors.gray)

    local label = root:addLabel()
        :setText("Fl: ???")
        :setForeground(colors.black)
        :setBackground(colors.orange)
        :setBackgroundEnabled(true)
        :setPosition(1,1)
        :setBorderLeft(true)

    function root:update()
        local _, t = logic.getFuel()
        local text = "Fl:" .. (t or "????")

        label:setText(text)
        root:setSize(#text, 1)
        label:setSize(#text, 1)
    end

    root:update()
    return root
end

------------------------------------------------------------
-- ProgramWidget
------------------------------------------------------------
function M.ProgramWidget(parent)
    local root = parent:addFrame():setBackground(colors.gray)

    local label = root:addLabel()
        :setText("Prog: ???")  ---wrong name on startup
        :setForeground(colors.white)
        :setBackground(colors.gray)
        :setBackgroundEnabled(true)

    function root:update()
        local prog = logic.getProgramName()
        local text = "Prog:" .. prog

        label:setText(text)
        root:setSize(#text, 1)
        label:setSize(#text, 1)
        label:setPosition(1,1)
    end

    root:update()
    return root
end

------------------------------------------------------------
-- TurtleNameWidget
------------------------------------------------------------
function M.TurtleNameWidget(parent)
    local root = parent:addFrame():setBackground(colors.gray)

    local label = root:addLabel()
        :setText("Turtle: ???")
        :setForeground(colors.white)
        :setBackground(colors.gray)
        :setBackgroundEnabled(true)

    function root:update()
        local name = logic.getTurtleName()
        local text = "T:" .. name

        label:setText(text)
        root:setSize(#text, 1)
        label:setSize(#text, 1)
        label:setPosition(1,1)
    end

    root:update()
    return root
end

------------------------------------------------------------
-- Button prototypes (INV / ABORT / CORD)
------------------------------------------------------------
local function makeButton(parent, txt, bg, fg)
    local btn = parent:addFrame():setBackground(bg)

    local label = btn:addLabel()
        :setText(txt)
        :setForeground(fg)
        :setBackground(bg)
        :setBackgroundEnabled(true)
        :setPosition(1,1)

    btn:setSize(#txt, 1)

    function btn:update()
        -- No dynamic data for now
    end
    --btn:update()
    return btn
end

function M.invButtonWidget(parent, mainframe)
    -- do return makeButton(parent, "[Inv]", colors.red, colors.white) end
    local invButton = parent:addFrame():setBackground(colors.red):setSize(5, 1)
    local clickable = invButton:addButton()
        :setPosition(1, 1)
        :setText("[Inv]")
        :setBackground(colors.red)
        :setForeground(colors.white)
        :setSize(5, 1)
        
    -- Add click handling
    clickable:onClick(function(self, button, x, y)
    -- Change appearance when clicked
    self:setBackground(colors.green)
    self:setText("[OWO]")

    -- Revert after delay
    basalt.schedule(function()
    sleep(1)
    self:setBackground(colors.red)
    self:setText("[Inv]")
    end)
    end)
    function invButton:update()-- update functions feels stupid... everything should be dynamic rather than running a constant loop, no?
        -- No dynamic data for now
    end
    return invButton
end

function M.AbortButtonWidget(parent)
    return makeButton(parent, "[X]", colors.red, colors.white)
end

function M.CordButtonWidget(parent)
    return makeButton(parent, "[C]", colors.lime, colors.black)
end


------------------------------------------------------------
-- list widget of dynamic constants 
------------------------------------------------------------

function M.ConstantsListWidget(parent)
    local root = parent:addFrame()
    local Program = M.ConstantsList_lineProgram(root)
    local State = M.ConstantsList_lineState(root)
    local Message = M.ConstantsList_lineMessage(root)
    Program:alignTop(root)
    State:below(Program, 1)
    --State:setHeight(3)
    Message:below(State, 1)
    logic.applyStripes(root, colors.gray, colors.black)
    root:setBorderBottom(false)
    root:setBorderColor(colors.white)
    logic.autoHeight(root, 0)
    function root:update()
        Program:update()
        State:update()
        Message:update()
        logic.autoHeight(root, - 1)
    end
    root:update()
    return root
end
---- meta widgets:
-- lines in constants tist -- needs better naming. they are not constants they are dynamic data that always apear no matter the program

function M.ConstantsList_lineMain(parent, key)
    local root = parent:addFrame()
        :stretchWidth(parent, 0)
        :setSize("parent.w", 1)

    local labelKey = root:addLabel()
        :setPosition(1, 1)
        :setText(key)

    local labelValue = root:addLabel()
        :rightOf(labelKey, 2)
        :setText("?")

    function root:setValue(value)
        labelValue:setText(value)
    end
    return root
end
function M.ConstantsList_lineProgram(parent)  -- defines the colums of a line

    local stateTable = listener.read()
    local value = stateTable.program or "?"
    local key = "Program: "


    local root = M.ConstantsList_lineMain(parent, key)
    function root:update()
        local st = listener.read()
        root:setValue(st.program or "?")
    end
    root:update()
    return root
end
function M.ConstantsList_lineState(parent)  -- defines the colums of a line

    local value = "?"
    local key = "State:   "


    local root = M.ConstantsList_lineMain(parent, key)
    function root:update()
        local st = listener.read()
        root:setValue(st.state or "?")
    end
    root:update()
    return root
end
function M.ConstantsList_lineMessage(parent)  -- defines the colums of a line

    local value = "?"
    local key = "Message: "


    local root = M.ConstantsList_lineMain(parent, key)
    function root:update()
        local st = listener.read()
        root:setValue(st.message or "?")
    end
    root:update()
    return root
end

------------------------------------------------------------
-- custom data windows:
------------------------------------------------------------

local testdata = --listener.read() or 
{
    state   = "done",
    program = "cobbleMiner.lua",
    message = "inventory full. stopping...",
    custom = {
        minedBlocks = 1,
        target = 128,
    },
}

function M.customDataMain(parent) -- defines structure of custom data field
    local root = parent:addFrame() -- adds the box
        :setBorderTop(true) -- ads a border so i gain a bit of extra space to put buttons on
    local checkbox = root:addCheckBox() -- error: does not apear: text, nor background -- but rightOf function works, so it exists for sure... strange
        :setBackground(colors.red) -- for testing
        :setPosition(0, 1)
        :setText("format:\xba ")
        :setCheckedText("format:\xf8 ")
        :onChange("checked", function(self, checked) 
            --  logic.movableSetting(root, reformat) 
            --  reloadButton.setInvisible
            --  else reloadButton.setVisible
        end) -- turns off the movabylity and enables repack on update tick -- also toggles visability of the repack button
        :setSize(8,1)
        :alignLeft(root, 1)
        :setBackgroundEnabled(true)
        
    local reloadButton = M.customDataRelaodButton(root)
        
    
    --local k1, v1 = next(testdata.custom)          -- first pair
    --local k2, v2 = next(testdata.custom, k1) 
    --field1 = M.customDataObjectMain(root, k1, v1)
    --field2 = M.customDataObjectMain(root, k2, v2)
    --field2:setPosition(3,3)
    datafield = M.customDataField(root)
        :stretchWidth(root)
        :stretchHeight(root, 1)
        :below(checkbox, 1)
        :setBackgroundEnabled(false)
    reloadButton:onClick(function(self, button)
        -- delete the datastream file (supporting either fs.delete or fs.remove)  --- holy shit this looks vibe coded... aaaallll of this needs to be cleaned up.
        local delete = fs and (fs.delete or fs.remove)
        if delete then pcall(delete, "status/datastream.json") end

        -- remove all children from the datafield safely
        local children = (datafield.getChildren and datafield:getChildren()) or {}
        for _, child in ipairs(children) do
            pcall(function()
                if type(datafield.removeChild) == "function" then
                    datafield:removeChild(child)
                else
                    local fn = datafield.removeChild
                    if type(fn) == "function" then pcall(fn, datafield, child) end
                end
            end)
        end

        -- try to refresh the field
        pcall(function() if type(datafield.update) == "function" then datafield:update() end end)
    end)
    -- later this will be a for loop that is going to be moved to statusLogic
    
    --relaodButton:rightOf(checkbox)
    --fieldTable = M.customDataField(parent) -- adds the all the sub windows and functionality switching
    function root:update()
        datafield:update()
    end
    root:update()
    return root
end
function M.customDataAutoFormatSetting(parent)
    return parent
end
function M.customDataRelaodButton(parent)
    local backgroundColor = colors.lightBlue
    local clickColor = colors.red

    local reformat = parent:addButton() -- reload button. re checks the field and repacks the fields -- error: only background colors apear.
        :setBackground(backgroundColor)
        
        -- this code aught to be made dynamic in load. i doubt the size will change during runtime, but maybe inbetween,
        :setPosition(11, 1)
        :setSize(3, 1)
        :setText("[ ]") --sets the button icon

    reformat:onClick(function(self, button)
        self:setBackground(clickColor)

        basalt.schedule(function()
            sleep(0.2)
            self:setBackground(backgroundColor)
        end)
    end)
    return parent
end    

function M.customDataField(parent)  -- only adds a frame -- defines structure of custom data field
--[[
    Creates and returns a frame for displaying custom data fields within the parent UI element.
    This function is responsible for managing and updating dynamic custom data widgets based on instructions
    provided by the logic layer, and is intended to be used as a container for custom status or informational fields.
    Usage: Call M.customDataField(parent) to add a custom data area to a parent frame.
]]
function M.customDataField(parent)  -- only adds a frame -- defines structure of custom data field
    local root = parent:addFrame()    
    --local k1, v1 = next(testdata.custom)          -- first pair
    --local k2, v2 = next(testdata.custom, k1) 
    --field1 = M.customDataObjectMain(root, k1, v1)
    --field2 = M.customDataObjectMain(root, k2, v2)
    --field2:setPosition(3,3)                   -- TEMP

    -- local h = fs.open("debug.json", "w+")
    -- h.write(textutils.serializeJSON(instructions))
    -- h.close()
    function root:update()
        local status = listener.read() 
        local instructions = logic.customFieldLogic(root, status)
        M.applyCustomFieldInstructions(root, instructions)
    end
    root:update()
    return root
end
-- Apply instructions to the custom-data playfield.
-- For now: only "add" is implemented.
function M.applyCustomFieldInstructions(playfield, instructions)
    -- instructions may be either:
    -- 1) list of { keyString, instrTable } (older format)
    -- 2) list of instrTable where instrTable = { action="add", key=..., text=..., title=... }
    for _, item in ipairs(instructions or {}) do
        local handle, instr

        if type(item) == "table" and item[1] ~= nil and item[2] ~= nil then
            -- old pair format: { handle, instr }
            handle = item[1]
            instr  = item[2]
        elseif type(item) == "table" and (item.action ~= nil or item.key ~= nil) then
            -- new instr-only format
            instr  = item
            handle = instr.key
        else
        end

        if instr.action == "add" then
            local key  = instr.key or handle
            local text = instr.text or ""
            local win  = M.customDataObjectMain(playfield, key, text)

            -- tag it so logic can recognize it later
            win._isCustomWindow = true
            win._customKey      = key
            win._lastValue      = text

            -- position it using logic helper (if available)
            if logic and logic.findOpenSpotInFrame then
                local x, y = logic.findOpenSpotInFrame(playfield, win)
                if x and y and type(win.setPosition) == "function" then
                    win:setPosition(x, y)
                end
            end

        elseif instr.action == "update" then
            -- prefer explicit target, else try to find child by key
            local target = item.target or instr.target
            if not target and instr.key then
            -- find child with matching _customKey
            for _, c in ipairs(playfield:getChildren() or {}) do
                if c._customKey == instr.key then target = c; break end
            end
            end
            if target then
            -- Remove all children (labels) from target
            local children = target:getChildren() or {}
            for _, child in ipairs(children) do
                pcall(function() target:removeChild(child) end)
            end
            
            -- Regenerate with new value
            M.customDataObject_simple(target, instr.key, instr.text)
            
            -- Resize target and parent
            logic.autosize(target, 0)
            logic.autoHeight(playfield, 0)
            
            target._lastValue = instr.text
            end

        elseif instr.action == "remove" then
            local target = item.target or instr.target
            if not target and instr.key then
                for _, c in ipairs(playfield:getChildren() or {}) do
                    if c._customKey == instr.key then target = c; break end
                end
            end
            if target then
                -- Try to remove the child safely; some frame implementations may not
                -- expose removeChild as a callable method, so use pcall to avoid errors.
                local ok = pcall(function() playfield:removeChild(target) end)
                if not ok then
                    -- Fallback: try calling the raw function if present on the table
                    local fn = playfield.removeChild
                    if type(fn) == "function" then
                        pcall(fn, playfield, target)
                    end
                end
--[[
    Creates a draggable custom data object frame with a key and value label.
    @param parent The parent frame to attach this object to.
    @param key The key or title for the data object.
    @param value The value to display for the data object.
    @return The created frame containing the key and value labels.
]]
function M.customDataObjectMain(parent, key, value)
    -- if logic.dataField_checkIfDataStillExists() then return end -- i thiiiink this should only be done in update
    local root = parent:addFrame()
    end
end

function M.customDataObjectMain(parent, key, value)
    -- if logic.dataField_checkIfDataStillExists() then return end -- i thiiiink this should only be done in update
    local root = parent:addFrame()
        :setDraggable(true)
        :setBorderBottom(true)
        :setBorderTop(true)
        :setBorderColor(colors.blue)
        :setBackground(colors.lightBlue)
    root:setSize(10,4) -- temporary
    root:setPosition(2, 2) -- temporary
    -- root.setPosition(logic.dataField_findOpenSpot(root)) -- finds a open spot to put the box on initialation.

    M.customDataObject_simple(root, key, value) -- for now nop logic to change object type
    logic.autosize(root, 0)
    return root
end
function M.customDataObject_simple(parent, key, value)
    key = (tostring(key) .. ":") or "\xbfN-F?" -- stands for not found
    value = value or "????"
    local root = parent:addFrame() 
        :setPosition(2, 2)
    local labelKey = root:addLabel()
        :setPosition(1, 1)
        --:setText(tostring("testing:")) -- 
        :setText(tostring(key))
    local labelValue = root:addLabel()
        :below(labelKey, 1)
        :alignLeft(labelKey)
        --:setText(tostring("works")) --
        :setText(tostring(value))
    logic.autosize(root, 0) -- not working
    --root:setSize(8 ,2) -- temporary

    return root
end


return M
