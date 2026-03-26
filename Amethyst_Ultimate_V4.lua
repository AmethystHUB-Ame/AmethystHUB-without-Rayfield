--[[
+====================================================================+
|       [*]  A M E T H Y S T   U L T I M A T E   V 4 . 0  [*]      |
|       Professional-Grade Universal Mod Menu                        |
|       100% Custom UI — Zero External Dependencies                  |
+====================================================================+
]]

-- DOUBLE EXECUTION GUARD + PREVIOUS INSTANCE CLEANUP
if _G.__AmethystCleanup then
    pcall(_G.__AmethystCleanup)
end
if _G.__AmethystUltimateV4 then
    warn("[Amethyst V4] Already running.")
    return
end
_G.__AmethystUltimateV4 = true

-- ROBUST ERROR HANDLER
local function _safeCall(fn, ...)
    return xpcall(fn, function(err)
        warn("[Amethyst Error]: " .. tostring(err) .. "\n" .. debug.traceback())
    end, ...)
end

-- SERVICES
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

--------------------------------------------------------------------------------
-- PART 2 — CENTRAL CONFIG
--------------------------------------------------------------------------------
_G.Config = {
    Version            = "4.0.0",
    ESPThrottle        = 1/60,
    SkeletonThrottle   = 1/30,
    AimRefreshInterval = 0.15,
    KillAuraCooldown   = 0.2,
    WeaponScanInterval = 0.2,
    AimPredictVelMin   = 5,
    AimHumanization    = 0.5,
    AutoHopInterval    = 15,
    AntiAFKInterval    = 55,
    CacheBuildDelay    = 0.5,
}

--------------------------------------------------------------------------------
-- PART 3 — CONNECTION TRACKING + DRAWING CLEANUP
--------------------------------------------------------------------------------
local _connections = {}
local _drawingCleanup = {}

local function track(conn)
    _connections[#_connections + 1] = conn
    return conn
end

local function trackDrawing(obj)
    _drawingCleanup[#_drawingCleanup + 1] = obj
    return obj
end

local function cleanupAll()
    for _, c in ipairs(_connections) do
        _safeCall(function() c:Disconnect() end)
    end
    _connections = {}
    for _, d in ipairs(_drawingCleanup) do
        _safeCall(function() d:Remove() end)
    end
    _drawingCleanup = {}
    -- Destroy custom GUI
    _safeCall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name == "AmethystHubV4" or gui.Name == "AmethystWatermarkV4"
               or gui.Name == "AmethystToggleV4" or gui.Name == "AmethystFlyButtons" then
                gui:Destroy()
            end
        end
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetChildren()) do
                if gui.Name == "AmethystHubV4" or gui.Name == "AmethystWatermarkV4"
                   or gui.Name == "AmethystToggleV4" or gui.Name == "AmethystFlyButtons" then
                    gui:Destroy()
                end
            end
        end
    end)
    _G.__AmethystUltimateV4 = nil
end

--------------------------------------------------------------------------------
-- PART 4 — THEME CONSTANTS (Deep Amethyst Purple — EXACT RGB values)
--------------------------------------------------------------------------------
local THEME = {
    -- Core palette
    Background     = Color3.fromRGB(35, 10, 50),
    Main           = Color3.fromRGB(50, 20, 70),
    Accent         = Color3.fromRGB(180, 100, 255),
    AccentSoft     = Color3.fromRGB(140, 80, 210),
    AccentDim      = Color3.fromRGB(100, 50, 160),
    AccentBright   = Color3.fromRGB(220, 160, 255),
    AccentGlow     = Color3.fromRGB(200, 140, 255),
    DeepPurple     = Color3.fromRGB(80, 30, 120),
    RoyalPurple    = Color3.fromRGB(120, 50, 180),
    NeonPurple     = Color3.fromRGB(220, 160, 255),
    DarkAmethyst   = Color3.fromRGB(25, 5, 40),
    CrystalWhite   = Color3.fromRGB(240, 230, 255),
    Shadow         = Color3.fromRGB(25, 5, 35),
    TextPrimary    = Color3.fromRGB(240, 235, 255),
    TextSecondary  = Color3.fromRGB(180, 160, 210),
    Lavender       = Color3.fromRGB(200, 180, 240),
    ESPColor       = Color3.fromRGB(180, 100, 255),
    ESPTracer      = Color3.fromRGB(153, 85, 217),
    HealthGreen    = Color3.fromRGB(100, 255, 100),
    HealthRed      = Color3.fromRGB(255, 60, 60),
    AlertRed       = Color3.fromRGB(255, 40, 40),
    White          = Color3.fromRGB(255, 255, 255),

    -- UI component colors (unified)
    WindowBackground           = Color3.fromRGB(35, 10, 50),
    Topbar                     = Color3.fromRGB(50, 20, 70),
    TopbarStroke               = Color3.fromRGB(80, 40, 120),
    SidebarBackground          = Color3.fromRGB(30, 8, 45),
    SidebarSelected            = Color3.fromRGB(65, 30, 95),
    SidebarHover               = Color3.fromRGB(55, 25, 75),
    ContentBackground          = Color3.fromRGB(35, 10, 50),
    ElementBackground          = Color3.fromRGB(55, 25, 75),
    ElementBackgroundHover     = Color3.fromRGB(65, 35, 90),
    ElementStroke              = Color3.fromRGB(80, 40, 120),
    SliderBackground           = Color3.fromRGB(35, 10, 50),
    SliderProgress             = Color3.fromRGB(180, 100, 255),
    SliderStroke               = Color3.fromRGB(120, 60, 180),
    ToggleBackground           = Color3.fromRGB(55, 25, 75),
    ToggleEnabled              = Color3.fromRGB(180, 100, 255),
    ToggleDisabled             = Color3.fromRGB(80, 40, 100),
    ToggleEnabledStroke        = Color3.fromRGB(200, 130, 255),
    ToggleDisabledStroke       = Color3.fromRGB(70, 35, 90),
    DropdownSelected           = Color3.fromRGB(65, 30, 95),
    DropdownUnselected         = Color3.fromRGB(45, 15, 65),
    InputBackground            = Color3.fromRGB(45, 15, 65),
    InputStroke                = Color3.fromRGB(80, 40, 120),
    PlaceholderColor           = Color3.fromRGB(140, 100, 170),
    NotificationBackground     = Color3.fromRGB(45, 15, 65),
    NotificationActionsBackground = Color3.fromRGB(55, 25, 75),
    TabStroke                  = Color3.fromRGB(80, 40, 120),
    TabBackground              = Color3.fromRGB(45, 15, 65),
    TabBackgroundSelected      = Color3.fromRGB(65, 30, 95),
    TabStrokeSelected          = Color3.fromRGB(180, 100, 255),
    StatusBarBackground        = Color3.fromRGB(25, 5, 40),
    LoadingBackground          = Color3.fromRGB(20, 5, 30),
    LoadingBarBackground       = Color3.fromRGB(40, 15, 60),
    LoadingBarFill             = Color3.fromRGB(180, 100, 255),
}

--------------------------------------------------------------------------------
-- PART 5 — TWEEN PRESETS
--------------------------------------------------------------------------------
local TI_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_FAST   = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_PULSE  = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local TI_BOUNCE = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tweenProp(obj, props, tweenInfo)
    _safeCall(function()
        TweenService:Create(obj, tweenInfo or TI_SMOOTH, props):Play()
    end)
end

--------------------------------------------------------------------------------
-- PART 6 — DRAWING LIBRARY POLYFILL
--------------------------------------------------------------------------------
do
    local _drawOk = false
    _safeCall(function()
        local _t = Drawing.new("Line")
        if _t then _t:Remove(); _drawOk = true end
    end)
    if not _drawOk then
        local _noop = function() end
        local _DummyMT = {
            __newindex = function(self, k, v) rawset(self, k, v) end,
            __index = function(_, k)
                if k == "Remove" or k == "Destroy" then return _noop end
                return nil
            end,
        }
        local function _makeDummy()
            return setmetatable({
                Visible = false, Color = Color3.new(1,1,1), Thickness = 1,
                Filled = false, Transparency = 1, NumSides = 64,
                Position = Vector2.new(0,0), Size = Vector2.new(0,0),
                From = Vector2.new(0,0), To = Vector2.new(0,0),
                Radius = 0, Text = "", Outline = false, Center = false,
                TextSize = 14, Font = 0,
            }, _DummyMT)
        end
        _safeCall(function() Drawing = { new = function() return _makeDummy() end } end)
        if not Drawing then
            rawset(_G, "Drawing", { new = function() return _makeDummy() end })
        end
        warn("[Amethyst V4] Drawing library not available - visual overlays will be no-ops")
    end
end

--------------------------------------------------------------------------------
-- PART 7 — MOBILE DETECTION
--------------------------------------------------------------------------------
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--------------------------------------------------------------------------------
-- PART 8 — STATE TABLE
--------------------------------------------------------------------------------
local S = {
    Combat = {
        Aimbot        = false,
        AimbotSmooth  = 3,
        AimPart       = "Head",
        AimPredict    = false,
        AimPredictStr = 0.12,
        FOV_Show      = false,
        FOV_Lock      = false,
        FOV_Radius    = 120,
        SilentAim     = false,
        TriggerBot    = false,
        KillAura      = false,
        KillAuraRange = 25,
        Hitbox        = false,
        HitboxScale   = 2,
        NoRecoil      = false,
        NoSpread      = false,
        FastReload    = false,
        InfAmmo       = false,
    },
    Visuals = {
        Wallhack      = false,
        ESP_Box       = false,
        ESP_Name      = false,
        ESP_Health    = false,
        ESP_Skeleton  = false,
        ESP_Tracer    = false,
        ESP_Distance  = false,
        VisCheck      = false,
        ESPColor      = Color3.fromRGB(180, 100, 255),
        Crosshair     = false,
        XH_Size       = 8,
        XH_Gap        = 4,
        Fullbright    = false,
        EnemyAlert    = false,
        EnemyAlertDist = 40,
        Radar         = false,
        RadarRange    = 120,
        RadarSize     = 130,
        PlayerBotHUD  = false,
        KillCounter   = false,
    },
    Movement = {
        Speed      = false,
        SpeedVal   = 16,
        Jump       = false,
        JumpVal    = 50,
        AutoStrafe = false,
        InfJump    = false,
        NoFallDmg  = false,
        FastRespawn = false,
        JumpScale  = 1,
        Fly        = false,
        FlySpeed   = 50,
        Noclip     = false,
    },
    Utility = {
        GodMode       = false,
        FPSBoost      = false,
        LightingUltra = false,
        TexturePurge  = false,
        ParticlePurge = false,
        TerrainSimple = false,
        AntiAFK       = false,
        AutoHop       = false,
        AutoHopMax    = 6,
        ServerList    = {},
        TargetPlaceId = game.PlaceId,
        SilentMode    = false,
    },
}

-- Proxy metatable for flat access (S.Aimbot -> S.Combat.Aimbot)
do
    local _subs = {S.Combat, S.Visuals, S.Movement, S.Utility}
    setmetatable(S, {
        __index = function(_, k)
            for _, sub in ipairs(_subs) do
                if rawget(sub, k) ~= nil then return sub[k] end
            end
        end,
        __newindex = function(_, k, v)
            for _, sub in ipairs(_subs) do
                if rawget(sub, k) ~= nil then sub[k] = v; return end
            end
            rawset(S, k, v)
        end,
    })
end

--------------------------------------------------------------------------------
-- PART 12 — HELPERS: notify, notifyToggle, debounced, safeHttpGet
--------------------------------------------------------------------------------

-- GUI parent resolution
local function getGuiParent()
    local ok, result = pcall(function() return CoreGui end)
    if ok and result then return result end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

-- Notification system container
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "AmethystNotifV4"
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.ResetOnSpawn = false
_safeCall(function() notifGui.Parent = getGuiParent() end)

local notifContainer = Instance.new("Frame")
notifContainer.Name = "NotifContainer"
notifContainer.Size = UDim2.new(0, 270, 1, -20)
notifContainer.Position = UDim2.new(1, -280, 0, 10)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = notifGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Padding = UDim.new(0, 6)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
notifLayout.Parent = notifContainer

local activeNotifs = {}

local function notify(title, content, dur)
    if S.SilentMode then return end
    dur = dur or 4

    -- Max 4 visible: dismiss oldest
    while #activeNotifs >= 4 do
        local oldest = table.remove(activeNotifs, 1)
        _safeCall(function()
            tweenProp(oldest, {Position = oldest.Position + UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}, TI_FAST)
            task.delay(0.25, function() _safeCall(function() oldest:Destroy() end) end)
        end)
    end

    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(1, 0, 0, 0)
    nf.AutomaticSize = Enum.AutomaticSize.Y
    nf.BackgroundColor3 = THEME.NotificationBackground
    nf.BorderSizePixel = 0
    nf.ClipsDescendants = true
    nf.Parent = notifContainer

    local nc = Instance.new("UICorner", nf)
    nc.CornerRadius = UDim.new(0, 8)

    local ns = Instance.new("UIStroke", nf)
    ns.Color = Color3.fromRGB(80, 40, 120)
    ns.Thickness = 1

    -- Left accent bar
    local accentBar = Instance.new("Frame", nf)
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = THEME.Accent
    accentBar.BorderSizePixel = 0
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

    local pad = Instance.new("UIPadding", nf)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 8)

    local innerLayout = Instance.new("UIListLayout", nf)
    innerLayout.Padding = UDim.new(0, 3)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Icon + Title
    local titleLabel = Instance.new("TextLabel", nf)
    titleLabel.Size = UDim2.new(1, 0, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = THEME.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "\xF0\x9F\x92\x8E " .. tostring(title)
    titleLabel.LayoutOrder = 1

    local contentLabel = Instance.new("TextLabel", nf)
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.BackgroundTransparency = 1
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 12
    contentLabel.TextColor3 = THEME.TextSecondary
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Text = tostring(content)
    contentLabel.LayoutOrder = 2

    -- Slide in from right
    nf.Position = UDim2.new(0, 280, 0, 0)
    activeNotifs[#activeNotifs + 1] = nf
    tweenProp(nf, {Position = UDim2.new(0, 0, 0, 0)}, TI_SMOOTH)

    -- Auto-dismiss
    task.delay(dur, function()
        _safeCall(function()
            tweenProp(nf, {Position = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}, TI_FAST)
            task.delay(0.3, function()
                _safeCall(function()
                    for i, v in ipairs(activeNotifs) do
                        if v == nf then table.remove(activeNotifs, i); break end
                    end
                    nf:Destroy()
                end)
            end)
        end)
    end)
end

local function notifyToggle(name, state)
    notify(name, state and "Enabled" or "Disabled", 2.5)
end

local function debounced(fn, cooldown)
    local last = 0
    return function(...)
        local now = os.clock()
        if now - last < cooldown then return end
        last = now
        return fn(...)
    end
end

-- Safe HTTP GET
local function safeHttpGet(url)
    local result = nil
    _safeCall(function()
        if game.HttpGet then
            result = game:HttpGet(url)
        end
    end)
    if result then return result end
    _safeCall(function()
        if request then
            local r = request({Url = url, Method = "GET"})
            if r and r.Body then result = r.Body end
        end
    end)
    if result then return result end
    _safeCall(function()
        if http_request then
            local r = http_request({Url = url, Method = "GET"})
            if r and r.Body then result = r.Body end
        end
    end)
    return result
end

--------------------------------------------------------------------------------
-- PART 12A — BONE DEFINITIONS
--------------------------------------------------------------------------------
local BONES_R6 = {
    {"Head","Torso"},
    {"Torso","Left Arm"},  {"Torso","Right Arm"},
    {"Torso","Left Leg"},  {"Torso","Right Leg"},
}
local BONES_R15 = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},  {"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"},
    {"LowerTorso","LeftUpperLeg"},  {"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"},
}
local MAX_BONES = #BONES_R15

--------------------------------------------------------------------------------
-- PART 12B — PART CACHE
--------------------------------------------------------------------------------
local PartCache = {}

local function buildPartCache(player)
    local char = player.Character
    if not char then PartCache[player] = nil return end
    local hum   = char:FindFirstChildOfClass("Humanoid")
    local head  = char:FindFirstChild("Head")
    local root  = char:FindFirstChild("HumanoidRootPart")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not hum or not head or not root then PartCache[player] = nil return end

    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    local defs  = isR15 and BONES_R15 or BONES_R6
    local bp    = {}
    for _, pair in ipairs(defs) do
        bp[#bp + 1] = { char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2]) }
    end

    PartCache[player] = {
        hum = hum, head = head, root = root,
        torso = torso or root,
        boneParts = bp, numBones = #bp,
    }
end

--------------------------------------------------------------------------------
-- PART 12C — HITBOX SYSTEM
--------------------------------------------------------------------------------
local headOrigSizes = {}

local function applyHitbox(player)
    local pc = PartCache[player]
    if not pc or not pc.head then return end
    if S.Hitbox then
        if not headOrigSizes[player] then
            headOrigSizes[player] = pc.head.Size
        end
        local orig = headOrigSizes[player]
        if orig then
            _safeCall(function()
                pc.head.Size = orig * S.HitboxScale
                pc.head.Transparency = 0.85
                pc.head.CanCollide = false
            end)
        end
    else
        if headOrigSizes[player] then
            _safeCall(function()
                pc.head.Size = headOrigSizes[player]
                pc.head.Transparency = 0
                pc.head.CanCollide = true
            end)
            headOrigSizes[player] = nil
        end
    end
end

--------------------------------------------------------------------------------
-- PART 12D — SMART PART FILTER (DANGER_WORDS)
--------------------------------------------------------------------------------
local DANGER_WORDS = {
    "damagebrick","lava","kill","killbrick","killpart",
    "damage","deathbrick","acid","poison","fire","hazard"
}

local function isDangerPart(part)
    if not part or not part:IsA("BasePart") then return false end
    local ln = string.lower(part.Name)
    for _, w in ipairs(DANGER_WORDS) do
        if string.find(ln, w) then return true end
    end
    local c = part.Color
    if c.R > 0.7 and c.G < 0.3 and c.B < 0.3 then return true end
    if c.R > 0.8 and c.G > 0.3 and c.G < 0.6 and c.B < 0.2 then return true end
    return false
end

--------------------------------------------------------------------------------
-- PART 12E — OMEGA FPS, LIGHTING, TEXTURE/PARTICLE/TERRAIN
--------------------------------------------------------------------------------
local function simplifyPart(part)
    _safeCall(function()
        if part:IsA("BasePart") and not isDangerPart(part) then
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
            part.CastShadow = false
        end
    end)
end

local fpsListenerConn = nil

local function runOmegaFPS()
    for _, obj in ipairs(workspace:GetDescendants()) do
        simplifyPart(obj)
    end
end

local function enableFPSListener()
    if fpsListenerConn then return end
    fpsListenerConn = track(workspace.DescendantAdded:Connect(function(obj)
        task.defer(function() simplifyPart(obj) end)
    end))
end

local function disableFPSListener()
    if fpsListenerConn then
        _safeCall(function() fpsListenerConn:Disconnect() end)
        fpsListenerConn = nil
    end
end

-- Saved lighting
local savedLighting = {}
_safeCall(function()
    savedLighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
    }
end)

local function applyLightingUltra()
    _safeCall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(160, 160, 160)
        Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
        Lighting.ClockTime = 12

        for _, eff in ipairs(Lighting:GetChildren()) do
            if eff:IsA("BloomEffect") or eff:IsA("BlurEffect") or eff:IsA("ColorCorrectionEffect")
               or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") then
                eff.Enabled = false
            end
            if eff:IsA("Atmosphere") then
                eff.Density = 0
                eff.Glare = 0
                eff.Haze = 0
            end
        end
    end)
end

local function restoreLighting()
    _safeCall(function()
        for k, v in pairs(savedLighting) do
            Lighting[k] = v
        end
        for _, eff in ipairs(Lighting:GetChildren()) do
            if eff:IsA("BloomEffect") or eff:IsA("BlurEffect") or eff:IsA("ColorCorrectionEffect")
               or eff:IsA("SunRaysEffect") or eff:IsA("DepthOfFieldEffect") then
                eff.Enabled = true
            end
        end
    end)
end

local texListenerConn = nil

local function purgeTextures()
    _safeCall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
            if obj:IsA("Sky") then
                obj:Destroy()
            end
        end
    end)
end

local function enableTexListener()
    if texListenerConn then return end
    texListenerConn = track(workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            _safeCall(function()
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end)
        end)
    end))
end

local function disableTexListener()
    if texListenerConn then
        _safeCall(function() texListenerConn:Disconnect() end)
        texListenerConn = nil
    end
end

local function purgeParticles()
    _safeCall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
               or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
    end)
end

local function simplifyTerrain()
    _safeCall(function()
        local t = workspace.Terrain
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        t.Decoration = false
    end)
end

local function applyFullbright(on)
    _safeCall(function()
        if on then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            restoreLighting()
        end
    end)
end

--------------------------------------------------------------------------------
-- PART 12F — ESP POOL
--------------------------------------------------------------------------------
local ESPPool = {}

local function makeHighlight(char)
    local hl = Instance.new("Highlight")
    hl.Name = "AmethystHL"
    hl.FillColor = THEME.ESPColor
    hl.OutlineColor = THEME.White
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = S.Wallhack
    hl.Parent = char
    return hl
end

local function createESP(player)
    if ESPPool[player] or player == LocalPlayer then return end
    local c = THEME.ESPColor

    local box = trackDrawing(Drawing.new("Square"))
    box.Visible = false; box.Color = c; box.Thickness = 1.4; box.Filled = false

    local tracer = trackDrawing(Drawing.new("Line"))
    tracer.Visible = false; tracer.Color = THEME.ESPTracer; tracer.Thickness = 1

    local distLabel = trackDrawing(Drawing.new("Text"))
    distLabel.Visible = false; distLabel.Color = Color3.fromRGB(255, 230, 80)
    distLabel.Size = 13; distLabel.Outline = true; distLabel.Center = true

    local nameLabel = trackDrawing(Drawing.new("Text"))
    nameLabel.Visible = false; nameLabel.Size = 13; nameLabel.Outline = true; nameLabel.Center = true
    nameLabel.Color = THEME.AccentBright
    nameLabel.Text = player.DisplayName or player.Name

    local healthBg = trackDrawing(Drawing.new("Square"))
    healthBg.Visible = false; healthBg.Color = Color3.fromRGB(15, 5, 20); healthBg.Filled = true

    local healthBar = trackDrawing(Drawing.new("Square"))
    healthBar.Visible = false; healthBar.Color = THEME.HealthGreen; healthBar.Filled = true

    local bones = {}
    for i = 1, MAX_BONES do
        local b = trackDrawing(Drawing.new("Line"))
        b.Visible = false; b.Color = c; b.Thickness = 1.2
        bones[i] = b
    end

    local radarDot = trackDrawing(Drawing.new("Circle"))
    radarDot.Radius = 4; radarDot.Filled = true; radarDot.Color = c; radarDot.Visible = false

    local highlight = nil
    if player.Character then highlight = makeHighlight(player.Character) end

    ESPPool[player] = {
        box = box, tracer = tracer, distLabel = distLabel,
        nameLabel = nameLabel, healthBg = healthBg, healthBar = healthBar,
        bones = bones, highlight = highlight, radarDot = radarDot,
    }
end

local function removeESP(player)
    local pool = ESPPool[player]
    if not pool then return end
    _safeCall(function()
        pool.box.Visible = false; pool.box:Remove()
        pool.tracer.Visible = false; pool.tracer:Remove()
        pool.distLabel.Visible = false; pool.distLabel:Remove()
        pool.nameLabel.Visible = false; pool.nameLabel:Remove()
        pool.healthBg.Visible = false; pool.healthBg:Remove()
        pool.healthBar.Visible = false; pool.healthBar:Remove()
        for _, b in ipairs(pool.bones) do
            b.Visible = false; b:Remove()
        end
        pool.radarDot.Visible = false; pool.radarDot:Remove()
        if pool.highlight then pool.highlight:Destroy() end
    end)
    ESPPool[player] = nil
end

--------------------------------------------------------------------------------
-- PART 12G — HEALTH COLOR FORMULA
--------------------------------------------------------------------------------
local function healthColor(pct)
    if pct > 0.5 then
        return Color3.fromRGB(math.floor(255*(1-pct)*2), 255, 0)
    end
    return Color3.fromRGB(255, math.floor(255*pct*2), 0)
end

--------------------------------------------------------------------------------
-- PART 12H — CROSSHAIR
--------------------------------------------------------------------------------
local xhLines = {}
for i = 1, 4 do
    local l = trackDrawing(Drawing.new("Line"))
    l.Color = THEME.White; l.Thickness = 1.5; l.Visible = false
    xhLines[i] = l
end

local function updateCrosshair()
    local vp = Camera.ViewportSize
    local cx = vp.X * 0.5
    local cy = vp.Y * 0.5
    local g = S.XH_Gap
    local sz = S.XH_Size
    local show = S.Crosshair

    xhLines[1].From = Vector2.new(cx, cy - g - sz)
    xhLines[1].To   = Vector2.new(cx, cy - g)
    xhLines[2].From = Vector2.new(cx, cy + g)
    xhLines[2].To   = Vector2.new(cx, cy + g + sz)
    xhLines[3].From = Vector2.new(cx - g - sz, cy)
    xhLines[3].To   = Vector2.new(cx - g, cy)
    xhLines[4].From = Vector2.new(cx + g, cy)
    xhLines[4].To   = Vector2.new(cx + g + sz, cy)
    for i = 1, 4 do xhLines[i].Visible = show end
end

--------------------------------------------------------------------------------
-- PART 12I — FOV CIRCLE
--------------------------------------------------------------------------------
local fovCircle = trackDrawing(Drawing.new("Circle"))
fovCircle.Color = THEME.Accent; fovCircle.Thickness = 1.5
fovCircle.Filled = false; fovCircle.Visible = false; fovCircle.NumSides = 64

--------------------------------------------------------------------------------
-- PART 12J — ENEMY ALERT
--------------------------------------------------------------------------------
local alertCircle = trackDrawing(Drawing.new("Circle"))
alertCircle.Color = THEME.AlertRed; alertCircle.Thickness = 3
alertCircle.Filled = false; alertCircle.Visible = false; alertCircle.NumSides = 48; alertCircle.Radius = 60

local alertText = trackDrawing(Drawing.new("Text"))
alertText.Color = THEME.AlertRed; alertText.Size = 16
alertText.Outline = true; alertText.Center = true
alertText.Text = "ENEMY NEARBY"; alertText.Visible = false

local lastAlertUpdate = 0

local function updateEnemyAlert(now)
    if not S.EnemyAlert then
        alertCircle.Visible = false
        alertText.Visible = false
        return
    end
    if now - lastAlertUpdate < 0.25 then return end
    lastAlertUpdate = now

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        alertCircle.Visible = false
        alertText.Visible = false
        return
    end

    local closest = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = PartCache[p]
            if pc and pc.root then
                local dist = (pc.root.Position - myRoot.Position).Magnitude
                if dist < closest then closest = dist end
            end
        end
    end

    if closest <= S.EnemyAlertDist then
        local vp = Camera.ViewportSize
        local cx = vp.X * 0.5
        local cy = vp.Y * 0.5

        local r = 60 + math.sin(now * 8) * 15
        alertCircle.Position = Vector2.new(cx, cy)
        alertCircle.Radius = r
        alertCircle.Visible = true
        alertText.Position = Vector2.new(cx, cy - r - 20)
        alertText.Visible = true
    else
        alertCircle.Visible = false
        alertText.Visible = false
    end
end

--------------------------------------------------------------------------------
-- PART 12K — RADAR
--------------------------------------------------------------------------------
local radarBg = trackDrawing(Drawing.new("Square"))
radarBg.Filled = true; radarBg.Color = Color3.fromRGB(8, 4, 18); radarBg.Transparency = 0.3

local radarBorder = trackDrawing(Drawing.new("Square"))
radarBorder.Filled = false; radarBorder.Color = THEME.ESPColor; radarBorder.Thickness = 1.5

local radarSelf = trackDrawing(Drawing.new("Circle"))
radarSelf.Filled = true; radarSelf.Color = Color3.fromRGB(80, 255, 100); radarSelf.Radius = 4

local radarLabel = trackDrawing(Drawing.new("Text"))
radarLabel.Color = THEME.Accent; radarLabel.Size = 11; radarLabel.Outline = true
radarLabel.Center = true; radarLabel.Text = "RADAR"

local lastRadarUpdate = 0

local function updateRadar(now)
    if not S.Radar then
        radarBg.Visible = false
        radarBorder.Visible = false
        radarSelf.Visible = false
        radarLabel.Visible = false
        for _, p in ipairs(Players:GetPlayers()) do
            if ESPPool[p] and ESPPool[p].radarDot then
                ESPPool[p].radarDot.Visible = false
            end
        end
        return
    end
    if now - lastRadarUpdate < 0.05 then return end
    lastRadarUpdate = now

    local vp = Camera.ViewportSize
    local sz = S.RadarSize
    local half = sz * 0.5
    local margin = 10
    local rx = vp.X - sz - margin
    local ry = vp.Y - sz - margin

    radarBg.Position = Vector2.new(rx, ry)
    radarBg.Size = Vector2.new(sz, sz)
    radarBg.Visible = true

    radarBorder.Position = Vector2.new(rx, ry)
    radarBorder.Size = Vector2.new(sz, sz)
    radarBorder.Visible = true

    local cx = rx + half
    local cy = ry + half
    radarSelf.Position = Vector2.new(cx, cy)
    radarSelf.Visible = true

    radarLabel.Position = Vector2.new(cx, ry - 14)
    radarLabel.Visible = true

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local look = Camera.CFrame.LookVector
    local yaw = math.atan2(look.X, look.Z)
    local cosY = math.cos(-yaw)
    local sinY = math.sin(-yaw)
    local scale = half / S.RadarRange

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and ESPPool[p] and ESPPool[p].radarDot then
            local pc = PartCache[p]
            if pc and pc.root then
                local rel = pc.root.Position - myRoot.Position
                local relX = rel.X
                local relZ = rel.Z
                local rotX = relX * cosY - relZ * sinY
                local rotZ = relX * sinY + relZ * cosY

                local dx = math.clamp(rotX * scale, -half + 4, half - 4)
                local dz = math.clamp(rotZ * scale, -half + 4, half - 4)

                ESPPool[p].radarDot.Position = Vector2.new(cx + dx, cy + dz)
                ESPPool[p].radarDot.Visible = true
            else
                ESPPool[p].radarDot.Visible = false
            end
        end
    end
end

--------------------------------------------------------------------------------
-- PART 12L — HUD COUNTERS
--------------------------------------------------------------------------------
local SessionKills, SessionDeaths = 0, 0
local trackedHP = {}

local hudPBg = trackDrawing(Drawing.new("Square")); hudPBg.Filled = true; hudPBg.Color = Color3.fromRGB(200, 40, 40)
local hudBBg = trackDrawing(Drawing.new("Square")); hudBBg.Filled = true; hudBBg.Color = Color3.fromRGB(40, 180, 60)
local hudPTxt = trackDrawing(Drawing.new("Text")); hudPTxt.Color = THEME.White; hudPTxt.Size = 15; hudPTxt.Outline = true; hudPTxt.Center = true
local hudBTxt = trackDrawing(Drawing.new("Text")); hudBTxt.Color = THEME.White; hudBTxt.Size = 15; hudBTxt.Outline = true; hudBTxt.Center = true
local killBg = trackDrawing(Drawing.new("Square")); killBg.Filled = true; killBg.Color = Color3.fromRGB(30, 10, 50)
local killTxt = trackDrawing(Drawing.new("Text")); killTxt.Color = Color3.fromRGB(255, 200, 80); killTxt.Size = 14; killTxt.Outline = true; killTxt.Center = true

local lastHUDUpdate = 0
local lastKillUpdate = 0

local function updatePlayerBotHUD(now)
    if not S.PlayerBotHUD then
        hudPBg.Visible = false; hudBBg.Visible = false
        hudPTxt.Visible = false; hudBTxt.Visible = false
        return
    end
    if now - lastHUDUpdate < 0.5 then return end
    lastHUDUpdate = now

    local vp = Camera.ViewportSize
    local bW = 56
    local bH = 26
    local gap = 6
    local cx = vp.X * 0.5

    local playerCount = #Players:GetPlayers()
    local botCount = 0
    for _, m in ipairs(workspace:GetChildren()) do
        if m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then
            botCount = botCount + 1
        end
    end

    hudPBg.Position = Vector2.new(cx - bW - gap/2, 6)
    hudPBg.Size = Vector2.new(bW, bH)
    hudPBg.Visible = true
    hudPTxt.Position = Vector2.new(cx - gap/2 - bW/2, 6 + bH/2 - 7)
    hudPTxt.Text = tostring(playerCount)
    hudPTxt.Visible = true

    hudBBg.Position = Vector2.new(cx + gap/2, 6)
    hudBBg.Size = Vector2.new(bW, bH)
    hudBBg.Visible = true
    hudBTxt.Position = Vector2.new(cx + gap/2 + bW/2, 6 + bH/2 - 7)
    hudBTxt.Text = tostring(botCount)
    hudBTxt.Visible = true
end

local function updateKillCounter(now)
    if not S.KillCounter then
        killBg.Visible = false; killTxt.Visible = false
        return
    end
    if now - lastKillUpdate < 0.4 then return end
    lastKillUpdate = now

    local vp = Camera.ViewportSize
    killBg.Position = Vector2.new(10, vp.Y - 36)
    killBg.Size = Vector2.new(120, 26)
    killBg.Visible = true

    local ratio = SessionDeaths > 0 and string.format("%.1f", SessionKills/SessionDeaths) or tostring(SessionKills)
    killTxt.Position = Vector2.new(10 + 60, vp.Y - 36 + 6)
    killTxt.Text = "K:" .. SessionKills .. " D:" .. SessionDeaths .. " R:" .. ratio
    killTxt.Visible = true
end

-- Track kills by monitoring HP changes
local function trackPlayerHP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = PartCache[p]
            if pc and pc.hum then
                local hp = pc.hum.Health
                local prev = trackedHP[p]
                if prev and prev > 0 and hp <= 0 then
                    SessionKills = SessionKills + 1
                end
                trackedHP[p] = hp
            end
        end
    end
end

--------------------------------------------------------------------------------
-- PART 12M — AIMBOT TARGET CACHE
--------------------------------------------------------------------------------
local cachedTarget = nil
local _lastAimRefresh = 0

local function getClosestEnemy(now)
    if now - _lastAimRefresh < _G.Config.AimRefreshInterval then
        return cachedTarget
    end
    _lastAimRefresh = now

    local best = nil
    local bestDist = math.huge
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = PartCache[p]
            if pc and pc.hum and pc.hum.Health > 0 then
                local aimPart = S.AimPart == "Torso" and pc.torso or pc.head
                if aimPart then
                    local sp, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if S.FOV_Lock and d > S.FOV_Radius then continue end

                        -- Vis check
                        if S.VisCheck then
                            local parts = Camera:GetPartsObscuringTarget({aimPart.Position}, {LocalPlayer.Character, p.Character})
                            if #parts > 0 then continue end
                        end

                        if d < bestDist then
                            bestDist = d
                            best = p
                        end
                    end
                end
            end
        end
    end

    cachedTarget = best
    _G.__AmethystTargetV4 = best
    return best
end

--------------------------------------------------------------------------------
-- PART 12N — WEAPON MODIFIER
--------------------------------------------------------------------------------
local weaponCache = {}
local lastWeaponScan = 0

local function scanWeapon(tool)
    if weaponCache[tool] then return weaponCache[tool] end
    local cache = {recoil = {}, spread = {}, reload = {}, ammo = {}}

    _safeCall(function()
        for _, obj in ipairs(tool:GetDescendants()) do
            if obj:IsA("ValueBase") then
                local ln = string.lower(obj.Name)
                if ln == "recoil" or ln == "kick" or string.find(ln, "recoilforce") then
                    cache.recoil[#cache.recoil + 1] = obj
                end
                if ln == "spread" or ln == "accuracy" or string.find(ln, "bulletspread") then
                    cache.spread[#cache.spread + 1] = obj
                end
                if ln == "reloadtime" or ln == "reload" then
                    cache.reload[#cache.reload + 1] = obj
                end
                if ln == "ammo" or ln == "currentammo" or ln == "magsize" or ln == "clipsize" then
                    cache.ammo[#cache.ammo + 1] = obj
                end
            end
        end
    end)

    weaponCache[tool] = cache
    return cache
end

local function applyWeaponMods(tool)
    local cache = scanWeapon(tool)
    _safeCall(function()
        if S.NoRecoil then
            for _, v in ipairs(cache.recoil) do v.Value = 0 end
        end
        if S.NoSpread then
            for _, v in ipairs(cache.spread) do v.Value = 0 end
        end
        if S.FastReload then
            for _, v in ipairs(cache.reload) do v.Value = 0.05 end
        end
        if S.InfAmmo then
            for _, v in ipairs(cache.ammo) do v.Value = math.max(v.Value, 999) end
        end
    end)
end

--------------------------------------------------------------------------------
-- PART 12O — SERVER FINDER
--------------------------------------------------------------------------------
local function findServers(placeId, callback)
    task.spawn(function()
        local servers = {}
        local cursor = ""
        local url = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/0?sortOrder=1&excludeFullGames=true&limit=100"

        for page = 1, 5 do
            local pageUrl = url
            if cursor and cursor ~= "" then
                pageUrl = pageUrl .. "&cursor=" .. cursor
            end

            local body = safeHttpGet(pageUrl)
            if not body then break end

            _safeCall(function()
                local data = HttpService:JSONDecode(body)
                if data and data.data then
                    for _, sv in ipairs(data.data) do
                        servers[#servers + 1] = sv
                    end
                    cursor = data.nextPageCursor or ""
                end
            end)

            if cursor == "" then break end
            task.wait(0.4)
        end

        -- Sort ascending by playing
        table.sort(servers, function(a, b)
            return (a.playing or 0) < (b.playing or 0)
        end)

        if callback then callback(servers) end
    end)
end

--------------------------------------------------------------------------------
-- PART 12P — SILENT AIM
--------------------------------------------------------------------------------
local function hookSilentAim(tool)
    if not tool:IsA("Tool") then return end
    track(tool.Activated:Connect(function()
        if not S.SilentAim then return end
        local target = cachedTarget
        if not target then return end
        local pc = PartCache[target]
        if not pc or not pc.head then return end

        local savedCF = Camera.CFrame
        local targetPos = (S.AimPart == "Torso" and pc.torso or pc.head).Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), 0.85)
        task.defer(function()
            Camera.CFrame = savedCF
        end)
    end))
end

--------------------------------------------------------------------------------
-- PART 12Q — FLY SYSTEM
--------------------------------------------------------------------------------
local flyBV, flyBG = nil, nil
local isFlying = false
local flyUpDown = 0
local flyMobileGui = nil

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    isFlying = true
    hum.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 9e4
    flyBG.D = 600
    flyBG.Parent = root

    -- Mobile fly buttons
    if IS_MOBILE then
        flyMobileGui = Instance.new("ScreenGui")
        flyMobileGui.Name = "AmethystFlyButtons"
        flyMobileGui.ResetOnSpawn = false
        _safeCall(function() flyMobileGui.Parent = getGuiParent() end)

        local btnUp = Instance.new("TextButton", flyMobileGui)
        btnUp.Size = UDim2.new(0, 60, 0, 60)
        btnUp.Position = UDim2.new(1, -80, 0.5, -70)
        btnUp.BackgroundColor3 = THEME.Main
        btnUp.TextColor3 = THEME.Accent
        btnUp.Font = Enum.Font.GothamBold
        btnUp.TextSize = 24
        btnUp.Text = "\xe2\x96\xb2"
        Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 10)

        local btnDown = Instance.new("TextButton", flyMobileGui)
        btnDown.Size = UDim2.new(0, 60, 0, 60)
        btnDown.Position = UDim2.new(1, -80, 0.5, 10)
        btnDown.BackgroundColor3 = THEME.Main
        btnDown.TextColor3 = THEME.Accent
        btnDown.Font = Enum.Font.GothamBold
        btnDown.TextSize = 24
        btnDown.Text = "\xe2\x96\xbc"
        Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 10)

        btnUp.MouseButton1Down:Connect(function() flyUpDown = 1 end)
        btnUp.MouseButton1Up:Connect(function() if flyUpDown == 1 then flyUpDown = 0 end end)
        btnDown.MouseButton1Down:Connect(function() flyUpDown = -1 end)
        btnDown.MouseButton1Up:Connect(function() if flyUpDown == -1 then flyUpDown = 0 end end)
    end
end

local function stopFly()
    isFlying = false
    flyUpDown = 0
    _safeCall(function()
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if flyMobileGui then flyMobileGui:Destroy(); flyMobileGui = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end)
end

local function updateFly()
    if not isFlying or not flyBV or not flyBG then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local camCF = Camera.CFrame
    local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
    local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

    local moveDir = hum.MoveDirection
    local dir = flatLook * moveDir.Z * -1 + flatRight * moveDir.X
    if dir.Magnitude < 0.1 then
        dir = flatLook * moveDir.Magnitude
    end

    local finalVel = dir * S.FlySpeed
    local yVel = flyUpDown * S.FlySpeed * 0.8

    flyBV.Velocity = Vector3.new(finalVel.X, yVel, finalVel.Z)
    flyBG.CFrame = camCF
end

-- Keyboard fly vertical
track(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space and isFlying then
        flyUpDown = 1
    elseif (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl) and isFlying then
        flyUpDown = -1
    end
end))

track(UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.Space and flyUpDown == 1 then
        flyUpDown = 0
    elseif (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl) and flyUpDown == -1 then
        flyUpDown = 0
    end
end))

--------------------------------------------------------------------------------
-- PART 12R — NOCLIP
--------------------------------------------------------------------------------
local noclipConn = nil

local function enableNoclip()
    if noclipConn then return end
    noclipConn = track(RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char or not S.Noclip then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end))
end

local function disableNoclip()
    if noclipConn then
        _safeCall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

--------------------------------------------------------------------------------
-- PART 12S — GOD MODE
--------------------------------------------------------------------------------
local godModeConn = nil

local function enableGodMode()
    if godModeConn then return end
    godModeConn = track(RunService.Heartbeat:Connect(function()
        if not S.GodMode then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = hum.MaxHealth end
    end))
end

local function disableGodMode()
    if godModeConn then
        _safeCall(function() godModeConn:Disconnect() end)
        godModeConn = nil
    end
end

--------------------------------------------------------------------------------
-- PART 12T — KILL AURA
--------------------------------------------------------------------------------
local lastKillAura = 0

local function doKillAura(now)
    if not S.KillAura then return end
    if now - lastKillAura < 0.15 then return end
    lastKillAura = now

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = PartCache[p]
            if pc and pc.root and pc.hum and pc.hum.Health > 0 then
                local dist = (pc.root.Position - root.Position).Magnitude
                if dist <= S.KillAuraRange then
                    -- Camera lerp toward target
                    local targetPos = pc.torso and pc.torso.Position or pc.root.Position
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), 0.5)
                    _safeCall(function() tool:Activate() end)
                    task.wait(_G.Config.KillAuraCooldown)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- PART 12U — ESP UPDATE (exact box sizing math)
--------------------------------------------------------------------------------
local lastESPUpdate = 0
local lastSkeletonUpdate = 0

local function updateESP(now)
    if now - lastESPUpdate < _G.Config.ESPThrottle then return end
    lastESPUpdate = now

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local vp = Camera.ViewportSize
    local doSkeleton = now - lastSkeletonUpdate >= _G.Config.SkeletonThrottle

    if doSkeleton then lastSkeletonUpdate = now end

    for player, pool in pairs(ESPPool) do
        local pc = PartCache[player]
        if not pc or not pc.hum or pc.hum.Health <= 0 or not pc.root or not pc.head then
            pool.box.Visible = false
            pool.tracer.Visible = false
            pool.distLabel.Visible = false
            pool.nameLabel.Visible = false
            pool.healthBg.Visible = false
            pool.healthBar.Visible = false
            for _, b in ipairs(pool.bones) do b.Visible = false end
            if pool.highlight then pool.highlight.Enabled = false end
            continue
        end

        -- Wallhack highlight
        if pool.highlight then
            pool.highlight.Enabled = S.Wallhack
        end

        -- VisCheck
        if S.VisCheck then
            local parts = Camera:GetPartsObscuringTarget({pc.head.Position}, {LocalPlayer.Character, player.Character})
            if #parts > 0 then
                pool.box.Visible = false
                pool.tracer.Visible = false
                pool.distLabel.Visible = false
                pool.nameLabel.Visible = false
                pool.healthBg.Visible = false
                pool.healthBar.Visible = false
                for _, b in ipairs(pool.bones) do b.Visible = false end
                continue
            end
        end

        local isR15 = pc.boneParts and #pc.boneParts > 5
        local headOff = isR15 and 0.7 or 0.5
        local feetOff = isR15 and 3.2 or 2.8

        local headPos = pc.head.Position + Vector3.new(0, headOff, 0)
        local feetPos = pc.root.Position - Vector3.new(0, feetOff, 0)

        local hSP, hOn = Camera:WorldToViewportPoint(headPos)
        local fSP, fOn = Camera:WorldToViewportPoint(feetPos)
        local rSP = Camera:WorldToViewportPoint(pc.root.Position)

        if not hOn then
            pool.box.Visible = false
            pool.tracer.Visible = false
            pool.distLabel.Visible = false
            pool.nameLabel.Visible = false
            pool.healthBg.Visible = false
            pool.healthBar.Visible = false
            for _, b in ipairs(pool.bones) do b.Visible = false end
            continue
        end

        local boxH = math.max(fSP.Y - hSP.Y, 4)
        local boxW = boxH * 0.55
        local bx = hSP.X - boxW * 0.5
        local by = hSP.Y

        -- Box ESP
        pool.box.Position = Vector2.new(bx, by)
        pool.box.Size = Vector2.new(boxW, boxH)
        pool.box.Color = S.ESPColor
        pool.box.Visible = S.ESP_Box

        -- Tracer
        pool.tracer.From = Vector2.new(vp.X * 0.5, vp.Y)
        pool.tracer.To = Vector2.new(rSP.X, rSP.Y)
        pool.tracer.Visible = S.ESP_Tracer

        -- Name
        pool.nameLabel.Position = Vector2.new(hSP.X, by - 16)
        pool.nameLabel.Visible = S.ESP_Name

        -- Distance
        if myRoot then
            local dist = math.floor((pc.root.Position - myRoot.Position).Magnitude)
            pool.distLabel.Text = tostring(dist) .. "m"
            pool.distLabel.Position = Vector2.new(hSP.X, by + boxH + 2)
            pool.distLabel.Visible = S.ESP_Distance
        else
            pool.distLabel.Visible = false
        end

        -- Health bar
        local hpPct = math.clamp(pc.hum.Health / pc.hum.MaxHealth, 0, 1)
        local hbX = bx - 5
        local hbH = boxH
        pool.healthBg.Position = Vector2.new(hbX - 3, by)
        pool.healthBg.Size = Vector2.new(3, hbH)
        pool.healthBg.Visible = S.ESP_Health

        pool.healthBar.Position = Vector2.new(hbX - 3, by + hbH * (1 - hpPct))
        pool.healthBar.Size = Vector2.new(3, hbH * hpPct)
        pool.healthBar.Color = healthColor(hpPct)
        pool.healthBar.Visible = S.ESP_Health

        -- Skeleton
        if doSkeleton and S.ESP_Skeleton then
            for i, bp in ipairs(pc.boneParts) do
                local b = pool.bones[i]
                if b and bp[1] and bp[2] then
                    local p1 = Camera:WorldToViewportPoint(bp[1].Position)
                    local p2 = Camera:WorldToViewportPoint(bp[2].Position)
                    b.From = Vector2.new(p1.X, p1.Y)
                    b.To = Vector2.new(p2.X, p2.Y)
                    b.Color = S.ESPColor
                    b.Visible = true
                else
                    if b then b.Visible = false end
                end
            end
            -- Hide unused bone slots
            for i = (pc.numBones or 0) + 1, MAX_BONES do
                if pool.bones[i] then pool.bones[i].Visible = false end
            end
        elseif not S.ESP_Skeleton then
            for _, b in ipairs(pool.bones) do b.Visible = false end
        end
    end
end

--------------------------------------------------------------------------------
-- CONFIG SAVE/LOAD (V4 NEW)
--------------------------------------------------------------------------------
local CONFIG_PATH = "AmethystV4_Config.json"

local function saveConfig()
    _safeCall(function()
        if not writefile then return end
        local data = {}
        for cat, tbl in pairs({Combat = S.Combat, Visuals = S.Visuals, Movement = S.Movement, Utility = S.Utility}) do
            data[cat] = {}
            for k, v in pairs(tbl) do
                if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                    data[cat][k] = v
                end
            end
        end
        writefile(CONFIG_PATH, HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    _safeCall(function()
        if not readfile or not isfile then return end
        if not isfile(CONFIG_PATH) then return end
        local raw = readfile(CONFIG_PATH)
        local data = HttpService:JSONDecode(raw)
        if not data then return end
        for cat, tbl in pairs(data) do
            local target = S[cat]
            if target and type(target) == "table" then
                for k, v in pairs(tbl) do
                    if rawget(target, k) ~= nil then
                        target[k] = v
                    end
                end
            end
        end
    end)
end

-- Try loading saved config
loadConfig()

--------------------------------------------------------------------------------
-- PART 9 — CUSTOM UI FRAMEWORK
--------------------------------------------------------------------------------

-- Main ScreenGui
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "AmethystHubV4"
hubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hubGui.ResetOnSpawn = false
_safeCall(function() hubGui.Parent = getGuiParent() end)

--------------------------------------------------------------------------------
-- 9A — LOADING SCREEN
--------------------------------------------------------------------------------
local loadingFrame = Instance.new("Frame", hubGui)
loadingFrame.Name = "LoadingScreen"
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = THEME.LoadingBackground
loadingFrame.BackgroundTransparency = 0
loadingFrame.BorderSizePixel = 0
loadingFrame.ZIndex = 100

local loadTitle = Instance.new("TextLabel", loadingFrame)
loadTitle.Size = UDim2.new(1, 0, 0, 40)
loadTitle.Position = UDim2.new(0, 0, 0.4, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Font = Enum.Font.GothamBold
loadTitle.TextSize = 32
loadTitle.TextColor3 = THEME.Accent
loadTitle.Text = "A M E T H Y S T"
loadTitle.TextXAlignment = Enum.TextXAlignment.Center

local loadSub = Instance.new("TextLabel", loadingFrame)
loadSub.Size = UDim2.new(1, 0, 0, 24)
loadSub.Position = UDim2.new(0, 0, 0.4, 44)
loadSub.BackgroundTransparency = 1
loadSub.Font = Enum.Font.Gotham
loadSub.TextSize = 16
loadSub.TextColor3 = THEME.TextSecondary
loadSub.Text = "Ultimate V4.0 | by Lutfie kenape ek"
loadSub.TextXAlignment = Enum.TextXAlignment.Center

local loadBarBg = Instance.new("Frame", loadingFrame)
loadBarBg.Size = UDim2.new(0, 200, 0, 4)
loadBarBg.Position = UDim2.new(0.5, -100, 0.4, 82)
loadBarBg.BackgroundColor3 = THEME.LoadingBarBackground
loadBarBg.BorderSizePixel = 0
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(0, 2)

local loadBarFill = Instance.new("Frame", loadBarBg)
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BackgroundColor3 = THEME.LoadingBarFill
loadBarFill.BorderSizePixel = 0
Instance.new("UICorner", loadBarFill).CornerRadius = UDim.new(0, 2)

-- Animate loading bar
TweenService:Create(loadBarFill, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
    Size = UDim2.new(1, 0, 1, 0)
}):Play()

task.delay(2.2, function()
    TweenService:Create(loadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    }):Play()
    for _, child in ipairs(loadingFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            tweenProp(child, {TextTransparency = 1}, TI_FAST)
        elseif child:IsA("Frame") then
            tweenProp(child, {BackgroundTransparency = 1}, TI_FAST)
        end
    end
    task.delay(0.6, function()
        loadingFrame:Destroy()
    end)
end)

--------------------------------------------------------------------------------
-- 9B — MAIN HUB WINDOW
--------------------------------------------------------------------------------
local sidebarWidth = IS_MOBILE and 110 or 130
local isMinimized = false
local hubVisible = true

local mainFrame = Instance.new("Frame", hubGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = IS_MOBILE and UDim2.new(0.92, 0, 0.7, 0) or UDim2.new(0, 550, 0, 380)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = THEME.WindowBackground
mainFrame.ClipsDescendants = true
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false  -- hidden until loading done

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(80, 40, 120)
mainStroke.Thickness = 1.5

-- Make draggable
do
    local dragging = false
    local dragStart, startPos

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))
end

-- TOP BAR
local topBar = Instance.new("Frame", mainFrame)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = THEME.Topbar
topBar.BorderSizePixel = 0

local topBarGrad = Instance.new("UIGradient", topBar)
topBarGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 20, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 30, 95)),
})

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = THEME.Lavender
titleLabel.Text = "  Amethyst  |  Universal  "
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = THEME.TextPrimary
closeBtn.Text = "\xe2\x9c\x95"
closeBtn.BorderSizePixel = 0

closeBtn.MouseEnter:Connect(function()
    tweenProp(closeBtn, {TextColor3 = Color3.fromRGB(255, 60, 60)}, TI_FAST)
end)
closeBtn.MouseLeave:Connect(function()
    tweenProp(closeBtn, {TextColor3 = THEME.TextPrimary}, TI_FAST)
end)
closeBtn.MouseButton1Click:Connect(function()
    hubVisible = false
    tweenProp(mainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, TI_SMOOTH)
    task.delay(0.4, function() mainFrame.Visible = false end)
end)

-- Minimize button
local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
minimizeBtn.Position = UDim2.new(1, -72, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.TextColor3 = THEME.TextPrimary
minimizeBtn.Text = "\xe2\x80\x94"
minimizeBtn.BorderSizePixel = 0

local originalSize = mainFrame.Size
local sidebar, contentArea, statusBar  -- forward declare

minimizeBtn.MouseEnter:Connect(function()
    tweenProp(minimizeBtn, {TextColor3 = THEME.Accent}, TI_FAST)
end)
minimizeBtn.MouseLeave:Connect(function()
    tweenProp(minimizeBtn, {TextColor3 = THEME.TextPrimary}, TI_FAST)
end)
minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        isMinimized = false
        tweenProp(mainFrame, {Size = originalSize}, TI_SMOOTH)
        task.delay(0.15, function()
            if sidebar then sidebar.Visible = true end
            if contentArea then contentArea.Visible = true end
            if statusBar then statusBar.Visible = true end
        end)
    else
        isMinimized = true
        if sidebar then sidebar.Visible = false end
        if contentArea then contentArea.Visible = false end
        if statusBar then statusBar.Visible = false end
        tweenProp(mainFrame, {Size = UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, 36)}, TI_SMOOTH)
    end
end)

-- SIDEBAR
sidebar = Instance.new("Frame", mainFrame)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, sidebarWidth, 1, -56)
sidebar.Position = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = THEME.SidebarBackground
sidebar.BorderSizePixel = 0

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sidebarPad = Instance.new("UIPadding", sidebar)
sidebarPad.PaddingTop = UDim.new(0, 6)

-- CONTENT AREA
contentArea = Instance.new("Frame", mainFrame)
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -sidebarWidth, 1, -56)
contentArea.Position = UDim2.new(0, sidebarWidth, 0, 36)
contentArea.BackgroundColor3 = THEME.ContentBackground
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true

-- STATUS BAR
statusBar = Instance.new("Frame", mainFrame)
statusBar.Name = "StatusBar"
statusBar.Size = UDim2.new(1, 0, 0, 20)
statusBar.Position = UDim2.new(0, 0, 1, -20)
statusBar.BackgroundColor3 = THEME.StatusBarBackground
statusBar.BorderSizePixel = 0

local statusLeft = Instance.new("TextLabel", statusBar)
statusLeft.Size = UDim2.new(0.3, 0, 1, 0)
statusLeft.Position = UDim2.new(0, 6, 0, 0)
statusLeft.BackgroundTransparency = 1
statusLeft.Font = Enum.Font.Gotham
statusLeft.TextSize = 10
statusLeft.TextColor3 = THEME.TextSecondary
statusLeft.Text = "Amethyst V4.0"
statusLeft.TextXAlignment = Enum.TextXAlignment.Left

local statusCenter = Instance.new("TextLabel", statusBar)
statusCenter.Size = UDim2.new(0.4, 0, 1, 0)
statusCenter.Position = UDim2.new(0.3, 0, 0, 0)
statusCenter.BackgroundTransparency = 1
statusCenter.Font = Enum.Font.Gotham
statusCenter.TextSize = 10
statusCenter.TextColor3 = THEME.TextSecondary
statusCenter.Text = "FPS: -- | Ping: --ms"
statusCenter.TextXAlignment = Enum.TextXAlignment.Right

local statusRight = Instance.new("TextLabel", statusBar)
statusRight.Size = UDim2.new(0.3, -6, 1, 0)
statusRight.Position = UDim2.new(0.7, 0, 0, 0)
statusRight.BackgroundTransparency = 1
statusRight.Font = Enum.Font.Gotham
statusRight.TextSize = 10
statusRight.TextColor3 = THEME.TextSecondary
statusRight.Text = "Game: " .. tostring(game.PlaceId)
statusRight.TextXAlignment = Enum.TextXAlignment.Right

-- FPS + Ping counter [V4 NEW]
local fpsFrameCount = 0
local fpsLastTime = os.clock()

track(RunService.RenderStepped:Connect(function()
    fpsFrameCount = fpsFrameCount + 1
end))

task.spawn(function()
    while true do
        task.wait(0.5)
        _safeCall(function()
            local now = os.clock()
            local elapsed = now - fpsLastTime
            local fps = math.floor(fpsFrameCount / elapsed)
            fpsFrameCount = 0
            fpsLastTime = now

            local ping = "--"
            _safeCall(function()
                local stats = game:GetService("Stats")
                local perfStats = stats:FindFirstChild("PerformanceStats")
                if perfStats then
                    local pingStat = perfStats:FindFirstChild("Ping")
                    if pingStat then
                        ping = tostring(math.floor(pingStat:GetValue()))
                    end
                end
            end)

            statusCenter.Text = "FPS: " .. fps .. " | Ping: " .. ping .. "ms"
        end)
    end
end)

-- Show main frame after loading
task.delay(2.3, function()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 0
    mainFrame.Size = IS_MOBILE and UDim2.new(0.92, 0, 0.7, 0) or UDim2.new(0, 550, 0, 380)
    originalSize = mainFrame.Size
end)

--------------------------------------------------------------------------------
-- 9D — REUSABLE UI COMPONENTS
--------------------------------------------------------------------------------

-- 1. createSection
local function createSection(parent, text)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -12, 0, 28)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = THEME.Accent
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0

    return frame
end

-- 2. createToggle
local function createToggle(parent, config)
    local enabled = config.CurrentValue or false

    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -12, 0, 36)
    row.BackgroundColor3 = THEME.ElementBackground
    row.BorderSizePixel = 0
    row.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = THEME.ElementStroke
    rowStroke.Thickness = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -56, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = config.Name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd

    -- Toggle track
    local toggleTrack = Instance.new("Frame", row)
    toggleTrack.Size = UDim2.new(0, 36, 0, 20)
    toggleTrack.Position = UDim2.new(1, -46, 0.5, -10)
    toggleTrack.BackgroundColor3 = enabled and THEME.ToggleEnabled or THEME.ToggleDisabled
    toggleTrack.BorderSizePixel = 0
    Instance.new("UICorner", toggleTrack).CornerRadius = UDim.new(1, 0)
    local trackStroke = Instance.new("UIStroke", toggleTrack)
    trackStroke.Color = enabled and THEME.ToggleEnabledStroke or THEME.ToggleDisabledStroke
    trackStroke.Thickness = 1

    -- Toggle circle
    local circle = Instance.new("Frame", toggleTrack)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = THEME.CrystalWhite
    circle.BorderSizePixel = 0
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        tweenProp(toggleTrack, {BackgroundColor3 = enabled and THEME.ToggleEnabled or THEME.ToggleDisabled}, TI_SMOOTH)
        tweenProp(circle, {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, TI_SMOOTH)
        trackStroke.Color = enabled and THEME.ToggleEnabledStroke or THEME.ToggleDisabledStroke
        if config.Callback then config.Callback(enabled) end
    end)

    return row
end

-- 3. createSlider
local function createSlider(parent, config)
    local min = config.Range[1]
    local max = config.Range[2]
    local inc = config.Increment or 1
    local current = config.CurrentValue or min

    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -12, 0, 52)
    row.BackgroundColor3 = THEME.ElementBackground
    row.BorderSizePixel = 0
    row.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", row).Color = THEME.ElementStroke

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -60, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = config.Name
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", row)
    valLabel.Size = UDim2.new(0, 50, 0, 20)
    valLabel.Position = UDim2.new(1, -55, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12
    valLabel.TextColor3 = THEME.Accent
    valLabel.Text = tostring(current)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- Track
    local sliderTrack = Instance.new("Frame", row)
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 0, 34)
    sliderTrack.BackgroundColor3 = THEME.SliderBackground
    sliderTrack.BorderSizePixel = 0
    Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(0, 3)

    local fillBar = Instance.new("Frame", sliderTrack)
    local pct = math.clamp((current - min) / (max - min), 0, 1)
    fillBar.Size = UDim2.new(pct, 0, 1, 0)
    fillBar.BackgroundColor3 = THEME.SliderProgress
    fillBar.BorderSizePixel = 0
    Instance.new("UICorner", fillBar).CornerRadius = UDim.new(0, 3)

    -- Drag
    local dragging = false

    local function updateSlider(inputPos)
        local absPos = sliderTrack.AbsolutePosition.X
        local absSize = sliderTrack.AbsoluteSize.X
        local relX = math.clamp((inputPos.X - absPos) / absSize, 0, 1)
        local raw = min + (max - min) * relX
        local snapped = math.floor(raw / inc + 0.5) * inc
        snapped = math.clamp(snapped, min, max)
        current = snapped
        local newPct = math.clamp((current - min) / (max - min), 0, 1)
        fillBar.Size = UDim2.new(newPct, 0, 1, 0)
        valLabel.Text = tostring(current)
        if config.Callback then config.Callback(current) end
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position)
        end
    end)

    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position)
        end
    end))

    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    return row
end

-- 4. createButton
local function createButton(parent, config)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.BackgroundColor3 = THEME.ElementBackground
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = THEME.Accent
    btn.Text = config.Name
    btn.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = THEME.ElementStroke

    btn.MouseEnter:Connect(function()
        tweenProp(btn, {BackgroundColor3 = THEME.ElementBackgroundHover}, TI_FAST)
    end)
    btn.MouseLeave:Connect(function()
        tweenProp(btn, {BackgroundColor3 = THEME.ElementBackground}, TI_FAST)
    end)
    btn.MouseButton1Click:Connect(function()
        tweenProp(btn, {Size = UDim2.new(1, -16, 0, 30)}, TI_FAST)
        task.delay(0.15, function()
            tweenProp(btn, {Size = UDim2.new(1, -12, 0, 32)}, TI_BOUNCE)
        end)
        if config.Callback then config.Callback() end
    end)

    return btn
end

-- 5. createDropdown
local function createDropdown(parent, config)
    local options = config.Options or {}
    local currentOption = config.CurrentOption or (options[1] and {options[1]}) or {}
    local multi = config.MultipleOptions or false
    local isOpen = false

    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -12, 0, 36)
    container.BackgroundColor3 = THEME.ElementBackground
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", container).Color = THEME.ElementStroke

    local header = Instance.new("TextButton", container)
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.Gotham
    header.TextSize = 12
    header.TextColor3 = THEME.TextPrimary
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = "  " .. config.Name .. ": " .. table.concat(currentOption, ", ")

    local arrow = Instance.new("TextLabel", header)
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.TextColor3 = THEME.Accent
    arrow.Text = "\xe2\x96\xbc"

    local optList = Instance.new("Frame", container)
    optList.Size = UDim2.new(1, 0, 0, #options * 28)
    optList.Position = UDim2.new(0, 0, 0, 36)
    optList.BackgroundTransparency = 1

    local optLayout = Instance.new("UIListLayout", optList)
    optLayout.Padding = UDim.new(0, 2)
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local optButtons = {}
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", optList)
        optBtn.Size = UDim2.new(1, -4, 0, 26)
        optBtn.BackgroundColor3 = (table.find(currentOption, opt)) and THEME.DropdownSelected or THEME.DropdownUnselected
        optBtn.BorderSizePixel = 0
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 12
        optBtn.TextColor3 = THEME.TextPrimary
        optBtn.Text = "  " .. opt
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.LayoutOrder = i
        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
        optButtons[i] = optBtn

        optBtn.MouseButton1Click:Connect(function()
            if multi then
                local idx = table.find(currentOption, opt)
                if idx then
                    table.remove(currentOption, idx)
                else
                    currentOption[#currentOption + 1] = opt
                end
            else
                currentOption = {opt}
            end
            -- Update visuals
            for j, ob in ipairs(optButtons) do
                ob.BackgroundColor3 = table.find(currentOption, options[j]) and THEME.DropdownSelected or THEME.DropdownUnselected
            end
            header.Text = "  " .. config.Name .. ": " .. table.concat(currentOption, ", ")
            if not multi then
                isOpen = false
                tweenProp(container, {Size = UDim2.new(1, -12, 0, 36)}, TI_SMOOTH)
                arrow.Text = "\xe2\x96\xbc"
            end
            if config.Callback then config.Callback(currentOption) end
        end)
    end

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            tweenProp(container, {Size = UDim2.new(1, -12, 0, 36 + #options * 28 + 4)}, TI_SMOOTH)
            arrow.Text = "\xe2\x96\xb2"
        else
            tweenProp(container, {Size = UDim2.new(1, -12, 0, 36)}, TI_SMOOTH)
            arrow.Text = "\xe2\x96\xbc"
        end
    end)

    return container
end

-- 6. createInput
local function createInput(parent, config)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -12, 0, 36)
    row.BackgroundColor3 = THEME.InputBackground
    row.BorderSizePixel = 0
    row.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local inputStroke = Instance.new("UIStroke", row)
    inputStroke.Color = THEME.InputStroke
    inputStroke.Thickness = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = config.Name
    label.TextXAlignment = Enum.TextXAlignment.Left

    local textBox = Instance.new("TextBox", row)
    textBox.Size = UDim2.new(0.55, -10, 0, 26)
    textBox.Position = UDim2.new(0.4, 5, 0.5, -13)
    textBox.BackgroundColor3 = THEME.ElementBackground
    textBox.BorderSizePixel = 0
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 12
    textBox.TextColor3 = THEME.TextPrimary
    textBox.PlaceholderText = config.PlaceholderText or ""
    textBox.PlaceholderColor3 = THEME.PlaceholderColor
    textBox.Text = ""
    textBox.ClearTextOnFocus = false
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 4)

    textBox.Focused:Connect(function()
        tweenProp(inputStroke, {Color = THEME.Accent}, TI_FAST)
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        tweenProp(inputStroke, {Color = THEME.InputStroke}, TI_FAST)
        if config.Callback then config.Callback(textBox.Text) end
        if config.RemoveTextAfterFocusLost then textBox.Text = "" end
    end)

    return row, textBox
end

-- 7. createParagraph
local function createParagraph(parent, config)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -12, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = THEME.ElementBackground
    frame.BorderSizePixel = 0
    frame.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local pad = Instance.new("UIPadding", frame)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)

    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, 0, 0, 16)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = THEME.TextPrimary
    titleLbl.Text = config.Title or ""
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.LayoutOrder = 1

    local contentLbl = Instance.new("TextLabel", frame)
    contentLbl.Size = UDim2.new(1, 0, 0, 0)
    contentLbl.AutomaticSize = Enum.AutomaticSize.Y
    contentLbl.BackgroundTransparency = 1
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextSize = 12
    contentLbl.TextColor3 = THEME.TextSecondary
    contentLbl.Text = config.Content or ""
    contentLbl.TextWrapped = true
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.LayoutOrder = 2

    return frame
end

-- 8. createColorPicker
local function createColorPicker(parent, config)
    local currentColor = config.Color or THEME.ESPColor
    local h, s, v = Color3.toHSV(currentColor)
    local pickerOpen = false

    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -12, 0, 36)
    row.BackgroundColor3 = THEME.ElementBackground
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    row.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", row).Color = THEME.ElementStroke

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -50, 0, 36)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = config.Name
    label.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("Frame", row)
    preview.Size = UDim2.new(0, 24, 0, 24)
    preview.Position = UDim2.new(1, -34, 0, 6)
    preview.BackgroundColor3 = currentColor
    preview.BorderSizePixel = 0
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)

    -- Hue bar
    local hueBar = Instance.new("Frame", row)
    hueBar.Size = UDim2.new(1, -20, 0, 16)
    hueBar.Position = UDim2.new(0, 10, 0, 42)
    hueBar.BorderSizePixel = 0
    Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 4)

    local hueGrad = Instance.new("UIGradient", hueBar)
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })

    -- SV square: Layer 1 (saturation)
    local svFrame = Instance.new("Frame", row)
    svFrame.Size = UDim2.new(1, -20, 0, 80)
    svFrame.Position = UDim2.new(0, 10, 0, 64)
    svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    svFrame.BorderSizePixel = 0
    Instance.new("UICorner", svFrame).CornerRadius = UDim.new(0, 4)

    local svGradSat = Instance.new("UIGradient", svFrame)
    svGradSat.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
    svGradSat.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })

    -- SV Layer 2 (value overlay)
    local svOverlay = Instance.new("Frame", svFrame)
    svOverlay.Size = UDim2.new(1, 0, 1, 0)
    svOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    svOverlay.BorderSizePixel = 0
    Instance.new("UICorner", svOverlay).CornerRadius = UDim.new(0, 4)

    local svGradVal = Instance.new("UIGradient", svOverlay)
    svGradVal.Rotation = 90
    svGradVal.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })

    -- Preview swatch
    local swatchPreview = Instance.new("Frame", row)
    swatchPreview.Size = UDim2.new(0, 20, 0, 20)
    swatchPreview.Position = UDim2.new(1, -30, 0, 150)
    swatchPreview.BackgroundColor3 = currentColor
    swatchPreview.BorderSizePixel = 0
    Instance.new("UICorner", swatchPreview).CornerRadius = UDim.new(0, 4)

    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)
        preview.BackgroundColor3 = currentColor
        swatchPreview.BackgroundColor3 = currentColor
        svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        if config.Callback then config.Callback(currentColor) end
    end

    -- Hue drag
    local draggingHue = false
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            local relX = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            h = relX
            updateColor()
        end
    end)

    -- SV drag
    local draggingSV = false
    svOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
            local relX = math.clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
            s = relX
            v = 1 - relY
            updateColor()
        end
    end)

    track(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if draggingHue then
                local relX = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                h = relX
                updateColor()
            end
            if draggingSV then
                local relX = math.clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                s = relX
                v = 1 - relY
                updateColor()
            end
        end
    end))

    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = false
            draggingSV = false
        end
    end))

    -- Toggle picker open/close
    local toggleBtn = Instance.new("TextButton", row)
    toggleBtn.Size = UDim2.new(1, 0, 0, 36)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 5

    toggleBtn.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        if pickerOpen then
            tweenProp(row, {Size = UDim2.new(1, -12, 0, 180)}, TI_SMOOTH)
        else
            tweenProp(row, {Size = UDim2.new(1, -12, 0, 36)}, TI_SMOOTH)
        end
    end)

    return row
end

-- 9. createLabel
local function createLabel(parent, text)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -12, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextSecondary
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren()) or 0
    return label
end

--------------------------------------------------------------------------------
-- PART 13 — TAB SYSTEM + ALL 7 TABS
--------------------------------------------------------------------------------

local TAB_NAMES = {"Home", "Combat", "Visuals", "Gameplay", "Performance", "Server", "Credits"}
local tabPages = {}
local tabButtons = {}
local currentTab = "Home"

-- Create scrolling frames for each tab
for i, tabName in ipairs(TAB_NAMES) do
    local page = Instance.new("ScrollingFrame", contentArea)
    page.Name = "Page_" .. tabName
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = THEME.AccentDim
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ElasticBehavior = Enum.ElasticBehavior.Always
    page.Visible = (tabName == "Home")

    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pagePad = Instance.new("UIPadding", page)
    pagePad.PaddingTop = UDim.new(0, 6)
    pagePad.PaddingBottom = UDim.new(0, 6)
    pagePad.PaddingLeft = UDim.new(0, 6)
    pagePad.PaddingRight = UDim.new(0, 6)

    tabPages[tabName] = page
end

-- Create sidebar tab buttons
for i, tabName in ipairs(TAB_NAMES) do
    local tabBtn = Instance.new("TextButton", sidebar)
    tabBtn.Size = UDim2.new(1, -8, 0, 32)
    tabBtn.BackgroundColor3 = (tabName == "Home") and THEME.TabBackgroundSelected or THEME.TabBackground
    tabBtn.BorderSizePixel = 0
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.TextColor3 = THEME.TextPrimary
    tabBtn.Text = "  " .. tabName
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.LayoutOrder = i
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local tabStroke = Instance.new("UIStroke", tabBtn)
    tabStroke.Color = (tabName == "Home") and THEME.TabStrokeSelected or THEME.TabStroke
    tabStroke.Thickness = 1

    -- Left accent bar
    local accentBar = Instance.new("Frame", tabBtn)
    accentBar.Size = UDim2.new(0, 3, 0.6, 0)
    accentBar.Position = UDim2.new(0, 0, 0.2, 0)
    accentBar.BackgroundColor3 = THEME.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Visible = (tabName == "Home")
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

    tabButtons[tabName] = {button = tabBtn, stroke = tabStroke, accent = accentBar}

    tabBtn.MouseEnter:Connect(function()
        if currentTab ~= tabName then
            tweenProp(tabBtn, {BackgroundColor3 = THEME.SidebarHover}, TI_FAST)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if currentTab ~= tabName then
            tweenProp(tabBtn, {BackgroundColor3 = THEME.TabBackground}, TI_FAST)
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        -- Deselect old
        if tabButtons[currentTab] then
            tweenProp(tabButtons[currentTab].button, {BackgroundColor3 = THEME.TabBackground}, TI_SMOOTH)
            tabButtons[currentTab].stroke.Color = THEME.TabStroke
            tabButtons[currentTab].accent.Visible = false
        end
        if tabPages[currentTab] then tabPages[currentTab].Visible = false end

        -- Select new
        currentTab = tabName
        tweenProp(tabBtn, {BackgroundColor3 = THEME.TabBackgroundSelected}, TI_SMOOTH)
        tabStroke.Color = THEME.TabStrokeSelected
        accentBar.Visible = true
        if tabPages[tabName] then tabPages[tabName].Visible = true end
    end)
end

--------------------------------------------------------------------------------
-- TAB 1: HOME
--------------------------------------------------------------------------------
do
    local page = tabPages["Home"]
    createSection(page, "Welcome")
    createParagraph(page, {
        Title = "  Amethyst  |  Universal  ",
        Content = "Game: " .. tostring(game.PlaceId) .. "\nPlayers: " .. #Players:GetPlayers() .. "\nVersion: " .. _G.Config.Version .. "\nPlatform: " .. (IS_MOBILE and "Mobile" or "Desktop")
    })

    createSection(page, "Quick Presets")
    createButton(page, { Name = "Enable All FPS Optimizations", Callback = function()
        S.FPSBoost = true; runOmegaFPS(); enableFPSListener()
        S.LightingUltra = true; applyLightingUltra()
        S.TexturePurge = true; purgeTextures(); enableTexListener()
        S.ParticlePurge = true; purgeParticles()
        S.TerrainSimple = true; simplifyTerrain()
        notify("Preset", "All FPS optimizations enabled!", 3)
    end})
    createButton(page, { Name = "Enable Full ESP Suite", Callback = function()
        S.Wallhack = true; S.ESP_Box = true; S.ESP_Name = true
        S.ESP_Health = true; S.ESP_Skeleton = true; S.ESP_Tracer = true; S.ESP_Distance = true
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                createESP(p)
                if ESPPool[p] and ESPPool[p].highlight then ESPPool[p].highlight.Enabled = true end
            end
        end
        notify("Preset", "Full ESP suite enabled!", 3)
    end})
    createButton(page, { Name = "Enable Combat Suite", Callback = function()
        S.Aimbot = true; S.FOV_Show = true; S.FOV_Lock = true; S.TriggerBot = true
        notify("Preset", "Combat suite enabled!", 3)
    end})
    createButton(page, { Name = "Enable Movement Suite", Callback = function()
        S.Speed = true; S.SpeedVal = 32; S.Jump = true; S.JumpVal = 80; S.InfJump = true; S.AutoStrafe = true; S.NoFallDmg = true
        notify("Preset", "Movement suite enabled!", 3)
    end})
    createButton(page, { Name = "Disable Everything", Callback = function()
        -- Combat
        S.Aimbot = false; S.AimPredict = false; S.FOV_Show = false; S.FOV_Lock = false
        S.SilentAim = false; S.TriggerBot = false; S.KillAura = false; S.Hitbox = false
        S.NoRecoil = false; S.NoSpread = false; S.FastReload = false; S.InfAmmo = false
        -- Visuals
        S.Wallhack = false; S.ESP_Box = false; S.ESP_Name = false; S.ESP_Health = false
        S.ESP_Skeleton = false; S.ESP_Tracer = false; S.ESP_Distance = false; S.VisCheck = false
        S.Crosshair = false; S.Fullbright = false; S.EnemyAlert = false; S.Radar = false
        S.PlayerBotHUD = false; S.KillCounter = false
        -- Movement
        S.Speed = false; S.Jump = false; S.AutoStrafe = false; S.InfJump = false; S.NoFallDmg = false
        S.Fly = false; stopFly(); S.Noclip = false; disableNoclip()
        -- Utility
        S.GodMode = false; disableGodMode(); S.FPSBoost = false; disableFPSListener()
        S.LightingUltra = false; restoreLighting(); S.TexturePurge = false; disableTexListener()
        S.ParticlePurge = false; S.TerrainSimple = false; S.AntiAFK = false; S.AutoHop = false
        applyFullbright(false)
        -- Disable wallhack highlights
        for _, pool in pairs(ESPPool) do
            if pool.highlight then pool.highlight.Enabled = false end
        end
        notify("Preset", "All features disabled.", 3)
    end})
end

--------------------------------------------------------------------------------
-- TAB 2: COMBAT
--------------------------------------------------------------------------------
do
    local page = tabPages["Combat"]

    createSection(page, "-- Aimbot (Camera.CFrame + ClosestPlayer) --")
    createToggle(page, { Name = "Aimbot", CurrentValue = S.Aimbot, Callback = function(v) S.Aimbot = v; notifyToggle("Aimbot", v) end })
    createSlider(page, { Name = "Smoothness (1=snap, 10=slow)", Range = {1, 10}, Increment = 1, CurrentValue = S.AimbotSmooth, Callback = function(v) S.AimbotSmooth = v end })
    createDropdown(page, { Name = "Aim Part", Options = {"Head", "Torso"}, CurrentOption = {S.AimPart}, Callback = function(v) S.AimPart = v[1] end })
    createToggle(page, { Name = "Aim Prediction (Lead Targets)", CurrentValue = S.AimPredict, Callback = function(v) S.AimPredict = v; notifyToggle("Aim Prediction", v) end })
    createSlider(page, { Name = "Prediction Strength", Range = {1, 30}, Increment = 1, CurrentValue = 12, Callback = function(v) S.AimPredictStr = v / 100 end })

    createSection(page, "-- Aimlock (FOV Circle) --")
    createToggle(page, { Name = "Show FOV Circle", CurrentValue = S.FOV_Show, Callback = function(v) S.FOV_Show = v end })
    createToggle(page, { Name = "FOV Lock (Only Aim Inside Circle)", CurrentValue = S.FOV_Lock, Callback = function(v) S.FOV_Lock = v; notifyToggle("FOV Lock", v) end })
    createSlider(page, { Name = "FOV Radius (px)", Range = {40, 400}, Increment = 10, CurrentValue = S.FOV_Radius, Callback = function(v) S.FOV_Radius = v end })

    createSection(page, "Silent Aim")
    createToggle(page, { Name = "Silent Aim (1-frame snap)", CurrentValue = S.SilentAim, Callback = function(v) S.SilentAim = v; notifyToggle("Silent Aim", v) end })

    createSection(page, "Auto Fire")
    createToggle(page, { Name = "TriggerBot (Auto Fire on Hit)", CurrentValue = S.TriggerBot, Callback = function(v) S.TriggerBot = v; notifyToggle("TriggerBot", v) end })
    createToggle(page, { Name = "Kill Aura (Fire Nearby)", CurrentValue = S.KillAura, Callback = function(v) S.KillAura = v; notifyToggle("Kill Aura", v) end })
    createSlider(page, { Name = "Kill Aura Range (m)", Range = {10, 80}, Increment = 5, CurrentValue = S.KillAuraRange, Callback = function(v) S.KillAuraRange = v end })

    createSection(page, "Hitbox")
    createToggle(page, { Name = "Hitbox Expand", CurrentValue = S.Hitbox, Callback = function(v)
        S.Hitbox = v; notifyToggle("Hitbox Expand", v)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then applyHitbox(p) end
        end
    end})
    createSlider(page, { Name = "Hitbox Scale", Range = {1, 8}, Increment = 1, CurrentValue = S.HitboxScale, Callback = function(v)
        S.HitboxScale = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then applyHitbox(p) end
        end
    end})
end

--------------------------------------------------------------------------------
-- TAB 3: VISUALS
--------------------------------------------------------------------------------
do
    local page = tabPages["Visuals"]

    createSection(page, "Wallhack")
    createToggle(page, { Name = "Wallhack (Highlight Through Walls)", CurrentValue = S.Wallhack, Callback = function(v)
        S.Wallhack = v; notifyToggle("Wallhack", v)
        for _, pool in pairs(ESPPool) do
            if pool.highlight then pool.highlight.Enabled = v end
        end
    end})

    createSection(page, "-- ESP (Amethyst-Colored Outlines) --")
    createToggle(page, { Name = "Box ESP", CurrentValue = S.ESP_Box, Callback = function(v) S.ESP_Box = v; notifyToggle("Box ESP", v) end })
    createToggle(page, { Name = "Name Tags", CurrentValue = S.ESP_Name, Callback = function(v) S.ESP_Name = v; notifyToggle("Name Tags", v) end })
    createToggle(page, { Name = "Health Bars", CurrentValue = S.ESP_Health, Callback = function(v) S.ESP_Health = v; notifyToggle("Health Bars", v) end })
    createToggle(page, { Name = "Skeleton", CurrentValue = S.ESP_Skeleton, Callback = function(v) S.ESP_Skeleton = v; notifyToggle("Skeleton", v) end })
    createToggle(page, { Name = "Tracers (Amethyst)", CurrentValue = S.ESP_Tracer, Callback = function(v) S.ESP_Tracer = v; notifyToggle("Tracers", v) end })
    createToggle(page, { Name = "Distance Tags", CurrentValue = S.ESP_Distance, Callback = function(v) S.ESP_Distance = v; notifyToggle("Distance Tags", v) end })
    createToggle(page, { Name = "Visible Check (Hide Behind Walls)", CurrentValue = S.VisCheck, Callback = function(v) S.VisCheck = v; notifyToggle("VisCheck", v) end })

    createSection(page, "Color")
    createColorPicker(page, { Name = "ESP Color", Color = S.ESPColor, Callback = function(c)
        S.ESPColor = c
        -- Update existing ESP
        for _, pool in pairs(ESPPool) do
            pool.box.Color = c
            for _, b in ipairs(pool.bones) do b.Color = c end
            pool.radarDot.Color = c
            if pool.highlight then pool.highlight.FillColor = c end
        end
    end})

    createSection(page, "Crosshair")
    createToggle(page, { Name = "Crosshair", CurrentValue = S.Crosshair, Callback = function(v) S.Crosshair = v end })
    createSlider(page, { Name = "Line Length", Range = {4, 20}, Increment = 1, CurrentValue = S.XH_Size, Callback = function(v) S.XH_Size = v end })
    createSlider(page, { Name = "Gap", Range = {0, 10}, Increment = 1, CurrentValue = S.XH_Gap, Callback = function(v) S.XH_Gap = v end })

    createSection(page, "Fullbright")
    createToggle(page, { Name = "Fullbright (No Darkness)", CurrentValue = S.Fullbright, Callback = function(v)
        S.Fullbright = v; notifyToggle("Fullbright", v)
        applyFullbright(v)
    end})

    createSection(page, "Alert")
    createToggle(page, { Name = "Enemy Proximity Alert", CurrentValue = S.EnemyAlert, Callback = function(v) S.EnemyAlert = v; notifyToggle("Enemy Alert", v) end })
    createSlider(page, { Name = "Alert Distance (m)", Range = {15, 80}, Increment = 5, CurrentValue = S.EnemyAlertDist, Callback = function(v) S.EnemyAlertDist = v end })

    createSection(page, "Radar")
    createToggle(page, { Name = "Radar", CurrentValue = S.Radar, Callback = function(v) S.Radar = v; notifyToggle("Radar", v) end })
    createSlider(page, { Name = "Radar Range (m)", Range = {40, 300}, Increment = 10, CurrentValue = S.RadarRange, Callback = function(v) S.RadarRange = v end })
    createSlider(page, { Name = "Radar Size (px)", Range = {80, 200}, Increment = 10, CurrentValue = S.RadarSize, Callback = function(v) S.RadarSize = v end })

    createSection(page, "HUD")
    createToggle(page, { Name = "Player / Bot Counter", CurrentValue = S.PlayerBotHUD, Callback = function(v) S.PlayerBotHUD = v; notifyToggle("Player/Bot HUD", v) end })
    createToggle(page, { Name = "Kill / Death Counter", CurrentValue = S.KillCounter, Callback = function(v) S.KillCounter = v; notifyToggle("Kill Counter", v) end })
end

--------------------------------------------------------------------------------
-- TAB 4: GAMEPLAY
--------------------------------------------------------------------------------
do
    local page = tabPages["Gameplay"]

    createSection(page, "Weapon Modifiers")
    createToggle(page, { Name = "No Recoil", CurrentValue = S.NoRecoil, Callback = function(v) S.NoRecoil = v; notifyToggle("No Recoil", v) end })
    createToggle(page, { Name = "No Spread", CurrentValue = S.NoSpread, Callback = function(v) S.NoSpread = v; notifyToggle("No Spread", v) end })
    createToggle(page, { Name = "Fast Reload", CurrentValue = S.FastReload, Callback = function(v) S.FastReload = v; notifyToggle("Fast Reload", v) end })
    createToggle(page, { Name = "Infinite Ammo", CurrentValue = S.InfAmmo, Callback = function(v) S.InfAmmo = v; notifyToggle("Infinite Ammo", v) end })

    createSection(page, "Speed")
    createToggle(page, { Name = "Speed Boost", CurrentValue = S.Speed, Callback = function(v) S.Speed = v; notifyToggle("Speed Boost", v) end })
    createSlider(page, { Name = "Speed Value", Range = {16, 200}, Increment = 2, CurrentValue = S.SpeedVal, Callback = function(v) S.SpeedVal = v end })

    createSection(page, "Jump")
    createToggle(page, { Name = "Jump Boost", CurrentValue = S.Jump, Callback = function(v) S.Jump = v; notifyToggle("Jump Boost", v) end })
    createSlider(page, { Name = "Jump Power", Range = {50, 250}, Increment = 5, CurrentValue = S.JumpVal, Callback = function(v) S.JumpVal = v end })
    createToggle(page, { Name = "Infinite Jump", CurrentValue = S.InfJump, Callback = function(v) S.InfJump = v; notifyToggle("Infinite Jump", v) end })
    createToggle(page, { Name = "Auto Strafe", CurrentValue = S.AutoStrafe, Callback = function(v) S.AutoStrafe = v; notifyToggle("Auto Strafe", v) end })
    createToggle(page, { Name = "No Fall Damage", CurrentValue = S.NoFallDmg, Callback = function(v) S.NoFallDmg = v; notifyToggle("No Fall Damage", v) end })

    createSection(page, "Respawn")
    createToggle(page, { Name = "Fast Respawn", CurrentValue = S.FastRespawn, Callback = function(v) S.FastRespawn = v; notifyToggle("Fast Respawn", v) end })

    createSection(page, "Mobile Tools")
    createSlider(page, { Name = "Jump Button Scale (1x to 3x)", Range = {1, 3}, Increment = 0.5, CurrentValue = S.JumpScale, Callback = function(v)
        S.JumpScale = v
        _safeCall(function()
            local jb = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
            if jb then
                local jumpBtn = jb:FindFirstChild("TouchControlFrame") and jb.TouchControlFrame:FindFirstChild("JumpButton")
                if jumpBtn then
                    jumpBtn.Size = UDim2.new(0, 70 * v, 0, 70 * v)
                end
            end
        end)
    end})

    createSection(page, "Fly")
    createToggle(page, { Name = "Fly", CurrentValue = S.Fly, Callback = function(v)
        S.Fly = v; notifyToggle("Fly", v)
        if v then startFly() else stopFly() end
    end})
    createSlider(page, { Name = "Fly Speed", Range = {10, 200}, Increment = 10, CurrentValue = S.FlySpeed, Callback = function(v) S.FlySpeed = v end })

    createSection(page, "Noclip")
    createToggle(page, { Name = "Noclip (Walk Through Walls)", CurrentValue = S.Noclip, Callback = function(v)
        S.Noclip = v; notifyToggle("Noclip", v)
        if v then enableNoclip() else disableNoclip() end
    end})

    createSection(page, "God Mode")
    createToggle(page, { Name = "God Mode (Client-Side)", CurrentValue = S.GodMode, Callback = function(v)
        S.GodMode = v; notifyToggle("God Mode", v)
        if v then enableGodMode() else disableGodMode() end
    end})

    createSection(page, "Teleport")
    local teleportTarget = ""
    createInput(page, { Name = "Player Name", PlaceholderText = "Enter name...", RemoveTextAfterFocusLost = false, Callback = function(t) teleportTarget = t end })
    createButton(page, { Name = "Teleport to Player", Callback = function()
        _safeCall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and (string.lower(p.Name):find(string.lower(teleportTarget)) or string.lower(p.DisplayName):find(string.lower(teleportTarget))) then
                    local pc = PartCache[p]
                    if pc and pc.root then
                        root.CFrame = pc.root.CFrame + Vector3.new(0, 3, 0)
                        notify("Teleport", "Teleported to " .. p.DisplayName, 3)
                        return
                    end
                end
            end
            notify("Teleport", "Player not found!", 3)
        end)
    end})
    createButton(page, { Name = "Teleport to Nearest Player", Callback = function()
        _safeCall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local closest, closeDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local pc = PartCache[p]
                    if pc and pc.root then
                        local d = (pc.root.Position - root.Position).Magnitude
                        if d < closeDist then closeDist = d; closest = p end
                    end
                end
            end
            if closest and PartCache[closest] then
                root.CFrame = PartCache[closest].root.CFrame + Vector3.new(0, 3, 0)
                notify("Teleport", "Teleported to " .. closest.DisplayName, 3)
            else
                notify("Teleport", "No player found!", 3)
            end
        end)
    end})
end

--------------------------------------------------------------------------------
-- TAB 5: PERFORMANCE
--------------------------------------------------------------------------------
do
    local page = tabPages["Performance"]

    createSection(page, "-- Omega AntiLag Engine --")
    createLabel(page, "Smart filter protects DamageBrick, Lava, Kill parts.")
    createToggle(page, { Name = "Omega FPS Boost (SmoothPlastic + No Shadows)", CurrentValue = S.FPSBoost, Callback = function(v)
        S.FPSBoost = v; notifyToggle("Omega FPS Boost", v)
        if v then runOmegaFPS(); enableFPSListener() else disableFPSListener() end
    end})

    createSection(page, "Lighting")
    createToggle(page, { Name = "Lighting Ultra", CurrentValue = S.LightingUltra, Callback = function(v)
        S.LightingUltra = v; notifyToggle("Lighting Ultra", v)
        if v then applyLightingUltra() else restoreLighting() end
    end})

    createSection(page, "Purge")
    createToggle(page, { Name = "Texture Purge", CurrentValue = S.TexturePurge, Callback = function(v)
        S.TexturePurge = v; notifyToggle("Texture Purge", v)
        if v then purgeTextures(); enableTexListener() else disableTexListener() end
    end})
    createToggle(page, { Name = "Particle Purge", CurrentValue = S.ParticlePurge, Callback = function(v)
        S.ParticlePurge = v; notifyToggle("Particle Purge", v)
        if v then purgeParticles() end
    end})
    createToggle(page, { Name = "Simplify Terrain", CurrentValue = S.TerrainSimple, Callback = function(v)
        S.TerrainSimple = v; notifyToggle("Simplify Terrain", v)
        if v then simplifyTerrain() end
    end})

    createSection(page, "Manual Actions")
    createButton(page, { Name = "Destroy All Decals", Callback = function()
        _safeCall(function()
            local count = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                    count = count + 1
                end
            end
            notify("Purge", "Destroyed " .. count .. " decals/textures (irreversible)", 4)
        end)
    end})
    createButton(page, { Name = "Remove SurfaceAppearances", Callback = function()
        _safeCall(function()
            local count = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("SurfaceAppearance") then
                    obj:Destroy()
                    count = count + 1
                end
            end
            notify("Purge", "Removed " .. count .. " SurfaceAppearances", 4)
        end)
    end})
    createButton(page, { Name = "Set Rendering to Level 1", Callback = function()
        local ok = _safeCall(function()
            settings().Rendering.QualityLevel = 1
        end)
        if ok then
            notify("Rendering", "Quality set to Level 1", 3)
        else
            notify("Rendering", "Not supported on this executor", 3)
        end
    end})
end

--------------------------------------------------------------------------------
-- TAB 6: SERVER
--------------------------------------------------------------------------------
do
    local page = tabPages["Server"]
    local serverButtons = {}

    createSection(page, "Find Smallest Server")
    createButton(page, { Name = "Find Smallest and Join", Callback = function()
        notify("Server", "Searching for smallest server...", 3)
        findServers(S.TargetPlaceId, function(servers)
            if #servers > 0 then
                local sv = servers[1]
                notify("Server", "Joining server with " .. (sv.playing or "?") .. " players...", 3)
                _safeCall(function()
                    TeleportService:TeleportToPlaceInstance(S.TargetPlaceId, sv.id, LocalPlayer)
                end)
            else
                notify("Server", "No servers found!", 3)
            end
        end)
    end})
    createButton(page, { Name = "Scan Servers (Preview)", Callback = function()
        notify("Server", "Scanning servers...", 3)
        findServers(S.TargetPlaceId, function(servers)
            S.Utility.ServerList = {}
            for i = 1, math.min(5, #servers) do
                S.Utility.ServerList[i] = servers[i]
            end
            -- Update buttons
            for i = 1, 5 do
                if serverButtons[i] then
                    if S.Utility.ServerList[i] then
                        serverButtons[i].Text = "Server #" .. i .. " (" .. (S.Utility.ServerList[i].playing or "?") .. " players)"
                    else
                        serverButtons[i].Text = "Server #" .. i
                    end
                end
            end
            notify("Servers", "Found " .. #servers .. " servers. Top 5 loaded.", 4)
        end)
    end})

    createSection(page, "Custom Game")
    createInput(page, { Name = "Place ID", PlaceholderText = "Enter Place ID...", RemoveTextAfterFocusLost = false, Callback = function(t)
        local id = tonumber(t)
        if id then S.TargetPlaceId = id end
    end})
    createButton(page, { Name = "Find Smallest in Custom Game", Callback = function()
        notify("Server", "Searching custom game...", 3)
        findServers(S.TargetPlaceId, function(servers)
            if #servers > 0 then
                local sv = servers[1]
                notify("Server", "Joining server with " .. (sv.playing or "?") .. " players...", 3)
                _safeCall(function()
                    TeleportService:TeleportToPlaceInstance(S.TargetPlaceId, sv.id, LocalPlayer)
                end)
            else
                notify("Server", "No servers found!", 3)
            end
        end)
    end})

    createSection(page, "Quick Join (from last scan)")
    for i = 1, 5 do
        local svBtn = createButton(page, { Name = "Server #" .. i, Callback = function()
            local sv = S.Utility.ServerList[i]
            if sv then
                notify("Server", "Joining Server #" .. i .. "...", 3)
                _safeCall(function()
                    TeleportService:TeleportToPlaceInstance(S.TargetPlaceId, sv.id, LocalPlayer)
                end)
            else
                notify("Server", "No data - scan first!", 3)
            end
        end})
        serverButtons[i] = svBtn
    end

    createSection(page, "Hop / Rejoin")
    createButton(page, { Name = "Server Hop (Smallest)", Callback = function()
        notify("Server", "Finding smallest server to hop...", 3)
        findServers(game.PlaceId, function(servers)
            for _, sv in ipairs(servers) do
                if sv.id ~= game.JobId then
                    _safeCall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                    end)
                    return
                end
            end
            notify("Server", "No other servers found!", 3)
        end)
    end})
    createButton(page, { Name = "Rejoin Current Server", Callback = function()
        notify("Server", "Rejoining...", 2)
        _safeCall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end})

    createSection(page, "Auto Hop")
    createToggle(page, { Name = "Auto Hop if Too Many Players", CurrentValue = S.AutoHop, Callback = function(v)
        S.AutoHop = v; notifyToggle("Auto Hop", v)
    end})
    createSlider(page, { Name = "Auto Hop Threshold", Range = {2, 30}, Increment = 1, CurrentValue = S.AutoHopMax, Callback = function(v) S.AutoHopMax = v end })

    createSection(page, "Utility")
    createToggle(page, { Name = "Anti-AFK", CurrentValue = S.AntiAFK, Callback = function(v) S.AntiAFK = v; notifyToggle("Anti-AFK", v) end })
    createToggle(page, { Name = "Silent Mode (No Notifications)", CurrentValue = S.SilentMode, Callback = function(v) S.SilentMode = v end })
    createButton(page, { Name = "Copy Job ID", Callback = function()
        _safeCall(function()
            if setclipboard then
                setclipboard(game.JobId)
                notify("Clipboard", "Job ID copied!", 2)
            else
                notify("Clipboard", "Job ID: " .. game.JobId, 5)
            end
        end)
    end})
    createButton(page, { Name = "Show Player List", Callback = function()
        local playerNames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            playerNames[#playerNames + 1] = p.DisplayName
        end
        notify("Players (" .. #Players:GetPlayers() .. ")", table.concat(playerNames, ", "), 8)
    end})
    createParagraph(page, {
        Title = "Server Info",
        Content = "Place: " .. game.PlaceId .. "\nJob: " .. game.JobId .. "\nPlayers: " .. #Players:GetPlayers()
    })
end

--------------------------------------------------------------------------------
-- TAB 7: CREDITS
--------------------------------------------------------------------------------
do
    local page = tabPages["Credits"]

    createSection(page, "Amethyst Ultimate V4.0")
    createParagraph(page, {
        Title = "Amethyst Ultimate V4.0",
        Content = "32 Feature Systems | 100% Custom UI\nAimbot, Silent Aim, TriggerBot, Kill Aura\nESP (Box, Name, Health, Skeleton, Tracer, Distance)\nWallhack, Crosshair, FOV Circle, Radar\nEnemy Alert, Player/Bot Counter, Kill Tracker\nSpeed, Jump, Fly, Noclip, God Mode\nOmega FPS Boost, Lighting Ultra\nTexture/Particle Purge, Terrain Simplify\nServer Finder, Auto Hop, Anti-AFK\nWeapon Mods (Recoil, Spread, Reload, Ammo)\nConfig Save/Load, Keybind System"
    })

    createSection(page, "Owner")
    createParagraph(page, {
        Title = "Lutfie kenape ek",
        Content = "Script owner and creator."
    })
end

--------------------------------------------------------------------------------
-- PART 10 — WATERMARK
--------------------------------------------------------------------------------
do
    local wmGui = Instance.new("ScreenGui")
    wmGui.Name = "AmethystWatermarkV4"
    wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    wmGui.ResetOnSpawn = false
    _safeCall(function() wmGui.Parent = getGuiParent() end)

    -- Background pill
    local wmBg = Instance.new("Frame", wmGui)
    wmBg.Size = UDim2.new(0, 180, 0, 34)
    wmBg.Position = UDim2.new(1, -190, 1, -44)
    wmBg.BackgroundColor3 = Color3.fromRGB(20, 8, 30)
    wmBg.BackgroundTransparency = 0.3
    wmBg.BorderSizePixel = 0

    local wmCorner = Instance.new("UICorner", wmBg)
    wmCorner.CornerRadius = UDim.new(0, 8)

    local wmStroke = Instance.new("UIStroke", wmBg)
    wmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    wmStroke.Color = THEME.AccentDim
    wmStroke.Thickness = 1.5
    wmStroke.Transparency = 0.4

    -- Glow frame
    local wmGlow = Instance.new("Frame", wmBg)
    wmGlow.Size = UDim2.new(1, 12, 1, 12)
    wmGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    wmGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    wmGlow.BackgroundColor3 = THEME.Accent
    wmGlow.BackgroundTransparency = 0.9
    wmGlow.BorderSizePixel = 0
    wmGlow.ZIndex = 0
    Instance.new("UICorner", wmGlow).CornerRadius = UDim.new(0, 10)

    -- Glow pulse
    TweenService:Create(wmGlow, TI_PULSE, {BackgroundTransparency = 0.7}):Play()

    -- UIGradient on wmBg
    local wmGrad = Instance.new("UIGradient", wmBg)
    wmGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 8, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45, 18, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 8, 40)),
    })

    -- Gradient rotation tween
    TweenService:Create(wmGrad, TweenInfo.new(18, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), {
        Rotation = 360
    }):Play()

    -- Accent bar
    local wmAccent = Instance.new("Frame", wmBg)
    wmAccent.Size = UDim2.new(0, 3, 0.6, 0)
    wmAccent.Position = UDim2.new(0, 8, 0.2, 0)
    wmAccent.BackgroundColor3 = THEME.Accent
    wmAccent.BorderSizePixel = 0
    Instance.new("UICorner", wmAccent).CornerRadius = UDim.new(0, 2)

    -- Accent bar pulse
    TweenService:Create(wmAccent, TI_PULSE, {BackgroundTransparency = 0.5}):Play()

    -- Text
    local wmText = Instance.new("TextLabel", wmBg)
    wmText.Size = UDim2.new(1, -20, 1, 0)
    wmText.Position = UDim2.new(0, 18, 0, 0)
    wmText.BackgroundTransparency = 1
    wmText.Font = Enum.Font.GothamBold
    wmText.TextSize = 15
    wmText.TextColor3 = THEME.Lavender
    wmText.TextTransparency = 0.15
    wmText.Text = "Amethyst | Luyy"
    wmText.TextXAlignment = Enum.TextXAlignment.Left

    -- Text UIStroke
    local wmTextStroke = Instance.new("UIStroke", wmText)
    wmTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    wmTextStroke.Color = THEME.Accent
    wmTextStroke.Thickness = 1.2
    wmTextStroke.Transparency = 0.5

    -- Text stroke pulse
    TweenService:Create(wmTextStroke, TI_PULSE, {Transparency = 0.1}):Play()

    -- wmStroke color breathing
    TweenService:Create(wmStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Color = Color3.fromRGB(140, 75, 210),
        Transparency = 0.1,
    }):Play()

    -- wmText transparency pulse
    TweenService:Create(wmText, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        TextTransparency = 0.25,
    }):Play()
end

--------------------------------------------------------------------------------
-- PART 11 — FLOATING TOGGLE BUTTON
--------------------------------------------------------------------------------
do
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "AmethystToggleV4"
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.ResetOnSpawn = false
    _safeCall(function() toggleGui.Parent = getGuiParent() end)

    local btnSize = IS_MOBILE and 54 or 42

    -- Glow
    local toggleGlow = Instance.new("Frame", toggleGui)
    toggleGlow.Size = UDim2.new(0, btnSize + 12, 0, btnSize + 12)
    toggleGlow.Position = UDim2.new(0, 4, 0.4, -6)
    toggleGlow.AnchorPoint = Vector2.new(0, 0)
    toggleGlow.BackgroundColor3 = THEME.Accent
    toggleGlow.BackgroundTransparency = 0.7
    toggleGlow.BorderSizePixel = 0
    Instance.new("UICorner", toggleGlow).CornerRadius = UDim.new(0.5, 0)

    -- Button
    local toggleBtn = Instance.new("TextButton", toggleGui)
    toggleBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    toggleBtn.Position = UDim2.new(0, 10, 0.4, 0)
    toggleBtn.BackgroundColor3 = THEME.Main
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "\xf0\x9f\x92\x8e"
    toggleBtn.TextSize = IS_MOBILE and 22 or 18
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextColor3 = THEME.Accent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0.5, 0)

    -- Button gradient
    local toggleGrad = Instance.new("UIGradient", toggleBtn)
    toggleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 20, 70)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 40, 140)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 20, 70)),
    })
    toggleGrad.Rotation = 135

    -- Button stroke
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Color = THEME.Accent
    toggleStroke.Thickness = 2

    -- Stroke pulse
    TweenService:Create(toggleStroke, TI_PULSE, {Color = Color3.fromRGB(180, 100, 255)}):Play()

    -- Drag system
    local dragging = false
    local totalDragDist = 0
    local dragStart, startPos

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            totalDragDist = 0  -- Reset on each InputBegan
            dragStart = input.Position
            startPos = toggleBtn.Position
            local glowOffset = Vector2.new(-6, -6)
        end
    end)

    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            totalDragDist = totalDragDist + delta.Magnitude
            toggleBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            toggleGlow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X - 6,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y - 6
            )
            dragStart = input.Position
            startPos = toggleBtn.Position
        end
    end))

    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if totalDragDist > 10 then return end  -- Was a drag, not a click

                -- Click animation
                tweenProp(toggleBtn, {Size = UDim2.new(0, btnSize - 6, 0, btnSize - 6)}, TI_FAST)
                task.delay(0.15, function()
                    tweenProp(toggleBtn, {Size = UDim2.new(0, btnSize, 0, btnSize)}, TI_BOUNCE)
                end)

                -- Toggle hub visibility
                if hubVisible then
                    hubVisible = false
                    tweenProp(mainFrame, {BackgroundTransparency = 1}, TI_SMOOTH)
                    task.delay(0.2, function() mainFrame.Visible = false end)
                    -- Visual: hidden state
                    tweenProp(toggleBtn, {BackgroundColor3 = Color3.fromRGB(30, 12, 45)}, TI_SMOOTH)
                    tweenProp(toggleGlow, {BackgroundTransparency = 0.95}, TI_SMOOTH)
                    toggleStroke.Color = THEME.AccentDim
                else
                    hubVisible = true
                    mainFrame.Visible = true
                    mainFrame.BackgroundTransparency = 0
                    tweenProp(mainFrame, {BackgroundTransparency = 0}, TI_SMOOTH)
                    if isMinimized then
                        mainFrame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 36)
                    else
                        mainFrame.Size = originalSize
                    end
                    -- Visual: shown state
                    tweenProp(toggleBtn, {BackgroundColor3 = THEME.Main}, TI_SMOOTH)
                    tweenProp(toggleGlow, {BackgroundTransparency = 0.7}, TI_SMOOTH)
                    toggleStroke.Color = THEME.Accent
                end
            end
        end
    end))
end

-- Keybind: RightShift toggles hub [V4 NEW]
track(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if hubVisible then
            hubVisible = false
            tweenProp(mainFrame, {BackgroundTransparency = 1}, TI_SMOOTH)
            task.delay(0.2, function() mainFrame.Visible = false end)
        else
            hubVisible = true
            mainFrame.Visible = true
            mainFrame.BackgroundTransparency = 0
            if isMinimized then
                mainFrame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 36)
            else
                mainFrame.Size = originalSize
            end
        end
    end
end))

--------------------------------------------------------------------------------
-- PART 14 — CHARACTER HOOKS
--------------------------------------------------------------------------------

local function hookCharacterModLoop(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    -- WalkSpeed persistence
    track(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if S.Speed then hum.WalkSpeed = S.SpeedVal end
    end))

    -- JumpPower persistence
    track(hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if S.Jump then hum.JumpPower = S.JumpVal end
    end))

    -- UseJumpPower persistence
    track(hum:GetPropertyChangedSignal("UseJumpPower"):Connect(function()
        if S.Jump then hum.UseJumpPower = true end
    end))
end

local function onCharAdded(player, char)
    -- Race condition fix: wait for character to be in workspace
    if not char:IsDescendantOf(workspace) then
        char.AncestryChanged:Wait()
        if not char:IsDescendantOf(workspace) then return end
    end

    task.wait(_G.Config.CacheBuildDelay)

    buildPartCache(player)

    if not ESPPool[player] and player ~= LocalPlayer then
        createESP(player)
    end

    -- Refresh highlight
    if ESPPool[player] then
        if ESPPool[player].highlight then
            _safeCall(function() ESPPool[player].highlight:Destroy() end)
        end
        ESPPool[player].highlight = makeHighlight(char)
    end

    -- Local player specific hooks
    if player == LocalPlayer then
        hookCharacterModLoop(char)

        -- Hook silent aim on tools
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then hookSilentAim(tool) end
        end
        track(char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then hookSilentAim(child) end
        end))

        -- Disable ragdoll states
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            _safeCall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end)
        end

        -- Fast Respawn
        if S.FastRespawn then
            task.delay(0.5, function()
                _safeCall(function()
                    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if pg then
                        local btnNames = {"Respawn", "RespawnButton", "PlayAgain", "DeployButton"}
                        for _, gui in ipairs(pg:GetDescendants()) do
                            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                                for _, name in ipairs(btnNames) do
                                    if gui.Name == name then
                                        _safeCall(function() gui:Activate() end)
                                        return
                                    end
                                end
                            end
                        end
                    end
                end)
            end)
        end

        -- Re-start fly if was flying
        if S.Fly then
            task.delay(1.5, function()
                if S.Fly then startFly() end
            end)
        end
    end

    -- Hitbox apply after delay
    if player ~= LocalPlayer then
        task.delay(0.5, function()
            applyHitbox(player)
        end)
    end
end

-- Hook existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            task.spawn(function() onCharAdded(player, player.Character) end)
        end
        track(player.CharacterAdded:Connect(function(char)
            onCharAdded(player, char)
        end))
    end
end

-- Hook new players
track(Players.PlayerAdded:Connect(function(player)
    if player.Character then
        task.spawn(function() onCharAdded(player, player.Character) end)
    end
    track(player.CharacterAdded:Connect(function(char)
        onCharAdded(player, char)
    end))
end))

-- LocalPlayer character hooks
if LocalPlayer.Character then
    task.spawn(function() onCharAdded(LocalPlayer, LocalPlayer.Character) end)
end
track(LocalPlayer.CharacterAdded:Connect(function(char)
    onCharAdded(LocalPlayer, char)
end))

-- LocalPlayer death tracking
track(LocalPlayer.CharacterRemoving:Connect(function()
    SessionDeaths = SessionDeaths + 1
    if isFlying then stopFly() end
end))

-- Player removing cleanup (for OTHER players)
track(Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    PartCache[player] = nil
    headOrigSizes[player] = nil
    trackedHP[player] = nil
    -- V4: only clear weaponCache for this player's tools
    _safeCall(function()
        if player.Character then
            for _, tool in ipairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    weaponCache[tool] = nil
                end
            end
        end
    end)
end))

--------------------------------------------------------------------------------
-- PART 14 — CONSOLIDATED HEARTBEAT
--------------------------------------------------------------------------------
local lastAntiAFK = 0
local lastAutoHop = 0
local lastTriggerBot = 0
local lastWeaponMod = 0

track(RunService.Heartbeat:Connect(function(dt)
    local now = os.clock()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- [1] WalkSpeed / JumpPower persistence
    if S.Speed then
        hum.WalkSpeed = S.SpeedVal
    end
    if S.Jump then
        hum.UseJumpPower = true
        hum.JumpPower = S.JumpVal
    end

    -- [2] Auto Strafe
    if S.AutoStrafe and S.Speed then
        local vel = root.AssemblyLinearVelocity
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local strafeSpeed = S.SpeedVal * 0.6
            local newVel = Vector3.new(moveDir.X * strafeSpeed, vel.Y, moveDir.Z * strafeSpeed)
            root.AssemblyLinearVelocity = newVel
        end
    end

    -- [3] No Fall Damage
    if S.NoFallDmg then
        local vel = root.AssemblyLinearVelocity
        if vel.Y < -80 then
            root.AssemblyLinearVelocity = Vector3.new(vel.X, -80, vel.Z)
        end
    end

    -- [4] TriggerBot
    if S.TriggerBot and now - lastTriggerBot > 0.1 then
        lastTriggerBot = now
        _safeCall(function()
            local vp = Camera.ViewportSize
            local ray = Camera:ScreenPointToRay(vp.X * 0.5, vp.Y * 0.5)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {char}
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            if result and result.Instance then
                local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
                if hitModel then
                    local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
                    if hitPlayer and hitPlayer ~= LocalPlayer then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end)
    end

    -- [5] Kill Aura
    doKillAura(now)

    -- [6] Weapon Mods
    if now - lastWeaponMod > _G.Config.WeaponScanInterval then
        lastWeaponMod = now
        if S.NoRecoil or S.NoSpread or S.FastReload or S.InfAmmo then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    applyWeaponMods(tool)
                end
            end
        end
    end

    -- [7] Anti-AFK
    if S.AntiAFK and now - lastAntiAFK > _G.Config.AntiAFKInterval then
        lastAntiAFK = now
        _safeCall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end

    -- [8] Auto Hop
    if S.AutoHop and now - lastAutoHop > _G.Config.AutoHopInterval then
        lastAutoHop = now
        if #Players:GetPlayers() > S.AutoHopMax then
            findServers(game.PlaceId, function(servers)
                for _, sv in ipairs(servers) do
                    if sv.id ~= game.JobId and sv.playing and sv.playing < S.AutoHopMax then
                        _safeCall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                        end)
                        return
                    end
                end
            end)
        end
    end

    -- Track HP for kill counter
    if S.KillCounter then trackPlayerHP() end

    -- Config auto-save (every 30s)
    if math.floor(now) % 30 == 0 then
        task.defer(saveConfig)
    end
end))

--------------------------------------------------------------------------------
-- PART 14 — MAIN RENDERSTEPPED
--------------------------------------------------------------------------------
track(RunService.RenderStepped:Connect(function(delta)
    local now = os.clock()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Speed CFrame supplement for values > 100
    if S.Speed and root and hum and S.SpeedVal > 100 then
        local extra = (S.SpeedVal - 100) * delta * 0.5
        if hum.MoveDirection.Magnitude > 0.1 then
            root.CFrame = root.CFrame + (hum.MoveDirection * extra)
        end
    end

    -- Fly update
    if isFlying then updateFly() end

    -- ESP update (throttled to 60fps)
    updateESP(now)

    -- Aimbot (Camera.CFrame lerp)
    if S.Aimbot then
        _safeCall(function()
            local target = getClosestEnemy(now)
            if target then
                local pc = PartCache[target]
                if pc then
                    local aimPart = S.AimPart == "Torso" and pc.torso or pc.head
                    if aimPart then
                        local aimPos = aimPart.Position

                        -- Prediction
                        if S.AimPredict and pc.root then
                            local vel = pc.root.AssemblyLinearVelocity
                            if vel.Magnitude > _G.Config.AimPredictVelMin then
                                aimPos = aimPos + vel * S.AimPredictStr
                            end
                        end

                        -- Humanization
                        local hum_offset = _G.Config.AimHumanization
                        aimPos = aimPos + Vector3.new(
                            (math.random() - 0.5) * hum_offset,
                            (math.random() - 0.5) * hum_offset,
                            (math.random() - 0.5) * hum_offset
                        )

                        -- Delta-time corrected smoothing [V4]
                        local factor = 1 - (1 - 1/S.AimbotSmooth)^(delta * 60)
                        local targetCF = CFrame.lookAt(Camera.CFrame.Position, aimPos)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCF, factor)
                    end
                end
            end
        end)
    end

    -- Crosshair
    if S.Crosshair then updateCrosshair() end

    -- FOV Circle
    if S.FOV_Show then
        local vp = Camera.ViewportSize
        fovCircle.Position = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
        fovCircle.Radius = S.FOV_Radius
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end

    -- Radar
    updateRadar(now)

    -- Enemy Alert
    updateEnemyAlert(now)

    -- HUD Counters
    updatePlayerBotHUD(now)
    updateKillCounter(now)
end))

--------------------------------------------------------------------------------
-- INFINITE JUMP HANDLER
--------------------------------------------------------------------------------
track(UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        _safeCall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end))

--------------------------------------------------------------------------------
-- BACKGROUND TASKS
--------------------------------------------------------------------------------

-- Anti-AFK VirtualUser
_safeCall(function()
    local VirtualUser = game:GetService("VirtualUser")
    if VirtualUser then
        track(LocalPlayer.Idled:Connect(function()
            _safeCall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end))
    end
end)

-- TeleportInitFailed retry
track(TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
    if player == LocalPlayer then
        warn("[Amethyst V4] Teleport failed: " .. tostring(errorMessage) .. " — retrying in 3s")
        task.delay(3, function()
            _safeCall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end)
    end
end))

--------------------------------------------------------------------------------
-- CLEANUP REGISTRATION
--------------------------------------------------------------------------------
_G.__AmethystCleanup = cleanupAll

--------------------------------------------------------------------------------
-- LOADED NOTIFICATION
--------------------------------------------------------------------------------
task.delay(2.8, function()
    notify("Amethyst V4.0", "Loaded successfully! " .. (IS_MOBILE and "(Mobile)" or "(Desktop)") .. "\nPress RightShift or tap toggle button to show/hide.", 5)
end)

-- Print loaded message
warn([[
+====================================================================+
|       [*]  A M E T H Y S T   U L T I M A T E   V 4 . 0  [*]      |
|       Loaded Successfully                                          |
|       100% Custom UI — Zero External Dependencies                  |
+====================================================================+
]])
