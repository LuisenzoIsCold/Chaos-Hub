local Ctrl_click_tp = false
local plrs = game:GetService'Players'
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()
local rep = game:GetService'ReplicatedStorage'
local uis = game:GetService'UserInputService'
local ts = game:GetService'TweenService'
local rs = game:GetService'RunService'.RenderStepped
local function findplr(Target)
    local name = Target
    local found = false
    for _,v in pairs(game.Players:GetPlayers()) do 
        if not found and (v.Name:lower():sub(1,#name) == name:lower() or v.DisplayName:lower():sub(1,#name) == name:lower()) then
            name = v
            found = true
        end
    end
    if name ~= nil and name ~= Target then
        return name
    end
end
local function Notify(title,text,duration)
    game:GetService'StarterGui':SetCore('SendNotification',{
    	Title = tostring(title),
    	Text = tostring(text),
    	Duration = tonumber(duration),
    })
end
local function AddCd(tool,Cd)
    local cd = Instance.new('IntValue',tool)
    cd.Name = 'ClientCD'
    game.Debris:AddItem(cd,Cd)
end
local function Shoot(firstPos,nextPos,Revolver)
    if Revolver:FindFirstChild'Barrel' and Revolver.Barrel:FindFirstChild'Attachment' then
    	if Revolver.Barrel.Attachment:FindFirstChild'Sound' then
    		local SoundClone = Revolver.Barrel.Attachment.Sound:Clone()
    		SoundClone.Name = 'Uncopy'
    		SoundClone.Parent = Revolver.Barrel.Attachment
    		SoundClone:Play()
    		game.Debris:AddItem(SoundClone, 1)
    	end
    	local FilterTable = {}
    	table.insert(FilterTable, plr.Character)
    	table.insert(FilterTable, game.Workspace['Target Filter'])
    	for _, v in pairs(game.Workspace:GetDescendants()) do
    		if v.ClassName == 'Accessory' then
    			table.insert(FilterTable, v)
    		end
    	end
    	local a_1, a_2, a_3 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(firstPos, (nextPos - firstPos).Unit * 100), FilterTable)
    	local BulletCl = rep['Revolver Bullet']:Clone()
    	game.Debris:AddItem(BulletCl, 1)
    	BulletCl.Parent = game.Workspace['Target Filter']
    	local mg = (firstPos - a_2).Magnitude
    	BulletCl.Size = Vector3.new(0.2, 0.2, mg)
    	BulletCl.CFrame = CFrame.new(firstPos, nextPos) * CFrame.new(0, 0, -mg / 2)
    	ts:Create(BulletCl, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
    		Size = Vector3.new(0.05, 0.05, mg), 
    		Transparency = 1
    	}):Play()
    	if a_1 then
    		local expPart = Instance.new'Part'
    		game.Debris:AddItem(expPart, 2)
    		expPart.Name = 'Exploding Neon Part'
    		expPart.Anchored = true
    		expPart.CanCollide = false
    		expPart.Shape = 'Ball'
    		expPart.Material = Enum.Material.Neon
    		expPart.BrickColor = BulletCl.BrickColor
    		expPart.Size = Vector3.new(0.1, 0.1, 0.1)
    		expPart.Parent = game.Workspace['Target Filter']
    		expPart.Position = a_2
    		ts:Create(expPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
    			Size = Vector3.new(2, 2, 2), 
    			Transparency = 1
    		}):Play()
    		if Revolver:FindFirstChild'DamageRemote' and a_1.Parent:FindFirstChild'Humanoid' then
    			Revolver.DamageRemote:FireServer(a_1.Parent.Humanoid)
    		end
    	end
    end
end
mouse.Button1Down:connect(function()
    if not uis:IsKeyDown(Enum.KeyCode.LeftControl) then return end if not mouse.Hit then return end 
    if plr.Character and plr.Character:FindFirstChild'HumanoidRootPart' then
        plr.Character:FindFirstChild'HumanoidRootPart'.CFrame = mouse.Hit + Vector3.new(0,5,0)
    end
end)
local tar
plr:GetMouse().KeyDown:Connect(function(key)
    if key == 'r' then
        tar = nil
        for _,v in next,workspace:GetDescendants() do
            if v.Name == 'SelectedPlayer' then
                v:Destroy()
            end
        end
        local n_plr, dist
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= plr and plr.Character and plr.Character:FindFirstChild'HumanoidRootPart' then
                local distance = v:DistanceFromCharacter(plr.Character.HumanoidRootPart.Position)
                if v.Character and (not dist or distance <= dist) and v.Character:FindFirstChildOfClass'Humanoid' and v.Character:FindFirstChildOfClass'Humanoid'.Health>0 and v.Character:FindFirstChild'HumanoidRootPart' then
                    dist = distance
                    n_plr = v
                end
            end
        end
        local sp = Instance.new('SelectionBox',n_plr.Character.HumanoidRootPart)
        sp.Name = 'SelectedPlayer'
        sp.Adornee = n_plr.Character.HumanoidRootPart
        tar = n_plr
    elseif key == 'q' and tar and plr.Character then
        for _,v in next,plr.Character:GetDescendants() do
            if v:IsA'Tool' and v.Name ~= 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'DamageRemote' and v:FindFirstChild'Cooldown' and tar and tar.Character and tar.Character:FindFirstChildOfClass'Humanoid' then
                AddCd(v,v.Cooldown.Value)
                v.DamageRemote:FireServer(tar.Character:FindFirstChildOfClass'Humanoid')
                if v:FindFirstChild'Attack' and plr.Character:FindFirstChildOfClass'Humanoid' then
                    plr.Character:FindFirstChildOfClass'Humanoid':LoadAnimation(v.Attack):Play()
                end
                if v:FindFirstChild'Blade' then
                    for _,x in next,v.Blade:GetChildren() do
                        if x:IsA'Sound' then
                            x:Play()
                        end
                    end
                end
            elseif v:IsA'Tool' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' and tar and tar.Character and tar.Character:FindFirstChild'HumanoidRootPart' then
                v.Parent = plr.Character
                AddCd(v,2)
                rs:wait()
                Shoot(v.Barrel.Attachment.WorldPosition,tar.Character.HumanoidRootPart.Position,v)
                v.ReplicateRemote:FireServer(tar.Character.HumanoidRootPart.Position)
            end
        end
    elseif key == 'c' and plr:FindFirstChild'Backpack' then
        local guns = 0
        for _,v in next,plr.Backpack:GetChildren() do
            if guns<= 10 and plr.Character and plr.Character:FindFirstChild'Head' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' then
                guns = guns+1
                AddCd(v,2)
                v.Parent = plr.Character
                Shoot(plr.Character.Head.Position,mouse.Hit.p,v)
                v.ReplicateRemote:FireServer(mouse.Hit.p)
                v.Parent = plr.Backpack
            end
        end
    elseif key == 'v' then
        for _,v in next,plr.Backpack:GetChildren() do
            if plr.Character and plr.Character:FindFirstChild'Head' and v.Name == 'Kawaii Revolver' and v:FindFirstChild'ReplicateRemote' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' then
                AddCd(v,2)
                v.Parent = plr.Character
                Shoot(v.Barrel.Attachment.WorldPosition,mouse.Hit.p,v)
                v.ReplicateRemote:FireServer(mouse.Hit.p)
                rs:wait()
                v.Parent = plr.Backpack
            end
        end
    elseif key == 'l' and plr.Character then
        Notify('Dupping','Time left: 25 sec',5)
        spawn(function()
            local c = 1
            for i = 1,50 do
                pcall(function()
                    if c>#rep.Weapons:GetChildren() then
                        c = 1
                    end
                end)
                for _,v in next,plr.Character:GetChildren() do
                    if v.Name == 'Loaded' and v:IsA'IntValue' then
                        v:Destroy()
                    end
                end
                for _,v in next,plr.PlayerGui:GetDescendants() do
                    if v:IsA'RemoteEvent' and v.Name == 'RemoteEvent' then
                        pcall(function()
                            v:FireServer(rep.Weapons:GetChildren()[c].Name)
                            c=c+1
                        end)
                    end
                end
                wait(0.5)
            end
        end)
    end
end)


_G.HeadSize = 0
_G.Disabled = nil
 
game:GetService('RunService').RenderStepped:connect(function()
if _G.Disabled then
for i,v in next, game:GetService('Players'):GetPlayers() do
if v.Name ~= game:GetService('Players').LocalPlayer.Name then
pcall(function()
v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
v.Character.HumanoidRootPart.Transparency = 0.7
v.Character.HumanoidRootPart.BrickColor = BrickColor.new("White")
v.Character.HumanoidRootPart.Material = "Neon"
v.Character.HumanoidRootPart.CanCollide = false
end)
end
end
end
end)


---main--------------------------------------------------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({
    Name = "Chaos Hub",
    LoadingTitle = "Chaos Hub Script",
    LoadingSubtitle = "by LuisenzoIsColdest",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "ch"
    },
    Discord = {
       Enabled = false,
       Invite = "", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD.
       RememberJoins = false -- Set this to false to make them join the discord every time they load it up
    },
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Sirius Hub",
       Subtitle = "Key System",
       Note = "Join the discord (discord.gg/sirius)",
       FileName = "SiriusKey",
       SaveKey = true,
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = "Hello"
    }
 })

 local Main = Window:CreateTab("Main", 4370345144)


 local Section = Main:CreateSection("KeyBinds")

 local Label = Main:CreateLabel(" C to Snipe Shot ")

 local Label = Main:CreateLabel(" L to dupe ")

 local Label = Main:CreateLabel(" V to Minigun ")

 local Section = Main:CreateSection("Duping")
 
 local Button = Main:CreateButton({
    Name = "Dupe",
    Callback = function()
        Notify('Dupping','Time left: 25 sec',5)
        spawn(function()
            local c = 1
            for i = 1,50 do
                pcall(function()
                    if c>#rep.Weapons:GetChildren() then
                        c = 1
                    end
                end)
                for _,v in next,plr.Character:GetChildren() do
                    if v.Name == 'Loaded' and v:IsA'IntValue' then
                        v:Destroy()
                    end
                end
                for _,v in next,plr.PlayerGui:GetDescendants() do
                    if v:IsA'RemoteEvent' and v.Name == 'RemoteEvent' then
                        pcall(function()
                            v:FireServer(rep.Weapons:GetChildren()[c].Name)
                            c=c+1
                        end)
                    end
                end
                wait(0.5)
            end
        end)
    end,
 })

 local Section = Main:CreateSection("Main")

 local Button = Main:CreateButton({
    Name = "Godmode",
    Callback = function()
        Notify('Godmode','Loading... wait 5 sec.',5)
        for _,v in next,plr.PlayerGui:GetChildren() do
            if v:IsA'ScreenGui' and v.Name ~= 'Chat' and v.Name ~= 'BubbleChat' then
                v.ResetOnSpawn = false
                spawn(function()
                    wait(5)
                    plr.CharacterAdded:wait()
                    if v then
                        v:Destroy()
                    end
                end)
            elseif v:IsA'LocalScript' then
                v.Parent = plr
                spawn(function()
                    wait(5)
                    v.Parent = plr.PlayerGui
                end)
            end
        end
        if plr.Character and plr.Character:FindFirstChildOfClass'Humanoid' then
            if plr.Character:FindFirstChild'Ragdolled' and plr.Character.Ragdolled:FindFirstChildOfClass'Script' then
                plr.Character.Ragdolled:FindFirstChildOfClass'Script':Destroy()
            end
            local char = plr.Character
            char.Archivable = true
            local new = char:Clone()
            new.Parent = workspace
            plr.Character = new
            wait(2)
            local oldhum = char:FindFirstChildOfClass'Humanoid'
            local newhum = oldhum:Clone()
            newhum.Parent = char
            newhum.RequiresNeck = false
            oldhum.Parent = nil
            wait(2)
            plr.Character = char
            new:Destroy()
            wait(1)
            newhum:GetPropertyChangedSignal('Health'):Connect(
                function()
                    if newhum.Health <= 0 then
                        oldhum.Parent = plr.Character
                        wait(1)
                        oldhum:Destroy()
                    end
                end)
            workspace.CurrentCamera.CameraSubject = char
        end
        Notify('Godmode','Godmode loaded',3)
    end,
 })

 local Button = Main:CreateButton({
    Name = "Sniper Rifle (c)",
    Callback = function()
        wait(2)
        local guns = 0
        for _,v in next,plr.Backpack:GetChildren() do
            if guns<=10 and plr.Character and plr.Character:FindFirstChild'Head' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' then
                guns = guns+1
                AddCd(v,2)
                v.Parent = plr.Character
                Shoot(plr.Character.Head.Position,mouse.Hit.p,v)
                v.ReplicateRemote:FireServer(mouse.Hit.p)
                v.Parent = plr.Backpack
            end
        end
    end,
 })

 local Button = Main:CreateButton({
    Name = "Minigun (v)",
    Callback = function()
        wait(2)
        local c_ = 0
        for _,v in next,plr.Backpack:GetChildren() do
            c_=c_+1
            if c_>=10 then rs:wait() c_=0 end
            if plr.Character and plr.Character:FindFirstChild'Head' and v.Name == 'Kawaii Revolver' and v:FindFirstChild'ReplicateRemote' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' then
                AddCd(v,2)
                v.Parent = plr.Character
                Shoot(v.Barrel.Attachment.WorldPosition,mouse.Hit.p,v)
                v.ReplicateRemote:FireServer(mouse.Hit.p)
                rs:wait()
                v.Parent = plr.Backpack
            end
        end
    end,
 })


 local spam = Window:CreateTab("Spamming", 4483364237)

 local Section = spam:CreateSection("Spam Items")

 local Button = spam:CreateButton({
    Name = "spam C4",
    Callback = function()
        wait(1)
        for _,v in next,plr.Backpack:GetChildren() do
            if v.Name == 'C4' then
                pcall(function()
                    v.Parent = plr.Character
                    rs:wait()
                    v.RemoteEvent:FireServer()
                end)
            end
        end
    end,
 })
 local Button = spam:CreateButton({
    Name = "spam Grenade",
    Callback = function()
        wait(1)
        for _,v in next,plr.Backpack:GetChildren() do
            if v.Name == 'Grenade' then
                pcall(function()
                    v.Parent = plr.Character
                    rs:wait()
                    v.RemoteEvent:FireServer(mouse.Hit.LookVector)
                end)
            end
        end
    end,
 })
 local Button = spam:CreateButton({
    Name = "spam Trap",
    Callback = function()
        wait(1)
        for _,v in next,plr.Backpack:GetChildren() do
            if v.Name == 'Spiked Trap' then
                pcall(function()
                    v.Parent = plr.Character
                    rs:wait()
                    v:Activate()
                end)
            end
        end
    end,
 })

 local Section = spam:CreateSection("Lagging (not recommendable)")

 local Button = spam:CreateButton({
    Name = "Lag Others (100+ guns)",
    Callback = function()
        wait(2)
        local c_
        for _,v in next,plr.Backpack:GetChildren() do
            c_=c_+1
            if c_>=10 then rs:wait() c_=0 end
            if plr.Character and plr.Character:FindFirstChild'Head' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' then
                AddCd(v,2)
                v.Parent = plr.Character
                Shoot(plr.Character.Head.Position,mouse.Hit.p,v)
                v.ReplicateRemote:FireServer(mouse.Hit.p)
                v.Parent = plr.Backpack
            end
        end
    end,
 })


 local Player = Window:CreateTab("Player", 6961018885)


 local Section = Player:CreateSection("Movement LocalPlayer")


 local Toggle = Player:CreateToggle({
    Name = "Ctrl click tp",
    CurrentValue = false,
    Flag = "cct",
    Callback = function(bool)
        Ctrl_click_tp = bool
    end,
 })

 local Slider = Player:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "WS",
    Callback = function(w)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = w
    end,
 })

 local Slider = Player:CreateSlider({
    Name = "JumpPower",
    Range = {50, 400},
    Increment = 10,
    Suffix = "Jumppower",
    CurrentValue = 50,
    Flag = "JP",
    Callback = function(j)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = j
    end,
 })

 local Section = Player:CreateSection("Hitbox Expander")

 local Toggle = Player:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "si", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        _G.Disabled = Value
    end,
 })

 local Slider = Player:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 20},
    Increment = 1,
    Suffix = "Size",
    CurrentValue = 0,
    Flag = "hitbox size",
    Callback = function(Value)
        _G.HeadSize = Value
    end,
 })




 local Credits = Window:CreateTab("Credits", 4483345278)
 local Section = Credits:CreateSection("Credits")
 local Label = Credits:CreateLabel("Original Code:KAKOYTO_LOXX")
 local Label = Credits:CreateLabel("UI lib:Rayfield")
