local MODEM     = "back"
local SZERVER_ID = nil

rednet.open(MODEM)

-- Szerver keresése
term.clear()
term.setCursorPos(1,1)
print("=== AI TERMINAL ===")
print("Szerver ID?")
io.write("> ")
SZERVER_ID = tonumber(read())

-- Felhasználónév
print("Felhasznalonev?")
io.write("> ")
local nev = read()

-- Csatlakozás
print("Csatlakozas...")
rednet.send(SZERVER_ID, {
    tipus = "connect",
    nev   = nev
})

local _, valasz = rednet.receive(5)
if not valasz or valasz.tipus ~= "connect_ok" then
    print("HIBA: Nem sikerult csatlakozni!")
    return
end

term.clear()
term.setCursorPos(1,1)
print("=== " .. valasz.uzenet .. " ===")
print("Irj 'exit' a kilepeshez")
print("")

-- Szöveg tördelés
local function wrap(s)
    local w = term.getSize()
    while #s > w do
        print(s:sub(1,w))
        s = s:sub(w+1)
    end
    if #s > 0 then print(s) end
end

-- Főciklus
while true do
    io.write("Te: ")
    local input = read()

    if input == "exit" then
        rednet.send(SZERVER_ID, { tipus = "disconnect" })
        print("Viszlat!")
        break
    end

    if input ~= "" then
        rednet.send(SZERVER_ID, {
            tipus  = "ai_kerdes",
            szoveg = input
        })

        io.write("Gemini: ")
        local _, resp = rednet.receive(15)

        if resp and resp.tipus == "ai_valasz" then
            wrap(resp.szoveg)
        else
            print("HIBA: Nem jott valasz!")
        end
        print("")
    end
end