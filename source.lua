-- Platoboost configuration
local service = 362  -- Your service ID
local secret = "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad"  -- Your secret key for security
local useNonce = true  -- Use a nonce to prevent replay attacks

-- Callbacks
local onMessage = function(message) 
    print(message) -- Print messages to console for debugging
end

-- Wait for the game to load completely
repeat task.wait(1) until game:IsLoaded()

-- Functions
local requestSending = false
local fRequest = request or http_request or syn_request
local fOsTime = os.time
local fMathRandom = math.random
local fGetUserId = function() return game.Players.LocalPlayer.UserId end -- Changed from HWID to UserId
local cachedLink, cachedTime = "", 0 -- Variables for caching

-- Pick host
local host = "https://api.platoboost.com"
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
})
if hostResponse.StatusCode ~= 200 then
    host = "https://api.platoboost.net"
end

-- Function to encode data to JSON
local function lEncode(data)
    return game:GetService("HttpService"):JSONEncode(data)
end

-- Function to decode JSON data
local function lDecode(data)
    return game:GetService("HttpService"):JSONDecode(data)
end

-- Load Key Function
local function loadKey()
    local response = fRequest({
        Url = host .. "/public/whitelist",
        Method = "POST",
        Body = lEncode({
            service = service,
            identifier = fGetUserId() -- Using UserId
        }),
        Headers = {
            ["Content-Type"] = "application/json"
        }
    })

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success then
            onMessage("Key loaded successfully: " .. decoded.data.key)
            return decoded.data.key
        else
            onMessage(decoded.message)
            return nil
        end
    else
        onMessage("Failed to load key: " .. response.StatusCode)
        return nil
    end
end

-- Cache Link Function
function cacheLink()
    if (not cachedLink or cachedTime + (10 * 60) < fOsTime()) then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({
                service = service,
                identifier = fGetUserId() -- Now using UserId
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })

        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body)

            if decoded.success then
                cachedLink = decoded.data.url
                cachedTime = fOsTime()
                return true, cachedLink
            else
                onMessage(decoded.message)
                return false, decoded.message
            end
        elseif response.StatusCode == 429 then
            local msg = "You are being rate limited, please wait 20 seconds and try again."
            onMessage(msg)
            return false, msg
        end

        local msg = "Failed to cache link."
        onMessage(msg)
        return false, msg
    else
        return true, cachedLink
    end
end

-- Nonce generation
local function generateNonce()
    local str = ""
    for _ = 1, 16 do
        str = str .. string.char(fMathRandom(97, 122)) -- Generate random lowercase letters
    end
    return str
end

-- Copy link function
local function copyLink()
    local success, link = cacheLink()
    
    if success then
        setclipboard(link)
        onMessage("Link copied to clipboard: " .. link)
    end
end

-- Redeem key function
local function redeemKey(key)
    local nonce = generateNonce()
    local endpoint = host .. "/public/redeem/" .. tostring(service)

    local body = {
        identifier = fGetUserId(), -- Now using UserId
        key = key,
        nonce = useNonce and nonce or nil
    }

    local response = fRequest({
        Url = endpoint,
        Method = "POST",
        Body = lEncode(body),
        Headers = { ["Content-Type"] = "application/json" }
    })

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            onMessage("Key redeemed successfully!")
            return true
        else
            onMessage("Invalid key.")
            return false
        end
    else
        onMessage("Error redeeming key: " .. response.StatusCode)
        return false
    end
end

-- Verify key function
local function verifyKey(key)
    if requestSending then
        onMessage("A request is already being sent, please slow down.")
        return false
    else
        requestSending = true
    end

    local nonce = generateNonce()
    local endpoint = host .. "/public/whitelist/" .. tostring(service) .. "?identifier=" .. tostring(fGetUserId()) .. "&key=" .. key

    if useNonce then
        endpoint = endpoint .. "&nonce=" .. nonce
    end

    local response = fRequest({
        Url = endpoint,
        Method = "GET"
    })

    requestSending = false

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            onMessage("Key is valid!")
            return true
        else
            return redeemKey(key) -- Try redeeming the key if it is not valid
        end
    else
        onMessage("Error verifying key: " .. response.StatusCode)
        return false
    end
end

-- Function to load another script based on key status
local function loadAnotherScript(scriptUrl)
    local response = fRequest({
        Url = scriptUrl,
        Method = "GET"
    })

    if response.StatusCode == 200 then
        loadstring(response.Body)() -- Execute the loaded script
        onMessage("Successfully loaded and executed the additional script.")
    else
        onMessage("Failed to load the additional script: " .. response.StatusCode)
    end
end

-- Auto-load key when the script runs
local verifyKey(key)
local autoLoadedKey = loadKey()
if autoLoadedKey then
    -- Verify the loaded key and load another script if valid
    local isValid = verifyKey(autoLoadedKey)
    if isValid then
        loadAnotherScript("https://example.com/path/to/your/valid/script.lua") -- Replace with your valid script URL
    else
        loadAnotherScript("https://example.com/path/to/your/invalid/script.lua") -- Replace with your invalid script URL
    end
end
