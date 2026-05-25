-- [[ GAVITY HUB - RAYFIELD EDITION ]]
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- ====================================================================
-- 1. CẤU HÌNH BIẾN CHẠY (SETTINGS)
-- ====================================================================
_G.AutoFarm = false
_G.BringMob = true
_G.SelectWeapon = "Melee" -- Lựa chọn: "Melee", "Sword", "Blox Fruit"
_G.SelectFarmSpot = "Bone Farm" -- Lựa chọn: "Bone Farm", "Cake Farm"
_G.TargetMonster = ""
_G.QuestName = ""
_G.QuestNumber = 1

local FarmData = {
    ["Bone Farm"] = {
        Monster = "Reborn Skeleton",
        NPCName = "Skeleton Comm",
        NPC_CFrame = CFrame.new(-9515, 164, 5786),
        Spot_CFrame = CFrame.new(-9350, 150, 5600),
        QuestName = "SkeletonQuest",
        QuestNumber = 1
    },
    ["Cake Farm"] = {
        Monster = "Baking Commando",
        NPCName = "Cake Governor",
        NPC_CFrame = CFrame.new(-11600, 15, -12000),
        Spot_CFrame = CFrame.new(-11800, 30, -12300),
        QuestName = "CakeQuest",
        QuestNumber = 1
    }
}

-- ====================================================================
-- 2. CÁC TÍNH NĂNG TỐI ƯU (FUNCTIONS)
-- ====================================================================

-- Hàm bay tới mục tiêu mượt mà (Tween)
local function TweenTo(targetCFrame)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 320 -- Tốc độ tối ưu an toàn
        if distance > 15 then
            local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
            local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            return tween
        end
    end
end

-- Tự động mang vũ khí đã chọn
local function EquipWeapon()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == _G.SelectWeapon then
                player.Character.Humanoid:EquipTool(tool)
            end
        end
    end
end

-- Tự động bật Haki Vũ Trang (Cải tiến mới)
local function AutoHaki()
    if game.Players.LocalPlayer.Character and not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.Comm:InvokeServer("Buso")
    end
end

-- Cơ chế Gom quái (Bring Mob) siêu mượt dưới chân
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and _G.BringMob and _G.TargetMonster ~= "" then
            pcall(function()
                local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy.Name == _G.TargetMonster and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
                        if enemy.Humanoid.Health > 0 and (enemy.HumanoidRootPart.Position - playerPos.Position).Magnitude < 300 then
                            -- Gom quái về ngay trước mặt và hạ thấp xuống chút để dễ chém lan
                            enemy.HumanoidRootPart.CFrame = playerPos * CFrame.new(0, -1, -4)
                            enemy.HumanoidRootPart.CanCollide = false
                            if not enemy.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                                local bv = Instance.new("BodyVelocity")
                                bv.Velocity = Vector3.new(0, 0, 0)
                                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                bv.Parent = enemy.HumanoidRootPart
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Cơ chế Auto Click & Kill Aura (Tối ưu tốc độ bấm)
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    while task.wait(0.05) do -- Đẩy tốc độ click nhanh hơn (0.05 giây)
        if _G.AutoFarm then
            pcall(function()
                EquipWeapon()
                AutoHaki()
                vu:CaptureController()
                vu:ClickButton1(Vector2.new(851, 529))
            end)
        end
    end
end)

-- Vòng lặp quản lý nhiệm vụ và bãi farm
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFarm then
            pcall(function()
                local data = FarmData[_G.SelectFarmSpot]
                if data then
                    _G.TargetMonster = data.Monster
                    local hasQuest = game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible
                    
                    if not hasQuest then
                        -- Chưa có Q thì bay đi nhận Q
                        TweenTo(data.NPC_CFrame)
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.NPC_CFrame.Position).Magnitude < 15 then
                            game:GetService("ReplicatedStorage").Remotes.Comm:InvokeServer("StartQuest", data.QuestName, data.QuestNumber)
                        end
                    else
                        -- Đã có Q, bay ra giữa bãi đứng đợi gom quái
                        TweenTo(data.Spot_CFrame)
                    end
                end
            end)
        end
    end
end)

-- ====================================================================
-- 3. KHỞI TẠO GIAO DIỆN RAYFIELD UI
-- ====================================================================
local Window = Rayfield:CreateWindow({
   Name = "Gavity Hub | Bản Tối Ưu",
   LoadingTitle = "Gavity Hub đang tải...",
   LoadingSubtitle = "by DhuutaiScript",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Tự Động Farm", 4483362458)

MainTab:CreateSection("Cấu hình chính")

-- Nút Bật/Tắt Auto Farm
MainTab:CreateToggle({
   Name = "Kích Hoạt Auto Farm",
   CurrentValue = _G.AutoFarm,
   Callback = function(Value)
      _G.AutoFarm = Value
   end,
})

-- Nút Bật/Tắt Gom Quái
MainTab:CreateToggle({
   Name = "Bật Cơ Chế Bring Mob",
   CurrentValue = _G.BringMob,
   Callback = function(Value)
      _G.BringMob = Value
   end,
})

-- Chọn Bãi Farm
MainTab:CreateDropdown({
   Name = "Chọn Bãi Farm (Địa điểm)",
   Options = {"Bone Farm", "Cake Farm"},
   CurrentOption = {"Bone Farm"},
   MultipleOptions = false,
   Callback = function(Option)
      _G.SelectFarmSpot = Option[1]
   end,
})

-- Chọn Vũ Khí
MainTab:CreateDropdown({
   Name = "Chọn Vũ Khí Chiến Đấu",
   Options = {"Melee", "Sword", "Blox Fruit"},
   CurrentOption = {"Melee"},
   MultipleOptions = false,
   Callback = function(Option)
      _G.SelectWeapon = Option[1]
   end,
})

-- Tab thông tin cấu hình ảnh Logo của bạn
local InfoTab = Window:CreateTab("Thông Tin", 4483362458)
InfoTab:CreateSection("Logo Hệ Thống")
InfoTab:CreateImage({
    Image = "rbxassetid://92816396268641", -- ID ảnh mới của bạn
    Transparency = 0,
})

Rayfield:Notify({
   Title = "Gavity Hub",
   Content = "Bản Rayfield mượt mà đã sẵn sàng hoạt động!",
   Duration = 5
})
