local BASE = "https://raw.githubusercontent.com/phytonhacker/CC-T/main/"

local function tolt(fajl)
    if fs.exists(fajl) then fs.delete(fajl) end
    print("Letoltes: " .. fajl)
    local ok = http.get(BASE .. fajl)
    if ok then
        local f = fs.open(fajl, "w")
        f.write(ok.readAll())
        f.close()
        print("  OK!")
    else
        print("  HIBA: " .. fajl)
    end
end

tolt("protokoll.lua")
tolt("filekuldo.lua")

print("====================")
print("  1 = Master        ")
print("  2 = Worker        ")
print("====================")
local valasz = read()

if valasz == "1" then
    tolt("master.lua")
    local f = fs.open("startup.lua", "w")
    f.write('os.loadAPI("/protokoll.lua")\n')
    f.write('MSG = protokoll.MSG\n')
    f.write('shell.run("master")')
    f.close()
    print("Master kesz! -> reboot")

elseif valasz == "2" then
    tolt("worker.lua")
    print("Szerepkor? (fileserver/logserver/stb)")
    local szerepkor = read()
    local f = fs.open("startup.lua", "w")
    f.write('SZEREPKOR = "' .. szerepkor .. '"\n')
    f.write('os.loadAPI("/protokoll.lua")\n')
    f.write('MSG = protokoll.MSG\n')
    f.write('shell.run("worker")')
    f.close()
    print("Worker kesz! -> reboot")
end