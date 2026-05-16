local API_KEY = "IDE_IRD_AZ_API_KULCSOT"
local URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" .. API_KEY

local body = '{"contents":[{"parts":[{"text":"Szia!"}]}]}'

print("Kuldes...")
local ok, err = http.post(URL, body, {
    ["Content-Type"] = "application/json"
})

if not ok then
    print("HIBA: " .. tostring(err))
else
    local raw = ok.readAll()
    ok.close()
    print("SIKER!")
    print(raw)
end