local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 1. MEMBUAT JENDELA UTAMA
local Window = Rayfield:CreateWindow({
   Name = "XAVYERA EXECUTOR HUB",
   LoadingTitle = "Xavyera Interface",
   LoadingSubtitle = "by Xavyera",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "XavyeraConfig", 
      FileName = "MainHub"
   },
   KeySystem = false
})

-- 2. TAB UTAMA (External Scripts)
local MainTab = Window:CreateTab("Main Scripts", 4483362458)
MainTab:CreateSection("Execute External Scripts")

MainTab:CreateButton({
   Name = "Jalankan Chloe-X",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/MajestySkie/Chloe-X/main/Main/ChloeX"))()
   end,
})

MainTab:CreateButton({
   Name = "Jalankan Lynx",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua"))()
   end,
})

-- 3. TAB SUPPORT FEATURES (Sesuai Gambar 1)
local SupportTab = Window:CreateTab("Support Features", 4483362458)

SupportTab:CreateToggle({
   Name = "No Fishing Animation",
   CurrentValue = false,
   Flag = "NoFishAnim",
   Callback = function(Value)
       print("No Fishing Animation: ", Value)
   end,
})

SupportTab:CreateToggle({
   Name = "Auto Equip Rod (Not Supported)",
   CurrentValue = false,
   Flag = "AutoEquipRod",
   Callback = function(Value)
       print("Auto Equip: ", Value)
   end,
})

SupportTab:CreateToggle({
   Name = "Lock Position",
   CurrentValue = false,
   Flag = "LockPos",
   Callback = function(Value)
       print("Lock Position: ", Value)
   end,
})

SupportTab:CreateToggle({
   Name = "Disable Cutscenes",
   CurrentValue = false,
   Flag = "NoCutscene",
   Callback = function(Value)
       print("Disable Cutscenes: ", Value)
   end,
})

SupportTab:CreateToggle({
   Name = "Show Real Ping Panel",
   CurrentValue = false,
   Flag = "ShowPing",
   Callback = function(Value)
       print("Show Ping: ", Value)
   end,
})

SupportTab:CreateToggle({
   Name = "Disable Obtained Fish Notification",
   CurrentValue = false,
   Flag = "NoFishNotif",
   Callback = function(Value)
       print("Disable Notif: ", Value)
   end,
})

SupportTab:CreateToggle({
   Name = "Disable Skin Effect",
   CurrentValue = false,
   Flag = "NoSkinEffect",
   Callback = function(Value)
       print("Disable Skin Effect: ", Value)
   end,
})

SupportTab:CreateToggle({
   Name = "Walk On Water",
   CurrentValue = false,
   Flag = "WalkWater",
   Callback = function(Value)
       print("Walk On Water: ", Value)
   end,
})

-- 4. TAB PERFORMANCE (Sesuai Gambar 2)
local PerfTab = Window:CreateTab("Performance", 4483362458)

PerfTab:CreateToggle({
   Name = "FPS Booster",
   CurrentValue = false,
   Flag = "FPSBoost",
   Callback = function(Value)
       print("FPS Booster: ", Value)
   end,
})

PerfTab:CreateToggle({
   Name = "Disable 3D Rendering",
   CurrentValue = false,
   Flag = "No3DRender",
   Callback = function(Value)
       if Value then
           game:GetService("RunService"):Set3dRenderingEnabled(false)
       else
           game:GetService("RunService"):Set3dRenderingEnabled(true)
       end
   end,
})

PerfTab:CreateDropdown({
   Name = "FPS Cap",
   Options = {"30", "60", "120", "Unlimited"},
   CurrentOption = {"60"},
   MultipleOptions = false,
   Flag = "FPSCapDropdown",
   Callback = function(Option)
       local targetFPS = Option[1]
       if setfpscap then
            if targetFPS == "Unlimited" then 
                setfpscap(999) 
            else 
                setfpscap(tonumber(targetFPS)) 
            end
       end
   end,
})

-- 5. NOTIFIKASI BERHASIL
Rayfield:Notify({
   Title = "Berhasil!",
   Content = "Xavyera Hub siap digunakan",
   Duration = 5,
   Image = 4483362458,
   Actions = {
      Ignore = {
         Name = "Okay!",
         Callback = function()
            print("User acknowledged.")
         end
      },
   },
})
