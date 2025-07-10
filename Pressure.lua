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
PasswordPaper={Color=Color3.fromRGB(255,255,255),DisplayName="PasswordPaper"},
},
Settings={MaxDistance=500,CheckAllInstances=false,HighlightEnabled=true,BillboardEnabled=true}
}

local Property = {WalkSpeed=16, JumpPower=50, FOV=75, Brightness=3}
local Loops = {GodMode=false, FullBright=false, LowLagMode=false, ClearFog=false, NoClip=false, WalkOnAir=false}
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
for _,v in pairs(ESPVisuals) do if v and v.Parent then v:Destroy() end end
ESPObjects = {} ESPVisuals = {}
end

function CreateESP()
ClearESP()
if not Config.ESPEnabled then return end
local function Track(o)
if ESPObjects[o] then return end
local ok,c,t=ShouldTrack(o) if not ok then return end
local part = o:IsA("Player") and o.Character and o.Character:FindFirstChild("HumanoidRootPart") or
o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or
(o:IsA("BasePart") and o)
if not part then return end
if Config.Settings.HighlightEnabled then
local h = Instance.new("Highlight")
h.Name = "ESP_Highlight" h.FillColor = c h.OutlineColor = Color3.new(0,0,0)
h.FillTransparency = 0.5 h.OutlineTransparency = 0 h..Parent = o
table.insert(ESPVisuals,h)
end
if Config.Settings.BillboardEnabled and t then
local b = Instance.new("BillboardGui")
b.Name = "ESP_Billboard" b.Adornee = part b.Size = UDim2.new(0,200,0,50)
b.StudsOffset = Vector3.new(0,3,0) b.AlwaysOnTop = true b.Parent = o
local l = Instance.new("TextLabel")
l.Name = "ESP_Text" l.Size = UDim2.new(1,0,1,0) l.BackgroundTransparency = 1
l.Text = t l.TextColor3 = c l.TextSize = 20 l.Font = Enum.Font.GothamBold
l.Parent = b
table.insert(ESPVisuals,b)
end
ESPObjects[o] = true
end

for _, o in ipairs(workspace:GetDescendants()) do
if Config.Settings.CheckAllInstances or o:IsA("Model") or o:IsA("BasePart") then Track(o) end
end

workspace.DescendantAdded:Connect(function(o)
if Config.Settings.CheckAllInstances or o:IsA("Model") or o:IsA("BasePart") then Track(o) end
end)

if Config.Players.Enabled then
for _, p in ipairs(Players:GetPlayers()) do Track(p) end
Players.PlayerAdded:Connect(function(p) Track(p) end)
end
end

function UpdateESP()
ClearESP()
if Config.ESPEnabled then CreateESP() end
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

function GodMode()
local args_true = {"true"}
local args_false = {"false"}
local index = 1

for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("RemoteFunction") and v.Name == "Enter" then
v.Name = "Enter_" .. index
index += 1
pcall(function()
v:InvokeServer(unpack(args_true))
end)
end
end

workspace.DescendantAdded:Connect(function(obj)
if obj:IsA("RemoteFunction") and obj.Name == "Enter" then
obj.Name = "Enter_" .. index
index += 1

for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("RemoteFunction") and v.Name:match("^Enter_%d+$") and v ~= obj then
pcall(function()
v:InvokeServer(unpack(args_false))
end)
end
end

pcall(function()
obj:InvokeServer(unpack(args_true))
end)
end
end)
end


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
if k == "GodMode" then GodMode()
elseif k == "FullBright" then FullBright()
elseif k == "LowLagMode" then LowLagMode()
elseif k == "ClearFog" then ClearFog()
elseif k == "NoClip" then NoClip()
elseif k == "WalkOnAir" then WalkOnAir()
end
end
end
end)
local VelocityEnabled = false
local VelocitySpeed = 1.5

PropTab:Checkbox("CFrame Movement", false, function(state)
    VelocityEnabled = state
end)
PropTab:Textbox("CFrame Speed", false, function(txt)
    local n = tonumber(txt)
    if n then VelocitySpeed = n end
end)
function Velocity()
    local c = Players.LocalPlayer.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not root or not hum or not VelocityEnabled then return end

    local dir = hum.MoveDirection
    if dir.Magnitude > 0 then
        local offset = CFrame.new(dir.Unit * VelocitySpeed)
        root.CFrame = root.CFrame + offset.Position
    end
end
RunService.RenderStepped:Connect(Velocity)
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

PropTab:Checkbox("Ignore Monster", false, function(state)
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
