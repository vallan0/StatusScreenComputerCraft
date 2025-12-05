local id = shell.openTab("mirror right statusLayout")
shell.switchTab(id)
sleep(0.1)
local id2 = shell.openTab("lua") -- a invisible debug menue. here you can listen for events maually.
shell.run("cobbleMiner") -- for testing, replace with veinminer later or startup v2
print("cobbleMiner completed???") -- debug info
--
--shell.run("clear")
--shell.run("statusLogic")
