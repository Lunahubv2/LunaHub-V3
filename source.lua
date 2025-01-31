--! Configuration
local service = 362 -- Your service id, used to identify your service.
local secret = "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad" -- Make sure to obfuscate this if you want to ensure security.
local useNonce = true -- Use a nonce to prevent replay attacks and request tampering.

--! GitHub Configuration
local GITHUB_TOKEN = "YOUR_GITHUB_TOKEN" -- Your GitHub token
local GIST_ID = "YOUR_GIST_ID" -- Your Gist ID

local HttpService = game:GetService("HttpService")

--! Callbacks
local onMessage = function(message) print(message) end

--! Wait for game to load
repeat task.wait(1) until game:IsLoaded()

--! Functions
local requestSending = false

local fGetUserId = function() 
    return game.Players.LocalPlayer.UserId 
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
            Url = "https://api.github.com/gists/" .. GIST_ID,
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
        warn("Failed to save key: " .. (response and response.StatusCode or "Unknown error"))
    end
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
        warn("Failed
