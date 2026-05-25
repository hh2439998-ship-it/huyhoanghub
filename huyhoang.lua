-- [[ GAVITY HUB - BLOX FRUITS PRO SYSTEM ]]
-- Chú ý: Nếu không hiện giao diện, hãy ấn nút F9 trong game để xem lỗi của bản Hack (Executor)

local success, RedzLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
end)

if not success or not RedzLib then
    warn("LỖI: Executor của bạn không tải được giao diện Redz UI từ internet. Hãy đổi Executor khác!")
    return
end

-- ====================================================================
-- 1. CẤU HÌNH BIẾN CHẠY (SETTINGS)
-- ====================================================================
_G.AutoFarm = false
_G.BringMob = true
_G.SelectWeapon = "Melee" -- Các lựa chọn: "Melee" (Võ), "Sword" (Kiếm), "Blox Fruit" (Trái)
_G.SelectFarmSpot = "Bone Farm" -- Các lựa chọn: "Bone Farm", "Cake Farm"
_G.TargetMonster = ""
_G.QuestNPC = ""
_G.QuestName = ""
_G.QuestNumber = 1

-- Dữ liệu Tọa độ các đảo & bãi Farm (Cập nhật chuẩn 2026)
local FarmData = {
    ["Bone Farm"] = {
        Monster = "Reborn Skeleton",
        NPCName = "Skeleton Comm",
        NPC_CFrame = CFrame.new(-9515, 164, 5786), -- Tọa độ NPC nhận Q Bone
        Spot_CFrame = CFrame.new(-9350, 150, 5600), -- Tọa độ bãi quái Xương
        QuestName = "SkeletonQuest",
        QuestNumber = 1
    },
    ["Cake Farm"] = {
        Monster = "Baking Commando",
        NPCName = "Cake Governor",
        NPC_CFrame = CFrame.new(-11600, 15, -12000), -- Tọa độ NPC Đảo Bánh
        Spot_CFrame = CFrame.new(-11800, 30, -12300), -- Tọa độ bãi quái Bánh
        QuestName = "CakeQuest",
        QuestNumber = 1
    }
}

-- ====================================================================
-- 2. HỆ THỐNG LOGIC LẬP TRÌNH (CORE LOGIC)
-- ====================================================================

-- Hàm di chuyển mượt mà (Tween Service) không bị Anticheat phát hiện
local function TweenTo(targetCFrame)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 300 -- Tốc độ bay an toàn
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end

-- Hệ thống tự động chọn và mang vũ khí (Weapon Selector)
local function EquipWeapon()
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == _G.SelectWeapon then
                character.Humanoid:EquipTool(tool)
            end
        end
    end
end

-- Cơ chế gom quái tự động (BRING MOB MECHANISM)
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and _G.BringMob and _G.TargetMonster ~= "" then
            pcall(function()
                local myPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy.Name == _G.TargetMonster and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
                        if enemy.Humanoid.Health > 0 then
                            -- Mang quái lại đặt ngay dưới chân / trước mặt người chơi
                            enemy.HumanoidRootPart.CFrame = myPos * CFrame.new(0, -2, -5)
                            enemy.HumanoidRootPart.CanCollide = false
                            if enemy.HumanoidRootPart:FindFirstChild("BodyVelocity") == nil then
                                local bv = Instance.new("BodyVelocity")
                                bv.Velocity = Vector3.new(0,0,0)
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

-- Cơ chế Auto Click & Kill Aura phá đảo tốc độ đánh
task.spawn(function()
    local virtualUser = game:GetService("VirtualUser")
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                EquipWeapon()
                -- Giả lập bấm chuột trái liên tục để đánh quái bằng vũ khí đã chọn
                virtualUser:CaptureController()
                virtualUser:ClickButton1(Vector2.new(851, 529))
            end)
        end
    end
end)

-- Vòng lặp kiểm tra bãi farm và nhiệm vụ (Quest Manager)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoFarm then
            pcall(function()
                local data = FarmData[_G.SelectFarmSpot]
                if data then
                    _G.TargetMonster = data.Monster
                    
                    -- Kiểm tra xem đã nhận nhiệm vụ chưa
                    local hasQuest = game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible
                    if not hasQuest then
                        -- Bay tới NPC để nhận nhiệm vụ tự động
                        TweenTo(data.NPC_CFrame)
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - data.NPC_CFrame.Position).Magnitude < 15 then
                            -- Gọi lệnh gọi Server của Blox Fruits để nhận Quest
                            game:GetService("ReplicatedStorage").Remotes.Comm:InvokeServer("StartQuest", data.QuestName, data.QuestNumber)
                        end
                    else
                        -- Đã có nhiệm vụ, bay thẳng tới bãi quái đứng đợi mang quái tới chân để diệt
                        TweenTo(data.Spot_CFrame)
                    end
                end
            end)
        end
    end
end)

-- ====================================================================
-- 3. KÍCH HOẠT GIAO DIỆN REDZ UI CHUẨN ĐẸP 100%
-- ====================================================================
local Window = RedzLib:MakeWindow({
  Title = "Gavity Hub",
  SubTitle = "by DhuutaiScript",
  SaveFolder = "GavityConfig.lua"
})

-- Tạo nút Logo bay nổi trên màn hình bằng ID ảnh mới nhất của bạn
Window:AddMinimizeButton({
  Button = { 
      Image = "rbxassetid://92816396268641", 
      BackgroundTransparency = 0 
  },
  Corner = { CornerRadius = UDim.new(0, 6) }
})

-- TẠO CÁC PHÂN MỤC TRONG MENU
local FarmTab = Window:MakeTab({"Auto Farm", "home"})

FarmTab:AddSection({"Cấu hình Auto Farm"})

-- Nút Bật/Tắt Auto Farm chính
FarmTab:AddToggle({"Kích Hoạt Auto Farm", _G.AutoFarm, function(state)
    _G.AutoFarm = state
    print("Trạng thái Auto Farm: ", state)
end})

-- Nút Bật/Tắt Gom quái (Bring Mob)
FarmTab:AddToggle({"Bật Cơ Chế Bring Mob", _G.BringMob, function(state)
    _G.BringMob = state
end})

-- Menu lựa chọn bãi Farm (Bone, Cake, v.v...)
FarmTab:AddDropdown({"Chọn Bãi Farm / Nhiệm Vụ", {"Bone Farm", "Cake Farm"}, function(selected)
    _G.SelectFarmSpot = selected
    print("Đã chuyển bãi farm sang: ", selected)
end})

-- Menu lựa chọn vũ khí để farm (Võ, Kiếm, Trái ác quỷ)
FarmTab:AddDropdown({"Chọn Vũ Khí Chiến Đấu", {"Melee", "Sword", "Blox Fruit"}, function(selected)
    _G.SelectWeapon = selected
    print("Vũ khí sử dụng: ", selected)
end})

-- Thông báo kích hoạt thành công ra màn hình
RedzLib:MakeNotification({
  Title = "Gavity Hub",
  Text = "Hệ thống Farm và Giao diện đã sẵn sàng!",
  Time = 5
})
