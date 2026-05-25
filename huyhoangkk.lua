-- Khởi tạo UI Library (Đúng y chang bản đầu tiên bạn chạy được)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

-- ====================================================================
-- CẤU HÌNH BIẾN CHẠY (SETTINGS)
-- ====================================================================
_G.AutoFarm = false
_G.BringMob = true
_G.SelectWeapon = "Melee" 
_G.SelectFarmSpot = "Bone Farm" 
_G.TargetMonster = ""

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
-- CÁC TÍNH NĂNG CHẠY NGẦM (FUNCTIONS)
-- ====================================================================

local function TweenTo(targetCFrame)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 320 
        if distance > 15 then
            local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
            local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            return tween
        end
    end
end

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

-- Cơ chế gom quái (Bring Mob) dưới chân
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and _G.BringMob and _G.TargetMonster ~= "" then
            pcall(function()
                local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy.Name == _G.TargetMonster and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
                        if enemy.Humanoid.Health > 0 and (enemy.HumanoidRootPart.Position - playerPos.Position).Magnitude < 300 then
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

-- Cơ chế Auto Click
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    while task.wait(0.05) do 
        if _G.AutoFarm then
            pcall(function()
                EquipWeapon()
                vu:CaptureController()
                vu:ClickButton1(Vector2.new(851, 529))
            end)
        end
    end
end)

-- Vòng lặp nhận Quest và di chuyển ra bãi farm
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFarm then
            pcall(function()
                local data = FarmData[_G.SelectFarmSpot]
                if data then
                    _G.TargetMonster = data.Monster
                    local hasQuest = game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible
                    
                    if not hasQuest then
                        TweenTo(data.NPC_CFrame)
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.NPC_CFrame.Position).Magnitude < 15 then
                            game:GetService("ReplicatedStorage").Remotes.Comm:InvokeServer("StartQuest", data.QuestName, data.QuestNumber)
                        end
                    else
                        TweenTo(data.Spot_CFrame)
                    end
                end
            end)
        end
    end
end)

-- ====================================================================
-- KHỞI TẠO CỬA SỔ CHÍNH (ĐÚNG BẢN GỐC)
-- ====================================================================
local Window = Library:CreateWindow({
    Name = "Gavity Hub | [Tên Game]",
    LoadingTitle = "Gavity Hub đang khởi động...",
    LoadingSubtitle = "by DhuutaiScript",
    ConfigurationSaving = { Enabled = true, FileName = "GavityConfig" },
    KeySystem = false 
})

-- Tạo Tab
local MainTab = Window:CreateTab("Trang chủ", 4483362458)

-- Tạo Section
MainTab:CreateSection("Công cụ chính")

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

-- Phần hiển thị ảnh logo của bạn
MainTab:CreateSection("Logo")
MainTab:CreateImage({
    Image = "rbxassetid://92816396268641",
    Transparency = 0,
})
