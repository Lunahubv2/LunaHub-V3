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

-- Function to load key from GitHub Gist using UserId
local function loadKeyFromGist()
    local userId = fGetUserId()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://api.github.com/gists/" .. GIST_ID, true, {
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

-- Example usage of saving and loading keys
local playerKey = "Keys.lua" -- Replace this with the actual key you want to save

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

-- Function to load key from GitHub Gist using UserId
local function loadKeyFromGist()
    local userId = fGetUserId()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://api.github.com/gists/" .. GIST_ID, true, {
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
