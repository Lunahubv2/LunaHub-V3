local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local GITHUB_USERNAME = "your_github_username" -- Your GitHub username
local GITHUB_TOKEN = "your_personal_access_token" -- Your GitHub personal access token
local REPO_NAME = "your_repository_name" -- The name of your repository

-- Function to create or update a file on GitHub
local function saveKeyToGitHub(userId, keyData)
    local filePath = tostring(userId) .. ".txt"
    local url = "https://api.github.com/repos/" .. GITHUB_USERNAME .. "/" .. REPO_NAME .. "/contents/" .. filePath
    
    -- Prepare the content to be saved (base64 encoding)
    local contentToSave = HttpService:JSONEncode(keyData)
    local encodedContent = HttpService:Base64Encode(contentToSave)

    -- Prepare the body for the request
    local body = {
        message = "Auto-save key data for User ID: " .. userId,
        content = encodedContent
    }

    -- Attempt to get the existing file to check for updates
    local existingFileResponse
    local success, errorMessage = pcall(function()
        existingFileResponse = HttpService:GetAsync(url, true)
    end)

    -- If the file already exists, we need to include the SHA for updating
    local sha
    if success and existingFileResponse.StatusCode == 200 then
        local existingFile = HttpService:JSONDecode(existingFileResponse)
        sha = existingFile.sha -- Get the SHA for the existing file
        body.sha = sha -- Include SHA in the body for updates
    end

    -- Send the PUT request to create/update the file
    local response = HttpService:RequestAsync({
        Url = url,
        Method = "PUT",
        Headers = {
            ["Authorization"] = "token " .. GITHUB_TOKEN,
            ["Accept"] = "application/vnd.github.v3+json"
        },
        Body = HttpService:JSONEncode(body)
    })

    -- Handle the response
    if response.StatusCode == 201 then
        print("File created successfully!")
    elseif response.StatusCode == 200 then
        print("File updated successfully!")
    else
        warn("Failed to save key: " .. response.StatusCode .. " " .. response.StatusMessage)
    end
end

-- Function to load key data from GitHub
local function loadKeyFromGitHub(userId)
    local filePath = tostring(userId) .. ".txt"
    local url = "https://api.github.com/repos/" .. GITHUB_USERNAME .. "/" .. REPO_NAME .. "/contents/" .. filePath
    local response

    local success, errorMessage = pcall(function()
        response = HttpService:GetAsync(url, true)
    end)

    if success and response.StatusCode == 200 then
        local fileData = HttpService:JSONDecode(response)
        local decodedContent = HttpService:Base64Decode(fileData.content)
        local keyData = HttpService:JSONDecode(decodedContent)
        print("Loaded key data for User ID:", userId, keyData)
        return keyData
    else
        warn("Failed to load key for User ID " .. userId .. ": " .. (errorMessage or response.StatusMessage))
    end

    return nil
end

-- Function to handle player joining
local function onPlayerAdded(player)
    local userId = player.UserId
    local loadedKeyData = loadKeyFromGitHub(userId) -- Load key data automatically upon player join
    
    if not loadedKeyData then
        -- If loading failed, you can save a default or new key
        local defaultKeyData = "your_default_key_data_here" -- Replace with your default key data
        saveKeyToGitHub(userId, defaultKeyData) -- Save default key data if loading fails
    end
end

-- Connect the PlayerAdded event to the onPlayerAdded function
Players.PlayerAdded:Connect(onPlayerAdded)
