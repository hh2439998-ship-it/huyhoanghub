local success, err = pcall(function()
    -- ==========================================================
    -- 1. MÀN HÌNH LOADING AN TOÀN CHO MOBILE
    -- ==========================================================
    local guiParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local TweenService = game:GetService("TweenService")

    if guiParent:FindFirstChild("GavityLoading") then
        guiParent.GavityLoading:Destroy()
    end

    local GavityLoading = Instance.new("ScreenGui")
    GavityLoading.Name = "GavityLoading"
    GavityLoading.Parent = guiParent
    GavityLoading.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = GavityLoading
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    MainFrame.Size = UDim2.new(0, 300, 0, 150)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0.1, 0)
    Title.Size = UDim2.new(1, 0, 0.4, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "GAVITY HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 26

    local Status = Instance.new("TextLabel")
    Status.Parent = MainFrame
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 0, 0.55, 0)
    Status.Size = UDim2.new(1, 0, 0.2, 0)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Đang khởi tạo hệ thống..."
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 14

    local BarBack = Instance.new("Frame")
    BarBack.Parent = MainFrame
    BarBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBack.Position = UDim2.new(0.1, 0, 0.8, 0)
    BarBack.Size = UDim2.new(0.8, 0, 0.05, 0)

    local BarFill = Instance.new("Frame")
    BarFill.Parent = BarBack
    BarFill.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    BarFill.Size = UDim2.new(0, 0, 1, 0)

    task.wait(0.5)
    Status.Text = "Đang kết nối thư viện UI..."
    TweenService:Create(BarFill, TweenInfo.new(1), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
    task.wait(1)

    Status.Text = "Đang nạp Rayfield mới..."
    TweenService:Create(BarFill, TweenInfo.new(1.5), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.5)

    GavityLoading:Destroy() -- Xóa Loading

    -- ==========================================================
    -- 2. TẢI GIAO DIỆN CHÍNH (LINK ĐÃ FIX)
    -- ==========================================================
    -- Sửa link shlexware bị sập thành link chính thức của nhóm Sirius
    local Library = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Library:CreateWindow({
        Name = "Gavity Hub | Bản Mobile",
        LoadingTitle = "Gavity Hub",
        LoadingSubtitle = "by lightgumball",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    _G.AutoFarm = false
    _G.BringMob = true
    _G.SelectWeapon = "Melee"
    _G.SelectFarmSpot = "Bone Farm"

    local MainTab = Window:CreateTab("Tự Động Farm", 4483362458)
    MainTab:CreateToggle({Name = "Kích Hoạt Auto Farm", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})
    MainTab:CreateToggle({Name = "Bật Gom Quái (Bring Mob)", CurrentValue = true, Callback = function(v) _G.BringMob = v end})
    MainTab:CreateDropdown({Name = "Chọn Bãi", Options = {"Bone Farm", "Cake Farm"}, CurrentOption = {"Bone Farm"}, Callback = function(o) _G.SelectFarmSpot = o[1] end})
    MainTab:CreateDropdown({Name = "Chọn Vũ Khí", Options = {"Melee", "Sword", "Blox Fruit"}, CurrentOption = {"Melee"}, Callback = function(o) _G.SelectWeapon = o[1] end})

    MainTab:CreateSection("Logo")
    MainTab:CreateImage({Image = "rbxassetid://92816396268641", Transparency = 0})

    -- ==========================================================
    -- 3. CHỨC NĂNG FARM
    -- ==========================================================
    task.spawn(function()
        while task.wait(0.5) do
            if _G.AutoFarm then
                pcall(function()
                    local player = game.Players.LocalPlayer
                    local hasQuest = player.PlayerGui.Main:FindFirstChild("Quest") and player.PlayerGui.Main.Quest.Visible
                end)
            end
        end
    end)
end)

-- BÁO LỖI NẾU CÒN VẤN ĐỀ KHÁC
if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "LỖI HỆ THỐNG",
        Text = tostring(err),
        Duration = 10
    })
end
