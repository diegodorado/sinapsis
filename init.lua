print ("---------------------")
print("Setting up WiFi AP...")
wifi.setmode(wifi.SOFTAP)
cfg = {}
cfg.ssid = "Sinapsis"
wifi.ap.config(cfg)
print("Done.")
print ("---------------------")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")

        if file.open("init.lua") ~= nil then
          print ("---------------------")
          print('Starting HTTP Server')
          dofile('app.lua')
          print ('Starting DNS Server')
          dofile('dns-liar.lua')
          print ("---------------------")
        end

    end
end

-- you have 3 seconds to delete/rename init.lua
-- if something goes wrong
tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
