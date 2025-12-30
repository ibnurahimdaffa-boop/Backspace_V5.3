-- BACKSPACE DROP v5.2 - FULL FIX
-- GitHub: Backspace.V5 | Color: Gray/Red 15%
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- ================= CONFIG FIXED =================
local CONFIG = {
    ButtonText = "BACKSPACE/DROP",
    ButtonSize = UDim2.new(0, 165, 0, 40),
    ButtonPosition = UDim2.new(1, -170, 0, 12), -- Pojok kanan atas
    
    -- WARNA FIX: Abu-abu & Merah dengan 15% transparansi
    TextColor = Color3.fromRGB(255, 60, 60),      -- MERAH
    BgColor = Color3.fromRGB(100, 100, 100),      -- ABU-ABU
    Transparency = 0.15,                           -- 15% transparansi
    
    -- Drop settings
    DropDistance = 5,     -- Jarak drop dari karakter (studs)
    DropHeight = 2.5      -- Tinggi drop dari tanah
}

-- ================= GUI SETUP =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackspaceV52_GUI"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local dropButton = Instance.new("TextButton")
dropButton.Name = "BackspaceBtn_V52"
dropButton.Text = CONFIG.ButtonText
dropButton.Font = Enum.Font.GothamMedium
dropButton.TextSize = 14

-- WARNA FIXED 15% TRANSPARANSI
dropButton.TextColor3 = CONFIG.TextColor
dropButton.TextTransparency = CONFIG.Transparency
dropButton.BackgroundColor3 = CONFIG.BgColor
dropButton.BackgroundTransparency = CONFIG.Transparency

dropButton.BorderSizePixel = 0
dropButton.AutoButtonColor = false
dropButton.Size = CONFIG.ButtonSize
dropButton.Position = CONFIG.ButtonPosition
dropButton.Visible = true
dropButton.Active = true
dropButton.Draggable = false
dropButton.ZIndex = 999

-- Styling
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = dropButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(130, 130, 130)
stroke.Thickness = 1.2
stroke.Transparency = 0.15
stroke.Parent = dropButton

-- ================= IMPROVED DROP FUNCTION =================
-- FIX: No freeze, no teleport, real server-side drop attempt
local function improvedDrop()
    if not player.Character then
        print("[Backspace] No character")
        return
    end
    
    -- Cari tool yang dipegang
    local tool = player.Character:FindFirstChildWhichIsA("Tool")
    if not tool then
        local originalText = dropButton.Text
        dropButton.Text = "NO TOOL!"
        task.wait(0.7)
        dropButton.Text = originalText
        return
    end
    
    -- Visual feedback
    local originalText = dropButton.Text
    local originalColor = dropButton.BackgroundColor3
    dropButton.Text = "DROPPING..."
    dropButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    
    -- FIX: Cari cara SERVER-SIDE drop dulu
    local success = false
    
    -- METHOD 1: Cari RemoteEvent untuk drop (SERVER-SIDE)
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            if nameLower:find("drop") or nameLower:find("unequip") or nameLower:find("tool") then
                pcall(function()
                    obj:FireServer(tool)
                    print("[Backspace] 📡 Used RemoteEvent: " .. obj.Name)
                    success = true
                end)
                if success then break end
            end
        end
    end
    
    -- METHOD 2: Humanoid UnequipTools (lebih natural)
    if not success then
        pcall(function()
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
                print("[Backspace] ⚙️ Used UnequipTools()")
                success = true
            end
        end)
    end
    
    -- METHOD 3: Last resort - client-side drop (visual doang)
    if not success then
        task.spawn(function()
            pcall(function()
                -- Simpan dulu di backpack
                tool.Parent = player.Backpack or workspace
                
                -- FIX: Tidak beku - pakai delayed position
                task.wait(0.05)
                
                -- Drop di depan karakter
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local lookVector = root.CFrame.LookVector
                    local dropCF = root.CFrame + (lookVector * CONFIG.DropDistance) 
                                 + Vector3.new(0, CONFIG.DropHeight, 0)
                    
                    tool.Parent = workspace
                    if tool:FindFirstChild("Handle") then
                        tool:PivotTo(dropCF)
                    end
                end
                
                print("[Backspace] ⚠️ Client-side drop: " .. tool.Name)
            end)
        end)
    end
    
    -- Reset button
    task.wait(0.3)
    dropButton.Text = success and "DROPPED ✓" or "VISUAL ONLY"
    dropButton.BackgroundColor3 = success and Color3.fromRGB(80, 180, 80) 
                                   or Color3.fromRGB(180, 80, 80)
    
    task.wait(0.6)
    dropButton.Text = originalText
    dropButton.BackgroundColor3 = originalColor
end

-- ================= EVENT HANDLERS =================
dropButton.MouseButton1Click:Connect(improvedDrop)
dropButton.TouchTap:Connect(improvedDrop)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Backspace then
        improvedDrop()
    end
end)

-- ================= FINALIZE =================
dropButton.Parent = screenGui

-- Cleanup
for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if gui.Name == "BackspaceV52_GUI" and gui ~= screenGui then
        gui:Destroy()
    end
end

print("╔══════════════════════════════════════╗")
print("║     BACKSPACE DROP v5.2 LOADED       ║")
print("║     FIXED: No Freeze/Teleport        ║")
print("║     Colors: Gray/Red 15% Transp.     ║")
print("║     Attempts Real Server Drop        ║")
print("╚══════════════════════════════════════╝")
