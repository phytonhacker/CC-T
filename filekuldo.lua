os.loadAPI("/protokoll.lua")
MSG = protokoll.MSG

local MODEM = "right"
rednet.open(MODEM)

local function kuldd_fajlt(cel_id, utvonal)
    if not fs.exists(utvonal) then
        print("Nem talalom: " .. utvonal)
        return false
    end
    local f = fs.open(utvonal, "r")
    local tartalom = f.readAll()
    f.close()

    print("Kuldes: " .. utvonal
        .. " (" .. #tartalom .. " byte)")

    rednet.send(cel_id, protokoll.csomagol(MSG.FILE_SEND, {
        utvonal  = utvonal,
        tartalom = tartalom,
        meret    = #tartalom
    }))

    local _, valasz = rednet.receive(5)
    if valasz and valasz.tipus == MSG.FILE_ACK then
        print("  OK!")
        return true
    end
    print("  HIBA!")
    return false
end

local function kuldd_mappat(cel_id, mappa)
    print("Mappa: " .. mappa)
    for _, nev in ipairs(fs.list(mappa)) do
        local ut = mappa .. "/" .. nev
        if fs.isDir(ut) then
            kuldd_mappat(cel_id, ut)
        else
            kuldd_fajlt(cel_id, ut)
        end
    end
end

print("=== FAJLKULDO ===")
print("Cel gep ID?")
local cel = tonumber(read())
print("Fajl vagy mappa?")
local ut = read()

if fs.isDir(ut) then
    kuldd_mappat(cel, ut)
else
    kuldd_fajlt(cel, ut)
end

print("Kuldes befejezve!")