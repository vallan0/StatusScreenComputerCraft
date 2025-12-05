-- statusLayout.lua
-- this is the final destination. layer 1 so to speak. this is where you take the lego pices from StatusWidgets and build your own UI
-- here i value pretty code over aaaaalll else.

-- side note: maybe it is time to get a main.lua file for this project seing how its becoming harder to keep this file pretty..
-- maybe i should consider uploading to github? 

-- todo: have 2 update loops running. 1 for wifgets (with long update  timer) and 1 for data (short timer) and use dynamic elements to update the screen dynamically

local basalt  = require("basalt")
local widgets = require("statusWidgets")

local termW, termH = term.getSize()
local main = basalt.createFrame()
:setBackground(colors.purple)  -- to identify errors easier
:setSize(termW, termH)
-- Instances stored here
local W = {}


------------------------------------------------------------
-- SETTINGS START HERE (user editable)
------------------------------------------------------------

-- Header (full width, 2 tall)
---------
local header = main:addFrame()
    :setBackground(colors.gray)
    :setPosition(1,1)

-- Body, this will try to fill the screen if posible
---------
local body = main:addFrame()
    :setBackground(colors.red) -- to identify errors easier
    :setScrollable(true)

-- footer not defined yet
---------

local footer = nil
-------------------
-- FRAME LAYOUT
-------------------

header:setSize(termW, 2)
body:stretchWidth(main,0) 
body:below(header, 1)
body:setConstraint("height", main, "height", -header.get("height"))
--body:addBorder(colors.pink) 


-- Fuel widget -----------------------------------------------------
local function wdg_Fuel(isUpdate)
    if not W.fuel then W.fuel = widgets.FuelWidget(header) end -- initialises the widget
    if isUpdate then W.fuel:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.fuel:toBottom(0)
    W.fuel:alignRight("parent", 0)
end

-- Program widget --------------------------------------------------
local function wdg_Program(isUpdate)
    if not W.prog then W.prog = widgets.ProgramWidget(header) end
    if isUpdate then W.prog:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.prog:toTop(0)
    W.prog:alignLeft("parent", 1)
end

-- Turtle name widget ----------------------------------------------
local function wdg_TurtleName(isUpdate)
    if not W.name then W.name = widgets.TurtleNameWidget(header) end -- initialises the widget
    if isUpdate then W.name:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.name:toTop(1)
    W.name:centerHorizontal("parent", 0)
end

-- INV button -------------------------------------------------------
local function wdg_Inv(isUpdate)
    if not W.inv then W.inv = widgets.invButtonWidget(header, main) end -- initialises the widget
    if isUpdate then W.inv:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.inv:toBottom(0)
    W.inv:alignLeft("parent", 1)
end

-- ABORT button -----------------------------------------------------
local function wdg_Abort(isUpdate)
    if not W.abort then W.abort = widgets.AbortButtonWidget(header) end -- initialises the widget
    if isUpdate then W.abort:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.abort:toTop(0)
    W.abort:alignRight("parent", 0)
end

-- CORD button ------------------------------------------------------
local function wdg_Cord(isUpdate)
    if not W.cord then W.cord = widgets.CordButtonWidget(header) end -- initialises the widget
    if isUpdate then W.cord:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.cord:toBottom(0)
    W.cord:leftOf(W.fuel, 2)
end

------------------------------------------------------------
-- BODY SETTINGS
------------------------------------------------------------
local function wdg_BodyConstants(isUpdate)
    if not W.bodyConst then W.bodyConst = widgets.ConstantsListWidget(body) end -- initialises the widget
    if isUpdate then  W.bodyConst:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.bodyConst:stretchWidth(body, 0)
    W.bodyConst:setPosition(1,1)
end
-- Custom Data Field ------------------------------------------------------
local function wdg_customDataMain(isUpdate)
    if not W.dataField then W.dataField = widgets.customDataMain(body) end -- initialises the widget
    if isUpdate then  W.dataField:update() end -- updates if its the second time loaded. 
    
    -- widget placement goes here:
    W.dataField:below(W.bodyConst, 1)
    W.dataField:stretchWidth(body, 0)
    --W.dataField:stretchHeight(body, 0)
    W.dataField:setConstraint("height", body, "height", -W.bodyConst.get("height"))
    W.dataField:setBackground(colors.lightGray)

end
------------------------------------------------------------
-- WIDGET DISABLE
------------------------------------------------------------
local function updateWidgets(updt)
    updt = (updt ~= false)   -- default = true
    -- comment out wdg to temporaraly disable corosponding widget  -- needs to be formulated better :T
    wdg_Fuel(updt)
    wdg_Program(updt)
    wdg_TurtleName(updt)
    wdg_Inv(updt)
    wdg_Abort(updt)
    wdg_Cord(updt)
    wdg_BodyConstants(updt)
    wdg_customDataMain(updt)
end
------------------------------------------------------------
-- SETTINGS END HERE (user should not edit below)
------------------------------------------------------------
local function initWidgets() updateWidgets(false) end 
-- makes the line below easier to read, doing updateWidgets(false) below would do the same thing with less explanation



basalt.schedule(function()
    while true do
        sleep(0.2)
        updateWidgets()
    end
end)

updateWidgets(false)
basalt.run()
updateWidgets()
