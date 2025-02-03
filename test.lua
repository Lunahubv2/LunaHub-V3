local HttpService = game:GetService("HttpService")

local GITHUB_USERNAME = "your_github_username" -- Your GitHub username
local GITHUB_TOKEN = "your_personal_access_token" -- Your GitHub personal access token
local REPO_NAME = "your_repository_name" -- The name of your repository
local USER_ID = tostring(game.Players.LocalPlayer.UserId) -- Get the current player's UserId
local FILE_PATH = USER_ID .. ".txt" -- The path inside the repository, using UserId for the filename
local KEY_DATA = "your_key_data_here" -- Replace with the actual key data you want to save

-- Function to create or update a file on GitHub
local function saveKeyToGitHub(keyData)
    local url = "https://api.github.com/repos/" .. GITHUB_USERNAME .. "/" .. REPO_NAME .. "/contents/" .. FILE_PATH
    
    -- Prepare the content to be saved (base64 encoding)
    local contentToSave = HttpService:JSONEncode(keyData)
    local encodedContent = HttpService:Base64Encode(contentToSave)

    -- Prepare the body for the request
    local body = {
        message = "Auto-save key data for User ID: " .. USER_ID,
        content = encodedContent
    }

    -- Attempt to get the existing file to check for updates
    local existingFileResponse = HttpService:GetAsync(url, true)

    -- If the file already exists, we need to include the SHA for updating
    local sha
    if existingFileResponse.StatusCode == 200 then
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

-- Call the function to save the key
saveKeyToGitHub(KEY_DATA)
