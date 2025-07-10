function Notification(title, text, duration)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = duration
	})
	local sound = Instance.new("Sound", workspace)
	sound.SoundId = "rbxassetid://4590657391"
	sound.Volume = 2
	sound:Play()
end
Notification("Notification", "Pressure Loading", 2)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/TynaRan/VapeMobile/refs/heads/main/vapemobile.lua"))()

local Win = UI:Window("Preesure Creepy client", Color3.fromRGB(80, 120, 200), Enum.KeyCode.RightControl)
local ESPTab = Win:Tab("ESP")
local PropTab = Win:Tab("Property")
local LoopTab = Win:Tab("Loops")
Notification("Notification", "God is fixing (now use hipheight)", 2)
local Config = {
ESPEnabled=false,
Players={Enabled=true,Color=Color3.fromRGB(0,255,0),ShowDistance=true,ShowName=true},
Special={
["NormalKeyCard"]={Color=Color3.fromRGB(255,0,255),DisplayName="Key"},
["ItemLocker"]={Color=Color3.fromRGB(0,255,255),DisplayName="Hiding Place"},
["LockerCollision"]={Color=Color3.fromRGB(0,200,200),DisplayName="Hiding Place"}
},
Items={
Flashlight={Color=Color3.fromRGB(255,165,0),DisplayName="Flashlight"},
["Code Breacher"]={Color=Color3.fromRGB(255,0,0),DisplayName="Code Breacher"},
Batteries={Color=Color3.fromRGB(255,255,0),DisplayName="Batteries"},
Lantern={Color=Color3.fromRGB(255,215,0),DisplayName="Lantern"},
["Flash Beacon"]={Color=Color3.fromRGB(0,255,255),DisplayName="Flash Beacon"},
Medkit={Color=Color3.fromRGB(255,0,0),DisplayName="Medkit"},
Perithesene={Color=Color3.fromRGB(0,255,0),DisplayName="Perithesene"},
Defibrillator={Color=Color3.fromRGB(255,0,255),DisplayName="Defibrillator"},
["Hand-Cranked Flashlight"]={Color=Color3.fromRGB(200,200,200),DisplayName="Hand-Cranked Flashlight"},
["Sebastian's Scanner"]={Color=Color3.fromRGB(0,0,255),DisplayName="Sebastian's Scanner"},
Blacklight={Color=Color3.fromRGB(75,0,130),DisplayName="Blacklight"},
["Toy Remote"]={Color=Color3.fromRGB(255,105,180),DisplayName="Toy Remote"},
Gummylight={Color=Color3.fromRGB(255,20,147),DisplayName="Gummylight"},
Notebook={Color=Color3.fromRGB(255,255,255),DisplayName="Notebook"},
Necrobloxicon={Color=Color3.fromRGB(139,0,0),DisplayName="Necrobloxicon"},
CollisionPart={Color=Color3.fromRGB(255,255,255),DisplayName="Door"},
--CollisionPart={Color=Color3.fromRGB(255,255,255),DisplayName="Door"},
Froger={Color=Color3.fromRGB(255,255,255),DisplayName="Froger"},
Chainsmoker={Color=Color3.fromRGB(255,255,255),DisplayName="Chainsmoker"},
Pandemonium={Color=Color3.fromRGB(255,255,255),DisplayName="Pandemonium"},
Body={Color=Color3.fromRGB(255,255,255),DisplayName="Bad Door"},
Pinkie={Color=Color3.fromRGB(255,255,255),DisplayName="Pinkie"},
Blitz={Color=Color3.fromRGB(255,255,255),DisplayName="Blitz"},
Eyefestation={Color=Color3.fromRGB(255,255,255),DisplayName="Eyefestation"},
Angler={Color=Color3.fromRGB(255,255,255),DisplayName="Angler"},
},
Settings={MaxDistance=500,CheckAllInstances=false,HighlightEnabled=true,BillboardEnabled=true}
}

local Property = {WalkSpeed=16, JumpPower=50, FOV=75, Brightness=3}
local Loops = {FullBright=false, LowLagMode=false, ClearFog=false, NoClip=false, WalkOnAir=false}
local ESPObjects = {}
local ESPVisuals = {}

for k,v in pairs(Config.Settings) do
ESPTab:Checkbox(k,v,function(b) Config.Settings[k]=b UpdateESP() end)
end
ESPTab:Checkbox("ESPEnabled",false,function(b) Config.ESPEnabled=b if b then CreateESP() else ClearESP() end end)
ESPTab:Slider("MaxDistance",50,1000,Config.Settings.MaxDistance,function(v) Config.Settings.MaxDistance=v end)
for k,v in pairs(Config.Players) do
if type(v)=="boolean" then ESPTab:Checkbox(k,v,function(b) Config.Players[k]=b UpdateESP() end) end
end
for k,v in pairs(Config.Items) do ESPTab:Checkbox(v.DisplayName,true,function(b) v.Enabled=b UpdateESP() end) end
for k,v in pairs(Config.Special) do ESPTab:Checkbox(v.DisplayName,true,function(b) v.Enabled=b UpdateESP() end) end

for k,v in pairs(Property) do PropTab:Textbox(k,false,function(txt)local n=tonumber(txt)if n then Property[k]=n end end) end
for k,_ in pairs(Loops) do LoopTab:Checkbox("Loop "..k,false,function(b)Loops[k]=b end) end

function ShouldTrack(o)
if Config.Players.Enabled and o:IsA("Player") and o~=LocalPlayer then return true,Config.Players.Color,o.Name end
for name,d in pairs(Config.Items) do if string.find(o.Name,name) and d.Enabled~=false then return true,d.Color,d.DisplayName end end
for name,d in pairs(Config.Special) do
if name=="LockerCollision" and string.find(o.Name,"LockerCollision") then return true,d.Color,d.DisplayName
elseif name=="ItemLocker" and string.find(o.Name,"ItemLocker") then return true,d.Color,nil
elseif string.find(o.Name,name) and d.Enabled~=false then return true,d.Color,d.DisplayName end
end
return false
end

function ClearESP()
for _,v in pairs(ESPVisuals) do 
if v and v.Parent then 
if v.Destroy then v:Destroy() else for _,x in pairs(v) do x:Destroy() end end 
end 
end
ESPObjects = {} 
ESPVisuals = {}
end

function CreateESP()
ClearESP()
if not Config.ESPEnabled then return end

local function CreateUIElement(o,c,t)
local part = o:IsA("Player") and o.Character and o.Character:FindFirstChild("HumanoidRootPart") or
o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or
(o:IsA("BasePart") and o)
if not part then return {} end

local elements = {}

if Config.Settings.HighlightEnabled then
local h = Instance.new("Highlight")
h.Name = "ESP_Highlight"
h.FillColor = c
h.OutlineColor = Color3.fromRGB(15,15,15)
h.FillTransparency = Config.Settings.HighlightTransparency or 0.7
h.OutlineTransparency = 0
h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
h.Parent = o
table.insert(elements,h)
end

if Config.Settings.BillboardEnabled and t then
local b = Instance.new("BillboardGui")
b.Name = "ESP_Billboard"
b.Adornee = part
b.Size = UDim2.new(0,200,0,Config.Settings.TextSize or 24)
b.StudsOffset = Vector3.new(0,3,0)
b.AlwaysOnTop = true
b.MaxDistance = Config.Settings.MaxDistance or 1500
b.Parent = o

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1,0,1,0)
frame.BackgroundTransparency = Config.Settings.BackgroundTransparency or 1
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Parent = b

local l = Instance.new("TextLabel")
l.Name = "ESP_Text"
l.Size = UDim2.new(1,-10,1,-4)
l.Position = UDim2.new(0,5,0,2)
l.BackgroundTransparency = 1
l.Text = t
l.TextColor3 = c
l.TextSize = Config.Settings.TextSize or 18
l.Font = Enum.Font.Jura
l.TextStrokeColor3 = Color3.fromRGB(10,10,10)
l.TextStrokeTransparency = 0.4
l.TextXAlignment = Enum.TextXAlignment.Left
l.Parent = frame

table.insert(elements,b)
end

return elements
end

local function Track(o)
if ESPObjects[o] then return end
local ok,c,t=ShouldTrack(o) 
if not ok then return end

local elements = CreateUIElement(o,c,t)
if #elements > 0 then
ESPVisuals[o] = elements
ESPObjects[o] = true
end
end

local function SafeTrack(o)
if not o or not o.Parent then return end
pcall(Track,o)
end

coroutine.wrap(function()
local delay = Config.Settings.ScanDelay or 0.02
for _,o in ipairs(workspace:GetDescendants()) do
if Config.Settings.CheckAllInstances or o:IsA("Model") or o:IsA("BasePart") then
SafeTrack(o)
task.wait(delay)
end
end
end)()

workspace.DescendantAdded:Connect(function(o)
task.wait(1)
			
if Config.Settings.CheckAllInstances or o:IsA("Model") or o:IsA("BasePart") then
SafeTrack(o)
end
end)

if Config.Players.Enabled then
for _,p in ipairs(Players:GetPlayers()) do SafeTrack(p) end
Players.PlayerAdded:Connect(function(p) 
p.CharacterAdded:Connect(function() 
task.wait(1)
SafeTrack(p) 
end)
SafeTrack(p) 
end)
end
end

function UpdateESP()
task.spawn(CreateESP)
end

local Platform = Instance.new("Part")
Platform.Name = "_WalkAir"
Platform.Size = Vector3.new(10,1,10)
Platform.Anchored = true
Platform.Transparency = 0.6
Platform.Material = Enum.Material.ForceField
Platform.Color = Color3.fromRGB(150,150,255)

function WalkOnAir()
local c = LocalPlayer.Character
if not c or not c:FindFirstChild("HumanoidRootPart") then Platform.Parent = nil return end
local pos = c.HumanoidRootPart.Position
local ray = Ray.new(pos, Vector3.new(0,-4,0))
local hit = Workspace:FindPartOnRay(ray, c)
if not hit then Platform.Position = pos - Vector3.new(0,5,0) Platform.Parent = Workspace
else Platform.Parent = nil end
end
--[[
function GodMode()
    local args = {
        [1] = tostring(true)
    }

    coroutine.wrap(function()
        while true do
            local target = nil
            for _, child in ipairs(workspace:GetDescendants()) do
                if child.Name == "Enter" and child:IsA("RemoteFunction") then
                    target = child
                    break
                end
            end

            if target then
                local success, err = pcall(function()
                    target:InvokeServer(unpack(args))
                end)
                
                if not success then
                    warn("GodMode Error: "..tostring(err))
                end
            end

            task.wait(0.1)
        end
    end)()
end

function GodMode()
    local v1 = {"Angler","Blitz","Pinkie","Froger","Chainsmoker","Pandemonium"}
    local v2 = game.Players.LocalPlayer
    local v3 = {}
    local v4 = nil
    local v5 = {}
    local v6 = true
    local v7 = nil
    local v8 = nil

    local function v9()
        if v4 then v4:Destroy() end
        v4 = Instance.new("Part")
        v4.Size = Vector3.new(1000,1,1000)
        v4.Position = Vector3.new(0,150,0)
        v4.Anchored = true
        v4.Parent = workspace
    end

    local function v10(v11)
        if v11 and v11.Character and v11.Character:FindFirstChild("HumanoidRootPart") then
            local v12 = v4.Position + Vector3.new(0,5,0)
            v5[v11.UserId] = v11.Character.HumanoidRootPart.CFrame
            v11.Character.HumanoidRootPart.CFrame = CFrame.new(v12)
        end
    end

    local function v13(v14)
        if v5[v14.UserId] then
            v14.Character.HumanoidRootPart.CFrame = v5[v14.UserId]
            v5[v14.UserId] = nil
        end
    end

    local function v15(v16)
        if v16:IsA("Model") and table.find(v1,v16.Name) then
            v3[v16] = true
            v9()
            for _,v17 in pairs(game.Players:GetPlayers()) do
                v10(v17)
            end
        end
    end

    local function v18(v19)
        if v3[v19] then
            v3[v19] = nil
            local v20 = false
            for v21,_ in pairs(v3) do
                if v21:IsA("Model") and table.find(v1,v21.Name) then
                    v20 = true
                    break
                end
            end
            if not v20 then
                for _,v22 in pairs(game.Players:GetPlayers()) do
                    v13(v22)
                end
            end
        end
    end

    for _,v23 in pairs(workspace:GetChildren()) do
        v15(v23)
    end

    v7 = workspace.ChildAdded:Connect(v15)
    v8 = workspace.ChildRemoved:Connect(v18)

    while v6 do
        task.wait(1)
        if not v6 then
            if v4 then
                for _,v24 in pairs(game.Players:GetPlayers()) do
                    v13(v24)
                end
            end
            v6 = false
            v7:Disconnect()
            v8:Disconnect()
        end
    end
end
--]]
function FullBright() Lighting.Brightness = Property.Brightness end
function LowLagMode() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end
function ClearFog() Lighting.FogStart = 999999 Lighting.FogEnd = 9999999 end
function NoClip()
local c = LocalPlayer.Character
if c then for _,p in ipairs(c:GetDescendants()) do
if p:IsA("BasePart") then p.CanCollide = false end
end end
end

RunService.RenderStepped:Connect(function()
local c = LocalPlayer.Character
if c then
local h = c:FindFirstChildOfClass("Humanoid")
if h then
h.WalkSpeed = Property.WalkSpeed
h.JumpPower = Property.JumpPower
end
end
Camera.FieldOfView = Property.FOV
for k,v in pairs(Loops) do
if v then
--if k == "GodMode" then GodMode()
if k == "FullBright" then FullBright()
elseif k == "LowLagMode" then LowLagMode()
elseif k == "ClearFog" then ClearFog()
elseif k == "NoClip" then NoClip()
elseif k == "WalkOnAir" then WalkOnAir()
end
end
end
end)
local v2 = false
local v5 = 2
PropTab:Checkbox("Movement", false, function(v1)
    v2 = v1
end)

PropTab:Textbox("Speed", false, function(v3)
    local v4 = tonumber(v3)
    if v4 then v5 = v4 end
end)

function v6()
    local v7 = Players.LocalPlayer.Character
    local v8 = v7 and v7:FindFirstChildOfClass("Humanoid")
    
    if not v7 or not v8 or not v2 then return end

    local v9 = v8.MoveDirection
    if v9.Magnitude > 0 then
        v7:TranslateBy(v9.Unit * v5)
    end
end

RunService.RenderStepped:Connect(v6)
local v1 = false

PropTab:Checkbox("Hook SyncedPivot", false, function(v2)
v1 = v2
end)

local v3
v3 = hookmetamethod(game, "__namecall", function(v4, ...)
local v5 = getnamecallmethod()
if v5 == "InvokeServer" and v4:IsA("RemoteFunction") and v4.Name == "SyncedPivot" then
if v1 then return nil end
end
return v3(v4, ...)
end)
local IgnoreEnabled = false
local IgnoreTargets = {"MonsterLocker"}

PropTab:Checkbox("Ignore MonsterLocker", false, function(state)
    IgnoreEnabled = state
end)

local function IgnoreZone()
    if not IgnoreEnabled then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        for _, target in ipairs(IgnoreTargets) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and string.find(obj.Name, target) then
                obj:Destroy()
            end
        end
    end
end

RunService.RenderStepped:Connect(IgnoreZone)
local InteractionTab = Win:Tab("Interaction")
local InteractionEnabled = false

local TargetList = {
    ProxyPart = {
        Enabled = false,
        CustomHold = false,
        CustomDistance = false,
        HoldTime = 0.2,
        Distance = 10
    },
    Main = {
        Enabled = false,
        CustomHold = false,
        CustomDistance = false,
        HoldTime = 0.2,
        Distance = 10
    }
}

InteractionTab:Checkbox("Enable Interaction", false, function(b)
InteractionEnabled = b
end)

for name, config in pairs(TargetList) do
    InteractionTab:Checkbox("Enable " .. name, false, function(b)
        config.Enabled = b
    end)

    InteractionTab:Checkbox(name .. " Custom Hold", false, function(b)
        config.CustomHold = b
    end)

    InteractionTab:Checkbox(name .. " Custom Distance", false, function(b)
        config.CustomDistance = b
    end)

    InteractionTab:Textbox(name .. " HoldDuration", false, function(txt)
        local v = tonumber(txt)
        if v then config.HoldTime = v end
    end)

    InteractionTab:Textbox(name .. " MaxDistance", false, function(txt)
        local v = tonumber(txt)
        if v then config.Distance = v end
    end)
end
local function Interaction()
if not InteractionEnabled then return end

local c = Players.LocalPlayer.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if not root then return end

for _, obj in ipairs(workspace:GetDescendants()) do
    if not obj:IsA("BasePart") then continue end

    local config = TargetList[obj.Name]
    if not config or not config.Enabled then continue end

    local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        if config.CustomHold then prompt.HoldDuration = config.HoldTime end
        if config.CustomDistance then prompt.MaxActivationDistance = config.Distance end

        if (obj.Position - root.Position).Magnitude <= prompt.MaxActivationDistance then
            fireproximityprompt(prompt)
        end
    end
end
end

RunService.RenderStepped:Connect(Interaction)
local AutoPasswordEnabled = false

InteractionTab:Checkbox("Auto Password", false, function(state)
AutoPasswordEnabled = state
end)

function AutoPassword()
if not AutoPasswordEnabled then return end

local plr = Players.LocalPlayer
local sources = {workspace}
if plr then
if plr.Character then table.insert(sources, plr.Character) end
if plr:FindFirstChild("Backpack") then table.insert(sources, plr.Backpack) end
end

local foundPasswords = {}

for _, container in ipairs(sources) do
for _, v in ipairs(container:GetDescendants()) do
if v:IsA("Model") and v.Name == "PasswordPaper" then
local code = v:FindFirstChild("Code")
if not code then continue end
local gui = code:FindFirstChildOfClass("SurfaceGui")
if not gui then continue end
local label = gui:FindFirstChildWhichIsA("TextLabel", true)
if not label then continue end
local text = label.Text
if text and text ~= "" then
table.insert(foundPasswords, text)
end
end
end
end

if #foundPasswords == 0 then return end

for _, remote in ipairs(workspace:GetDescendants()) do
if remote:IsA("RemoteFunction") and remote.Parent and remote.Parent.Name == "Main" then
for _, password in ipairs(foundPasswords) do
local args = {password}
pcall(function()
remote:InvokeServer(unpack(args))
end)
end
end
end
end

RunService.RenderStepped:Connect(AutoPassword)
local Notification = {
	Enabled = false,
	EntityNames = {
		"Angler", "Eyefestation", "Blitz", "Pinkie",
		"Froger", "Chainsmoker", "Pandemonium", "Body"
	},
	Cache = {}
}

PropTab:Checkbox("Notification", false, function(v)
	Notification.Enabled = v
end)

function SendNotification(title, text, duration)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = duration
	})
	local sound = Instance.new("Sound", workspace)
	sound.SoundId = "rbxassetid://4590657391"
	sound.Volume = 2
	sound:Play()
end

function ScanEntities()
	if not Notification.Enabled then return end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if table.find(Notification.EntityNames, obj.Name) and not Notification.Cache[obj] then
			Notification.Cache[obj] = true
			SendNotification("Entity Notification", obj.Name .. " has spawned.", 3)
		end
	end
end

game:GetService("RunService").RenderStepped:Connect(ScanEntities)

local v1 = {"Angler","Blitz","Pinkie","Froger","Chainsmoker","Pandemonium"}
local v2 = false
local v3 = {}
local v4 = nil
local v5 = {}
local v6 = nil
local v7 = nil

local function v8()
    --if v4 then v4:Destroy() end
    v4 = Instance.new("Part")
    v4.Size = Vector3.new(1000,1,1000)
    v4.Position = Vector3.new(0,150,0)
    v4.Anchored = true
    v4.Transparency = 0.7
    v4.Parent = workspace
end

local function v9(v10)
    if v10 and v10.Character and v10.Character:FindFirstChild("HumanoidRootPart") then
        local v11 = v4.Position + Vector3.new(0,5,0)
        v5[v10.UserId] = v10.Character.HumanoidRootPart.CFrame
        v10.Character.HumanoidRootPart.CFrame = CFrame.new(v11)
    end
end

local function v12(v13)
    if v5[v13.UserId] then
        v13.Character.HumanoidRootPart.CFrame = v5[v13.UserId]
        v5[v13.UserId] = nil
    end
end

local function v14(v15)
    if v15:IsA("Model") and table.find(v1,v15.Name) then
        v3[v15] = true
        v8()
        for _,v16 in pairs(game.Players:GetPlayers()) do
            v9(v16)
        end
    end
end

local function v17(v18)
    if v3[v18] then
        v3[v18] = nil
        local v19 = false
        for v20,_ in pairs(v3) do
            if v20:IsA("Model") and table.find(v1,v20.Name) then
                v19 = true
                break
            end
        end
        if not v19 then
            for _,v21 in pairs(game.Players:GetPlayers()) do
                v12(v21)
            end
        end
    end
end

PropTab:Checkbox("Anti Entity", false, function(v22)
    v2 = v22
    if v2 then
        for _,v23 in pairs(workspace:GetChildren()) do
            v14(v23)
        end
        v6 = workspace.ChildAdded:Connect(v14)
        v7 = workspace.ChildRemoved:Connect(v17)
    else
        if v4 then
            for _,v24 in pairs(game.Players:GetPlayers()) do
                v12(v24)
            end
            v4:Destroy()
            v4 = nil
        end
        if v6 then v6:Disconnect() end
        if v7 then v7:Disconnect() end
        v3 = {}
        v5 = {}
    end
end)
