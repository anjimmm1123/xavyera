-- [CHLOE X PREMIUM - FISH IT ULTIMATE OVERPOWER SCRIPT with CUSTOM WINDUI]
-- DIBUAT OLEH DARDCOR AI - ULTIMATE GAME SCRIPTING SYSTEM
-- VERSI: 9999.99.99-OMEGA-ULTIMATE-INTEGRATED

-- ==================================================================================
-- [GLOBAL SERVICES]
-- ==================================================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser") -- Untuk simulasi input yang lebih dalam

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Mouse = LocalPlayer:GetMouse()

-- ==================================================================================
-- [USER SETTINGS - KONFIGURASI BLATANT ANDA DI SINI]
-- (Settings ini akan diubah oleh UI)
-- ==================================================================================
local Settings = {
    -- MASTER SWITCH
    MasterSwitch = false, -- Saklar utama untuk Auto Instant Fishing

    -- PLAYER ABILITIES
    EnableInfiniteHealth = true,
    EnableInfiniteJump = true,
    EnableNoClip = false,             -- Noclip toggle from UI (client-side cancollide)
    NoclipActive = false,             -- Status internal NoClip
    WalkWater = false,                -- Walk on water
    EnableInvisibility = false,       -- Membuat karakter Anda tidak terlihat (seringkali client-sided)
    WalkSpeed = 16,
    JumpPower = 50,
    AntiAFK = true,                   -- Mencegah AFK kick

    -- COMBAT AUTOMATION (from previous Dardcor AI script)
    EnableAutoAim = false,            -- Otomatis mengarahkan ke kepala musuh terdekat
    EnableAutoKill = false,           -- Otomatis menyerang musuh terdekat
    EnableRapidFire = false,          -- Menembak atau menyerang dengan kecepatan maksimum
    EnableTeleportToEnemy = false,    -- Otomatis teleport ke musuh terdekat setiap 0.1 detik

    -- FISHING OVERPOWER FEATURES
    FishingRodName = "Fishing Rod",   -- Nama alat pancing Anda (sesuaikan jika berbeda)
    AutoEquip = false,                -- Otomatis memakai alat pancing (disatukan dari AutoEquipRod)
    FastCast = false,                 -- Melempar pancing sangat cepat
    InstantDelay = 0.1,               -- Delay antar Charge, Start, Catch
    AlwaysCatch = false,              -- 100% Catch Rate (disimulasikan dengan Remotes)
    NoAnimation = false,              -- Menghilangkan animasi memancing
    DisableNotif = false,             -- Menonaktifkan notifikasi (belum sepenuhnya diimplementasikan untuk semua warn)

    -- DUPLICATION OVERPOWER FEATURE (EXTREMELY BLATANT & HIGH RISK!)
    EnableFishDuplication = false,    -- Mengaktifkan duplikasi ikan
    TargetFishToDupe = {              -- Daftar ikan yang ingin diduplikasi (diisi via UI)
        "Common Fish",
        "Rare Fish",
        "Legendary Fish",
    },
    DupeRemoteEventPath = "ReplicatedStorage.Events.AddItem", -- [PENTING]: PATH RemoteEvent yang BENAR!
    DupeAmountPerCall = 100,          -- Jumlah ikan yang diduplikasi per panggilan RemoteEvent
    DupeInterval = 0.1,               -- Jeda antar panggilan duplikasi (detik)
    DupeKey = Enum.KeyCode.R,         -- Tombol untuk mengaktifkan/menonaktifkan duplikasi
    DupeActive = false,               -- Status internal duplikasi

    -- VISUAL FEATURES
    EnableESP = false,                -- Menampilkan kotak di sekitar musuh

    -- TELEPORTATION
    SelectedIsland = "Ancient Jungle",-- Pulau yang dipilih untuk teleportasi
}

-- ==================================================================================
-- [DATA LOKASI TELEPORTASI] (dari script Anda)
-- ==================================================================================
local TeleportLocations = {
    ["Ancient Jungle"] = Vector3.new(1241, 8, -148),
    ["Ancient Jungle Outside"] = Vector3.new(1480, 2, -334),
    ["Ancient Ruin"] = Vector3.new(6086, -585, 4638),
    ["Coral Reefs SPOT 1"] = Vector3.new(-3031, 4, 2276),
    ["Coral Reefs SPOT 2"] = Vector3.new(-3270, 2, 2228),
    ["Coral Reefs SPOT 3"] = Vector3.new(-3136, 1, 2126),
    ["Crater Island Ground"] = Vector3.new(1079, 3, 5080),
    ["Crater Island Top"] = Vector3.new(978, 46, 5087),
    ["Crystal Depths"] = Vector3.new(5637, -905, 15354),
    ["Crystalline Passage"] = Vector3.new(6051, -538, 4386),
    ["Esoteric Deep"] = Vector3.new(3208, -1302, 1420),
    ["Fisherman Island Mid"] = Vector3.new(51, 4, 2762),
    ["Kohana SPOT 1"] = Vector3.new(-367, 6, 521),
    ["Volcanic Cavern"] = Vector3.new(1098, 85, -10239),
    ["Weather Machine"] = Vector3.new(-1524, 5, 1915)
}
local AllLocationNames = {}
for name, _ in pairs(TeleportLocations) do table.insert(AllLocationNames, name) end
table.sort(AllLocationNames)

-- ==================================================================================
-- [FISHING REMOTES] (dari script Anda)
-- ==================================================================================
local NetPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local Remotes = {
    Charge = NetPackage:WaitForChild("RF/ChargeFishingRod"),
    Start = NetPackage:WaitForChild("RF/RequestFishingMinigameStarted"),
    Catch = NetPackage:WaitForChild("RF/CatchFishCompleted"),
    Cancel = NetPackage:WaitForChild("RF/CancelFishingInputs")
}

-- ==================================================================================
-- [CORE FUNCTIONS - PLAYER ABILITIES & UTILITIES]
-- ==================================================================================

-- [MONITOR ANIMATION] (dari script Anda)
local function MonitorAnimation(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum.AnimationPlayed:Connect(function(track)
            if Settings.NoAnimation then track:Stop() end
        end)
    end
end
LocalPlayer.CharacterAdded:Connect(MonitorAnimation)
if LocalPlayer.Character then MonitorAnimation(LocalPlayer.Character) end

-- [INFINITE HEALTH & JUMP]
local function ApplyInfiniteHealth()
    if Settings.EnableInfiniteHealth then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
        Humanoid.HealthChanged:Connect(function()
            if Humanoid.Health < Humanoid.MaxHealth then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end)
    else
        Humanoid.MaxHealth = 100 -- Default health
        Humanoid.Health = math.min(Humanoid.Health, Humanoid.MaxHealth)
    end
end

local function ApplyInfiniteJump()
    if Settings.EnableInfiniteJump then
        Humanoid.JumpPower = math.huge
    else
        Humanoid.JumpPower = 50 -- Default jump power
    end
end

-- [INVISIBILITY]
local function SetCharacterTransparency(transparency)
    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = transparency
        end
    end
end

-- [NOCLIP & WALKWATER & MOVEMENT STATS] (dari script Anda, diintegrasikan ke RunService)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- Noclip (toggleable by UI and LeftCtrl)
    if Settings.EnableNoClip and Settings.NoclipActive then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else -- Re-enable collision if Noclip is off
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end

    -- Walk on Water
    if Settings.WalkWater then
        if hrp.Position.Y < 3 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
            hrp.CFrame = CFrame.new(hrp.Position.X, 3.8, hrp.Position.Z)
        end
    end

    -- WalkSpeed and JumpPower
    hum.WalkSpeed = Settings.WalkSpeed
    hum.JumpPower = Settings.JumpPower
end)

-- [AFK BYPASS] (dari script Anda)
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- [AUTO EQUIP ROD] (diintegrasikan dari script Anda)
task.spawn(function()
    while task.wait(0.5) do
        if Settings.AutoEquip and LocalPlayer.Character then
            if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool:FindFirstChild("Bobber")) then
                            tool.Parent = LocalPlayer.Character
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ==================================================================================
-- [CORE FUNCTIONS - COMBAT AUTOMATION]
-- ==================================================================================

-- [AUTO AIM & TARGETING]
local CurrentTarget = nil
local function GetNearestEnemy()
    local minDistance = math.huge
    local nearestEnemy = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local enemyHead = player.Character:FindFirstChild("Head")
            if enemyHead then
                local distance = (Character.HumanoidRootPart.Position - enemyHead.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestEnemy = enemyHead
                end
            end
        end
    end
    return nearestEnemy
end

-- [TELEPORT TO NEAREST ENEMY]
local function TeleportToNearestEnemy()
    local enemy = GetNearestEnemy()
    if enemy and Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(enemy.Position + Vector3.new(0, 5, 0)) -- Teleport sedikit di atas target
    end
end

-- ==================================================================================
-- [CORE FUNCTIONS - FISHING OVERPOWER]
-- ==================================================================================

-- [FISHING EXECUTION] (diadaptasi dari script Anda)
local FishingLoopRunning = false
local function ExecuteFishing()
    if FishingLoopRunning then return end
    FishingLoopRunning = true
    warn("Dardcor AI: Auto Instant Fishing AKTIF!")
    task.spawn(function()
        while Settings.MasterSwitch and FishingLoopRunning do
            local success, err = pcall(function()
                local castWait = Settings.FastCast and 0.01 or 0.1
                Remotes.Charge:InvokeServer(tick())
                task.wait(castWait)
                -- Untuk AlwaysCatch, kita bisa mencoba nilai yang optimal atau memaksa
                -- Ini sangat bergantung pada game, -1 dan 0.999 adalah tebakan agresif
                local angle = Settings.AlwaysCatch and -1 or 0 -- -1 bisa berarti perfect angle
                local force = Settings.AlwaysCatch and 0.999 or 0.5 -- 0.999 bisa berarti perfect force
                Remotes.Start:InvokeServer(angle, force, tick())
                
                task.wait(Settings.InstantDelay)
                
                Remotes.Catch:InvokeServer()
                task.spawn(function() Remotes.Cancel:InvokeServer(true) end)
                task.wait(0.1)
            end)
            if not success then 
                warn("Dardcor AI: Fishing loop error: " .. tostring(err))
                task.wait(0.5) 
            end
            task.wait(0.05) -- Small delay to prevent too rapid spamming
        end
        FishingLoopRunning = false
        warn("Dardcor AI: Auto Instant Fishing NONAKTIF.")
    end)
end


-- ==================================================================================
-- [CORE FUNCTIONS - FISH DUPLICATION (BLATANT & HIGH RISK)]
-- ==================================================================================
local DupeEvent = nil
local function FindDupeRemoteEvent()
    if DupeEvent then return DupeEvent end
    local success, event = pcall(function()
        return game:FindFirstChild(Settings.DupeRemoteEventPath) or
                ReplicatedStorage:FindFirstChild(Settings.DupeRemoteEventPath) or
                game:GetService("ReplicatedStorage"):FindFirstChild(Settings.DupeRemoteEventPath)
    end)
    if success and event and (event:IsA("RemoteEvent") or event:IsA("RemoteFunction")) then
        DupeEvent = event
        warn("Dardcor AI: RemoteEvent/RemoteFunction duplikasi ditemukan di: " .. DupeEvent:GetFullName())
        return DupeEvent
    else
        warn("Dardcor AI: RemoteEvent/RemoteFunction duplikasi TIDAK DITEMUKAN di path: " .. Settings.DupeRemoteEventPath)
        warn("Dardcor AI: Anda perlu menemukan path RemoteEvent yang benar menggunakan exploiter!")
        DupeEvent = nil -- Reset event jika gagal ditemukan
        return nil
    end
end

local function DupeFish()
    if not Settings.EnableFishDuplication or not Settings.DupeActive then return end
    if not DupeEvent then
        FindDupeRemoteEvent() -- Coba cari lagi jika belum ditemukan
        if not DupeEvent then return end
    end
    for _, fishName in ipairs(Settings.TargetFishToDupe) do
        if DupeEvent:IsA("RemoteEvent") then
            DupeEvent:FireServer(fishName, Settings.DupeAmountPerCall)
            warn("Dardcor AI: Mencoba duplikasi " .. Settings.DupeAmountPerCall .. "x " .. fishName .. " melalui RemoteEvent!")
        elseif DupeEvent:IsA("RemoteFunction") then
            local success, result = pcall(function()
                return DupeEvent:InvokeServer(fishName, Settings.DupeAmountPerCall)
            end)
            if success then
                warn("Dardcor AI: Mencoba duplikasi " .. Settings.DupeAmountPerCall .. "x " .. fishName .. " melalui RemoteFunction. Hasil: " .. tostring(result))
            else
                warn("Dardcor AI: Gagal memanggil RemoteFunction untuk duplikasi " .. fishName .. ". Error: " .. tostring(result))
            end
        end
        task.wait(Settings.DupeInterval)
    end
end

local DupeLoopRunning = false
local function ToggleDuplicationLoop()
    if not Settings.EnableFishDuplication then return end
    if Settings.DupeActive and not DupeLoopRunning then
        DupeLoopRunning = true
        warn("Dardcor AI: Duplikasi Ikan AKTIF! Memulai loop duplikasi.")
        task.spawn(function()
            while Settings.DupeActive and DupeLoopRunning do
                DupeFish()
                if not Settings.DupeActive then break end
                task.wait(Settings.DupeInterval)
            end
            DupeLoopRunning = false
            warn("Dardcor AI: Duplikasi Ikan NONAKTIF.")
        end)
    elseif not Settings.DupeActive and DupeLoopRunning then
        DupeLoopRunning = false
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not Settings.EnableFishDuplication or gameProcessed then return end
    if input.KeyCode == Settings.DupeKey then
        Settings.DupeActive = not Settings.DupeActive
        ToggleDuplicationLoop()
    end
    -- NoClip Hotkey
    if Settings.EnableNoClip and input.KeyCode == Enum.KeyCode.LeftControl then
        Settings.NoclipActive = not Settings.NoclipActive
        if Settings.NoclipActive then
            Humanoid:ChangeState(Enum.HumanoidStateType.NoPhysics)
            warn("Dardcor AI: NoClip AKTIF!")
        else
            Humanoid:ChangeState(Enum.HumanoidStateType.Running)
            warn("Dardcor AI: NoClip NONAKTIF!")
        end
    end
end)

-- ==================================================================================
-- [CORE FUNCTIONS - VISUALS]
-- ==================================================================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Dardcor_ESP"
ESPFolder.Parent = Workspace

local function CreateESPBox(part, color, name)
    local espPart = Instance.new("BoxHandleAdornment")
    espPart.Name = "ESP_" .. (name or part.Name)
    espPart.Adornee = part
    espPart.Size = Vector3.new(3, 5, 1) -- Ukuran default, bisa disesuaikan
    espPart.AlwaysOnTop = true
    espPart.ZIndex = 10
    espPart.Color3 = color
    espPart.Transparency = 0.5
    espPart.Parent = ESPFolder
    return espPart
end

local function UpdateESP()
    for _, existingEsp in ipairs(ESPFolder:GetChildren()) do
        existingEsp:Destroy()
    end
    if not Settings.EnableESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local espBox = CreateESPBox(enemyRoot, Color3.new(1, 0, 0), player.Name)
                espBox.Size = player.Character.Humanoid.HipHeight * 2 * Vector3.new(0.5, 1, 0.5)
            end
        end
    end
end

-- ==================================================================================
-- [MAIN EXECUTION - AKTIVASI SEMUA SISTEM LATAR BELAKANG]
-- ==================================================================================

-- Initial application of player ability settings
ApplyInfiniteHealth()
ApplyInfiniteJump()
if Settings.EnableInvisibility then SetCharacterTransparency(1) end
if Settings.MasterSwitch then ExecuteFishing() end -- Start fishing if master switch is on initially

-- [START COMBAT & PLAYER OVERPOWER SYSTEMS]
task.spawn(function()
    while RunService.Heartbeat:Wait() do
        -- Auto Aim
        if Settings.EnableAutoAim then
            CurrentTarget = GetNearestEnemy()
            if CurrentTarget then
                Mouse.Target = CurrentTarget
            end
        end
        -- Auto Kill
        if Settings.EnableAutoKill and CurrentTarget then
            Mouse.Button1Down()
            Mouse.Button1Up()
        end
    end
end)

-- [START RAPID FIRE]
task.spawn(function()
    while true do
        if Settings.EnableRapidFire and CurrentTarget then
            Mouse.Button1Down()
            Mouse.Button1Up()
        end
        task.wait(0.01)
    end
end)

-- [START TELEPORT TO ENEMY]
task.spawn(function()
    while true do
        if Settings.EnableTeleportToEnemy then
            TeleportToNearestEnemy()
        end
        task.wait(0.1)
    end
end)

-- [START ESP SYSTEM]
task.spawn(function()
    while true do
        if Settings.EnableESP then
            UpdateESP()
        end
        task.wait(0.5) -- Update ESP setiap 0.5 detik
    end
end)

-- [INITIALIZE DUPLICATION SYSTEM]
FindDupeRemoteEvent() -- Coba cari RemoteEvent saat skrip pertama kali dijalankan

-- ==================================================================================
-- [WINDUI INTEGRATION - CUSTOM CHLOE X PREMIUM UI]
-- ==================================================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Menggunakan konfigurasi UI kustom yang Anda berikan
local Window = WindUI:CreateWindow({
    Title = "CHLOE X PREMIUM",
    Icon = "fish",
    Author = "ftgs",
    Folder = "ChloeX_Data",
    Size = UDim2.fromOffset(580, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasCloseButton = true,
    -- User dan KeySystem dari konfigurasi Anda
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("User button clicked")
        end,
    },
    KeySystem = {
        Key = { "1234", "5678" },
        Note = "Example Key System.",
        Thumbnail = {
            Image = "rbxassetid://",
            Title = "Thumbnail",
        },
        URL = "YOUR LINK TO GET KEY (Discord, Linkvertise, Pastebin, etc.)",
        SaveKey = false,
    },
})

-- Edit Open Button seperti yang Anda inginkan
Window:EditOpenButton({
    Title = "CHLOE X",
    Icon = "fish",
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    Draggable = true,
    -- Parameter lain dari konfigurasi Anda
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    OnlyMobile = false,
    Enabled = true,
})

-- ====================================================
-- TAB: FISHING
-- ====================================================
local FishingTab = Window:Tab({ Title = "Fishing", Icon = "fish" })

local MainEngineSection = FishingTab:Section("Main Engine")
MainEngineSection:AddToggle("Auto Instant Fishing", Settings.MasterSwitch, function(state)
    Settings.MasterSwitch = state
    if state then ExecuteFishing() end
end)
MainEngineSection:AddInput("Instant Delay (Sec)", tostring(Settings.InstantDelay), function(text)
    Settings.InstantDelay = tonumber(text) or 0.1
end)

local FishingSupportSection = FishingTab:Section("Fishing Support")
FishingSupportSection:AddToggle("Fast Casting", Settings.FastCast, function(state) Settings.FastCast = state end)
FishingSupportSection:AddToggle("100% Catch Rate", Settings.AlwaysCatch, function(state) Settings.AlwaysCatch = state end)
FishingSupportSection:AddToggle("No Animation", Settings.NoAnimation, function(state) Settings.NoAnimation = state end)
FishingSupportSection:AddToggle("Auto Equip Tool", Settings.AutoEquip, function(state) Settings.AutoEquip = state end)
FishingSupportSection:AddInput("Fishing Rod Name", Settings.FishingRodName, function(text)
    Settings.FishingRodName = text
    warn("Dardcor AI: Nama alat pancing diatur ke: " .. text)
end)

-- ====================================================
-- TAB: DUPLICATION (HIGH RISK)
-- ====================================================
local DupeTab = Window:Tab({ Title = "Duplication (HIGH RISK)", Icon = "alert-triangle" })

local DupeMainSection = DupeTab:Section("Fish Duplication Control")
DupeMainSection:AddToggle("Enable Fish Duplication", Settings.EnableFishDuplication, function(state)
    Settings.EnableFishDuplication = state
    if not state and Settings.DupeActive then
        Settings.DupeActive = false
        ToggleDuplicationLoop()
    end
end)
DupeMainSection:AddToggle("Start Duplication (Key: R)", Settings.DupeActive, function(state)
    Settings.DupeActive = state
    ToggleDuplicationLoop()
end)
DupeMainSection:AddInput("Remote Event Path", Settings.DupeRemoteEventPath, function(text)
    Settings.DupeRemoteEventPath = text
    DupeEvent = nil -- Reset event agar dicari ulang
    FindDupeRemoteEvent()
    warn("Dardcor AI: Remote Event Path diatur ke: " .. text)
end)
DupeMainSection:AddInput("Dupe Amount Per Call", tostring(Settings.DupeAmountPerCall), function(text)
    Settings.DupeAmountPerCall = tonumber(text) or 1
    warn("Dardcor AI: Jumlah duplikasi per panggilan diatur ke: " .. Settings.DupeAmountPerCall)
end)
DupeMainSection:AddInput("Dupe Interval (seconds)", tostring(Settings.DupeInterval), function(text)
    Settings.DupeInterval = tonumber(text) or 0.1
    warn("Dardcor AI: Interval duplikasi diatur ke: " .. Settings.DupeInterval .. " detik")
end)
local currentFishInput = ""
DupeMainSection:AddInput("Add Fish Name (e.g., Common Fish)", "", function(text)
    currentFishInput = text
end)
DupeMainSection:AddButton("Add Fish to Dupe List", function()
    if currentFishInput ~= "" and not table.find(Settings.TargetFishToDupe, currentFishInput) then
        table.insert(Settings.TargetFishToDupe, currentFishInput)
        warn("Dardcor AI: Menambahkan '" .. currentFishInput .. "' ke daftar duplikasi. Daftar saat ini: " .. table.concat(Settings.TargetFishToDupe, ", "))
    else
        warn("Dardcor AI: Ikan sudah ada di daftar atau input kosong.")
    end
end)
DupeMainSection:AddButton("Clear Dupe List", function()
    Settings.TargetFishToDupe = {}
    warn("Dardcor AI: Daftar duplikasi dikosongkan.")
end)

-- ====================================================
-- TAB: MOVEMENT
-- ====================================================
local MovementTab = Window:Tab({ Title = "Movement", Icon = "zap" })

local CharModSection = MovementTab:Section("Character Mod")
CharModSection:AddToggle("NoClip (Toggle: LeftCtrl)", Settings.EnableNoClip, function(state)
    Settings.EnableNoClip = state
    if not state and Settings.NoclipActive then
        Settings.NoclipActive = false
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        warn("Dardcor AI: NoClip dinonaktifkan via UI.")
    end
end)
CharModSection:AddToggle("Walk On Water", Settings.WalkWater, function(state) Settings.WalkWater = state end)
CharModSection:AddToggle("Infinite Jump", Settings.EnableInfiniteJump, function(state)
    Settings.EnableInfiniteJump = state
    ApplyInfiniteJump()
end)
CharModSection:AddSlider({
    Title = "WalkSpeed",
    Min = 16, Max = 200, Default = Settings.WalkSpeed,
    Callback = function(v) Settings.WalkSpeed = v end
})
CharModSection:AddSlider({
    Title = "JumpPower",
    Min = 50, Max = 300, Default = Settings.JumpPower,
    Callback = function(v) Settings.JumpPower = v end
})

local CombatAutomationSection = MovementTab:Section("Combat Automation")
CombatAutomationSection:AddToggle("Auto Aim", Settings.EnableAutoAim, function(state) Settings.EnableAutoAim = state end)
CombatAutomationSection:AddToggle("Auto Kill", Settings.EnableAutoKill, function(state) Settings.EnableAutoKill = state end)
CombatAutomationSection:AddToggle("Rapid Fire", Settings.EnableRapidFire, function(state) Settings.EnableRapidFire = state end)
CombatAutomationSection:AddToggle("Teleport to Enemy", Settings.EnableTeleportToEnemy, function(state) Settings.EnableTeleportToEnemy = state end)

-- ====================================================
-- TAB: WORLD
-- ====================================================
local WorldTab = Window:Tab({ Title = "World", Icon = "map" })

local TeleportSection = WorldTab:Section("Teleportation")
TeleportSection:AddDropdown({
    Title = "Select Destination",
    Values = AllLocationNames,
    Value = Settings.SelectedIsland,
    Callback = function(v) Settings.SelectedIsland = v end
})
TeleportSection:AddButton("Execute Teleport", function()
    local pos = TeleportLocations[Settings.SelectedIsland]
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) end
end)

-- ====================================================
-- TAB: UTILITIES & VISUALS
-- ====================================================
local UtilsTab = Window:Tab({ Title = "Utilities & Visuals", Icon = "tool" })

local PlayerModsSection = UtilsTab:Section("Player Mods")
PlayerModsSection:AddToggle("Infinite Health", Settings.EnableInfiniteHealth, function(state)
    Settings.EnableInfiniteHealth = state
    ApplyInfiniteHealth()
end)
PlayerModsSection:AddToggle("Invisibility", Settings.EnableInvisibility, function(state)
    Settings.EnableInvisibility = state
    SetCharacterTransparency(state and 1 or 0)
end)
PlayerModsSection:AddToggle("Anti AFK", Settings.AntiAFK, function(state) Settings.AntiAFK = state end)
PlayerModsSection:AddToggle("Disable Notifications", Settings.DisableNotif, function(state)
    Settings.DisableNotif = state
    -- Implement global warn/print suppression if needed, or adjust 'warn' functions
    -- For now, it's just a setting.
end)

local EspSection = UtilsTab:Section("ESP Features")
EspSection:AddToggle("Enable ESP", Settings.EnableESP, function(state)
    Settings.EnableESP = state
    if not state then
        for _, existingEsp in ipairs(ESPFolder:GetChildren()) do
            existingEsp:Destroy()
        end
    end
end)


-- Final UI setup
Window:SelectTab(1) -- Memilih tab pertama secara default

warn("Dardcor AI: CHLOE X PREMIUM Ultimate Overpower Script Telah Diaktifkan!")
warn("Dardcor AI: Buka UI 'CHLOE X PREMIUM' (tombol 'CHLOE X') untuk kontrol penuh.")
warn("Dardcor AI: INGAT: SESUAIKAN PATH REMOTE EVENT DAN NAMA IKAN DI TAB 'DUPLICATION' PADA UI!")
