-- ====================================================================
-- BƯỚC 1: LOAD GIAO DIỆN TRƯỚC TIÊN (BẮT BUỘC PHẢI LÊN)
-- ====================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Library:CreateWindow({
    Name = "Gavity Hub | Fix Lỗi Tối Đa",
    LoadingTitle = "Đang tải giao diện...",
    LoadingSubtitle = "by DhuutaiScript",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- ====================================================================
-- BƯỚC 2: TẠO CÁC NÚT TRÊN GIAO DIỆN VÀ BIẾN (VARIABLES)
-- ====================================================================
_G.AutoFarm = false
_G.BringMob = true
_G.SelectWeapon = "Melee" 
_G.SelectFarmSpot = "Bone Farm" 
_G.TargetMonster = ""

local MainTab = Window:CreateTab("Tự Động Farm", 4483362458)

MainTab:CreateToggle({
   Name = "Kích Hoạt Auto Farm",
   CurrentValue = _G.AutoFarm,
   Callback = function(Value)
      _G.AutoFarm = Value
   end,
})

MainTab:CreateToggle({
   Name = "Bật Cơ Chế Bring Mob (Gom quái)",
   CurrentValue = _G.BringMob,
   Callback = function(Value)
      _G.BringMob = Value
   end,
})

MainTab:CreateDropdown({
   Name = "Chọn Bãi Farm (Địa điểm)",
   Options = {"Bone Farm", "Cake Farm"},
   CurrentOption = {"Bone Farm"},
   MultipleOptions = false,
   Callback = function(Option)
      _G.SelectFarmSpot = Option[1]
   end,
})

MainTab:CreateDropdown({
   Name = "Chọn Vũ Khí Chiến Đấu",
   Options = {"Melee", "Sword", "Blox Fruit"},
   CurrentOption = {"Melee"},
   MultipleOptions = false,
   Callback = function(Option)
      _G.SelectWeapon = Option[1]
   end,
})

MainTab:CreateSection("Logo Hệ Thống")
MainTab:CreateImage({
    Image = "rbxassetid://92816396268641",
    Transparency = 0,
})

-- ====================================================================
-- BƯỚC 3: DATA VÀ CODE CHỨC NĂNG (ĐƯỢC BẢO VỆ CHỐNG CRASH)
-- ====================================================================
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

local function TweenTo(targetCFrame)
    pcall(function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local distance = (hrp.Position - targetCFrame.Position).Magnitude
            if distance > 15 then
                local tweenInfo = TweenInfo.new(distance / 320, Enum.EasingStyle.Linear)
                game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame}):Play()
            end
        end
    end)
end

local function EquipWeapon()
    pcall(function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == _G.SelectWeapon then
                    player.Character.Humanoid:EquipTool(tool)
                end
            end
        end
    end)
end

-- Vòng lặp gom quái an toàn
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and _G.BringMob and _G.TargetMonster ~= "" then
            pcall(function()
                local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in pairs(enemies:GetChildren()) do
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
                end
            end)
        end
    end
end)

-- Vòng lặp chém an toàn
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                EquipWeapon()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(851, 529))
            end)
        end
    end
end)

-- Vòng lặp nhận Quest (Fix triệt để lỗi chưa load xong game)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoFarm then
            pcall(function()
                local data = FarmData[_G.SelectFarmSpot]
                if data then
                    _G.TargetMonster = data.Monster
                    
                    -- Cách kiểm tra Quest an toàn không bị sập code
                    local player = game.Players.LocalPlayer
                    local hasQuest = false
                    if player and player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("Quest") then
                        hasQuest = player.PlayerGui.Main.Quest.Visible
                    end
                    
                    if not hasQuest then
                        TweenTo(data.NPC_CFrame)
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            if (player.Character.HumanoidRootPart.Position - data.NPC_CFrame.Position).Magnitude < 15 then
                                game:GetService("ReplicatedStorage").Remotes.Comm:InvokeServer("StartQuest", data.QuestName, data.QuestNumber)
                            end
                        end
                    else
                        TweenTo(data.Spot_CFrame)
                    end
                end
            end)
        end
    end
end)
