--! configuration
local service = 362 -- your service id, this is used to identify your service.
local secret = "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad" -- make sure to obfuscate this if you want to ensure security.
local useNonce = true -- use a nonce to prevent replay attacks and request tampering.

--! GitHub configuration
local GITHUB_TOKEN = "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" -- Your GitHub token
local GIST_ID = "Lunahubv2" -- Your Gist ID

--! callbacks
local onMessage = function(message) end

--! wait for game to load
repeat task.wait(1) until game:IsLoaded()

--! functions
local requestSending = false
local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor
local fGetUserId = function() return game.Players.LocalPlayer.UserId end
local cachedLink, cachedTime = "", 0

--! pick host
local host = "https://api.platoboost.com"
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
})
if hostResponse.StatusCode ~= 200 or hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net"
end

-- Function to save key to GitHub Gist using UserId
local function saveKeyToGist(key)
    local userId = fGetUserId()
    local body = HttpService:JSONEncode({
        files = {
            [userId .. "_keyBindings.json"] = { -- Using UserId as part of the file name
                content = HttpService:JSONEncode({ key = key })
            }
        }
    })

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://api.github.com/Lunahubv2" .. GIST_ID,
            Method = "PATCH",
            Headers = {
                ["Authorization"] = "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" .. GITHUB_TOKEN,
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)

    if success and response.StatusCode == 200 then
        print("Key saved successfully!")
    else
        warn("Failed to save key: " .. (response or "Unknown error"))
    end
end

-- Function to load key from GitHub Gist using UserId
local function loadKeyFromGist()
    local userId = fGetUserId()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://api.github.com/gists/Lunahubv2" .. GIST_ID, true, {
            ["Authorization"] = "token " .. GITHUB_TOKEN
        })
    end)

    if success and response then
        local data = HttpService:JSONDecode(response)
        local keyFileName = userId .. "_keyBindings.json" -- Using UserId for the file name
        if data.files[keyFileName] then
            local fileContent = data.files[keyFileName].content
            local keyData = HttpService:JSONDecode(fileContent)

            if keyData.key then
                return keyData.key
            else
                warn("No key found in Gist.")
                return nil
            end
        else
            warn("No key bindings file found for UserId.")
            return nil
        end
    else
        warn("Failed to load key: " .. (response or "Unknown error"))
        return nil
    end
end

-- Cache Link Function (Unchanged)
function cacheLink()
    if cachedTime + (10 * 60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            -- Change identifier to use UserId
            Body = lEncode({
                service = service,
                identifier = lDigest(fGetUserId()) -- Use UserID here
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })

        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body)

            if decoded.success == true then
                cachedLink = decoded.data.url
                cachedTime = fOsTime()
                return true, cachedLink
            else
                onMessage(decoded.message)
                return false, decoded.message
            end
        elseif response.StatusCode == 429 then
            local msg = "you are being rate limited, please wait 20 seconds and try again."
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

cacheLink()

-- Example usage of saving and loading keys
local playerKey = "examp_key" -- Replace this with the actual key you want to save

-- Save key when player leaves--! configuration
local service = 362 -- your service id, this is used to identify your service.
local secret = "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad" -- make sure to obfuscate this if you want to ensure security.
local useNonce = true -- use a nonce to prevent replay attacks and request tampering.

--! GitHub configuration
local GITHUB_TOKEN = "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" -- Your GitHub token
local GIST_ID = "YOUR_GIST_ID" -- Your Gist ID

--! callbacks
local onMessage = function(message) end

--! wait for game to load
repeat task.wait(1) until game:IsLoaded()

--! functions
local requestSending = false
local fSetClipboard, fRequest, fStringChar, fToString, fStringSub, fOsTime, fMathRandom, fMathFloor
local fGetUserId = function() return game.Players.LocalPlayer.UserId end
local cachedLink, cachedTime = "", 0

--! pick host
local host = "https://api.platoboost.com"
local hostResponse = fRequest({
    Url = host .. "/public/connectivity",
    Method = "GET"
})
if hostResponse.StatusCode ~= 200 or hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net"
end

-- Function to save key to GitHub Gist using UserId
local function saveKeyToGist(key)
    local userId = fGetUserId()
    local body = HttpService:JSONEncode({
        files = {
            [userId .. "_keyBindings.json"] = { -- Using UserId as part of the file name
                content = HttpService:JSONEncode({ key = key })
            }
        }
    })

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = "https://api.github.com/Lunahubv2" .. GIST_ID,
            Method = "PATCH",
            Headers = {
                ["Authorization"] = "token " .. GITHUB_TOKEN,
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)

    if success and response.StatusCode == 200 then
        print("Key saved successfully!")
    else
        warn("Failed to save key: " .. (response or "Unknown error"))
    end
end

-- Function to load key from GitHub Gist using UserId
local function loadKeyFromGist()
    local userId = fGetUserId()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://api.github.com/Lunahubv2" .. GIST_ID, true, {
            ["Authorization"] = "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" .. GITHUB_TOKEN
        })
    end)

    if success and response then
        local data = HttpService:JSONDecode(response)
        local keyFileName = userId .. "_keyBindings.json" -- Using UserId for the file name
        if data.files[keyFileName] then
            local fileContent = data.files[keyFileName].content
            local keyData = HttpService:JSONDecode(fileContent)

            if keyData.key then
                return keyData.key
            else
                warn("No key found in Gist.")
                return nil
            end
        else
            warn("No key bindings file found for UserId.")
            return nil
        end
    else
        warn("Failed to load key: " .. (response or "Unknown error"))
        return nil
    end
end

-- Cache Link Function (Unchanged)
function cacheLink()
    if cachedTime + (10 * 60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({
                service = service,
                identifier = lDigest(fGetUserId()) -- Use UserID here
            }),
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })

        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body)

            if decoded.success == true then
                cachedLink = decoded.data.url
                cachedTime = fOsTime()
                return true, cachedLink
            else
                onMessage(decoded.message)
                return false, decoded.message
            end
        elseif response.StatusCode == 429 then
            local msg = "you are being rate limited, please wait 20 seconds and try again."
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

cacheLink()

-- Example usage of saving and loading keys
local playerKey = "example_key" -- Replace this with the actual key you want to save

-- Save key when player leaves
game.Players.PlayerRemoving:Connect(function(player)
    saveKeyToGist(playerKey) -- Replace playerKey with the actual key you want to save
end)

-- Load key when player joins
game.Players.PlayerAdded:Connect(function(player)
    local loadedKey = loadKeyFromGist()
    if loadedKey then
        print("Loaded Key: " .. loadedKey)
        -- Here you can set the loaded key to appropriate game logic
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Lunahubv2/LunaHub-V3/refs/heads/main/lunahub-main.lua"))()
    end
end)
game.Players.PlayerRemoving:Connect(function(player)
    saveKeyToGist(playerKey) -- Replace playerKey with the actual key you want to save
end)

-- Load key when player joins
game.Players.PlayerAdded:Connect(function(player)
    local loadedKey = loadKeyFromGist()
    if loadedKey then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Lunahubv2/LunaHubV2/main/source.lua"))()
        -- Here you can set the loaded key to appropriate game logic
    end
end)
