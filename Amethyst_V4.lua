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

-- ============================================================
-- PART 2 — CENTRAL CONFIG
-- ============================================================

_G.Config = {
    Version            = "4.0.0",
    ESPThrottle        = 1/60,       -- ~16ms, max 60 FPS
    SkeletonThrottle   = 1/30,       -- ~33ms, max 30 FPS
    AimRefreshInterval = 0.15,       -- Target refresh rate
    KillAuraCooldown   = 0.2,
    WeaponScanInterval = 0.2,
    AimPredictVelMin   = 5,          -- minimum velocity for prediction
    AimHumanization    = 0.5,        -- randomization (studs)
    AutoHopInterval    = 15,
    AntiAFKInterval    = 55,
    CacheBuildDelay    = 0.5,
}

-- ============================================================
-- PART 3 — CONNECTION TRACKING + DRAWING CLEANUP
-- ============================================================

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

-- ============================================================
-- PART 4 — THEME CONSTANTS (Deep Amethyst Purple)
-- ============================================================

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

    -- UI component colors (unified — formerly UI_COLORS)
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

-- ============================================================
-- PART 5 — TWEEN PRESETS
-- ============================================================

local TI_SMOOTH = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_FAST   = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_PULSE  = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local TI_BOUNCE = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tweenProp(obj, props, tweenInfo)
    _safeCall(function()
        TweenService:Create(obj, tweenInfo or TI_SMOOTH, props):Play()
    end)
end

-- ============================================================
-- PART 6 — DRAWING LIBRARY POLYFILL
-- ============================================================

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

-- ============================================================
-- PART 7 — MOBILE DETECTION
-- ============================================================

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================
-- PART 8 — STATE TABLE
-- ============================================================

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

-- ============================================================
-- HELPERS — notify, notifyToggle, debounced
-- ============================================================

local _notifyImpl -- forward declaration, set by UI framework later

local function notify(title, content, dur)
    if S.SilentMode then return end
    if _notifyImpl then
        _notifyImpl(title, content, dur)
    end
end

local function notifyToggle(name, state)
    notify(
        name .. (state and " ON" or " OFF"),
        state and "Enabled" or "Disabled",
        3
    )
end

local _toggleDebounce = {}
local function debounced(name, callback)
    return function(v)
        local now = os.clock()
        if _toggleDebounce[name] and now - _toggleDebounce[name] < 0.3 then return end
        _toggleDebounce[name] = now
        callback(v)
    end
end

-- ============================================================
-- safeHttpGet
-- ============================================================

local function safeHttpGet(url)
    local ok, res = _safeCall(function() return game:HttpGet(url) end)
    if ok and res and res ~= "" then return res end
    ok, res = _safeCall(function()
        if request then return request({Url = url, Method = "GET"}).Body end
    end)
    if ok and res and res ~= "" then return res end
    ok, res = _safeCall(function()
        if http_request then return http_request({Url = url, Method = "GET"}).Body end
    end)
    if ok and res and res ~= "" then return res end
    return nil
end

-- ============================================================
-- [V4 NEW] Config Save/Load (writefile/readfile JSON)
-- ============================================================

local CONFIG_FILE = "AmethystV4_Config.json"

local function saveConfig()
    _safeCall(function()
        if not writefile then return end
        local data = {}
        for cat, tbl in pairs({Combat = S.Combat, Visuals = S.Visuals, Movement = S.Movement, Utility = S.Utility}) do
            data[cat] = {}
            for k, v in pairs(tbl) do
                if type(v) ~= "table" and type(v) ~= "function" then
                    if typeof(v) == "Color3" then
                        data[cat][k] = {R = v.R, G = v.G, B = v.B, _type = "Color3"}
                    else
                        data[cat][k] = v
                    end
                end
            end
        end
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    _safeCall(function()
        if not readfile or not isfile then return end
        if not isfile(CONFIG_FILE) then return end
        local raw = readfile(CONFIG_FILE)
        if not raw or raw == "" then return end
        local ok, data = _safeCall(function() return HttpService:JSONDecode(raw) end)
        if not ok or not data then return end
        for cat, tbl in pairs(data) do
            local target = S[cat]
            if target and type(target) == "table" then
                for k, v in pairs(tbl) do
                    if type(v) == "table" and v._type == "Color3" then
                        target[k] = Color3.new(v.R, v.G, v.B)
                    elseif rawget(target, k) ~= nil then
                        target[k] = v
                    end
                end
            end
        end
    end)
end

loadConfig()
-- ============================================================

-- Forward declarations for feature systems
local buildPartCache, applyHitbox, applyAllHitboxes, runOmegaFPS, enableFPSListener, disableFPSListener, applyLightingUltra, restoreLighting
local purgeTextures, enableTexListener, disableTexListener, purgeParticles, simplifyTerrain, applyFullbright, makeHighlight, createESP
local removeESP, hideESP, updateCrosshair, updateFOV, updateEnemyAlert, updateRadar, updateHUDs, getClosestEnemy
local applyWeaponMods, fetchSmallestServers, teleportToServer, findSmallestAndJoin, hookSilentAim, scaleJumpButton, startFly, stopFly
local enableNoclip, disableNoclip, enableGodMode, disableGodMode, updateKillAura, teleportToPlayer, teleportToNearest, refreshVP
local updateESP

local PartCache, headOrigSizes, ESPPool, trackedHP, weaponCache, serverFetching, lastVP, bottomCenter
local SessionKills, SessionDeaths, healthColor, simplifyPart, isDangerPart, matProcessed, fpsBoostConn, texPurgeConn
local savedLighting, BONES_R6, BONES_R15, MAX_BONES, kaActivateCooldown, _jumpOrigSizes, flyActive, flyBodyVelocity
local flyBodyGyro, flyConn, noclipConn, xhLines, fovCircle, alertCircle, alertText, radarBg
local radarBorder, radarCross1, radarCross2, radarDotSelf, hudPBg, hudBBg, hudPTxt, hudBTxt
local killBg, killTxt, hudThrottle, IsVisible, _espThrottle

do -- FEATURE SYSTEMS SCOPE
-- 12A — BONE DEFINITIONS (Skeleton ESP)
-- ============================================================
BONES_R6 = {
    {"Head","Torso"},
    {"Torso","Left Arm"},  {"Torso","Right Arm"},
    {"Torso","Left Leg"},  {"Torso","Right Leg"},
}
BONES_R15 = {
    {"Head","UpperTorso"},
    {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},  {"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"},
    {"LowerTorso","LeftUpperLeg"},  {"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"},
}
MAX_BONES = #BONES_R15

-- ============================================================
-- 12B — PART CACHE (zero FindFirstChild in render loop)
-- ============================================================
PartCache = {}

function buildPartCache(player)
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

-- ============================================================
-- 12C — HITBOX SYSTEM
-- ============================================================
headOrigSizes = {}

function applyHitbox(player)
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

function applyAllHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then applyHitbox(p) end
    end
end

-- ============================================================
-- 12D — SMART PART FILTER (DANGER_WORDS exact)
-- ============================================================
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
    if c.R > 0.7 and c.G < 0.3 and c.B < 0.3 then return true end       -- red
    if c.R > 0.8 and c.G > 0.3 and c.G < 0.6 and c.B < 0.2 then return true end  -- orange
    return false
end

-- ============================================================
-- 12E — OMEGA FPS, LIGHTING, TEXTURE/PARTICLE/TERRAIN
-- ============================================================
matProcessed = {}
fpsBoostConn = nil

local function simplifyPart(part)
    if not part:IsA("BasePart") then return end
    if matProcessed[part] then return end
    if isDangerPart(part) then return end
    _safeCall(function()
        part.Material = Enum.Material.SmoothPlastic
        part.Reflectance = 0
        part.CastShadow = false
    end)
    matProcessed[part] = true
end

function runOmegaFPS()
    local count = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if S.FPSBoost then
            _safeCall(function()
                simplifyPart(d)
                count = count + 1
            end)
        end
    end
    return count
end

function enableFPSListener()
    if fpsBoostConn then return end
    fpsBoostConn = workspace.DescendantAdded:Connect(function(d)
        if S.FPSBoost and d:IsA("BasePart") then
            task.defer(function() _safeCall(function() simplifyPart(d) end) end)
        end
    end)
end

function disableFPSListener()
    if fpsBoostConn then fpsBoostConn:Disconnect() fpsBoostConn = nil end
end

-- LIGHTING ULTRA
savedLighting = {}
_safeCall(function()
    savedLighting = {
        GS = Lighting.GlobalShadows,
        BR = Lighting.Brightness,
        FE = Lighting.FogEnd,
        FS = Lighting.FogStart,
        AM = Lighting.Ambient,
        OA = Lighting.OutdoorAmbient,
        CT = Lighting.ClockTime,
    }
end)

function applyLightingUltra()
    _safeCall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(160, 160, 160)
        Lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 160)
        Lighting.ClockTime = 12
        _safeCall(function() Lighting.Technology = Enum.Technology.Compatibility end)
        for _, fx in ipairs(Lighting:GetDescendants()) do
            _safeCall(function()
                if fx:IsA("BloomEffect") or fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect")
                   or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                    fx.Enabled = false
                end
                if fx:IsA("Atmosphere") then
                    fx.Density = 0; fx.Glare = 0; fx.Haze = 0
                end
            end)
        end
    end)
end

function restoreLighting()
    _safeCall(function()
        Lighting.GlobalShadows = savedLighting.GS or true
        Lighting.Brightness = savedLighting.BR or 1
        Lighting.FogEnd = savedLighting.FE or 10000
        Lighting.FogStart = savedLighting.FS or 0
        Lighting.Ambient = savedLighting.AM or Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = savedLighting.OA or Color3.fromRGB(128, 128, 128)
        Lighting.ClockTime = savedLighting.CT or 14
        for _, fx in ipairs(Lighting:GetDescendants()) do
            _safeCall(function()
                if fx:IsA("BloomEffect") or fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect")
                   or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                    fx.Enabled = true
                end
            end)
        end
    end)
end

-- TEXTURE PURGE
texPurgeConn = nil

function purgeTextures()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        _safeCall(function()
            if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1; n = n + 1 end
        end)
    end
    for _, c in ipairs(Lighting:GetChildren()) do
        _safeCall(function() if c:IsA("Sky") then c:Destroy(); n = n + 1 end end)
    end
    return n
end

function enableTexListener()
    if texPurgeConn then return end
    texPurgeConn = workspace.DescendantAdded:Connect(function(d)
        if S.TexturePurge then
            task.defer(function()
                _safeCall(function()
                    if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
                end)
            end)
        end
    end)
end

function disableTexListener()
    if texPurgeConn then texPurgeConn:Disconnect() texPurgeConn = nil end
end

-- PARTICLE PURGE + TERRAIN
function purgeParticles()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        _safeCall(function()
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
               or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                d.Enabled = false; n = n + 1
            end
        end)
    end
    return n
end

function simplifyTerrain()
    _safeCall(function()
        local t = workspace.Terrain
        t.WaterWaveSize = 0; t.WaterWaveSpeed = 0
        t.WaterReflectance = 0; t.WaterTransparency = 0
        t.Decoration = false
    end)
end

-- FULLBRIGHT
function applyFullbright(on)
    _safeCall(function()
        if on then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        else
            restoreLighting()
        end
    end)
end

-- ============================================================
-- 12F — ESP POOL (exact Drawing creation)
-- ============================================================
ESPPool = {}

function makeHighlight(char)
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

function createESP(player)
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

function removeESP(player)
    local esp = ESPPool[player]
    if not esp then return end
    local function rm(o) _safeCall(function() o:Remove() end) end
    rm(esp.box); rm(esp.tracer); rm(esp.distLabel); rm(esp.nameLabel)
    rm(esp.healthBg); rm(esp.healthBar); rm(esp.radarDot)
    for _, b in ipairs(esp.bones) do rm(b) end
    if esp.highlight then _safeCall(function() esp.highlight:Destroy() end) end
    ESPPool[player] = nil
    PartCache[player] = nil
end

function hideESP(esp)
    esp.box.Visible = false; esp.tracer.Visible = false
    esp.distLabel.Visible = false; esp.nameLabel.Visible = false
    esp.healthBg.Visible = false; esp.healthBar.Visible = false
    esp.radarDot.Visible = false
    for _, b in ipairs(esp.bones) do b.Visible = false end
end

-- ============================================================
-- 12G — HEALTH COLOR FORMULA (exact)
-- ============================================================
local function healthColor(pct)
    if pct > 0.5 then
        return Color3.fromRGB(math.floor(255*(1-pct)*2), 255, 0)
    end
    return Color3.fromRGB(255, math.floor(255*pct*2), 0)
end

-- ============================================================
-- 12H — CROSSHAIR (exact)
-- ============================================================
xhLines = {}
for i = 1, 4 do
    local l = trackDrawing(Drawing.new("Line"))
    l.Color = THEME.White; l.Thickness = 1.5; l.Visible = false
    xhLines[i] = l
end

function updateCrosshair()
    if not S.Crosshair then
        for _, l in ipairs(xhLines) do l.Visible = false end
        return
    end
    local cx = Camera.ViewportSize.X * 0.5
    local cy = Camera.ViewportSize.Y * 0.5
    local g, sz = S.XH_Gap, S.XH_Size
    xhLines[1].From = Vector2.new(cx, cy-g-sz); xhLines[1].To = Vector2.new(cx, cy-g)
    xhLines[2].From = Vector2.new(cx, cy+g);    xhLines[2].To = Vector2.new(cx, cy+g+sz)
    xhLines[3].From = Vector2.new(cx-g-sz, cy); xhLines[3].To = Vector2.new(cx-g, cy)
    xhLines[4].From = Vector2.new(cx+g, cy);    xhLines[4].To = Vector2.new(cx+g+sz, cy)
    for _, l in ipairs(xhLines) do l.Visible = true end
end

-- ============================================================
-- 12I — FOV CIRCLE
-- ============================================================
fovCircle = trackDrawing(Drawing.new("Circle"))
fovCircle.Color = THEME.Accent; fovCircle.Thickness = 1.5
fovCircle.Filled = false; fovCircle.Visible = false; fovCircle.NumSides = 64

function updateFOV()
    if not S.FOV_Show then fovCircle.Visible = false return end
    local vp = Camera.ViewportSize
    fovCircle.Position = Vector2.new(vp.X*0.5, vp.Y*0.5)
    fovCircle.Radius = S.FOV_Radius
    fovCircle.Color = THEME.Accent
    fovCircle.Visible = true
end

-- ============================================================
-- 12J — ENEMY ALERT (exact)
-- ============================================================
alertCircle = trackDrawing(Drawing.new("Circle"))
alertCircle.Color = THEME.AlertRed; alertCircle.Thickness = 3
alertCircle.Filled = false; alertCircle.Visible = false; alertCircle.NumSides = 48; alertCircle.Radius = 60

alertText = trackDrawing(Drawing.new("Text"))
alertText.Color = THEME.AlertRed; alertText.Size = 16
alertText.Outline = true; alertText.Center = true
alertText.Text = "ENEMY NEARBY"; alertText.Visible = false

local alertThrottle = 0

function updateEnemyAlert(now)
    if not S.EnemyAlert then
        alertCircle.Visible = false; alertText.Visible = false; return
    end
    if now - alertThrottle < 0.25 then return end
    alertThrottle = now

    local lr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lr then alertCircle.Visible = false; alertText.Visible = false; return end

    local found = false
    local look = lr.CFrame.LookVector
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = PartCache[p]
            if pc and pc.root and pc.hum and pc.hum.Health > 0 then
                local diff = pc.root.Position - lr.Position
                if diff.Magnitude <= S.EnemyAlertDist then
                    local dot = look.X * diff.Unit.X + look.Z * diff.Unit.Z
                    if dot < 0.2 then found = true; break end
                end
            end
        end
    end

    if found then
        local vp = Camera.ViewportSize
        alertCircle.Position = Vector2.new(vp.X*0.5, vp.Y*0.5)
        alertCircle.Radius = 60 + math.sin(now * 8) * 15
        alertCircle.Visible = true
        alertText.Position = Vector2.new(vp.X*0.5, vp.Y*0.5 - 80)
        alertText.Visible = true
    else
        alertCircle.Visible = false; alertText.Visible = false
    end
end

-- ============================================================
-- 12K — RADAR (exact math)
-- ============================================================
radarBg = trackDrawing(Drawing.new("Square"))
radarBg.Filled = true; radarBg.Color = Color3.fromRGB(8, 4, 18); radarBg.Transparency = 0.3

radarBorder = trackDrawing(Drawing.new("Square"))
radarBorder.Filled = false; radarBorder.Color = THEME.ESPColor; radarBorder.Thickness = 1.5

local radarSelf = trackDrawing(Drawing.new("Circle"))
radarSelf.Filled = true; radarSelf.Color = Color3.fromRGB(80, 255, 100); radarSelf.Radius = 4

local radarLabel = trackDrawing(Drawing.new("Text"))
radarLabel.Color = THEME.Accent; radarLabel.Size = 11; radarLabel.Outline = true
radarLabel.Center = true; radarLabel.Text = "RADAR"

local radarThrottle = 0

function updateRadar(now)
    if not S.Radar then
        radarBg.Visible = false; radarBorder.Visible = false
        radarSelf.Visible = false; radarLabel.Visible = false
        for _, esp in pairs(ESPPool) do esp.radarDot.Visible = false end
        return
    end
    if now - radarThrottle < 0.05 then return end
    radarThrottle = now

    local sz = S.RadarSize
    local vp = Camera.ViewportSize
    local rx, ry = vp.X - sz - 10, vp.Y - sz - 10
    local half = sz * 0.5
    local rcx, rcy = rx + half, ry + half

    radarBg.Position = Vector2.new(rx, ry); radarBg.Size = Vector2.new(sz, sz); radarBg.Visible = true
    radarBorder.Position = Vector2.new(rx, ry); radarBorder.Size = Vector2.new(sz, sz)
    radarBorder.Color = THEME.ESPColor; radarBorder.Visible = true
    radarSelf.Position = Vector2.new(rcx, rcy); radarSelf.Visible = true
    radarLabel.Position = Vector2.new(rcx, ry + sz + 2); radarLabel.Visible = true

    local look = Camera.CFrame.LookVector
    local yaw = math.atan2(look.X, look.Z)
    local cosY, sinY = math.cos(-yaw), math.sin(-yaw)
    local lr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for player, esp in pairs(ESPPool) do
        local pc = PartCache[player]
        if not pc or not pc.root or not lr then
            esp.radarDot.Visible = false
        else
            if not pc.hum or pc.hum.Health <= 0 then
                esp.radarDot.Visible = false
            else
                local relX = pc.root.Position.X - lr.Position.X
                local relZ = pc.root.Position.Z - lr.Position.Z
                local dist = math.sqrt(relX*relX + relZ*relZ)
                if dist > S.RadarRange then
                    esp.radarDot.Visible = false
                else
                    local rotX = relX*cosY - relZ*sinY
                    local rotZ = relX*sinY + relZ*cosY
                    local scale = half / S.RadarRange
                    esp.radarDot.Position = Vector2.new(
                        math.clamp(rcx + rotX*scale, rx+4, rx+sz-4),
                        math.clamp(rcy - rotZ*scale, ry+4, ry+sz-4)
                    )
                    esp.radarDot.Color = THEME.ESPColor
                    esp.radarDot.Visible = true
                end
            end
        end
    end
end

-- ============================================================
-- 12L — HUD COUNTERS (exact Drawing properties)
-- ============================================================
local SessionKills, SessionDeaths = 0, 0
trackedHP = {}

hudPBg = trackDrawing(Drawing.new("Square")); hudPBg.Filled = true; hudPBg.Color = Color3.fromRGB(200, 40, 40)
hudBBg = trackDrawing(Drawing.new("Square")); hudBBg.Filled = true; hudBBg.Color = Color3.fromRGB(40, 180, 60)
hudPTxt = trackDrawing(Drawing.new("Text")); hudPTxt.Color = THEME.White; hudPTxt.Size = 15; hudPTxt.Outline = true; hudPTxt.Center = true
hudBTxt = trackDrawing(Drawing.new("Text")); hudBTxt.Color = THEME.White; hudBTxt.Size = 15; hudBTxt.Outline = true; hudBTxt.Center = true
killBg = trackDrawing(Drawing.new("Square")); killBg.Filled = true; killBg.Color = Color3.fromRGB(30, 10, 50)
killTxt = trackDrawing(Drawing.new("Text")); killTxt.Color = Color3.fromRGB(255, 200, 80); killTxt.Size = 14; killTxt.Outline = true; killTxt.Center = true

hudThrottle = 0

function updateHUDs(now)
    if not S.PlayerBotHUD then
        hudPBg.Visible = false; hudBBg.Visible = false
        hudPTxt.Visible = false; hudBTxt.Visible = false
    else
        if now - hudThrottle >= 0.5 then
            hudThrottle = now
            local realCount = #Players:GetPlayers()
            local playerChars = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then playerChars[p.Character] = true end
            end
            local botCount = 0
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and not playerChars[obj] then
                    if obj:FindFirstChildOfClass("Humanoid") then botCount = botCount + 1 end
                end
            end
            local vp = Camera.ViewportSize
            local bW, bH, gap = 56, 26, 6
            local sx = (vp.X - bW*2 - gap) * 0.5
            hudPBg.Position = Vector2.new(sx, 8); hudPBg.Size = Vector2.new(bW, bH); hudPBg.Visible = true
            hudBBg.Position = Vector2.new(sx+bW+gap, 8); hudBBg.Size = Vector2.new(bW, bH); hudBBg.Visible = true
            local cy = 8 + bH*0.5 - 8
            hudPTxt.Text = "P:" .. realCount; hudPTxt.Position = Vector2.new(sx+bW*0.5, cy); hudPTxt.Visible = true
            hudBTxt.Text = "B:" .. botCount; hudBTxt.Position = Vector2.new(sx+bW+gap+bW*0.5, cy); hudBTxt.Visible = true
        end
    end

    if not S.KillCounter then
        killBg.Visible = false; killTxt.Visible = false
    else
        if now - hudThrottle >= 0.4 then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local pc = PartCache[p]
                    if pc and pc.hum then
                        local hp = pc.hum.Health
                        local last = trackedHP[p]
                        if last and last > 0 and hp <= 0 then SessionKills = SessionKills + 1 end
                        trackedHP[p] = hp
                    end
                end
            end
            local vp = Camera.ViewportSize
            killBg.Position = Vector2.new(10, vp.Y - 36); killBg.Size = Vector2.new(120, 26); killBg.Visible = true
            local kd = SessionDeaths > 0 and string.format("%.1f", SessionKills/SessionDeaths) or tostring(SessionKills)
            killTxt.Text = "K:" .. SessionKills .. " D:" .. SessionDeaths .. " R:" .. kd
            killTxt.Position = Vector2.new(70, vp.Y - 31); killTxt.Visible = true
        end
    end
end

-- ============================================================
-- 12M — AIMBOT TARGET CACHE (exact logic)
-- ============================================================
local cachedTarget = nil
local lastTargetRefresh = 0
_G.__AmethystTargetV4 = nil

function getClosestEnemy(now)
    if now - lastTargetRefresh < 0.15 then return cachedTarget end
    lastTargetRefresh = now

    local best, bestDist = nil, math.huge
    local vp = Camera.ViewportSize
    local cx, cy = vp.X*0.5, vp.Y*0.5

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = PartCache[p]
            if pc and pc.hum and pc.head and pc.hum.Health > 0 then
                local skip = false
                if S.VisCheck then
                    local char = p.Character
                    if char then
                        local obs = Camera:GetPartsObscuringTarget({pc.head.Position}, {LocalPlayer.Character, char})
                        if #obs > 0 then skip = true end
                    end
                end
                if not skip then
                    local sp, onScreen = Camera:WorldToViewportPoint(pc.head.Position)
                    if onScreen then
                        local dx, dy = sp.X - cx, sp.Y - cy
                        local d = math.sqrt(dx*dx + dy*dy)
                        if (not S.FOV_Lock or d <= S.FOV_Radius) and d < bestDist then
                            bestDist = d; best = p
                        end
                    end
                end
            end
        end
    end

    cachedTarget = best; _G.__AmethystTargetV4 = best
    return best
end

-- ============================================================
-- 12N — WEAPON MODIFIER (exact cache structure)
-- ============================================================
local weaponThrottle = 0
weaponCache = {} -- [tool] = {recoil, spread, reload, ammo}

function applyWeaponMods(now)
    if now - weaponThrottle < _G.Config.WeaponScanInterval then return end
    weaponThrottle = now
    _safeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end

        -- Build cache on first scan for this tool
        if not weaponCache[tool] then
            local cache = {recoil = {}, spread = {}, reload = {}, ammo = {}}
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("NumberValue") or d:IsA("IntValue") then
                    local n = string.lower(d.Name)
                    if n == "recoil" or n == "kick" or n:find("recoilforce") then
                        cache.recoil[#cache.recoil + 1] = d
                    end
                    if n == "spread" or n == "accuracy" or n:find("bulletspread") then
                        cache.spread[#cache.spread + 1] = d
                    end
                    if n == "reloadtime" or n == "reload" then
                        cache.reload[#cache.reload + 1] = d
                    end
                    if n == "ammo" or n == "currentammo" or n == "magsize" or n == "clipsize" then
                        cache.ammo[#cache.ammo + 1] = d
                    end
                end
            end
            weaponCache[tool] = cache
        end

        local c = weaponCache[tool]
        if S.NoRecoil then for _, d in ipairs(c.recoil) do _safeCall(function() d.Value = 0 end) end end
        if S.NoSpread then for _, d in ipairs(c.spread) do _safeCall(function() d.Value = 0 end) end end
        if S.FastReload then for _, d in ipairs(c.reload) do _safeCall(function() d.Value = 0.05 end) end end
        if S.InfAmmo then for _, d in ipairs(c.ammo) do _safeCall(function() d.Value = math.max(d.Value, 999) end) end end
    end)
end

-- Reusable helper — IsVisible
local function IsVisible(fromChar, targetHead, targetChar)
    if not fromChar or not targetHead then return false end
    local obs = Camera:GetPartsObscuringTarget({targetHead.Position}, {fromChar, targetChar})
    return #obs == 0
end

-- ============================================================
-- 12O — SERVER FINDER (exact API)
-- ============================================================
serverFetching = false

function fetchSmallestServers(placeId, maxPages)
    placeId = placeId or game.PlaceId
    maxPages = maxPages or 5
    serverFetching = true
    local all = {}
    local cursor = ""
    local page = 0

    while page < maxPages do
        page = page + 1
        local url = "https://games.roblox.com/v1/games/" .. tostring(placeId)
            .. "/servers/0?sortOrder=1&excludeFullGames=true&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local raw = safeHttpGet(url)
        if not raw then break end
        local ok, data = _safeCall(function() return HttpService:JSONDecode(raw) end)
        if not ok or not data or not data.data then break end

        for _, sv in ipairs(data.data) do
            if sv.playing and sv.id and sv.id ~= game.JobId and sv.playing > 0 then
                all[#all + 1] = { id = sv.id, playing = sv.playing, maxPlayers = sv.maxPlayers or 0 }
            end
        end

        if data.nextPageCursor and data.nextPageCursor ~= "" then
            cursor = data.nextPageCursor
        else break end
        task.wait(0.4)
    end

    table.sort(all, function(a, b) return a.playing < b.playing end)
    serverFetching = false
    S.ServerList = all
    return all
end

function teleportToServer(placeId, jobId)
    notify("Teleporting...", "Joining " .. string.sub(jobId, 1, 8) .. "...", 4)
    task.wait(0.5)
    local ok, err = _safeCall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)
    if not ok then
        notify("Failed", tostring(err), 4)
        task.wait(2)
        _safeCall(function() TeleportService:TeleportToPlaceInstance(placeId, jobId) end)
    end
end

function findSmallestAndJoin(placeId)
    if serverFetching then notify("Wait", "Already scanning...", 2) return end
    placeId = placeId or game.PlaceId
    notify("Scanning...", "Fetching servers...", 3)
    local list = fetchSmallestServers(placeId)
    if not list or #list == 0 then notify("Error", "No servers found.", 4) return end
    notify("Found " .. #list, "Smallest: " .. list[1].playing .. " players. Joining...", 4)
    task.wait(1)
    teleportToServer(placeId, list[1].id)
end

-- ============================================================
-- 12P — SILENT AIM (exact lerp)
-- ============================================================
function hookSilentAim(tool)
    tool.Activated:Connect(function()
        if not S.SilentAim then return end
        local t = _G.__AmethystTargetV4
        if not t then return end
        local pc = PartCache[t]
        if not pc then return end
        local aim = (S.AimPart == "Torso") and pc.torso or pc.head
        if not aim then return end
        -- Smooth lerp instead of instant snap
        local saved = Camera.CFrame
        Camera.CFrame = saved:Lerp(
            CFrame.new(Camera.CFrame.Position, aim.Position),
            0.85
        )
        task.defer(function() Camera.CFrame = saved end)
    end)
end

-- ============================================================
-- MOBILE JUMP BUTTON SCALE (1x to 3x)
-- ============================================================
_jumpOrigSizes = {}

function scaleJumpButton(mult)
    _safeCall(function()
        local function processJumpButtons(parent)
            if not parent then return end
            for _, d in ipairs(parent:GetDescendants()) do
                _safeCall(function()
                    if string.lower(d.Name):find("jump") and (d:IsA("ImageButton") or d:IsA("TextButton")) then
                        if not _jumpOrigSizes[d] then
                            _jumpOrigSizes[d] = d.Size
                        end
                        local orig = _jumpOrigSizes[d]
                        if orig then
                            d.Size = UDim2.new(
                                orig.X.Scale * mult, orig.X.Offset * mult,
                                orig.Y.Scale * mult, orig.Y.Offset * mult
                            )
                        end
                    end
                end)
            end
        end
        processJumpButtons(LocalPlayer:FindFirstChildOfClass("PlayerGui"))
        _safeCall(function() processJumpButtons(CoreGui:FindFirstChild("TouchGui")) end)
    end)
end

-- ============================================================
-- 12Q — FLY SYSTEM (with V4 CHANGE: Y-zeroed camera-relative vectors)
-- ============================================================
local flyBodyVel, flyBodyGyro
local flyConn
local flyUp, flyDown = false, false
local flyMobileGui = nil

local function createMobileFlyButtons()
    if not IS_MOBILE or flyMobileGui then return end
    _safeCall(function()
        flyMobileGui = Instance.new("ScreenGui")
        flyMobileGui.Name = "AmethystFlyButtons"
        flyMobileGui.ResetOnSpawn = false
        flyMobileGui.DisplayOrder = 1001
        local pgOk = _safeCall(function() flyMobileGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
        if not pgOk then flyMobileGui = nil; return end

        local upBtn = Instance.new("TextButton")
        upBtn.Name = "FlyUp"
        upBtn.Size = UDim2.new(0, 60, 0, 60)
        upBtn.Position = UDim2.new(1, -80, 0.5, -70)
        upBtn.BackgroundColor3 = THEME.Main
        upBtn.BackgroundTransparency = 0.3
        upBtn.TextColor3 = THEME.Accent
        upBtn.Text = "▲"
        upBtn.TextSize = 28
        upBtn.Font = Enum.Font.GothamBold
        upBtn.BorderSizePixel = 0
        upBtn.Parent = flyMobileGui
        Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 10)

        upBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then flyUp = true end
        end)
        upBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then flyUp = false end
        end)

        local downBtn = Instance.new("TextButton")
        downBtn.Name = "FlyDown"
        downBtn.Size = UDim2.new(0, 60, 0, 60)
        downBtn.Position = UDim2.new(1, -80, 0.5, 10)
        downBtn.BackgroundColor3 = THEME.Main
        downBtn.BackgroundTransparency = 0.3
        downBtn.TextColor3 = THEME.Accent
        downBtn.Text = "▼"
        downBtn.TextSize = 28
        downBtn.Font = Enum.Font.GothamBold
        downBtn.BorderSizePixel = 0
        downBtn.Parent = flyMobileGui
        Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 10)

        downBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then flyDown = true end
        end)
        downBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then flyDown = false end
        end)
    end)
end

local function destroyMobileFlyButtons()
    flyUp, flyDown = false, false
    if flyMobileGui then
        _safeCall(function() flyMobileGui:Destroy() end)
        flyMobileGui = nil
    end
end

function startFly()
    _safeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if flyBodyVel then _safeCall(function() flyBodyVel:Destroy() end) end
        if flyBodyGyro then _safeCall(function() flyBodyGyro:Destroy() end) end

        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVel.Velocity = Vector3.new(0, 0, 0)
        flyBodyVel.Parent = root

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyGyro.P = 9e4
        flyBodyGyro.D = 600
        flyBodyGyro.Parent = root

        hum.PlatformStand = true

        -- Create mobile buttons
        createMobileFlyButtons()

        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.RenderStepped:Connect(function()
            if not S.Fly then return end
            _safeCall(function()
                if not root or not root.Parent then
                    _safeCall(function() if flyConn then flyConn:Disconnect(); flyConn = nil end end)
                    return
                end
                local camCF = Camera.CFrame
                flyBodyGyro.CFrame = camCF

                -- [V4 CHANGE] Y-zeroed camera-relative vectors (prevents pitch drift)
                local dir = Vector3.new(0, 0, 0)
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0.1 then
                    local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                    local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
                    dir = flatLook * moveDir.Z * -1 + flatRight * moveDir.X
                    if dir.Magnitude < 0.1 then
                        dir = flatLook * moveDir.Magnitude
                    end
                    dir = dir.Unit
                end

                -- Mobile vs keyboard controls
                local upDown = 0
                if IS_MOBILE then
                    if flyUp then upDown = 1 end
                    if flyDown then upDown = -1 end
                else
                    _safeCall(function()
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then upDown = 1 end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or
                           UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then upDown = -1 end
                    end)
                end
                if hum.Jump then upDown = 1 end

                local finalVel = dir * S.FlySpeed
                finalVel = Vector3.new(finalVel.X, upDown * S.FlySpeed * 0.8, finalVel.Z)
                flyBodyVel.Velocity = finalVel
            end)
        end)
    end)
end

function stopFly()
    _safeCall(function()
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        -- Destroy mobile buttons on stopFly
        destroyMobileFlyButtons()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end)
end

-- ============================================================
-- 12R — NOCLIP (exact)
-- ============================================================
local noclipConn

function enableNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not S.Noclip then return end
        _safeCall(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end)
end

function disableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    _safeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end)
end

-- ============================================================
-- 12S — GOD MODE (exact)
-- ============================================================
local godConn

function enableGodMode()
    if godConn then return end
    godConn = RunService.Heartbeat:Connect(function()
        if not S.GodMode then return end
        _safeCall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end)
    end)
end

function disableGodMode()
    if godConn then godConn:Disconnect(); godConn = nil end
end

-- ============================================================
-- 12T — KILL AURA (exact)
-- ============================================================
local kaThrottle = 0
kaActivateCooldown = 0

function updateKillAura(now)
    if not S.KillAura then return end
    if now - kaThrottle < 0.15 then return end
    kaThrottle = now
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    if not root or not tool then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pc = PartCache[p]
            if pc and pc.root and pc.hum and pc.hum.Health > 0 then
                if (pc.root.Position - root.Position).Magnitude <= S.KillAuraRange then
                    _safeCall(function()
                        local aim = (S.AimPart == "Torso") and pc.torso or pc.head
                        if aim then
                            -- Smooth camera interpolation
                            Camera.CFrame = Camera.CFrame:Lerp(
                                CFrame.new(Camera.CFrame.Position, aim.Position),
                                0.5
                            )
                            -- Internal cooldown before tool:Activate()
                            if now - kaActivateCooldown >= _G.Config.KillAuraCooldown then
                                kaActivateCooldown = now
                                tool:Activate()
                            end
                        end
                    end)
                    break
                end
            end
        end
    end
end

-- ============================================================
-- TELEPORT TO PLAYER
-- ============================================================
function teleportToPlayer(targetName)
    _safeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pName = string.lower(p.Name)
                local pDisplay = string.lower(p.DisplayName)
                local search = string.lower(targetName)
                if pName:find(search) or pDisplay:find(search) then
                    local tChar = p.Character
                    if tChar then
                        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                        if tRoot then
                            root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                            notify("Teleported", "Teleported to " .. p.DisplayName, 3)
                            return
                        end
                    end
                end
            end
        end
        notify("Not Found", "Player not found: " .. targetName, 3)
    end)
end

function teleportToNearest()
    _safeCall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local d = (tRoot.Position - root.Position).Magnitude
                    if d < bestDist then bestDist = d; best = p end
                end
            end
        end
        if best and best.Character then
            local tRoot = best.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
                notify("Teleported", "Teleported to " .. best.DisplayName .. " (" .. math.floor(bestDist) .. "m)", 3)
            end
        else
            notify("No Players", "No other players found.", 3)
        end
    end)
end

-- ============================================================
-- 12U — ESP UPDATE (exact box sizing math)
-- ============================================================
lastVP = Vector2.new(0, 0)
bottomCenter = Vector2.new(0, 0)

function refreshVP()
    local vp = Camera.ViewportSize
    if vp ~= lastVP then lastVP = vp; bottomCenter = Vector2.new(vp.X*0.5, vp.Y) end
end

local skelThrottle = 0

function updateESP(now)
    refreshVP()
    local anyESP = S.ESP_Box or S.ESP_Skeleton or S.ESP_Tracer or S.ESP_Distance or S.ESP_Name or S.ESP_Health
    if not anyESP then
        for _, esp in pairs(ESPPool) do hideESP(esp) end
        return
    end

    local camPos = Camera.CFrame.Position
    local doSkel = S.ESP_Skeleton and (now - skelThrottle >= 0.033)
    if doSkel then skelThrottle = now end

    for player, esp in pairs(ESPPool) do
        local pc = PartCache[player]
        if not pc then hideESP(esp)
        else
            local hum, head, root = pc.hum, pc.head, pc.root
            if not hum or hum.Health <= 0 or not head or not root then hideESP(esp)
            else
                local skipVis = false
                if S.VisCheck then
                    local char = player.Character
                    if char then
                        local obs = Camera:GetPartsObscuringTarget({head.Position}, {LocalPlayer.Character, char})
                        if #obs > 0 then hideESP(esp); skipVis = true end
                    end
                end

                if not skipVis then
                    -- R6 vs R15 rig-aware box sizing
                    local isR15 = pc.torso and pc.torso.Name == "UpperTorso"
                    local headOff = isR15 and 0.7 or 0.5
                    local feetOff = isR15 and 3.2 or 2.8
                    local hSP, hOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, headOff, 0))
                    local rSP = Camera:WorldToViewportPoint(root.Position)
                    local fSP = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, feetOff, 0))

                    if not hOn then hideESP(esp)
                    else
                        local boxH = math.max(fSP.Y - hSP.Y, 4)
                        local boxW = boxH * 0.55
                        local boxL = rSP.X - boxW * 0.5
                        local boxT = hSP.Y

                        -- Box ESP
                        if S.ESP_Box then
                            esp.box.Size = Vector2.new(boxW, boxH)
                            esp.box.Position = Vector2.new(boxL, boxT)
                            esp.box.Color = S.ESPColor; esp.box.Visible = true
                        else esp.box.Visible = false end

                        if S.ESP_Name then
                            esp.nameLabel.Position = Vector2.new(rSP.X, boxT - 16)
                            esp.nameLabel.Visible = true
                        else esp.nameLabel.Visible = false end

                        if S.ESP_Health then
                            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                            local bW, bX = 3, boxL - 5
                            local fH = math.max(math.floor(boxH * pct), 1)
                            esp.healthBg.Size = Vector2.new(bW, boxH)
                            esp.healthBg.Position = Vector2.new(bX, boxT); esp.healthBg.Visible = true
                            esp.healthBar.Size = Vector2.new(bW, fH)
                            esp.healthBar.Position = Vector2.new(bX, boxT + boxH - fH)
                            esp.healthBar.Color = healthColor(pct); esp.healthBar.Visible = true
                        else
                            esp.healthBg.Visible = false; esp.healthBar.Visible = false
                        end

                        -- Tracers
                        if S.ESP_Tracer then
                            esp.tracer.From = bottomCenter
                            esp.tracer.To = Vector2.new(rSP.X, rSP.Y)
                            esp.tracer.Color = THEME.ESPTracer
                            esp.tracer.Visible = true
                        else esp.tracer.Visible = false end

                        if S.ESP_Distance then
                            local d = math.floor((camPos - root.Position).Magnitude)
                            esp.distLabel.Position = Vector2.new(rSP.X, boxT + boxH + 2)
                            esp.distLabel.Text = d .. "m"; esp.distLabel.Visible = true
                        else esp.distLabel.Visible = false end

                        if S.ESP_Skeleton and doSkel then
                            for i = 1, pc.numBones do
                                local bone = esp.bones[i]
                                if not bone then break end
                                local pair = pc.boneParts[i]
                                if pair[1] and pair[2] then
                                    local sA, oA = Camera:WorldToViewportPoint(pair[1].Position)
                                    local sB, oB = Camera:WorldToViewportPoint(pair[2].Position)
                                    if oA and oB then
                                        bone.From = Vector2.new(sA.X, sA.Y)
                                        bone.To = Vector2.new(sB.X, sB.Y)
                                        bone.Color = S.ESPColor; bone.Visible = true
                                    else bone.Visible = false end
                                else bone.Visible = false end
                            end
                            for i = pc.numBones + 1, MAX_BONES do
                                if esp.bones[i] then esp.bones[i].Visible = false end
                            end
                        elseif not S.ESP_Skeleton then
                            for _, b in ipairs(esp.bones) do b.Visible = false end
                        end
                    end
                end
            end
        end
    end
end
-- ============================================================
end -- FEATURE SYSTEMS SCOPE

-- Forward declarations for UI framework
local createSection, createToggle, createSlider, createButton, createDropdown, createInput, createParagraph, createColorPicker
local createLabel, createScreenGui
local mainFrame, tabPages, hubGui, _fpsFrameCount, _fpsValue

do -- UI FRAMEWORK SCOPE
-- PART 9 — CUSTOM UI FRAMEWORK (Loading, Hub, Notifications, Components)
-- ============================================================

-- Forward-declare notify so earlier code can reference it
local notify
local _notifyImpl

-- 9.0 — ScreenGui creation helper
function createScreenGui(name, displayOrder)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = displayOrder or 999
    gui.IgnoreGuiInset = true
    local ok = _safeCall(function() gui.Parent = CoreGui end)
    if not ok then
        _safeCall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
    return gui
end

-- Create the main ScreenGui
hubGui = createScreenGui("AmethystHubV4", 999)

-- ============================================================
-- 9A — Loading Screen
-- ============================================================

local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingFrame"
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.Position = UDim2.new(0, 0, 0, 0)
loadingFrame.BackgroundColor3 = THEME.LoadingBackground
loadingFrame.BackgroundTransparency = 0
loadingFrame.BorderSizePixel = 0
loadingFrame.ZIndex = 100
loadingFrame.Parent = hubGui

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Name = "Title"
loadingTitle.Size = UDim2.new(1, 0, 0, 40)
loadingTitle.Position = UDim2.new(0, 0, 0.5, -40)
loadingTitle.AnchorPoint = Vector2.new(0, 0)
loadingTitle.BackgroundTransparency = 1
loadingTitle.BorderSizePixel = 0
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextSize = 32
loadingTitle.TextColor3 = THEME.Accent
loadingTitle.Text = "A M E T H Y S T"
loadingTitle.TextXAlignment = Enum.TextXAlignment.Center
loadingTitle.TextYAlignment = Enum.TextYAlignment.Center
loadingTitle.ZIndex = 101
loadingTitle.Parent = loadingFrame

local loadingSubtitle = Instance.new("TextLabel")
loadingSubtitle.Name = "Subtitle"
loadingSubtitle.Size = UDim2.new(1, 0, 0, 24)
loadingSubtitle.Position = UDim2.new(0, 0, 0.5, 4)
loadingSubtitle.AnchorPoint = Vector2.new(0, 0)
loadingSubtitle.BackgroundTransparency = 1
loadingSubtitle.BorderSizePixel = 0
loadingSubtitle.Font = Enum.Font.Gotham
loadingSubtitle.TextSize = 16
loadingSubtitle.TextColor3 = THEME.TextSecondary
loadingSubtitle.Text = "Ultimate V4.0 | by Lutfie kenape ek"
loadingSubtitle.TextXAlignment = Enum.TextXAlignment.Center
loadingSubtitle.TextYAlignment = Enum.TextYAlignment.Center
loadingSubtitle.ZIndex = 101
loadingSubtitle.Parent = loadingFrame

local loadingBarBg = Instance.new("Frame")
loadingBarBg.Name = "BarBg"
loadingBarBg.Size = UDim2.new(0, 200, 0, 4)
loadingBarBg.Position = UDim2.new(0.5, 0, 0.5, 38)
loadingBarBg.AnchorPoint = Vector2.new(0.5, 0)
loadingBarBg.BackgroundColor3 = THEME.LoadingBarBackground
loadingBarBg.BorderSizePixel = 0
loadingBarBg.ZIndex = 101
loadingBarBg.Parent = loadingFrame

local loadingBarBgCorner = Instance.new("UICorner")
loadingBarBgCorner.CornerRadius = UDim.new(0, 2)
loadingBarBgCorner.Parent = loadingBarBg

local loadingBarFill = Instance.new("Frame")
loadingBarFill.Name = "Fill"
loadingBarFill.Size = UDim2.new(0, 0, 1, 0)
loadingBarFill.Position = UDim2.new(0, 0, 0, 0)
loadingBarFill.BackgroundColor3 = THEME.LoadingBarFill
loadingBarFill.BorderSizePixel = 0
loadingBarFill.ZIndex = 102
loadingBarFill.Parent = loadingBarBg

local loadingBarFillCorner = Instance.new("UICorner")
loadingBarFillCorner.CornerRadius = UDim.new(0, 2)
loadingBarFillCorner.Parent = loadingBarFill

-- ============================================================
-- 9B — Main Hub Window (created behind loading screen)
-- ============================================================

local sidebarWidth = IS_MOBILE and 110 or 130

-- Main Frame
mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = IS_MOBILE and UDim2.new(0.92, 0, 0.7, 0) or UDim2.new(0, 550, 0, 380)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = THEME.WindowBackground
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.ZIndex = 10
mainFrame.Parent = hubGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 10)
mainFrameCorner.Parent = mainFrame

local mainFrameStroke = Instance.new("UIStroke")
mainFrameStroke.Color = THEME.TopbarStroke
mainFrameStroke.Thickness = 1.5
mainFrameStroke.Parent = mainFrame

-- Dragging logic
local _dragging = false
local _dragStart = nil
local _startPos = nil

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = THEME.Topbar
topBar.BorderSizePixel = 0
topBar.ZIndex = 11
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = topBar

-- Fill bottom corners of topbar so it looks flat at bottom
local topBarFill = Instance.new("Frame")
topBarFill.Name = "BottomFill"
topBarFill.Size = UDim2.new(1, 0, 0, 10)
topBarFill.Position = UDim2.new(0, 0, 1, -10)
topBarFill.BackgroundColor3 = THEME.Topbar
topBarFill.BorderSizePixel = 0
topBarFill.ZIndex = 11
topBarFill.Parent = topBar

local topBarGradient = Instance.new("UIGradient")
topBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 20, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 30, 95)),
})
topBarGradient.Parent = topBar

-- Topbar title
local topBarTitle = Instance.new("TextLabel")
topBarTitle.Name = "Title"
topBarTitle.Size = UDim2.new(1, -80, 1, 0)
topBarTitle.Position = UDim2.new(0, 0, 0, 0)
topBarTitle.BackgroundTransparency = 1
topBarTitle.BorderSizePixel = 0
topBarTitle.Font = Enum.Font.GothamBold
topBarTitle.TextSize = 14
topBarTitle.TextColor3 = THEME.Lavender
topBarTitle.Text = "  Amethyst  |  Universal  "
topBarTitle.TextXAlignment = Enum.TextXAlignment.Left
topBarTitle.TextYAlignment = Enum.TextYAlignment.Center
topBarTitle.ZIndex = 12
topBarTitle.Parent = topBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.AnchorPoint = Vector2.new(0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = THEME.TextPrimary
closeBtn.Text = "✕"
closeBtn.ZIndex = 13
closeBtn.Parent = topBar

track(closeBtn.MouseEnter:Connect(function()
    tweenProp(closeBtn, {TextColor3 = Color3.fromRGB(255, 60, 60)}, TI_FAST)
end))

track(closeBtn.MouseLeave:Connect(function()
    tweenProp(closeBtn, {TextColor3 = THEME.TextPrimary}, TI_FAST)
end))

track(closeBtn.MouseButton1Click:Connect(function()
    tweenProp(mainFrame, {Size = UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, 0)}, TI_SMOOTH)
    task.wait(0.35)
    mainFrame.Visible = false
end))

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
minimizeBtn.Position = UDim2.new(1, -72, 0, 0)
minimizeBtn.AnchorPoint = Vector2.new(0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.TextColor3 = THEME.TextPrimary
minimizeBtn.Text = "—"
minimizeBtn.ZIndex = 13
minimizeBtn.Parent = topBar

local _minimized = false
local _savedSize = mainFrame.Size

track(minimizeBtn.MouseEnter:Connect(function()
    tweenProp(minimizeBtn, {TextColor3 = THEME.Accent}, TI_FAST)
end))

track(minimizeBtn.MouseLeave:Connect(function()
    tweenProp(minimizeBtn, {TextColor3 = THEME.TextPrimary}, TI_FAST)
end))

-- Dragging implementation
track(topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        _dragging = true
        _dragStart = input.Position
        _startPos = mainFrame.Position
    end
end))

track(topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        _dragging = false
    end
end))

track(UserInputService.InputChanged:Connect(function(input)
    if _dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - _dragStart
        mainFrame.Position = UDim2.new(
            _startPos.X.Scale, _startPos.X.Offset + delta.X,
            _startPos.Y.Scale, _startPos.Y.Offset + delta.Y
        )
    end
end))

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, sidebarWidth, 1, -56)
sidebar.Position = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = THEME.SidebarBackground
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 11
sidebar.ClipsDescendants = true
sidebar.Parent = mainFrame

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 6)
sidebarPadding.PaddingLeft = UDim.new(0, 4)
sidebarPadding.PaddingRight = UDim.new(0, 4)
sidebarPadding.Parent = sidebar

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -sidebarWidth, 1, -56)
contentArea.Position = UDim2.new(0, sidebarWidth, 0, 36)
contentArea.BackgroundColor3 = THEME.ContentBackground
contentArea.BorderSizePixel = 0
contentArea.ZIndex = 11
contentArea.ClipsDescendants = true
contentArea.Parent = mainFrame

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Name = "StatusBar"
statusBar.Size = UDim2.new(1, 0, 0, 20)
statusBar.Position = UDim2.new(0, 0, 1, -20)
statusBar.BackgroundColor3 = THEME.StatusBarBackground
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 11
statusBar.Parent = mainFrame

local statusBarCorner = Instance.new("UICorner")
statusBarCorner.CornerRadius = UDim.new(0, 0)
statusBarCorner.Parent = statusBar

local statusLeft = Instance.new("TextLabel")
statusLeft.Name = "StatusLeft"
statusLeft.Size = UDim2.new(0.3, 0, 1, 0)
statusLeft.Position = UDim2.new(0, 8, 0, 0)
statusLeft.BackgroundTransparency = 1
statusLeft.BorderSizePixel = 0
statusLeft.Font = Enum.Font.Gotham
statusLeft.TextSize = 10
statusLeft.TextColor3 = THEME.TextSecondary
statusLeft.Text = "Amethyst V4.0"
statusLeft.TextXAlignment = Enum.TextXAlignment.Left
statusLeft.TextYAlignment = Enum.TextYAlignment.Center
statusLeft.ZIndex = 12
statusLeft.Parent = statusBar

local statusCenter = Instance.new("TextLabel")
statusCenter.Name = "StatusCenter"
statusCenter.Size = UDim2.new(0.4, 0, 1, 0)
statusCenter.Position = UDim2.new(0.3, 0, 0, 0)
statusCenter.BackgroundTransparency = 1
statusCenter.BorderSizePixel = 0
statusCenter.Font = Enum.Font.Gotham
statusCenter.TextSize = 10
statusCenter.TextColor3 = THEME.TextSecondary
statusCenter.Text = "FPS: -- | Ping: --ms"
statusCenter.TextXAlignment = Enum.TextXAlignment.Center
statusCenter.TextYAlignment = Enum.TextYAlignment.Center
statusCenter.ZIndex = 12
statusCenter.Parent = statusBar

local statusRight = Instance.new("TextLabel")
statusRight.Name = "StatusRight"
statusRight.Size = UDim2.new(0.3, 0, 1, 0)
statusRight.Position = UDim2.new(0.7, 0, 0, 0)
statusRight.BackgroundTransparency = 1
statusRight.BorderSizePixel = 0
statusRight.Font = Enum.Font.Gotham
statusRight.TextSize = 10
statusRight.TextColor3 = THEME.TextSecondary
statusRight.Text = "Game: " .. tostring(game.PlaceId)
statusRight.TextXAlignment = Enum.TextXAlignment.Right
statusRight.TextYAlignment = Enum.TextYAlignment.Center
statusRight.ZIndex = 12
statusRight.Parent = statusBar

-- FPS Counter
_fpsFrameCount = 0
_fpsValue = 0
local _fpsPingUpdate = 0

track(RunService.RenderStepped:Connect(function()
    _fpsFrameCount = _fpsFrameCount + 1
end))

task.spawn(function()
    while hubGui and hubGui.Parent do
        task.wait(0.5)
        _fpsValue = _fpsFrameCount * 2
        _fpsFrameCount = 0

        local pingText = ""
        _safeCall(function()
            local stats = game:GetService("Stats")
            local perfStats = stats:FindFirstChild("PerformanceStats")
            if perfStats then
                local ping = perfStats:FindFirstChild("Ping")
                if ping then
                    pingText = " | Ping: " .. math.floor(ping:GetValue()) .. "ms"
                end
            end
        end)

        _safeCall(function()
            statusCenter.Text = "FPS: " .. tostring(_fpsValue) .. pingText
        end)
    end
end)

-- Minimize logic
track(minimizeBtn.MouseButton1Click:Connect(function()
    if not _minimized then
        _savedSize = mainFrame.Size
        _minimized = true
        sidebar.Visible = false
        contentArea.Visible = false
        statusBar.Visible = false
        tweenProp(mainFrame, {Size = UDim2.new(_savedSize.X.Scale, _savedSize.X.Offset, 0, 36)}, TI_SMOOTH)
    else
        _minimized = false
        tweenProp(mainFrame, {Size = _savedSize}, TI_SMOOTH)
        task.wait(0.35)
        sidebar.Visible = true
        contentArea.Visible = true
        statusBar.Visible = true
    end
end))

-- ============================================================
-- Tab Pages & Tab Buttons
-- ============================================================

local TAB_NAMES = {"Home", "Combat", "Visuals", "Gameplay", "Performance", "Server", "Credits"}
tabPages = {}
local tabButtons = {}
local _currentTab = "Home"

-- Create scroll frames for each tab
for i, tabName in ipairs(TAB_NAMES) do
    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = THEME.AccentDim
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ElasticBehavior = Enum.ElasticBehavior.Always
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = (tabName == "Home")
    page.ZIndex = 12
    page.Parent = contentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 6)
    pagePadding.PaddingBottom = UDim.new(0, 6)
    pagePadding.PaddingLeft = UDim.new(0, 6)
    pagePadding.PaddingRight = UDim.new(0, 6)
    pagePadding.Parent = page

    tabPages[tabName] = page
end

-- Tab switching function
local function switchTab(tabName)
    _currentTab = tabName
    for name, page in pairs(tabPages) do
        page.Visible = (name == tabName)
    end
    for name, btn in pairs(tabButtons) do
        local isSelected = (name == tabName)
        local btnFrame = btn.frame
        local accent = btn.accent
        local stroke = btn.stroke

        if isSelected then
            tweenProp(btnFrame, {BackgroundColor3 = THEME.TabBackgroundSelected}, TI_SMOOTH)
            stroke.Color = THEME.TabStrokeSelected
            accent.Visible = true
        else
            tweenProp(btnFrame, {BackgroundColor3 = THEME.TabBackground}, TI_SMOOTH)
            stroke.Color = THEME.TabStroke
            accent.Visible = false
        end
    end
end

-- Create sidebar tab buttons
for i, tabName in ipairs(TAB_NAMES) do
    local btnFrame = Instance.new("TextButton")
    btnFrame.Name = tabName .. "Tab"
    btnFrame.Size = UDim2.new(1, -8, 0, 32)
    btnFrame.BackgroundColor3 = (tabName == "Home") and THEME.TabBackgroundSelected or THEME.TabBackground
    btnFrame.BorderSizePixel = 0
    btnFrame.Font = Enum.Font.GothamBold
    btnFrame.TextSize = 12
    btnFrame.TextColor3 = THEME.TextPrimary
    btnFrame.Text = "    " .. tabName
    btnFrame.TextXAlignment = Enum.TextXAlignment.Left
    btnFrame.TextYAlignment = Enum.TextYAlignment.Center
    btnFrame.AutoButtonColor = false
    btnFrame.LayoutOrder = i
    btnFrame.ZIndex = 12
    btnFrame.Parent = sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btnFrame

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = (tabName == "Home") and THEME.TabStrokeSelected or THEME.TabStroke
    btnStroke.Thickness = 1
    btnStroke.Parent = btnFrame

    -- Left accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 3, 0.6, 0)
    accentBar.Position = UDim2.new(0, 2, 0.2, 0)
    accentBar.BackgroundColor3 = THEME.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Visible = (tabName == "Home")
    accentBar.ZIndex = 13
    accentBar.Parent = btnFrame

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accentBar

    tabButtons[tabName] = {
        frame = btnFrame,
        accent = accentBar,
        stroke = btnStroke,
    }

    -- Hover effects
    track(btnFrame.MouseEnter:Connect(function()
        if _currentTab ~= tabName then
            tweenProp(btnFrame, {BackgroundColor3 = THEME.SidebarHover}, TI_FAST)
        end
    end))

    track(btnFrame.MouseLeave:Connect(function()
        if _currentTab ~= tabName then
            tweenProp(btnFrame, {BackgroundColor3 = THEME.TabBackground}, TI_FAST)
        end
    end))

    track(btnFrame.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end))
end

-- ============================================================
-- 9C — Notification System
-- ============================================================

local notifContainer = Instance.new("Frame")
notifContainer.Name = "NotificationContainer"
notifContainer.Size = UDim2.new(0, 270, 1, -20)
notifContainer.Position = UDim2.new(1, -275, 0, 10)
notifContainer.BackgroundTransparency = 1
notifContainer.BorderSizePixel = 0
notifContainer.ZIndex = 200
notifContainer.Parent = hubGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Padding = UDim.new(0, 6)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.Parent = notifContainer

local _activeNotifications = {}
local _notifOrder = 0

local function dismissNotification(notifFrame)
    _safeCall(function()
        tweenProp(notifFrame, {Position = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}, TI_FAST)
        task.wait(0.25)
        for idx, n in ipairs(_activeNotifications) do
            if n == notifFrame then
                table.remove(_activeNotifications, idx)
                break
            end
        end
        notifFrame:Destroy()
    end)
end

_notifyImpl = function(title, content, dur)
    if S and S.Utility and S.Utility.SilentMode then return end
    dur = dur or 4

    -- Enforce max 4 visible
    while #_activeNotifications >= 4 do
        local oldest = _activeNotifications[1]
        if oldest then
            dismissNotification(oldest)
        end
        task.wait(0.1)
    end

    _notifOrder = _notifOrder + 1

    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notification_" .. _notifOrder
    notifFrame.Size = UDim2.new(0, 260, 0, 0)
    notifFrame.AutomaticSize = Enum.AutomaticSize.Y
    notifFrame.BackgroundColor3 = THEME.NotificationBackground
    notifFrame.BorderSizePixel = 0
    notifFrame.Position = UDim2.new(0, 280, 0, 0)
    notifFrame.LayoutOrder = _notifOrder
    notifFrame.ZIndex = 201
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = notifContainer

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notifFrame

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = THEME.TopbarStroke
    notifStroke.Thickness = 1
    notifStroke.Parent = notifFrame

    -- Left accent bar
    local notifAccent = Instance.new("Frame")
    notifAccent.Name = "AccentBar"
    notifAccent.Size = UDim2.new(0, 3, 1, -8)
    notifAccent.Position = UDim2.new(0, 4, 0, 4)
    notifAccent.BackgroundColor3 = THEME.Accent
    notifAccent.BorderSizePixel = 0
    notifAccent.ZIndex = 202
    notifAccent.Parent = notifFrame

    local notifAccentCorner = Instance.new("UICorner")
    notifAccentCorner.CornerRadius = UDim.new(0, 2)
    notifAccentCorner.Parent = notifAccent

    -- Inner padding
    local notifPadding = Instance.new("UIPadding")
    notifPadding.PaddingTop = UDim.new(0, 8)
    notifPadding.PaddingBottom = UDim.new(0, 8)
    notifPadding.PaddingLeft = UDim.new(0, 14)
    notifPadding.PaddingRight = UDim.new(0, 8)
    notifPadding.Parent = notifFrame

    local notifInnerLayout = Instance.new("UIListLayout")
    notifInnerLayout.Padding = UDim.new(0, 2)
    notifInnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifInnerLayout.Parent = notifFrame

    -- Icon + Title row
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 18)
    titleLabel.BackgroundTransparency = 1
    titleLabel.BorderSizePixel = 0
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = THEME.TextPrimary
    titleLabel.Text = "💎 " .. tostring(title or "Amethyst")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.TextWrapped = true
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.LayoutOrder = 1
    titleLabel.ZIndex = 202
    titleLabel.Parent = notifFrame

    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.BackgroundTransparency = 1
    contentLabel.BorderSizePixel = 0
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 12
    contentLabel.TextColor3 = THEME.TextSecondary
    contentLabel.Text = tostring(content or "")
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.LayoutOrder = 2
    contentLabel.ZIndex = 202
    contentLabel.Parent = notifFrame

    table.insert(_activeNotifications, notifFrame)

    -- Slide in
    tweenProp(notifFrame, {Position = UDim2.new(0, 0, 0, 0)}, TI_SMOOTH)

    -- Auto-dismiss after duration
    task.spawn(function()
        task.wait(dur)
        _safeCall(function()
            if notifFrame and notifFrame.Parent then
                dismissNotification(notifFrame)
            end
        end)
    end)
end

-- Set the global notify function
notify = function(title, content, dur)
    if _notifyImpl then
        _notifyImpl(title, content, dur)
    end
end

-- ============================================================
-- 9D — Reusable UI Components (9 factory functions)
-- ============================================================

-- Helper: set BorderSizePixel = 0 on any Instance that supports it
local function noBorder(inst)
    _safeCall(function() inst.BorderSizePixel = 0 end)
    return inst
end

-- 1. createSection(parent, text)
function createSection(parent, text)
    local container = Instance.new("Frame")
    container.Name = "Section_" .. text
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.LayoutOrder = (parent:FindFirstChildOfClass("UIListLayout") and #parent:GetChildren() or 0)
    container.ZIndex = 12
    container.Parent = parent

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.Padding = UDim.new(0, 2)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Parent = container

    local label = Instance.new("TextLabel")
    label.Name = "SectionLabel"
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = THEME.Accent
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.LayoutOrder = 1
    label.ZIndex = 13
    label.Parent = container

    local line = Instance.new("Frame")
    line.Name = "SectionLine"
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = THEME.TopbarStroke
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.LayoutOrder = 2
    line.ZIndex = 13
    line.Parent = container

    return container
end

-- 2. createToggle(parent, config)
function createToggle(parent, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local currentValue = config.CurrentValue or false
    local callback = config.Callback or function() end

    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. name
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = THEME.ElementBackground
    row.BorderSizePixel = 0
    row.ZIndex = 13
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = THEME.ElementStroke
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.ZIndex = 14
    label.Parent = row

    -- Track (background behind circle)
    local toggleTrack = Instance.new("Frame")
    toggleTrack.Name = "Track"
    toggleTrack.Size = UDim2.new(0, 36, 0, 20)
    toggleTrack.Position = UDim2.new(1, -46, 0.5, 0)
    toggleTrack.AnchorPoint = Vector2.new(0, 0.5)
    toggleTrack.BackgroundColor3 = currentValue and THEME.ToggleEnabled or THEME.ToggleDisabled
    toggleTrack.BorderSizePixel = 0
    toggleTrack.ZIndex = 14
    toggleTrack.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = toggleTrack

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = currentValue and THEME.ToggleEnabledStroke or THEME.ToggleDisabledStroke
    trackStroke.Thickness = 1
    trackStroke.Parent = toggleTrack

    -- Circle
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = currentValue and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    circle.AnchorPoint = Vector2.new(0, 0.5)
    circle.BackgroundColor3 = THEME.CrystalWhite
    circle.BorderSizePixel = 0
    circle.ZIndex = 15
    circle.Parent = toggleTrack

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    -- Click handler (invisible button overlay)
    local clickBtn = Instance.new("TextButton")
    clickBtn.Name = "ClickArea"
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.BorderSizePixel = 0
    clickBtn.Text = ""
    clickBtn.ZIndex = 16
    clickBtn.Parent = row

    local function setValue(val)
        currentValue = val
        if currentValue then
            tweenProp(toggleTrack, {BackgroundColor3 = THEME.ToggleEnabled}, TI_SMOOTH)
            tweenProp(circle, {Position = UDim2.new(1, -18, 0.5, 0)}, TI_SMOOTH)
            trackStroke.Color = THEME.ToggleEnabledStroke
        else
            tweenProp(toggleTrack, {BackgroundColor3 = THEME.ToggleDisabled}, TI_SMOOTH)
            tweenProp(circle, {Position = UDim2.new(0, 2, 0.5, 0)}, TI_SMOOTH)
            trackStroke.Color = THEME.ToggleDisabledStroke
        end
    end

    track(clickBtn.MouseButton1Click:Connect(function()
        currentValue = not currentValue
        setValue(currentValue)
        _safeCall(function() callback(currentValue) end)
    end))

    return {frame = row, setValue = setValue}
end

-- 3. createSlider(parent, config)
function createSlider(parent, config)
    config = config or {}
    local name = config.Name or "Slider"
    local range = config.Range or {0, 100}
    local increment = config.Increment or 1
    local currentValue = config.CurrentValue or range[1]
    local callback = config.Callback or function() end
    local minVal, maxVal = range[1], range[2]

    local row = Instance.new("Frame")
    row.Name = "Slider_" .. name
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = THEME.ElementBackground
    row.BorderSizePixel = 0
    row.ZIndex = 13
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = THEME.ElementStroke
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, -10, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.ZIndex = 14
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.3, -10, 0, 22)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.BorderSizePixel = 0
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = THEME.Accent
    valueLabel.Text = tostring(currentValue)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    valueLabel.ZIndex = 14
    valueLabel.Parent = row

    -- Slider track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 0, 34)
    sliderTrack.BackgroundColor3 = THEME.SliderBackground
    sliderTrack.BorderSizePixel = 0
    sliderTrack.ZIndex = 14
    sliderTrack.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack

    -- Fill
    local pct = math.clamp((currentValue - minVal) / (maxVal - minVal), 0, 1)
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderFill.BackgroundColor3 = THEME.SliderProgress
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 15
    sliderFill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill

    -- Drag interaction (invisible button on track)
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Name = "SliderBtn"
    sliderBtn.Size = UDim2.new(1, 0, 1, 10)
    sliderBtn.Position = UDim2.new(0, 0, 0, -5)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 16
    sliderBtn.Parent = sliderTrack

    local _sliderDragging = false

    local function updateSlider(inputX)
        local trackAbsPos = sliderTrack.AbsolutePosition.X
        local trackAbsSize = sliderTrack.AbsoluteSize.X
        if trackAbsSize <= 0 then return end

        local relX = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
        local rawVal = minVal + (maxVal - minVal) * relX

        -- Apply increment
        if increment > 0 then
            rawVal = math.floor(rawVal / increment + 0.5) * increment
        end
        rawVal = math.clamp(rawVal, minVal, maxVal)

        -- Round for display
        if increment >= 1 then
            rawVal = math.floor(rawVal + 0.5)
        else
            rawVal = math.floor(rawVal * 100 + 0.5) / 100
        end

        currentValue = rawVal
        local newPct = math.clamp((currentValue - minVal) / (maxVal - minVal), 0, 1)
        sliderFill.Size = UDim2.new(newPct, 0, 1, 0)
        valueLabel.Text = tostring(currentValue)
        _safeCall(function() callback(currentValue) end)
    end

    track(sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _sliderDragging = true
            updateSlider(input.Position.X)
        end
    end))

    track(sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _sliderDragging = false
        end
    end))

    track(UserInputService.InputChanged:Connect(function(input)
        if _sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end))

    local function setValue(val)
        currentValue = math.clamp(val, minVal, maxVal)
        local newPct = math.clamp((currentValue - minVal) / (maxVal - minVal), 0, 1)
        sliderFill.Size = UDim2.new(newPct, 0, 1, 0)
        valueLabel.Text = tostring(currentValue)
    end

    return {frame = row, setValue = setValue}
end

-- 4. createButton(parent, config)
function createButton(parent, config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end

    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. name
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = THEME.ElementBackground
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = THEME.Accent
    btn.Text = name
    btn.AutoButtonColor = false
    btn.ZIndex = 13
    btn.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = THEME.ElementStroke
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    track(btn.MouseEnter:Connect(function()
        tweenProp(btn, {BackgroundColor3 = THEME.ElementBackgroundHover}, TI_FAST)
    end))

    track(btn.MouseLeave:Connect(function()
        tweenProp(btn, {BackgroundColor3 = THEME.ElementBackground}, TI_FAST)
    end))

    track(btn.MouseButton1Click:Connect(function()
        -- Press animation: shrink 2px then bounce back
        local origSize = btn.Size
        tweenProp(btn, {Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 4, origSize.Y.Scale, origSize.Y.Offset - 4)}, TI_FAST)
        task.wait(0.15)
        tweenProp(btn, {Size = origSize}, TI_BOUNCE)
        _safeCall(function() callback() end)
    end))

    local function setText(newText)
        btn.Text = newText
    end

    return {frame = btn, setText = setText}
end

-- 5. createDropdown(parent, config)
function createDropdown(parent, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {}
    local currentOption = config.CurrentOption or {}
    local multipleOptions = config.MultipleOptions or false
    local callback = config.Callback or function() end

    -- Determine initial display text
    local displayText = ""
    if type(currentOption) == "table" and #currentOption > 0 then
        displayText = table.concat(currentOption, ", ")
    elseif type(currentOption) == "string" then
        displayText = currentOption
    else
        displayText = "Select..."
    end

    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. name
    container.Size = UDim2.new(1, 0, 0, 36)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.ZIndex = 13
    container.Parent = parent

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Padding = UDim.new(0, 2)
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- Header row
    local headerBtn = Instance.new("TextButton")
    headerBtn.Name = "Header"
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundColor3 = THEME.ElementBackground
    headerBtn.BorderSizePixel = 0
    headerBtn.Font = Enum.Font.Gotham
    headerBtn.TextSize = 12
    headerBtn.TextColor3 = THEME.TextPrimary
    headerBtn.Text = "  " .. name .. ": " .. displayText
    headerBtn.TextXAlignment = Enum.TextXAlignment.Left
    headerBtn.AutoButtonColor = false
    headerBtn.LayoutOrder = 1
    headerBtn.ZIndex = 14
    headerBtn.Parent = container

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = headerBtn

    local headerStroke = Instance.new("UIStroke")
    headerStroke.Color = THEME.ElementStroke
    headerStroke.Thickness = 1
    headerStroke.Parent = headerBtn

    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.BorderSizePixel = 0
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.TextColor3 = THEME.TextSecondary
    arrow.Text = "▼"
    arrow.ZIndex = 15
    arrow.Parent = headerBtn

    -- Options container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.AutomaticSize = Enum.AutomaticSize.Y
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.LayoutOrder = 2
    optionsFrame.ZIndex = 14
    optionsFrame.Parent = container

    local optLayout = Instance.new("UIListLayout")
    optLayout.Padding = UDim.new(0, 2)
    optLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optLayout.Parent = optionsFrame

    local _expanded = false
    local _selectedOptions = {}

    -- Initialize selected options
    if type(currentOption) == "table" then
        for _, opt in ipairs(currentOption) do
            _selectedOptions[opt] = true
        end
    elseif type(currentOption) == "string" then
        _selectedOptions[currentOption] = true
    end

    local function isSelected(opt)
        return _selectedOptions[opt] == true
    end

    local function updateDisplay()
        local selected = {}
        for _, opt in ipairs(options) do
            if _selectedOptions[opt] then
                table.insert(selected, opt)
            end
        end
        displayText = #selected > 0 and table.concat(selected, ", ") or "Select..."
        headerBtn.Text = "  " .. name .. ": " .. displayText
    end

    local optionButtons = {}

    local function buildOptions()
        -- Clear old
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        optionButtons = {}

        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Name = "Opt_" .. opt
            optBtn.Size = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = isSelected(opt) and THEME.DropdownSelected or THEME.DropdownUnselected
            optBtn.BorderSizePixel = 0
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 12
            optBtn.TextColor3 = THEME.TextPrimary
            optBtn.Text = "  " .. opt
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.AutoButtonColor = false
            optBtn.LayoutOrder = i
            optBtn.ZIndex = 15
            optBtn.Parent = optionsFrame

            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 4)
            optCorner.Parent = optBtn

            optionButtons[opt] = optBtn

            track(optBtn.MouseButton1Click:Connect(function()
                if multipleOptions then
                    _selectedOptions[opt] = not _selectedOptions[opt]
                    optBtn.BackgroundColor3 = isSelected(opt) and THEME.DropdownSelected or THEME.DropdownUnselected
                    updateDisplay()
                    local selected = {}
                    for _, o in ipairs(options) do
                        if _selectedOptions[o] then table.insert(selected, o) end
                    end
                    _safeCall(function() callback(selected) end)
                else
                    -- Single select
                    _selectedOptions = {}
                    _selectedOptions[opt] = true
                    for o, btn in pairs(optionButtons) do
                        btn.BackgroundColor3 = (o == opt) and THEME.DropdownSelected or THEME.DropdownUnselected
                    end
                    updateDisplay()
                    -- Collapse
                    _expanded = false
                    optionsFrame.Visible = false
                    arrow.Text = "▼"
                    _safeCall(function() callback(opt) end)
                end
            end))
        end
    end

    buildOptions()

    track(headerBtn.MouseButton1Click:Connect(function()
        _expanded = not _expanded
        optionsFrame.Visible = _expanded
        arrow.Text = _expanded and "▲" or "▼"
    end))

    local function setValue(val)
        if type(val) == "table" then
            _selectedOptions = {}
            for _, v in ipairs(val) do
                _selectedOptions[v] = true
            end
        elseif type(val) == "string" then
            _selectedOptions = {}
            _selectedOptions[val] = true
        end
        updateDisplay()
        for o, btn in pairs(optionButtons) do
            btn.BackgroundColor3 = isSelected(o) and THEME.DropdownSelected or THEME.DropdownUnselected
        end
    end

    return {frame = container, setValue = setValue}
end

-- 6. createInput(parent, config)
function createInput(parent, config)
    config = config or {}
    local name = config.Name or "Input"
    local placeholderText = config.PlaceholderText or "Enter text..."
    local removeTextAfterFocusLost = config.RemoveTextAfterFocusLost or false
    local callback = config.Callback or function() end

    local row = Instance.new("Frame")
    row.Name = "Input_" .. name
    row.Size = UDim2.new(1, 0, 0, 56)
    row.BackgroundColor3 = THEME.ElementBackground
    row.BorderSizePixel = 0
    row.ZIndex = 13
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = THEME.ElementStroke
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -16, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 14
    label.Parent = row

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "TextBox"
    inputBox.Size = UDim2.new(1, -20, 0, 22)
    inputBox.Position = UDim2.new(0, 10, 0, 26)
    inputBox.BackgroundColor3 = THEME.InputBackground
    inputBox.BorderSizePixel = 0
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    inputBox.TextColor3 = THEME.TextPrimary
    inputBox.PlaceholderText = placeholderText
    inputBox.PlaceholderColor3 = THEME.PlaceholderColor
    inputBox.Text = ""
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 14
    inputBox.Parent = row

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputBox

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = THEME.InputStroke
    inputStroke.Thickness = 1
    inputStroke.Parent = inputBox

    track(inputBox.Focused:Connect(function()
        tweenProp(inputStroke, {Color = THEME.Accent}, TI_FAST)
    end))

    track(inputBox.FocusLost:Connect(function(enterPressed)
        tweenProp(inputStroke, {Color = THEME.InputStroke}, TI_FAST)
        local text = inputBox.Text
        _safeCall(function() callback(text) end)
        if removeTextAfterFocusLost then
            inputBox.Text = ""
        end
    end))

    return {frame = row, textBox = inputBox}
end

-- 7. createParagraph(parent, config)
function createParagraph(parent, config)
    config = config or {}
    local title = config.Title or ""
    local content = config.Content or ""

    local frame = Instance.new("Frame")
    frame.Name = "Paragraph"
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = THEME.ElementBackground
    frame.BorderSizePixel = 0
    frame.ZIndex = 13
    frame.Parent = parent

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = THEME.ElementStroke
    frameStroke.Thickness = 1
    frameStroke.Parent = frame

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.Padding = UDim.new(0, 4)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Parent = frame

    local innerPadding = Instance.new("UIPadding")
    innerPadding.PaddingTop = UDim.new(0, 8)
    innerPadding.PaddingBottom = UDim.new(0, 8)
    innerPadding.PaddingLeft = UDim.new(0, 10)
    innerPadding.PaddingRight = UDim.new(0, 10)
    innerPadding.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 0)
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.BackgroundTransparency = 1
    titleLabel.BorderSizePixel = 0
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = THEME.TextPrimary
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextWrapped = true
    titleLabel.LayoutOrder = 1
    titleLabel.ZIndex = 14
    titleLabel.Parent = frame

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.BackgroundTransparency = 1
    contentLabel.BorderSizePixel = 0
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 12
    contentLabel.TextColor3 = THEME.TextSecondary
    contentLabel.Text = content
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.LayoutOrder = 2
    contentLabel.ZIndex = 14
    contentLabel.Parent = frame

    return frame
end

-- 8. createColorPicker(parent, config)
function createColorPicker(parent, config)
    config = config or {}
    local name = config.Name or "Color"
    local currentColor = config.Color or THEME.Accent
    local callback = config.Callback or function() end

    -- Decompose initial color to HSV
    local _h, _s, _v = Color3.toHSV(currentColor)

    local row = Instance.new("Frame")
    row.Name = "ColorPicker_" .. name
    row.Size = UDim2.new(1, 0, 0, 36)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = THEME.ElementBackground
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    row.ZIndex = 13
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = THEME.ElementStroke
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 0, 36)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextPrimary
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 14
    label.Parent = row

    -- Color preview swatch
    local swatch = Instance.new("TextButton")
    swatch.Name = "Swatch"
    swatch.Size = UDim2.new(0, 24, 0, 24)
    swatch.Position = UDim2.new(1, -34, 0, 6)
    swatch.BackgroundColor3 = currentColor
    swatch.BorderSizePixel = 0
    swatch.Text = ""
    swatch.ZIndex = 15
    swatch.Parent = row

    local swatchCorner = Instance.new("UICorner")
    swatchCorner.CornerRadius = UDim.new(0, 4)
    swatchCorner.Parent = swatch

    local swatchStroke = Instance.new("UIStroke")
    swatchStroke.Color = THEME.ElementStroke
    swatchStroke.Thickness = 1
    swatchStroke.Parent = swatch

    -- Picker panel (hidden by default)
    local pickerPanel = Instance.new("Frame")
    pickerPanel.Name = "PickerPanel"
    pickerPanel.Size = UDim2.new(1, -10, 0, 130)
    pickerPanel.Position = UDim2.new(0, 5, 0, 40)
    pickerPanel.BackgroundColor3 = THEME.ElementBackground
    pickerPanel.BorderSizePixel = 0
    pickerPanel.Visible = false
    pickerPanel.ZIndex = 16
    pickerPanel.Parent = row

    local _pickerOpen = false

    -- SV Square (Saturation-Value)
    local svFrame = Instance.new("Frame")
    svFrame.Name = "SVFrame"
    svFrame.Size = UDim2.new(1, -10, 0, 90)
    svFrame.Position = UDim2.new(0, 5, 0, 5)
    svFrame.BackgroundColor3 = Color3.fromHSV(_h, 1, 1)
    svFrame.BorderSizePixel = 0
    svFrame.ZIndex = 17
    svFrame.ClipsDescendants = true
    svFrame.Parent = pickerPanel

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 4)
    svCorner.Parent = svFrame

    -- Saturation gradient layer (White → Hue color) - applied to svFrame
    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
    })
    satGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    satGradient.Parent = svFrame

    -- Value gradient overlay (Transparent → Black) - separate frame
    local valueOverlay = Instance.new("Frame")
    valueOverlay.Name = "ValueOverlay"
    valueOverlay.Size = UDim2.new(1, 0, 1, 0)
    valueOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    valueOverlay.BorderSizePixel = 0
    valueOverlay.ZIndex = 18
    valueOverlay.Parent = svFrame

    local valueGradient = Instance.new("UIGradient")
    valueGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
    valueGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    valueGradient.Rotation = 90
    valueGradient.Parent = valueOverlay

    local valueOverlayCorner = Instance.new("UICorner")
    valueOverlayCorner.CornerRadius = UDim.new(0, 4)
    valueOverlayCorner.Parent = valueOverlay

    -- SV cursor
    local svCursor = Instance.new("Frame")
    svCursor.Name = "Cursor"
    svCursor.Size = UDim2.new(0, 8, 0, 8)
    svCursor.Position = UDim2.new(_s, -4, 1 - _v, -4)
    svCursor.BackgroundColor3 = THEME.White
    svCursor.BorderSizePixel = 0
    svCursor.ZIndex = 20
    svCursor.Parent = svFrame

    local svCursorCorner = Instance.new("UICorner")
    svCursorCorner.CornerRadius = UDim.new(1, 0)
    svCursorCorner.Parent = svCursor

    local svCursorStroke = Instance.new("UIStroke")
    svCursorStroke.Color = Color3.new(0, 0, 0)
    svCursorStroke.Thickness = 1
    svCursorStroke.Parent = svCursor

    -- Hue bar
    local hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.Size = UDim2.new(1, -10, 0, 16)
    hueBar.Position = UDim2.new(0, 5, 0, 100)
    hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
    hueBar.BorderSizePixel = 0
    hueBar.ZIndex = 17
    hueBar.Parent = pickerPanel

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueBar

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })
    hueGradient.Parent = hueBar

    -- Hue cursor
    local hueCursor = Instance.new("Frame")
    hueCursor.Name = "HueCursor"
    hueCursor.Size = UDim2.new(0, 4, 1, 0)
    hueCursor.Position = UDim2.new(_h, -2, 0, 0)
    hueCursor.BackgroundColor3 = THEME.White
    hueCursor.BorderSizePixel = 0
    hueCursor.ZIndex = 19
    hueCursor.Parent = hueBar

    local hueCursorCorner = Instance.new("UICorner")
    hueCursorCorner.CornerRadius = UDim.new(0, 2)
    hueCursorCorner.Parent = hueCursor

    -- Preview swatch (in picker)
    local previewSwatch = Instance.new("Frame")
    previewSwatch.Name = "Preview"
    previewSwatch.Size = UDim2.new(0, 20, 0, 16)
    previewSwatch.Position = UDim2.new(1, -30, 0, 100)
    previewSwatch.BackgroundColor3 = currentColor
    previewSwatch.BorderSizePixel = 0
    previewSwatch.Visible = false
    previewSwatch.ZIndex = 17
    previewSwatch.Parent = pickerPanel

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 3)
    previewCorner.Parent = previewSwatch

    local function updateColor()
        local newColor = Color3.fromHSV(_h, _s, _v)
        swatch.BackgroundColor3 = newColor
        previewSwatch.BackgroundColor3 = newColor
        svFrame.BackgroundColor3 = Color3.fromHSV(_h, 1, 1)
        svCursor.Position = UDim2.new(_s, -4, 1 - _v, -4)
        hueCursor.Position = UDim2.new(_h, -2, 0, 0)
        _safeCall(function() callback(newColor) end)
    end

    -- SV drag
    local _svDragging = false
    local svBtn = Instance.new("TextButton")
    svBtn.Name = "SVBtn"
    svBtn.Size = UDim2.new(1, 0, 1, 0)
    svBtn.BackgroundTransparency = 1
    svBtn.BorderSizePixel = 0
    svBtn.Text = ""
    svBtn.ZIndex = 21
    svBtn.Parent = svFrame

    local function updateSV(inputX, inputY)
        local absPos = svFrame.AbsolutePosition
        local absSize = svFrame.AbsoluteSize
        if absSize.X <= 0 or absSize.Y <= 0 then return end
        _s = math.clamp((inputX - absPos.X) / absSize.X, 0, 1)
        _v = 1 - math.clamp((inputY - absPos.Y) / absSize.Y, 0, 1)
        updateColor()
    end

    track(svBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _svDragging = true
            updateSV(input.Position.X, input.Position.Y)
        end
    end))

    track(svBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _svDragging = false
        end
    end))

    -- Hue drag
    local _hueDragging = false
    local hueBtn = Instance.new("TextButton")
    hueBtn.Name = "HueBtn"
    hueBtn.Size = UDim2.new(1, 0, 1, 0)
    hueBtn.BackgroundTransparency = 1
    hueBtn.BorderSizePixel = 0
    hueBtn.Text = ""
    hueBtn.ZIndex = 19
    hueBtn.Parent = hueBar

    local function updateHue(inputX)
        local absPos = hueBar.AbsolutePosition.X
        local absSize = hueBar.AbsoluteSize.X
        if absSize <= 0 then return end
        _h = math.clamp((inputX - absPos) / absSize, 0, 1)
        updateColor()
    end

    track(hueBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _hueDragging = true
            updateHue(input.Position.X)
        end
    end))

    track(hueBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _hueDragging = false
        end
    end))

    -- Shared InputChanged for SV and Hue drag
    track(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if _svDragging then
                updateSV(input.Position.X, input.Position.Y)
            elseif _hueDragging then
                updateHue(input.Position.X)
            end
        end
    end))

    -- Toggle picker open/close
    track(swatch.MouseButton1Click:Connect(function()
        _pickerOpen = not _pickerOpen
        pickerPanel.Visible = _pickerOpen
        previewSwatch.Visible = _pickerOpen
        if _pickerOpen then
            row.Size = UDim2.new(1, 0, 0, 180)
        else
            row.Size = UDim2.new(1, 0, 0, 36)
        end
    end))

    local function setValue(color)
        _h, _s, _v = Color3.toHSV(color)
        updateColor()
    end

    return {frame = row, setValue = setValue}
end

-- 9. createLabel(parent, text)
function createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = THEME.TextSecondary
    label.Text = text or ""
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = true
    label.ZIndex = 13
    label.Parent = parent

    return label
end

-- ============================================================
-- Loading Screen Animation + Show Hub
-- ============================================================

task.spawn(function()
    -- Animate loading bar fill from 0% to 100% over 2 seconds
    _safeCall(function()
        TweenService:Create(loadingBarFill, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
    end)

    task.wait(2.2)

    -- Fade out loading screen
    _safeCall(function()
        local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(loadingFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(loadingTitle, fadeInfo, {TextTransparency = 1}):Play()
        TweenService:Create(loadingSubtitle, fadeInfo, {TextTransparency = 1}):Play()
        TweenService:Create(loadingBarBg, fadeInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(loadingBarFill, fadeInfo, {BackgroundTransparency = 1}):Play()
    end)

    task.wait(0.6)

    -- Destroy loading screen
    _safeCall(function()
        loadingFrame:Destroy()
    end)

    -- Show main hub
    mainFrame.Visible = true
    mainFrame.Size = IS_MOBILE and UDim2.new(0.92, 0, 0, 0) or UDim2.new(0, 550, 0, 0)
    tweenProp(mainFrame, {
        Size = IS_MOBILE and UDim2.new(0.92, 0, 0.7, 0) or UDim2.new(0, 550, 0, 380)
    }, TI_BOUNCE)
end)
-- ============================================================
end -- UI FRAMEWORK SCOPE

do -- WATERMARK + TOGGLE + TABS SCOPE
-- PART 10 — WATERMARK (V4)
-- ============================================================
local _wmGui
_safeCall(function()
    _wmGui = Instance.new("ScreenGui")
    _wmGui.Name = "AmethystWatermarkV4"
    _wmGui.ResetOnSpawn = false
    _wmGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _wmGui.DisplayOrder = 999
    _wmGui.IgnoreGuiInset = true
    local pOk = _safeCall(function() _wmGui.Parent = CoreGui end)
    if not pOk then
        _safeCall(function() _wmGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end

    -- Background pill
    local wmBg = Instance.new("Frame")
    wmBg.Size = UDim2.new(0, 180, 0, 34)
    wmBg.Position = UDim2.new(1, -190, 1, -44)
    wmBg.BackgroundColor3 = Color3.fromRGB(20, 8, 30)
    wmBg.BackgroundTransparency = 0.3
    wmBg.BorderSizePixel = 0
    wmBg.Parent = _wmGui

    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(0, 8)
    wmCorner.Parent = wmBg

    local wmStroke = Instance.new("UIStroke")
    wmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    wmStroke.Color = THEME.AccentDim
    wmStroke.Thickness = 1.5
    wmStroke.Transparency = 0.4
    wmStroke.Parent = wmBg

    -- Glow frame behind watermark
    local wmGlow = Instance.new("Frame")
    wmGlow.Size = UDim2.new(1, 12, 1, 12)
    wmGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    wmGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    wmGlow.BackgroundColor3 = THEME.Accent
    wmGlow.BackgroundTransparency = 0.9
    wmGlow.BorderSizePixel = 0
    wmGlow.ZIndex = 9999
    wmGlow.Parent = wmBg
    local wmGlowCorner = Instance.new("UICorner")
    wmGlowCorner.CornerRadius = UDim.new(0, 10)
    wmGlowCorner.Parent = wmGlow

    -- TweenService looping pulse
    TweenService:Create(wmGlow, TI_PULSE, {BackgroundTransparency = 0.7}):Play()

    -- Amethyst gradient on watermark background
    local wmGrad = Instance.new("UIGradient")
    wmGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 8, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45, 18, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 8, 40)),
    })
    wmGrad.Rotation = 0
    wmGrad.Parent = wmBg

    -- Gradient rotation via TweenService (infinite)
    TweenService:Create(wmGrad,
        TweenInfo.new(18, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        {Rotation = 360}
    ):Play()

    -- Accent bar (left side)
    local wmAccent = Instance.new("Frame")
    wmAccent.Name = "Accent"
    wmAccent.Size = UDim2.new(0, 3, 0.6, 0)
    wmAccent.Position = UDim2.new(0, 8, 0.2, 0)
    wmAccent.BackgroundColor3 = THEME.Accent
    wmAccent.BorderSizePixel = 0
    wmAccent.Parent = wmBg
    local acCorner = Instance.new("UICorner")
    acCorner.CornerRadius = UDim.new(0, 2)
    acCorner.Parent = wmAccent

    -- Main text
    local wmText = Instance.new("TextLabel")
    wmText.Size = UDim2.new(1, -20, 1, 0)
    wmText.Position = UDim2.new(0, 18, 0, 0)
    wmText.BackgroundTransparency = 1
    wmText.Text = "Amethyst | Luyy"
    wmText.TextColor3 = THEME.Lavender
    wmText.TextTransparency = 0.15
    wmText.TextSize = 15
    wmText.Font = Enum.Font.GothamBold
    wmText.TextXAlignment = Enum.TextXAlignment.Left
    wmText.Parent = wmBg

    -- Premium Amethyst UIStroke on watermark text (contextual breathing glow)
    local wmTextStroke = Instance.new("UIStroke")
    wmTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    wmTextStroke.Color = THEME.Accent
    wmTextStroke.Thickness = 1.2
    wmTextStroke.Transparency = 0.5
    wmTextStroke.Parent = wmText

    -- Breathing animation: transparency oscillates 0.5 → 0.1 → 0.5 (infinite)
    TweenService:Create(wmTextStroke, TI_PULSE, {Transparency = 0.1}):Play()

    -- Pulse animation on accent bar (TweenService)
    tweenProp(wmAccent, {BackgroundTransparency = 0.5}, TI_PULSE)

    -- Stroke + text pulse via TweenService
    wmStroke.Color = Color3.fromRGB(60, 25, 110)
    -- Breathing glow: color + transparency oscillation
    TweenService:Create(wmStroke, TI_PULSE, {
        Color = Color3.fromRGB(140, 75, 210),
        Transparency = 0.1
    }):Play()
    wmText.TextTransparency = 0.1
    TweenService:Create(wmText, TI_PULSE, {TextTransparency = 0.25}):Play()
end)

-- ============================================================
-- PART 11 — FLOATING TOGGLE BUTTON (V4)
-- ============================================================
_safeCall(function()
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "AmethystToggleV4"
    toggleGui.ResetOnSpawn = false
    toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGui.DisplayOrder = 1000
    local _tgOk = _safeCall(function() toggleGui.Parent = CoreGui end)
    if not _tgOk then
        _safeCall(function() toggleGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end

    local btnSize = IS_MOBILE and 54 or 42

    -- Glow frame behind button
    local glowFrame = Instance.new("Frame")
    glowFrame.Size = UDim2.new(0, btnSize + 12, 0, btnSize + 12)
    glowFrame.Position = UDim2.new(0, 4, 0.4, -6)
    glowFrame.BackgroundColor3 = THEME.Accent
    glowFrame.BackgroundTransparency = 0.7
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = 99
    glowFrame.Parent = toggleGui
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0.5, 0)
    glowCorner.Parent = glowFrame

    -- Main button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    toggleBtn.Position = UDim2.new(0, 10, 0.4, 0)
    toggleBtn.BackgroundColor3 = THEME.Main
    toggleBtn.TextColor3 = THEME.Accent
    toggleBtn.Text = "A"
    toggleBtn.TextSize = IS_MOBILE and 24 or 18
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.ZIndex = 100
    toggleBtn.Parent = toggleGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = toggleBtn

    -- Gradient overlay (ONLY ONE — V4 fix for duplicate UIGradient)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 20, 70)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 40, 140)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 20, 70)),
    })
    gradient.Rotation = 135
    gradient.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Accent
    stroke.Thickness = 2
    stroke.Parent = toggleBtn

    -- Custom drag system using UserInputService (100% mobile + PC)
    local dragging = false
    local dragStart, startBtnPos, startGlowPos
    local totalDragDist = 0

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startBtnPos = toggleBtn.Position
            startGlowPos = glowFrame.Position
            totalDragDist = 0
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    -- Track this persistent UIS connection for cleanup
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            totalDragDist = math.max(totalDragDist, delta.Magnitude)
            toggleBtn.Position = UDim2.new(
                startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X,
                startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y
            )
            glowFrame.Position = UDim2.new(
                startGlowPos.X.Scale, startGlowPos.X.Offset + delta.X,
                startGlowPos.Y.Scale, startGlowPos.Y.Offset + delta.Y
            )
        end
    end))

    -- Click to toggle menu visibility (with TweenService animation)
    local menuVisible = true
    toggleBtn.MouseButton1Click:Connect(function()
        if totalDragDist > 10 then totalDragDist = 0; return end -- was a drag, not click
        menuVisible = not menuVisible

        -- Animate button press
        tweenProp(toggleBtn, {Size = UDim2.new(0, btnSize - 6, 0, btnSize - 6)}, TI_FAST)
        task.delay(0.15, function()
            tweenProp(toggleBtn, {Size = UDim2.new(0, btnSize, 0, btnSize)}, TI_BOUNCE)
        end)

        -- Toggle custom hub visibility
        mainFrame.Visible = menuVisible

        -- Visual feedback
        if menuVisible then
            tweenProp(toggleBtn, {BackgroundColor3 = THEME.Main}, TI_SMOOTH)
            tweenProp(toggleBtn, {TextColor3 = THEME.Accent}, TI_SMOOTH)
            tweenProp(glowFrame, {BackgroundTransparency = 0.7}, TI_SMOOTH)
        else
            tweenProp(toggleBtn, {BackgroundColor3 = Color3.fromRGB(30, 12, 45)}, TI_SMOOTH)
            tweenProp(toggleBtn, {TextColor3 = THEME.AccentDim}, TI_SMOOTH)
            tweenProp(glowFrame, {BackgroundTransparency = 0.95}, TI_SMOOTH)
        end
    end)

    -- [V4 NEW] RightShift keybind to toggle hub visibility
    track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            menuVisible = not menuVisible
            mainFrame.Visible = menuVisible
            -- same visual feedback as toggle button click
            if menuVisible then
                tweenProp(toggleBtn, {BackgroundColor3 = THEME.Main}, TI_SMOOTH)
                tweenProp(toggleBtn, {TextColor3 = THEME.Accent}, TI_SMOOTH)
                tweenProp(glowFrame, {BackgroundTransparency = 0.7}, TI_SMOOTH)
            else
                tweenProp(toggleBtn, {BackgroundColor3 = Color3.fromRGB(30, 12, 45)}, TI_SMOOTH)
                tweenProp(toggleBtn, {TextColor3 = THEME.AccentDim}, TI_SMOOTH)
                tweenProp(glowFrame, {BackgroundTransparency = 0.95}, TI_SMOOTH)
            end
        end
    end))

    -- Pulse glow animation
    tweenProp(glowFrame, {BackgroundTransparency = 0.85}, TI_PULSE)

    -- Stroke pulse via TweenService
    stroke.Color = Color3.fromRGB(120, 60, 185)
    TweenService:Create(stroke, TI_PULSE, {Color = Color3.fromRGB(180, 100, 255)}):Play()

    -- Auto-scale mobile jump button
    if IS_MOBILE then
        task.spawn(function()
            task.wait(2)
            scaleJumpButton(1.3)
        end)
    end
end)

-- ============================================================
-- PART 13 — TAB DEFINITIONS (all 7 tabs)
-- ============================================================

-- TAB 1: HOME ------------------------------------------------
createSection(tabPages.Home, "Welcome")
createParagraph(tabPages.Home, {
    Title = "  Amethyst  |  Universal  ",
    Content = "Professional-Grade Universal Mod Menu\n7 Tabs | Combat + Visuals + Gameplay + Performance\nGame: " .. tostring(game.PlaceId) .. "\nPlayers: " .. #Players:GetPlayers(),
})

createSection(tabPages.Home, "Quick Presets")

createButton(tabPages.Home, {
    Name = "Enable All FPS Optimizations",
    Callback = function()
        S.FPSBoost = true; S.LightingUltra = true
        S.TexturePurge = true; S.ParticlePurge = true; S.TerrainSimple = true
        task.spawn(runOmegaFPS); enableFPSListener()
        applyLightingUltra()
        local tc = purgeTextures(); enableTexListener()
        local pc = purgeParticles(); simplifyTerrain()
        notify("Omega FPS ON", tc .. " textures + " .. pc .. " particles removed.", 4)
    end,
})

createButton(tabPages.Home, {
    Name = "Enable Full ESP Suite",
    Callback = function()
        S.ESP_Box = true; S.ESP_Name = true; S.ESP_Health = true
        S.ESP_Tracer = true; S.Wallhack = true
        for _, esp in pairs(ESPPool) do
            if esp.highlight then esp.highlight.Enabled = true end
        end
        notify("Full ESP ON", "Box + Name + Health + Tracers + Wallhack", 3)
    end,
})

createButton(tabPages.Home, {
    Name = "Enable Combat Suite",
    Callback = function()
        S.Aimbot = true; S.SilentAim = true; S.FOV_Show = true
        S.FOV_Lock = true; S.NoRecoil = true; S.NoSpread = true
        notify("Combat Suite ON", "Aimbot + Silent Aim + FOV Lock + No Recoil", 3)
    end,
})

createButton(tabPages.Home, {
    Name = "Enable Movement Suite",
    Callback = function()
        S.Speed = true; S.SpeedVal = 50; S.InfJump = true; S.NoFallDmg = true
        _safeCall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end)
        notify("Movement Suite ON", "Speed + Inf Jump + No Fall Damage", 3)
    end,
})

createButton(tabPages.Home, {
    Name = "Disable Everything",
    Callback = function()
        S.FPSBoost = false; S.LightingUltra = false
        S.TexturePurge = false; S.ParticlePurge = false; S.TerrainSimple = false
        S.ESP_Box = false; S.ESP_Name = false; S.ESP_Health = false
        S.ESP_Tracer = false; S.ESP_Skeleton = false; S.ESP_Distance = false
        S.Wallhack = false; S.Aimbot = false; S.SilentAim = false
        S.TriggerBot = false; S.KillAura = false; S.Crosshair = false
        S.Radar = false; S.EnemyAlert = false
        S.Fly = false; S.Noclip = false; S.GodMode = false
        S.NoRecoil = false; S.NoSpread = false; S.FastReload = false; S.InfAmmo = false
        _safeCall(stopFly); _safeCall(disableNoclip); _safeCall(disableGodMode)
        disableFPSListener(); disableTexListener(); restoreLighting()
        for _, esp in pairs(ESPPool) do
            hideESP(esp)
            if esp.highlight then esp.highlight.Enabled = false end
        end
        notify("All OFF", "Every feature disabled.", 3)
    end,
})

-- TAB 2: COMBAT ----------------------------------------------
createSection(tabPages.Combat, "-- Aimbot (Camera.CFrame + ClosestPlayer) --")

createToggle(tabPages.Combat, {
    Name = "Aimbot", CurrentValue = false,
    Callback = debounced("Aimbot", function(v) S.Aimbot = v; notifyToggle("Aimbot", v) end),
})

createSlider(tabPages.Combat, {
    Name = "Smoothness (1=snap, 10=slow)",
    Range = {1, 10}, Increment = 1, CurrentValue = 3,
    Callback = function(v) S.AimbotSmooth = v end,
})

createDropdown(tabPages.Combat, {
    Name = "Aim Part",
    Options = {"Head", "Torso"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Callback = function(v) S.AimPart = type(v) == "table" and v[1] or tostring(v) end,
})

createToggle(tabPages.Combat, {
    Name = "Aim Prediction (Lead Targets)", CurrentValue = false,
    Callback = debounced("AimPredict", function(v) S.AimPredict = v; notifyToggle("Aim Prediction", v) end),
})

createSlider(tabPages.Combat, {
    Name = "Prediction Strength",
    Range = {1, 30}, Increment = 1, CurrentValue = 12,
    Callback = function(v) S.AimPredictStr = v / 100 end,
})

createSection(tabPages.Combat, "-- Aimlock (FOV Circle) --")

createToggle(tabPages.Combat, {
    Name = "Show FOV Circle", CurrentValue = false,
    Callback = debounced("FOV_Show", function(v) S.FOV_Show = v; notifyToggle("FOV Circle", v) end),
})

createToggle(tabPages.Combat, {
    Name = "FOV Lock (Only Aim Inside Circle)", CurrentValue = false,
    Callback = debounced("FOV_Lock", function(v) S.FOV_Lock = v; notifyToggle("FOV Lock", v) end),
})

createSlider(tabPages.Combat, {
    Name = "FOV Radius (px)",
    Range = {40, 400}, Increment = 10, CurrentValue = 120,
    Callback = function(v) S.FOV_Radius = v end,
})

createSection(tabPages.Combat, "Silent Aim")

createToggle(tabPages.Combat, {
    Name = "Silent Aim (1-frame snap)", CurrentValue = false,
    Callback = debounced("SilentAim", function(v) S.SilentAim = v; notifyToggle("Silent Aim", v) end),
})

createSection(tabPages.Combat, "Auto Fire")

createToggle(tabPages.Combat, {
    Name = "TriggerBot (Auto Fire on Hit)", CurrentValue = false,
    Callback = debounced("TriggerBot", function(v) S.TriggerBot = v; notifyToggle("TriggerBot", v) end),
})

createToggle(tabPages.Combat, {
    Name = "Kill Aura (Fire Nearby)", CurrentValue = false,
    Callback = debounced("KillAura", function(v) S.KillAura = v; notifyToggle("Kill Aura", v) end),
})

createSlider(tabPages.Combat, {
    Name = "Kill Aura Range (m)",
    Range = {10, 80}, Increment = 5, CurrentValue = 25,
    Callback = function(v) S.KillAuraRange = v end,
})

createSection(tabPages.Combat, "Hitbox")

createToggle(tabPages.Combat, {
    Name = "Hitbox Expand", CurrentValue = false,
    Callback = debounced("Hitbox", function(v) S.Hitbox = v; applyAllHitboxes(); notifyToggle("Hitbox Expand", v) end),
})

createSlider(tabPages.Combat, {
    Name = "Hitbox Scale",
    Range = {1, 8}, Increment = 1, CurrentValue = 2,
    Callback = function(v) S.HitboxScale = v; if S.Hitbox then applyAllHitboxes() end end,
})

-- TAB 3: VISUALS --------------------------------------------
createSection(tabPages.Visuals, "Wallhack")

createToggle(tabPages.Visuals, {
    Name = "Wallhack (Highlight Through Walls)", CurrentValue = false,
    Callback = debounced("Wallhack", function(v)
        S.Wallhack = v
        for _, esp in pairs(ESPPool) do
            if esp.highlight then esp.highlight.Enabled = v end
        end
        notifyToggle("Wallhack", v)
    end),
})

createSection(tabPages.Visuals, "-- ESP (Amethyst-Colored Outlines) --")

createToggle(tabPages.Visuals, { Name = "Box ESP", CurrentValue = false,
    Callback = function(v) S.ESP_Box = v; notifyToggle("Box ESP", v)
    if not v then for _, e in pairs(ESPPool) do e.box.Visible = false end end end })
createToggle(tabPages.Visuals, { Name = "Name Tags", CurrentValue = false,
    Callback = function(v) S.ESP_Name = v; notifyToggle("Name Tags", v)
    if not v then for _, e in pairs(ESPPool) do e.nameLabel.Visible = false end end end })
createToggle(tabPages.Visuals, { Name = "Health Bars", CurrentValue = false,
    Callback = function(v) S.ESP_Health = v; notifyToggle("Health Bars", v)
    if not v then for _, e in pairs(ESPPool) do e.healthBg.Visible = false; e.healthBar.Visible = false end end end })
createToggle(tabPages.Visuals, { Name = "Skeleton", CurrentValue = false,
    Callback = function(v) S.ESP_Skeleton = v; notifyToggle("Skeleton", v)
    if not v then for _, e in pairs(ESPPool) do for _, b in ipairs(e.bones) do b.Visible = false end end end end })
createToggle(tabPages.Visuals, { Name = "Tracers (Amethyst)", CurrentValue = false,
    Callback = function(v) S.ESP_Tracer = v; notifyToggle("Tracers", v)
    if not v then for _, e in pairs(ESPPool) do e.tracer.Visible = false end end end })
createToggle(tabPages.Visuals, { Name = "Distance Tags", CurrentValue = false,
    Callback = function(v) S.ESP_Distance = v; notifyToggle("Distance Tags", v)
    if not v then for _, e in pairs(ESPPool) do e.distLabel.Visible = false end end end })
createToggle(tabPages.Visuals, { Name = "Visible Check (Hide Behind Walls)", CurrentValue = false,
    Callback = function(v) S.VisCheck = v; notifyToggle("Visible Check", v) end })

createSection(tabPages.Visuals, "Color")

createColorPicker(tabPages.Visuals, {
    Name = "ESP Color",
    Color = THEME.ESPColor,
    Callback = function(c)
        S.ESPColor = c
        for _, esp in pairs(ESPPool) do
            esp.box.Color = c
            esp.tracer.Color = Color3.new(c.R*0.85, c.G*0.85, c.B*0.85)
            esp.nameLabel.Color = Color3.new(math.min(c.R+0.15,1), math.min(c.G+0.15,1), math.min(c.B+0.15,1))
            for _, bone in ipairs(esp.bones) do bone.Color = c end
            esp.radarDot.Color = c
            if esp.highlight then _safeCall(function() esp.highlight.FillColor = c end) end
        end
    end,
})

createSection(tabPages.Visuals, "Crosshair")

createToggle(tabPages.Visuals, { Name = "Crosshair", CurrentValue = false,
    Callback = function(v) S.Crosshair = v; notifyToggle("Crosshair", v) end })
createSlider(tabPages.Visuals, { Name = "Line Length", Range = {4, 20}, Increment = 1, CurrentValue = 8,
    Callback = function(v) S.XH_Size = v end })
createSlider(tabPages.Visuals, { Name = "Gap", Range = {0, 10}, Increment = 1, CurrentValue = 4,
    Callback = function(v) S.XH_Gap = v end })

createSection(tabPages.Visuals, "Fullbright")

createToggle(tabPages.Visuals, {
    Name = "Fullbright (No Darkness)", CurrentValue = false,
    Callback = function(v) S.Fullbright = v; applyFullbright(v); notifyToggle("Fullbright", v) end,
})

createSection(tabPages.Visuals, "Alert")

createToggle(tabPages.Visuals, { Name = "Enemy Proximity Alert", CurrentValue = false,
    Callback = function(v) S.EnemyAlert = v; notifyToggle("Enemy Alert", v) end })
createSlider(tabPages.Visuals, { Name = "Alert Distance (m)", Range = {15, 80}, Increment = 5, CurrentValue = 40,
    Callback = function(v) S.EnemyAlertDist = v end })

createSection(tabPages.Visuals, "Radar")

createToggle(tabPages.Visuals, { Name = "Radar", CurrentValue = false,
    Callback = function(v) S.Radar = v; notifyToggle("Radar", v) end })
createSlider(tabPages.Visuals, { Name = "Radar Range (m)", Range = {40, 300}, Increment = 10, CurrentValue = 120,
    Callback = function(v) S.RadarRange = v end })
createSlider(tabPages.Visuals, { Name = "Radar Size (px)", Range = {80, 200}, Increment = 10, CurrentValue = 130,
    Callback = function(v) S.RadarSize = v end })

createSection(tabPages.Visuals, "HUD")

createToggle(tabPages.Visuals, { Name = "Player / Bot Counter", CurrentValue = false,
    Callback = function(v) S.PlayerBotHUD = v; notifyToggle("Player/Bot Counter", v) end })
createToggle(tabPages.Visuals, { Name = "Kill / Death Counter", CurrentValue = false,
    Callback = function(v) S.KillCounter = v; notifyToggle("Kill Counter", v) end })

-- TAB 4: GAMEPLAY -------------------------------------------
createSection(tabPages.Gameplay, "Weapon Modifiers")

createToggle(tabPages.Gameplay, { Name = "No Recoil", CurrentValue = false,
    Callback = function(v) S.NoRecoil = v; notifyToggle("No Recoil", v) end })
createToggle(tabPages.Gameplay, { Name = "No Spread", CurrentValue = false,
    Callback = function(v) S.NoSpread = v; notifyToggle("No Spread", v) end })
createToggle(tabPages.Gameplay, { Name = "Fast Reload", CurrentValue = false,
    Callback = function(v) S.FastReload = v; notifyToggle("Fast Reload", v) end })
createToggle(tabPages.Gameplay, { Name = "Infinite Ammo", CurrentValue = false,
    Callback = function(v) S.InfAmmo = v; notifyToggle("Infinite Ammo", v) end })

createSection(tabPages.Gameplay, "Speed")

createToggle(tabPages.Gameplay, { Name = "Speed Boost", CurrentValue = false,
    Callback = function(v)
        S.Speed = v
        if not v then
            _safeCall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end)
        end
        notifyToggle("Speed Boost", v)
    end })
createSlider(tabPages.Gameplay, {
    Name = "Speed Value (WalkSpeed)",
    Range = {16, 200}, Increment = 2, CurrentValue = 16,
    Callback = function(v) S.SpeedVal = v end,
})

createSection(tabPages.Gameplay, "Jump")

createToggle(tabPages.Gameplay, { Name = "Jump Boost", CurrentValue = false,
    Callback = debounced("Jump", function(v)
        S.Jump = v
        if v then
            _safeCall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = S.JumpVal
                end
            end)
        else
            _safeCall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.UseJumpPower = true; hum.JumpPower = 50 end
            end)
        end
        notifyToggle("Jump Boost", v)
    end) })
createSlider(tabPages.Gameplay, { Name = "Jump Power", Range = {50, 250}, Increment = 5, CurrentValue = 50,
    Callback = function(v) S.JumpVal = v end })

createToggle(tabPages.Gameplay, {
    Name = "Infinite Jump", CurrentValue = false,
    Callback = function(v) S.InfJump = v; notifyToggle("Infinite Jump", v) end,
})

createToggle(tabPages.Gameplay, { Name = "Auto Strafe", CurrentValue = false,
    Callback = function(v) S.AutoStrafe = v; notifyToggle("Auto Strafe", v) end })

createToggle(tabPages.Gameplay, {
    Name = "No Fall Damage", CurrentValue = false,
    Callback = function(v)
        S.NoFallDmg = v; notifyToggle("No Fall Damage", v)
        if v then
            _safeCall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end
            end)
        end
    end,
})

createSection(tabPages.Gameplay, "Respawn")

createToggle(tabPages.Gameplay, {
    Name = "Fast Respawn", CurrentValue = false,
    Callback = function(v) S.FastRespawn = v; notifyToggle("Fast Respawn", v) end,
})

createSection(tabPages.Gameplay, "Mobile Tools")

createSlider(tabPages.Gameplay, {
    Name = "Jump Button Scale (1x to 3x)",
    Range = {1, 3}, Increment = 0.5, CurrentValue = 1,
    Callback = function(v)
        S.JumpScale = v; scaleJumpButton(v)
        notify("Jump Scale", v .. "x", 3)
    end,
})

createSection(tabPages.Gameplay, "Fly")

createToggle(tabPages.Gameplay, {
    Name = "Fly", CurrentValue = false,
    Callback = function(v)
        S.Fly = v
        if v then startFly(); notify("Fly ON", "WASD to move, Space=Up, Shift=Down", 3)
        else stopFly(); notify("Fly OFF", "Disabled", 3) end
    end,
})

createSlider(tabPages.Gameplay, {
    Name = "Fly Speed",
    Range = {10, 200}, Increment = 10, CurrentValue = 50,
    Callback = function(v) S.FlySpeed = v end,
})

createSection(tabPages.Gameplay, "Noclip")

createToggle(tabPages.Gameplay, {
    Name = "Noclip (Walk Through Walls)", CurrentValue = false,
    Callback = function(v)
        S.Noclip = v
        if v then enableNoclip() else disableNoclip() end
        notifyToggle("Noclip", v)
    end,
})

createSection(tabPages.Gameplay, "God Mode")

createToggle(tabPages.Gameplay, {
    Name = "God Mode (Client-Side)", CurrentValue = false,
    Callback = function(v)
        S.GodMode = v
        if v then enableGodMode() else disableGodMode() end
        notifyToggle("God Mode", v)
    end,
})

createSection(tabPages.Gameplay, "Teleport")

local _tpTarget = ""
createInput(tabPages.Gameplay, {
    Name = "Player Name",
    PlaceholderText = "Enter player name...",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) _tpTarget = t end,
})

createButton(tabPages.Gameplay, {
    Name = "Teleport to Player",
    Callback = function()
        if _tpTarget ~= "" then teleportToPlayer(_tpTarget)
        else notify("Error", "Enter a player name first.", 3) end
    end,
})

createButton(tabPages.Gameplay, {
    Name = "Teleport to Nearest Player",
    Callback = function() teleportToNearest() end,
})

-- TAB 5: PERFORMANCE ----------------------------------------
createSection(tabPages.Performance, "-- Omega AntiLag Engine --")
createLabel(tabPages.Performance, "Smart filter protects DamageBrick, Lava, Kill parts.")

createToggle(tabPages.Performance, {
    Name = "Omega FPS Boost (SmoothPlastic + No Shadows)", CurrentValue = false,
    Callback = function(v)
        S.FPSBoost = v
        if v then task.spawn(runOmegaFPS); enableFPSListener() else disableFPSListener() end
        notifyToggle("Omega FPS Boost", v)
    end,
})

createSection(tabPages.Performance, "Lighting")

createToggle(tabPages.Performance, {
    Name = "Lighting Ultra", CurrentValue = false,
    Callback = function(v)
        S.LightingUltra = v
        if v then applyLightingUltra() else restoreLighting() end
        notifyToggle("Lighting Ultra", v)
    end,
})

createSection(tabPages.Performance, "Purge")

createToggle(tabPages.Performance, {
    Name = "Texture Purge", CurrentValue = false,
    Callback = function(v)
        S.TexturePurge = v
        if v then local n = purgeTextures(); enableTexListener(); notify("Textures Purged", n .. " hidden.", 3)
        else disableTexListener(); notify("Texture Purge OFF", "Disabled", 3) end
    end,
})

createToggle(tabPages.Performance, {
    Name = "Particle Purge", CurrentValue = false,
    Callback = function(v)
        S.ParticlePurge = v
        if v then local n = purgeParticles(); notify("Particles Purged", n .. " disabled.", 3)
        else notify("Particle Purge OFF", "Disabled", 3) end
    end,
})

createToggle(tabPages.Performance, {
    Name = "Simplify Terrain", CurrentValue = false,
    Callback = function(v)
        S.TerrainSimple = v
        if v then simplifyTerrain(); notify("Terrain Simplified", "Water and decoration disabled", 3) end
    end,
})

createSection(tabPages.Performance, "Manual Actions")

createButton(tabPages.Performance, {
    Name = "Destroy All Decals",
    Callback = function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            _safeCall(function() if d:IsA("Decal") or d:IsA("Texture") then d:Destroy(); n = n+1 end end)
        end
        notify("Done", n .. " decals destroyed.", 3)
    end,
})

createButton(tabPages.Performance, {
    Name = "Remove SurfaceAppearances",
    Callback = function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            _safeCall(function() if d:IsA("SurfaceAppearance") or d:IsA("SpecialMesh") then d.Parent = nil; n = n+1 end end)
        end
        notify("Done", n .. " removed.", 3)
    end,
})

createButton(tabPages.Performance, {
    Name = "Set Rendering to Level 1",
    Callback = function()
        local ok = _safeCall(function() settings().Rendering.QualityLevel = 1 end)
        if ok then
            notify("Rendering", "Quality set to minimum.", 3)
        else
            notify("Error", "Not supported on this executor", 3)
        end
    end,
})

-- TAB 6: SERVER ---------------------------------------------
createSection(tabPages.Server, "Find Smallest Server")

createButton(tabPages.Server, {
    Name = "Find Smallest and Join",
    Callback = function() task.spawn(function() findSmallestAndJoin(game.PlaceId) end) end,
})

local serverBtns = {}

createButton(tabPages.Server, {
    Name = "Scan Servers (Preview)",
    Callback = function()
        task.spawn(function()
            if serverFetching then notify("Wait", "Scanning...", 2) return end
            notify("Scanning...", "", 2)
            local list = fetchSmallestServers(game.PlaceId)
            if not list or #list == 0 then notify("No Servers", "", 3) return end
            local msg = #list .. " servers\n"
            for i = 1, math.min(#list, 5) do
                msg = msg .. "#" .. i .. ": " .. list[i].playing .. "/" .. list[i].maxPlayers .. "\n"
                -- Update server button labels if they exist
                if serverBtns[i] then
                    _safeCall(function()
                        serverBtns[i].Text = "Server #" .. i .. " (" .. list[i].playing .. " players)"
                    end)
                end
            end
            notify("Scan Done", msg, 8)
        end)
    end,
})

createSection(tabPages.Server, "Custom Game")

local customPID = ""
createInput(tabPages.Server, {
    Name = "Place ID",
    PlaceholderText = "e.g. 2753915549",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) customPID = t end,
})

createButton(tabPages.Server, {
    Name = "Find Smallest in Custom Game",
    Callback = function()
        local pid = tonumber(customPID)
        if not pid or pid <= 0 then notify("Invalid", "Enter a valid Place ID.", 3) return end
        task.spawn(function() findSmallestAndJoin(pid) end)
    end,
})

createSection(tabPages.Server, "Quick Join (from last scan)")

for i = 1, 5 do
    local btn = createButton(tabPages.Server, {
        Name = "Server #" .. i,
        Callback = function()
            if #S.ServerList < i then notify("Scan First", "Not enough servers.", 3) return end
            local sv = S.ServerList[i]
            notify("Server #" .. i, sv.playing .. "/" .. sv.maxPlayers, 2)
            task.spawn(function() teleportToServer(game.PlaceId, sv.id) end)
        end,
    })
    serverBtns[i] = btn
end

createSection(tabPages.Server, "Hop / Rejoin")

createButton(tabPages.Server, {
    Name = "Server Hop (Smallest)",
    Callback = function() task.spawn(function() findSmallestAndJoin(game.PlaceId) end) end,
})

createButton(tabPages.Server, {
    Name = "Rejoin Current Server",
    Callback = function()
        notify("Rejoining...", "", 3)
        task.wait(0.5)
        _safeCall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    end,
})

createSection(tabPages.Server, "Auto Hop")

createToggle(tabPages.Server, {
    Name = "Auto Hop if Too Many Players", CurrentValue = false,
    Callback = function(v)
        S.AutoHop = v; notifyToggle("Auto Hop", v)
    end,
})

createSlider(tabPages.Server, {
    Name = "Auto Hop Threshold",
    Range = {2, 30}, Increment = 1, CurrentValue = 6,
    Callback = function(v) S.AutoHopMax = v end,
})

createSection(tabPages.Server, "Utility")

createToggle(tabPages.Server, {
    Name = "Anti-AFK", CurrentValue = false,
    Callback = function(v) S.AntiAFK = v; notifyToggle("Anti-AFK", v) end,
})

createToggle(tabPages.Server, {
    Name = "Silent Mode (No Notifications)", CurrentValue = false,
    Callback = debounced("SilentMode", function(v)
        S.SilentMode = v
    end),
})

createButton(tabPages.Server, {
    Name = "Show Player List",
    Callback = function()
        local playerNames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            playerNames[#playerNames + 1] = p.DisplayName
        end
        notify("Players (" .. #Players:GetPlayers() .. ")", table.concat(playerNames, ", "), 8)
    end,
})

createButton(tabPages.Server, {
    Name = "Copy Job ID",
    Callback = function()
        _safeCall(function()
            if setclipboard then setclipboard(game.JobId); notify("Copied", "Job ID copied", 3)
            elseif toclipboard then toclipboard(game.JobId); notify("Copied", "Job ID copied", 3)
            else notify("Error", "Clipboard not supported.", 3) end
        end)
    end,
})

createParagraph(tabPages.Server, {
    Title = "Server Info",
    Content = "Place: " .. tostring(game.PlaceId)
        .. "\nJob: " .. string.sub(game.JobId, 1, 20) .. "..."
        .. "\nPlayers: " .. #Players:GetPlayers(),
})

-- TAB 7: CREDITS --------------------------------------------
createSection(tabPages.Credits, "Amethyst Ultimate V4.0")
createParagraph(tabPages.Credits, {
    Title = "About",
    Content = "Professional-Grade Universal Mod Menu\n\nFeatures:\n- Deep Amethyst Purple Theme\n- 100% Custom UI Framework\n- Omega AntiLag Engine\n- Aimbot + Aimlock (Camera.CFrame)\n- Amethyst Box ESP + Tracers\n- Mobile-First Design\n\nUI: 100% Custom Built\nTheme: Deep Amethyst Purple\nVersion: 4.0.0",
})
createSection(tabPages.Credits, "Owner")
createParagraph(tabPages.Credits, {
    Title = "Lutfie kenape ek",
    Content = "Script owner and creator.\nAll rights reserved.",
})

-- ============================================================
end -- WATERMARK + TOGGLE + TABS SCOPE

do -- LOOPS + HOOKS + CLEANUP SCOPE
-- PART 14 — hookCharacterModLoop + Character Hooks
-- ============================================================
local _modChangedConns = {}

local function hookCharacterModLoop(char)
    -- Disconnect old Changed listeners
    for _, conn in ipairs(_modChangedConns) do
        _safeCall(function() conn:Disconnect() end)
    end
    _modChangedConns = {}

    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    -- Block game from resetting WalkSpeed
    table.insert(_modChangedConns, hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if S.Speed and hum.WalkSpeed ~= S.SpeedVal then
            hum.WalkSpeed = S.SpeedVal
        end
    end))

    -- Block game from resetting JumpPower
    table.insert(_modChangedConns, hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if S.Jump and hum.JumpPower ~= S.JumpVal then
            hum.UseJumpPower = true
            hum.JumpPower = S.JumpVal
        end
    end))

    -- Block game from disabling UseJumpPower
    table.insert(_modChangedConns, hum:GetPropertyChangedSignal("UseJumpPower"):Connect(function()
        if S.Jump and not hum.UseJumpPower then
            hum.UseJumpPower = true
        end
    end))
end

-- Hook current character
task.spawn(function()
    local char = LocalPlayer.Character
    if char then hookCharacterModLoop(char) end
end)

-- Re-hook on respawn (track for cleanup)
track(LocalPlayer.CharacterAdded:Connect(function(char)
    task.defer(function()
        hookCharacterModLoop(char)
    end)
end))

-- Character hooks (onCharAdded, hookPlayer, etc.)
local function onCharAdded(player, char)
    headOrigSizes[player] = nil
    -- Wait for full character load
    if not char:IsDescendantOf(workspace) then
        char.AncestryChanged:Wait()
    end
    -- Guard against the character being removed between Wait() and cache build
    if not char:IsDescendantOf(workspace) then return end
    task.wait(_G.Config.CacheBuildDelay)
    if not char.Parent then return end -- double-check after delay
    buildPartCache(player)

    -- Event-Driven ESP: auto-create ESP entry on character spawn if missing
    if player ~= LocalPlayer and not ESPPool[player] then
        createESP(player)
    end

    local esp = ESPPool[player]
    if esp then
        if esp.highlight then _safeCall(function() esp.highlight:Destroy() end) end
        esp.highlight = makeHighlight(char)
    end

    if player == LocalPlayer then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then hookSilentAim(obj) end
        end
        char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then hookSilentAim(obj) end
        end)

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            _safeCall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end)
        end

        -- Fast Respawn safety — search ONLY PlayerGui, EXACT names, pcall Activate
        if hum and S.FastRespawn then
            hum.Died:Connect(function()
                if not S.FastRespawn then return end
                task.wait(0.5)
                _safeCall(function()
                    local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if gui then
                        local RESPAWN_NAMES = {
                            Respawn = true, RespawnButton = true,
                            PlayAgain = true, DeployButton = true,
                        }
                        for _, d in ipairs(gui:GetDescendants()) do
                            if (d:IsA("TextButton") or d:IsA("ImageButton")) and RESPAWN_NAMES[d.Name] then
                                _safeCall(function() d:Activate() end)
                                break
                            end
                        end
                    end
                end)
            end)
        end
    end

    task.wait(0.5)
    if S.Hitbox and player ~= LocalPlayer then applyHitbox(player) end
end

local function hookPlayer(player)
    if player.Character then
        task.spawn(function()
            task.wait(_G.Config.CacheBuildDelay)
            buildPartCache(player)
        end)
    end
    player.CharacterAdded:Connect(function(char) onCharAdded(player, char) end)
end

-- Death tracking + fly cleanup
track(LocalPlayer.CharacterRemoving:Connect(function()
    SessionDeaths = SessionDeaths + 1
    if S.Fly then _safeCall(stopFly) end
end))

track(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    if S.Fly then _safeCall(startFly) end
end))

-- Init all existing players (task.defer prevents frame drops on bulk load)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        task.defer(function() createESP(p) end)
    end
    hookPlayer(p)
end

-- Event-Driven: PlayerAdded auto-inserts into ESP cache
track(Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    task.defer(function()
        createESP(p)
        hookPlayer(p)
    end)
end))

-- Event-Driven: PlayerRemoving auto-cleans ESP + memory immediately
-- [V4 CHANGE] Only clear weaponCache for that player's tools, not entire cache
track(Players.PlayerRemoving:Connect(function(p)
    removeESP(p); headOrigSizes[p] = nil; trackedHP[p] = nil
    if p.Character then
        for _, obj in ipairs(p.Character:GetChildren()) do
            if obj:IsA("Tool") then weaponCache[obj] = nil end
        end
    end
end))

-- ============================================================
-- VIEWPORT CACHE
-- ============================================================
local lastVP = Vector2.new(0, 0)
local bottomCenter = Vector2.new(0, 0)

local function refreshVP()
    local vp = Camera.ViewportSize
    if vp ~= lastVP then lastVP = vp; bottomCenter = Vector2.new(vp.X*0.5, vp.Y) end
end

-- ============================================================
-- CONSOLIDATED HEARTBEAT LOOP (single connection)
-- ============================================================
local _antiAFKTimer = 0
local _autoHopTimer = 0

track(RunService.Heartbeat:Connect(function(dt)
    local now = os.clock()

    -- ── [1] WalkSpeed / JumpPower persistence ────────────────────
    _safeCall(function()
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if S.Speed and hum.WalkSpeed ~= S.SpeedVal then
            hum.WalkSpeed = S.SpeedVal
        end
        if S.Jump then
            if not hum.UseJumpPower then hum.UseJumpPower = true end
            if hum.JumpPower ~= S.JumpVal then hum.JumpPower = S.JumpVal end
        end
    end)

    -- ── [2] Auto Strafe ──────────────────────────────────────────
    if S.AutoStrafe then _safeCall(function()
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local v = root.AssemblyLinearVelocity
            local strafeSpeed = S.SpeedVal * 0.6
            local dir = hum.MoveDirection
            root.AssemblyLinearVelocity = Vector3.new(
                dir.X * strafeSpeed, v.Y, dir.Z * strafeSpeed
            )
        end
    end) end

    -- ── [3] No fall damage ───────────────────────────────────────
    if S.NoFallDmg then _safeCall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local vel = root.AssemblyLinearVelocity
            if vel.Y < -80 then
                root.AssemblyLinearVelocity = Vector3.new(vel.X, -80, vel.Z)
            end
        end
    end) end

    -- ── [4] TriggerBot ───────────────────────────────────────────
    if S.TriggerBot then _safeCall(function()
        local vp = Camera.ViewportSize
        local ray = Camera:ScreenPointToRay(vp.X*0.5, vp.Y*0.5)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if result and result.Instance then
            local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
            local hitP = hitChar and Players:GetPlayerFromCharacter(hitChar)
            if hitP and hitP ~= LocalPlayer then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then _safeCall(function() tool:Activate() end) end
            end
        end
    end) end

    -- ── [5] Kill Aura ────────────────────────────────────────────
    _safeCall(function() updateKillAura(now) end)

    -- ── [6] Weapon Mods ──────────────────────────────────────────
    if S.NoRecoil or S.NoSpread or S.FastReload or S.InfAmmo then
        _safeCall(function() applyWeaponMods(now) end)
    end

    -- ── [7] Anti-AFK jump timer ──────────────────────────────────
    _antiAFKTimer = _antiAFKTimer + dt
    if _antiAFKTimer >= _G.Config.AntiAFKInterval then
        _antiAFKTimer = 0
        if S.AntiAFK then
            _safeCall(function()
                local hum = LocalPlayer.Character
                    and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Jump = true end
            end)
        end
    end

    -- ── [8] Auto Hop timer ───────────────────────────────────────
    _autoHopTimer = _autoHopTimer + dt
    if _autoHopTimer >= _G.Config.AutoHopInterval then
        _autoHopTimer = 0
        if S.AutoHop then
            local count = #Players:GetPlayers()
            if count > S.AutoHopMax then
                notify("Auto Hop", count .. " players (max " .. S.AutoHopMax .. "). Hopping...", 4)
                task.delay(2, function()
                    _safeCall(function() findSmallestAndJoin(game.PlaceId) end)
                end)
            end
        end
    end
end))

-- ============================================================
-- MAIN RENDER LOOP — delta-corrected, Drawing-only, ESP throttle
-- ============================================================
local _espThrottle = 0
track(RunService.RenderStepped:Connect(function(delta)
    local now = os.clock()

    -- Speed CFrame supplement for values above 100 (visual movement)
    if S.Speed then _safeCall(function()
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.WalkSpeed = S.SpeedVal
            -- CFrame supplement for values above 100 (physics starts failing)
            if S.SpeedVal > 100 and root and hum.MoveDirection.Magnitude > 0 then
                local extra = (S.SpeedVal - 100) * delta * 0.5
                root.CFrame = root.CFrame + (hum.MoveDirection * extra)
            end
        end
    end) end

    -- ESP — Throttled to max 60 FPS
    if now - _espThrottle >= _G.Config.ESPThrottle then
        _espThrottle = now
        _safeCall(function() updateESP(now) end)
    end

    -- Aimbot (Camera.CFrame + ClosestPlayer logic)
    if S.Aimbot then
        local target = getClosestEnemy(now)
        if target then
            local pc = PartCache[target]
            if pc then
                local aim = (S.AimPart == "Torso") and pc.torso or pc.head
                if aim then
                    local aimPos = aim.Position
                    if S.AimPredict and pc.root then
                        local vel = pc.root.AssemblyLinearVelocity
                        if vel and vel.Magnitude > _G.Config.AimPredictVelMin then
                            aimPos = aimPos + vel * S.AimPredictStr
                        end
                    end
                    -- Slight aim randomization (humanization)
                    local rand = _G.Config.AimHumanization
                    aimPos = aimPos + Vector3.new(
                        (math.random() - 0.5) * rand,
                        (math.random() - 0.5) * rand,
                        (math.random() - 0.5) * rand
                    )
                    -- [V4 CHANGE] Delta-time corrected aimbot
                    local aimAlpha = 1 - (1 - 1/S.AimbotSmooth)^(delta * 60)
                    aimAlpha = math.clamp(aimAlpha, 0, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(
                        CFrame.new(Camera.CFrame.Position, aimPos),
                        aimAlpha
                    )
                end
            end
        end
    elseif S.SilentAim then
        getClosestEnemy(now)
    end

    -- Drawing-only updates
    _safeCall(updateCrosshair)
    _safeCall(updateFOV)
    _safeCall(function() updateRadar(now) end)
    _safeCall(function() updateEnemyAlert(now) end)
    _safeCall(function() updateHUDs(now) end)
end))

-- ============================================================
-- INFINITE JUMP HANDLER
-- ============================================================
_safeCall(function()
    track(UserInputService.JumpRequest:Connect(function()
        if S.InfJump then
            _safeCall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end))
end)

-- ============================================================
-- BACKGROUND TASKS (event-driven, no polling loops)
-- ============================================================

-- Anti-AFK (VirtualUser + jump)
_safeCall(function()
    local vu = game:GetService("VirtualUser")
    track(LocalPlayer.Idled:Connect(function()
        if S.AntiAFK then
            _safeCall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
        end
    end))
end)

-- Teleport failure retry
_safeCall(function()
    track(TeleportService.TeleportInitFailed:Connect(function(player, result, msg)
        if player == LocalPlayer then
            notify("Teleport Failed", tostring(msg) .. "\nRetrying...", 4)
            task.wait(3)
            if #S.ServerList > 0 then
                _safeCall(function() teleportToServer(game.PlaceId, S.ServerList[1].id) end)
            end
        end
    end))
end)

-- ============================================================
-- CLEANUP REGISTRATION + LOADED NOTIFICATION
-- ============================================================
_G.__AmethystCleanup = cleanupAll

notify(
    "Amethyst Ultimate V4.0 Loaded",
    "100% Custom UI | Deep Amethyst Theme\n7 Tabs | 32 Feature Systems\nGame: " .. tostring(game.PlaceId),
    6
)

end -- LOOPS + HOOKS + CLEANUP SCOPE