local MODEM   = "top"
local API_KEY = "ide_jön_az_api_kulcsod"
local URL     = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" .. API_KEY

rednet.open(MODEM)
print("=== AI SZERVER ===")
print("ID: " .. os.getComputerID())
print("Varakozas csatlakozasra...")

local function json_str(s)
    return '"' .. s:gsub('\\','\\\\')
                   :gsub('"','\\"')
                   :gsub('\n','\\n') .. '"'
end

local function gemini(kerdes)
    local body = '{"contents":[{"parts":[{"text":'
        .. json_str(kerdes) .. '}]}]}'
    local ok = http.post(URL, body, {
        ["Content-Type"] = "application/json"
    })
    if not ok then return "HIBA: Nincs internet!" end
    local raw = ok.readAll()
    ok.close()
    local valasz = raw:match('"text": ?"(.-)"')
    if valasz then
        return valasz:gsub('\\n','\n'):gsub('\\"','"')
    end
    return "HIBA: Nem ertem a valaszt."
end

-- Bejelentkezett terminálok
local terminalok = {}

while true do
    local id, uzenet = rednet.receive()
    if uzenet then

        -- Csatlakozás kérés
        if uzenet.tipus == "connect" then
            terminalok[id] = uzenet.nev
            print("[+] Csatlakozott: " .. uzenet.nev
                .. " (#" .. id .. ")")
            rednet.send(id, {
                tipus = "connect_ok",
                uzenet = "Udvozlunk " .. uzenet.nev .. "!"
            })

        -- Lecsatlakozás
        elseif uzenet.tipus == "disconnect" then
            print("[-] Lecsatlakozott: "
                .. (terminalok[id] or "?")
                .. " (#" .. id .. ")")
            terminalok[id] = nil

        -- AI kérdés
        elseif uzenet.tipus == "ai_kerdes" then
            local nev = terminalok[id] or "Ismeretlen"
            print("[" .. nev .. "] " .. uzenet.szoveg)
            io.write("Gemini valaszol...")

            local valasz = gemini(uzenet.szoveg)
            print(" kesz!")

            rednet.send(id, {
                tipus  = "ai_valasz",
                szoveg = valasz
            })
        end
    end
end