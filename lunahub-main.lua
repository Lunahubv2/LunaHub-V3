local HttpService = game:GetService("HttpService")

-- GitHub Configuration
local githubToken = "your_github_token" -- Replace with your GitHub token
local repoOwner = "Lunahubv2" -- Your GitHub username
local repoName = "Keys-storage" -- Your repository name
local fileName = "Keys.json" -- File where the keys are stored

-- Platoboost Configuration
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

-- GitHub Save Function
local function saveKeysToGitHub(keys)
    local url = "https://api.github.com/repos/" .. repoOwner .. "/" .. repoName .. "/contents/" .. fileName
    local body = {
        message = "Update keys",
        content = HttpService:Base64Encode(HttpService:JSONEncode(keys)),
        sha = nil -- This will be set later if the file exists
    }

    -- Check if the file already exists to get the SHA
    local getResponse = fRequest({
        Url = url,
        Method = "GET",
        Headers = { 
            ["Authorization"] = "token " .. githubToken,
            ["Accept"] = "application/vnd.github.v3+json"
        }
    })

    if getResponse.StatusCode == 200 then
        local fileData = HttpService:JSONDecode(getResponse.Body)
        body.sha = fileData.sha -- Get the SHA of the existing file
    end

    -- Send the PUT request to save the keys
    local putResponse = fRequest({
        Url = url,
        Method = "PUT",
        Body = HttpService:JSONEncode(body),
        Headers = { 
            ["Authorization"] = "token " .. githubToken,
            ["Content-Type"] = "application/json"
        }
    })

    if putResponse.StatusCode == 201 or putResponse.StatusCode == 200 then
        onMessage("Keys saved to GitHub successfully!")
    else
        onMessage("Failed to save keys to GitHub: " .. putResponse.StatusCode)
    end
end

-- Other existing functions...

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
            -- Save the key to GitHub after successful redemption
            saveKeysToGitHub({key}) -- Assuming `keys` is a table of keys to save
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
    local endpoint = host .. "/public/whitelist/" .. tostring(service) .. "?identifier=" .. fGetUserId() .. "&key=" .. key

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

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer.PlayerGui
gui.ResetOnSpawn = false 

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.4, 0, 0.6, 0)
frame.Position = UDim2.new(0.3, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.BackgroundTransparency = 0 
frame.Draggable = true
frame.Parent = gui

local bruh = Instance.new("UICorner")
bruh.CornerRadius = UDim.new(0, 7)
bruh.Parent = frame

local bruh1 = Instance.new("TextLabel")
bruh1.Size = UDim2.new(0.3, 0, 0.15, 0)
bruh1.Position = UDim2.new(0.35, 0, 0.1, 0)
bruh1.BackgroundColor3 = Color3.new(0, 0, 0)
bruh1.BorderColor3 = Color3.new(0, 0, 0)
bruh1.BorderSizePixel = 1
bruh1.Text = "LUNA HUB | KEY SYSTEM" -- Name of your script
bruh1.BackgroundTransparency = 1
bruh1.TextColor3 = Color3.new(255, 255, 255)
bruh1.Font = Enum.Font.SourceSansBold
bruh1.TextSize = 40
bruh1.Parent = frame

local bruh2 = Instance.new("TextLabel")
bruh2.Size = UDim2.new(0.3, 0, 0.15, 0)
bruh2.Position = UDim2.new(0.35, 0, 0.22, 0)
bruh2.BackgroundColor3 = Color3.new(0, 0, 0)
bruh2.BorderColor3 = Color3.new(0, 0, 0)
bruh2.BorderSizePixel = 0
bruh2.Text = "Get Key 🔑"
bruh2.BackgroundTransparency = 1
bruh2.TextColor3 = Color3.new(255, 255, 255)
bruh2.Font = Enum.Font.SourceSans
bruh2.TextSize = 30
bruh2.Parent = frame

local bruh3 = Instance.new("TextBox")
bruh3.Size = UDim2.new(0.499, 0, 0.18, 0)
bruh3.Position = UDim2.new(0.25, 0, 0.43, 0)
bruh3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bruh3.BorderColor3 = Color3.new(0, 0, 0)
bruh3.BorderSizePixel = 0
bruh3.PlaceholderText = "Enter Key Here..."
bruh3.Text = ""
bruh3.TextColor3 = Color3.fromRGB(255, 255, 255)
bruh3.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
bruh3.BackgroundTransparency = 1
bruh3.Font = Enum.Font.Code
bruh3.TextSize = 15
bruh3.TextXAlignment = Enum.TextXAlignment.Center
bruh3.Parent = frame

local bruh4 = Instance.new("UICorner")
bruh4.CornerRadius = UDim.new(0, 5)
bruh4.Parent = bruh3

local bruh5 = Instance.new("UIStroke")
bruh5.Color = Color3.new(1, 1, 1)
bruh5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bruh5.Thickness = 2
bruh5.Parent = bruh3

local bruh6 = Instance.new("TextButton")
bruh6.Size = UDim2.new(0.3, 0, 0.18, 0)
bruh6.Position = UDim2.new(0.1, 0, 0.73, 0)
bruh6.BackgroundColor3 = Color3.new(0, 0, 0)
bruh6.BorderColor3 = Color3.new(0, 0, 0)
bruh6.BorderSizePixel = 0
bruh6.Text = "🔗   Get Key"
bruh6.BackgroundTransparency = 1
bruh6.TextColor3 = Color3.new(255, 255, 255)
bruh6.Font = Enum.Font.SourceSans
bruh6.TextSize = 25
bruh6.Parent = frame

local bruh7 = Instance.new("UICorner")
bruh7.CornerRadius = UDim.new(0, 5)
bruh7.Parent = bruh6

local bruh8 = Instance.new("UIStroke")
bruh8.Color = Color3.new(1, 1, 1)
bruh8.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bruh8.Thickness = 2
bruh8.Parent = bruh6

local bruh9 = Instance.new("TextButton")
bruh9.Size = UDim2.new(0.3, 0, 0.18, 0)
bruh9.Position = UDim2.new(0.6, 0, 0.73, 0)
bruh9.BackgroundColor3 = Color3.new(0, 0, 0)
bruh9.BorderColor3 = Color3.new(0, 0, 0)
bruh9.BorderSizePixel = 0
bruh9.Text = "🔑   Check Key"
bruh9.BackgroundTransparency = 1
bruh9.TextColor3 = Color3.new(255, 255, 255)
bruh9.Font = Enum.Font.SourceSans
bruh9.TextSize = 25
bruh9.Parent = frame

local bruh10 = Instance.new("UICorner")
bruh10.CornerRadius = UDim.new(0, 5)
bruh10.Parent = bruh9

local bruh11 = Instance.new("UIStroke")
bruh11.Color = Color3.new(1, 1, 1)
bruh11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bruh11.Thickness = 2
bruh11.Parent = bruh9

-- Event for Get Key Button
bruh6.MouseButton1Click:Connect(function()
    copyLink()
    bruh6.Text = "🔗   Link Copied!"
    wait(2)
    bruh6.Text = "🔗   Get Key"
end)

bruh9.MouseButton1Click:Connect(function()
    local key = bruh3.Text -- Get the input key from the TextBox
    bruh9.Text = "🔑   Verifying!"
    wait(1)
    
    local validKey = verifyKey(key) -- Verify the key

    if validKey then
        bruh3.Text = "[KeySystem] Valid Key!"

        -- Save the key to GitHub after successful verification
        saveKeysToGitHub(key) -- Save the valid key to GitHub

        -- Load the script from the URL
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Lunahubv2/LunaHubV2/main/source.lua"))()

        -- Destroy the GUI after loading the script
        gui:Destroy()
    else
        -- When the key is invalid
        bruh3.Text = "[KeySystem]🔑 Invalid Key!"
        wait(1)
        bruh3.Text = "[KeySystem]🔑 Enter Key Here"
    end
end)
