-- this is a example file meant to show and test how the system would work. all it does is mine cobble at a cobble gen.
-- in total the logic is barely 11 lines, the status code to integrate with status project is a additional 7 lines,  and the other 11 lines are just self debug. and lastly 4 lines are argument handeling.
-- my point is this project is optimised for least amount of clutter in active development files. meaning its fast & easy to implement, customize, and use.


local status = require("statusUpdates")  -- status code

local args = {...}
local DEFAULT_TARGET = 128

local target = tonumber(args[1]) or DEFAULT_TARGET
local cobble = 0
status.set("target", target)
status.set("target", target) -- status code
print(target)
status.state("working") -- status code
status.message("mining cobble...") -- status code
local ok, data = turtle.inspect()
turtle.select(1)
while ok do
    if turtle.dig() then
        cobble = cobble + 1
--        print("cobbles mined: " .. cobble) --
        status.set("minedBlocks", cobble) -- status code
--    else--
--        print("Could not dig!")--
    end
    if cobble >= target then----
        print("target reached, stopping...")--
        status.message("target reached. stopping...") -- status code
        break --
    elseif turtle.getItemSpace(16) == 0 then
        print("inventory full, stopping...")--
        status.message("inventory full. stopping...") -- status code
        break 
--    else--
--        print(cobble .. "~=" .. target)--
    end
end

--turtle.forward()
print("done") --
status.state("done") -- status code

