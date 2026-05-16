os.loadAPI("/protokoll.lua")
MSG = protokoll.MSG

local MODEM = "right"
rednet.open(MODEM)

local gepek = {}

print("=== MASTER SERVER ===")
print("ID: " .. os.getComputerID())
print("Varakozas...")

local function kuldd(cel_id, tipus, adat)
    rednet.send(cel_id, protokoll.csomagol(tipus, adat))
end

local function mindenkinek(tipus, adat)
    rednet.broadcast(protokoll.csomagol(tipus, adat))
end

local function log(szoveg)
    print("[LOG] " .. szoveg)
end

-- Fájl küldése egy gépnek
local function kuldd_fajlt(cel_id, utvonal)
    if not fs.exists(utvonal) then
        print("Nem talalom: " .. utvonal)
        return false
    end
    local f = fs.open(utvonal, "r")
    local tartalom = f.readAll()
    f.close()
    kuldd(cel_id, MSG.FILE_SEND, {
        utvonal  = utvonal,
        tartalom = tartalom,
        meret    = #tartalom
    })
    local _, valasz = rednet.receive(5)
    if valasz and valasz.tipus == MSG.FILE_ACK then
        print("Elkuldve: " .. utvonal)
        return true
    end
    print("HIBA: " .. utvonal)
    return false
end

-- Mappa küldése rekurzívan
local function kuldd_mappat(cel_id, mappa)
    for _, nev in ipairs(fs.list(mappa)) do
        local ut = mappa .. "/" .. nev
        if fs.isDir(ut) then
            kuldd_mappat(cel_id, ut)
        else
            kuldd_fajlt(cel_id, ut)
        end
    end
end

-- Parancs futtatása egy gépen
local function futtass(cel_id, parancs)
    kuldd(cel_id, MSG.CMD, parancs)
    print("Parancs elkuldve: #" .. cel_id)
end

print("Parancsok:")
print("  gepek     - listazza a gépeket")
print("  kuldd     - fajl/mappa kuldes")
print("  futtass   - parancs futtatasa")
print("")

while true do
    -- Üzenetek kezelése háttérben
    local timer = os.startTimer(0.1)
    local event, p1, p2 = os.pullEvent()

    if event == "rednet_message" then
        local kuldo_id, uzenet = p1, p2

        if uzenet.tipus == MSG.REGISTER then
            gepek[kuldo_id] = uzenet.adat
            print("[+] Belelepett: #" .. kuldo_id
                .. " = " .. uzenet.adat)
            kuldd(kuldo_id, MSG.PONG, "udvozlet!")

        elseif uzenet.tipus == MSG.PING then
            kuldd(kuldo_id, MSG.PONG, "ok")

        elseif uzenet.tipus == MSG.LOG then
            log("[#" .. kuldo_id .. "] " .. tostring(uzenet.adat))

        elseif uzenet.tipus == MSG.RESULT then
            print("[RESULT #" .. kuldo_id .. "] "
                .. tostring(uzenet.adat))

        elseif uzenet.tipus == MSG.FILE_ACK then
            print("[FILE OK #" .. kuldo_id .. "] "
                .. tostring(uzenet.adat))
        end

    elseif event == "char" then
        -- Billentyű parancsok
        io.write("\nParancs> ")
        local parancs = read()

        if parancs == "gepek" then
            print("Ismert gepek:")
            for id, szerep in pairs(gepek) do
                print("  #" .. id .. " = " .. szerep)
            end

        elseif parancs == "kuldd" then
            print("Cel gep ID?")
            local cel = tonumber(read())
            print("Fajl vagy mappa ut?")
            local ut = read()
            if fs.isDir(ut) then
                kuldd_mappat(cel, ut)
            else
                kuldd_fajlt(cel, ut)
            end

        elseif parancs == "futtass" then
            print("Cel gep ID?")
            local cel = tonumber(read())
            print("Parancs?")
            local p = read()
            futtass(cel, p)

        elseif parancs == "mindenki" then
            print("Parancs mindenkinek?")
            local p = read()
            mindenkinek(MSG.CMD, p)
        end
    end
end