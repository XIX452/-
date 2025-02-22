if _G.KeyUIScriptHasRun then
    warn("Anti multi execute")
    return
end
_G.KeyUIScriptHasRun = true

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Usuwanie ekranu ładowania
local loadingScreen = playerGui:FindFirstChild("LoadingScreen")
if loadingScreen then
    loadingScreen:Destroy()
end

-- Referencje do GameGui
local gameGui = playerGui:FindFirstChild("GameGui")
if not gameGui then
    while true do
        warn("-")
        task.wait(0.5) -- Krótkie opóźnienie, aby uniknąć przeciążenia konsoli
    end
end

-- Funkcja do znajdowania dziecka w strukturze
local function findChildRecursive(parent, names)
    local current = parent
    for _, name in ipairs(names) do
        current = current and current:FindFirstChild(name)
        if not current then break end
    end
    return current
end

-- Funkcja do usuwania elementów z listy nazw
local function deleteElements(parent, names)
    for _, name in ipairs(names) do
        local element = parent:FindFirstChild(name)
        if element then
            element:Destroy()
        end
    end
end

-- Usunięcie elementów GUI
deleteElements(gameGui, {"Transition", "KeyHints"})


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "NOTHING HUB",
    SubTitle = "",
    TabWidth = 0,
    Size = UDim2.fromOffset(220, 189),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local keyUrl = "https://raw.githubusercontent.com/XIX452/-/refs/heads/V/Key.lua"
local keyFile = "key.lua"
local savedKey = ""

-- Fetch the key from the URL
local function fetchKey()
    local success, keyResponse = pcall(function()
        return game:HttpGet(keyUrl)
    end)

    if success and keyResponse then
        return keyResponse:match("^%s*(.-)%s*$") -- Remove extra spaces and newlines
    else
        Fluent:Notify({
            Title = "Error!",
            Content = "Failed to fetch key.",
            Duration = 5
        })
        return nil
    end
end

-- Load the saved key from the file
local function loadSavedKey()
    if isfile and isfile(keyFile) then
        savedKey = readfile(keyFile)
    end
end

-- Save the key to a file
local function saveKey(key)
    if writefile then
        writefile(keyFile, key)
    end
end

-- Execute external script
local function executeScript()
    local success, errorMsg = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XIX452/-/refs/heads/V/UI.lua"))()
    end)

    if not success then
        Fluent:Notify({
            Title = "Error!",
            Content = "Failed to load script.",
            Duration = 5
        })
    end

    -- Loop every 0.01 seconds to destroy the window
    while Window do
        Window:Destroy()
        wait(0.01)
    end
end

-- Load previously saved key
loadSavedKey()

local Tabs = {
    x = Window:AddTab({ Title = "Key System", Icon = "" }),
}

-- Add input field for key
local Input = Tabs.x:AddInput("Input", {
    Title = "",
    Default = savedKey,
    Placeholder = "key12345678910",
    Callback = function(Value)
        local keyFromServer = fetchKey()

        if not keyFromServer then
            return -- If fetching the key fails, do nothing
        end

        if Value == keyFromServer then
            saveKey(Value) -- Save the key
            Fluent:Notify({
                Title = "Key Valid",
                Content = "The key is valid.",
                Duration = 3
            })
            executeScript() -- Execute the script, then destroy Fluent
        else
            Fluent:Notify({
                Title = "Key Invalid",
                Content = "The key is invalid.",
                Duration = 3
            })
        end
    end
})

-- Automatically fill the input field with the saved key
if savedKey ~= "" then
    Input:SetValue(savedKey)
end

Tabs.x:AddButton({
    Title = "Get key",
    Description = "",
    Callback = function()
        -- Copy the Discord invite link to the clipboard
        setclipboard("https://discord.gg/eu6gXnCCmZ")
        Fluent:Notify({
            Title = "Link Copied",
            Content = "The Discord invite link has been copied to your clipboard.",
            Duration = 3
        })
    end
})


Window:SelectTab(1)
