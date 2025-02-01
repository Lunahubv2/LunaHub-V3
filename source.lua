local HttpService = game:GetService("HttpService")

local function loadKeyFromGist()
    -- Function to load key from GitHub (Insert your logic here)
end

local loadedKey = loadKeyFromGist()
if loadedKey then
    print("Loaded Key: " .. loadedKey)
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Lunahubv2/LunaHub-V3/refs/heads/main/lunahub-main.lua"))()
end

-- Configuration
local githubToken = "your_github_token" -- Replace with your token
local repoOwner = "Lunahubv2" -- Your GitHub username
local repoName = "Keys-storage" -- Your repository name
local fileName = "Keys.json" -- File where the keys are stored

local service = 362 -- Your service ID
local secret = "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad" -- Obfuscate this for security
local useNonce = true -- Use a nonce to prevent replay attacks

-- Callbacks
local onMessage = function(message) end

-- Wait for game to load
repeat task.wait(1) until game:IsLoaded()

-- Function to make a request to the GitHub API
local function makeRequest(method, url, body)
    local success, response = pcall(function()
        return game:GetService("HttpService"):RequestAsync({
            Url = url,
            Method = method,
            Headers = {
                ["Authorization"] = "token " .. githubToken,
                ["Content-Type"] = "application/json"
            },
            Body = body or nil
        })
    end)

    if not success then
        warn("HTTP request failed: " .. response)
        return nil
    end

    return response
end

-- Function to load keys from GitHub
local function loadKeys()
    local urlBase = string.format("https://api.github.com/repos/%s/%s/contents/%s", repoOwner, repoName, fileName)
    local response = makeRequest("GET", urlBase)

    if response and response.StatusCode == 200 then
        local content = game:GetService("HttpService"):JSONDecode(response.Body)
        local keys = game:GetService("HttpService"):JSONDecode(content.content)
        return keys
    else
        warn("Failed to load keys: " .. (response and response.StatusCode or "No response"))
        return {}
    end
end

-- Function to save keys to GitHub
local function saveKeys(keys)
    local jsonKeys = game:GetService("HttpService"):JSONEncode(keys)

    -- Get the current file SHA for updating
    local urlBase = string.format("https://api.github.com/repos/%s/%s/contents/%s", repoOwner, repoName, fileName)
    local getResponse = makeRequest("GET", urlBase)
    if getResponse and getResponse.StatusCode == 200 then
        local content = game:GetService("HttpService"):JSONDecode(getResponse.Body)
        local sha = content.sha

        local body = game:GetService("HttpService"):JSONEncode({
            message = "Update keys",
            content = game:GetService("HttpService"):GenerateBase64(jsonKeys),
            sha = sha
        })

        local response = makeRequest("PUT", urlBase, body)
        if response and response.StatusCode == 200 then
            print("Keys saved successfully!")
        else
            warn("Failed to save keys: " .. (response and response.StatusCode or "No response"))
        end
    else
        warn("Failed to get file SHA: " .. (getResponse and getResponse.StatusCode or "No response"))
    end
end

-- Function to delete a key by UserId from GitHub
local function deleteKey(userId)
    local keys = loadKeys() -- Load current keys
    keys[userId] = nil -- Remove the key for the given UserId

    saveKeys(keys) -- Save the updated keys back to GitHub
    print("Deleted key for User ID " .. userId)
end

-- Function to redeem a key
local function redeemKey(key)
    -- Implementation of redeemKey function...
end

-- Function to verify a key
local function verifyKey(key)
    -- Implementation of verifyKey function...
end

-- Example usage when a player joins
game.Players.PlayerAdded:Connect(function(player)
    local userId = tostring(player.UserId) -- Get the User ID as a string
    local keys = loadKeys() -- Load all keys

    -- Check if the user already has a key
    local playerKey = keys[userId]

    if playerKey then
        print("Loaded Key for User ID " .. userId .. ": " .. playerKey) -- Display loaded key

        -- Verify the key and delete if it's invalid
        if not verifyKey(playerKey) then
            deleteKey(userId) -- Key is invalid, delete it
            print("Invalid key detected for User ID " .. userId .. ", deleted the key.")
        end
    else
        print("No key found for User ID " .. userId .. ". Assigning a new key.")

        -- Generate a new key for the player (implement your own key generation logic)
        playerKey = "KEY_" .. userId -- Simple example; replace with complex logic if needed
        keys[userId] = playerKey -- Add the new key to keys table
        
        -- Save updated keys back to GitHub
        saveKeys(keys)
    end
end)
