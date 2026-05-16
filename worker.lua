os.loadAPI("/protokoll.lua")
MSG = protokoll.MSG

local MODEM = "right"
rednet.open(MODEM)

if not SZEREPKOR then SZEREPKOR = "worker" end

print("=== WORKER: " .. SZEREPKOR .. " ===")
print("ID: " .. os.getComputerID())

-- Master keresése
print("Master keresese...")
rednet.broadcast(protokoll.csomagol(MSG.REGISTER, SZEREPKOR))

local MASTER_ID = nil
local id, valasz = rednet.receive(5)
if valasz and valasz.tipus == MSG.PONG then
    MASTER_ID = id
    print("Master: #" .. MASTER_ID)
else
    print("Master nem talalhato!")
    print("Kozvetlen mod (nincs master)")
end

local function log(szoveg)
    print("[LOG] " .. szoveg)
    if MASTER_ID then
        rednet.send(MASTER_ID,
            protokoll.csomagol(MSG.LOG, szoveg))
    end
end

local function eredmeny(adat)
    if MASTER_ID then
        rednet.send(MASTER_ID,
            protokoll.csomagol(MSG.RESULT, adat))
    end
end

log("Elindult: " .. SZEREPKOR)

while true do
    local kuldo_id, uzenet = rednet.receive()
    if not uzenet then break end

    -- Fájl fogadás
    if uzenet.tipus == MSG.FILE_SEND then
        local adat = uzenet.adat
        log("Fajl erkezik: " .. adat.utvonal)

        local mappa = fs.getDir(adat.utvonal)
        if mappa ~= "" and not fs.exists(mappa) then
            fs.makeDir(mappa)
        end

        local f = fs.open(adat.utvonal, "w")
        f.write(adat.tartalom)
        f.close()

        rednet.send(kuldo_id,
            protokoll.csomagol(MSG.FILE_ACK, adat.utvonal))
        log("Mentve: " .. adat.utvonal)

    -- Parancs futtatás
    elseif uzenet.tipus == MSG.CMD then
        local parancs = uzenet.adat
        log("Parancs: " .. parancs)
        local ok, err = pcall(function()
            load(parancs)()
        end)
        if ok then
            eredmeny("OK: " .. parancs)
        else
            eredmeny("HIBA: " .. tostring(err))
        end

    -- Ping
    elseif uzenet.tipus == MSG.PING then
        rednet.send(kuldo_id,
            protokoll.csomagol(MSG.PONG, SZEREPKOR))
    end
end