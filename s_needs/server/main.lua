--[[ s_needs server — hunger & thirst.
     Server-authoritative, decays on a timer, persists in s_core character
     metadata (survives relog), and syncs to the owner on the 'saga:needs'
     statebag so the HUD reads it with no round-trip. Items restore needs by
     calling the ModifyNeed export. ]]

local C  = Needs.config
local SC = exports['s_core']

local function clamp(v) v = tonumber(v) or 0; return math.max(0, math.min(100, v)) end

local function getNeeds(src)
    -- Assign to locals first: FiveM's export bridge can return 0 values when the
    -- underlying function returns nil, and tonumber() errors with no argument.
    local h = SC:GetMetadata(src, 'hunger')
    local t = SC:GetMetadata(src, 'thirst')
    return tonumber(h) or C.start, tonumber(t) or C.start
end

local function setNeeds(src, h, t)
    h, t = clamp(h), clamp(t)
    SC:SetMetadata(src, 'hunger', h)   -- persisted by s_core on save
    SC:SetMetadata(src, 'thirst', t)
    Player(src).state:set('saga:needs', { hunger = h, thirst = t }, true)
    return h, t
end

AddEventHandler('s_core:playerLoaded', function(src)
    local h, t = getNeeds(src)
    setNeeds(src, h, t)
end)

-- decay loop
CreateThread(function()
    while true do
        Wait(C.tickSeconds * 1000)
        for _, s in ipairs(SC:GetPlayers() or {}) do
            local src = tonumber(s)
            if src then
                local h, t = getNeeds(src)
                local nh, nt = clamp(h - C.hungerPerTick), clamp(t - C.thirstPerTick)
                setNeeds(src, nh, nt)
                if C.damageAtZero and (nh <= 0 or nt <= 0) then
                    local ped = GetPlayerPed(src)
                    if ped and ped ~= 0 then
                        local hp = GetEntityHealth(ped)
                        if hp > 101 then SetEntityHealth(ped, math.max(101, hp - C.damagePerTick)) end
                    end
                end
            end
        end
    end
end)

-- ---- exports (consumable items call these) -------------------------------
exports('GetNeed', function(src, key)
    local h, t = getNeeds(src); return key == 'thirst' and t or h
end)
exports('SetNeed', function(src, key, val)
    local h, t = getNeeds(src)
    if key == 'thirst' then t = val else h = val end
    setNeeds(src, h, t); return true
end)
exports('ModifyNeed', function(src, key, delta)
    local h, t = getNeeds(src)
    if key == 'thirst' then t = t + (tonumber(delta) or 0) else h = h + (tonumber(delta) or 0) end
    setNeeds(src, h, t); return true
end)

-- ---- test commands (until consumable items exist) ------------------------
lib.addCommand('eat',   { help = '(test) restore some hunger' }, function(src)
    if not SC:IsAdmin(src) then return end
    exports['s_needs']:ModifyNeed(src, 'hunger', 25)
    TriggerClientEvent('s_core:notify', src, { title = 'Hunger', description = 'You eat something.', type = 'success' })
end)
lib.addCommand('drink', { help = '(test) restore some thirst' }, function(src)
    if not SC:IsAdmin(src) then return end
    exports['s_needs']:ModifyNeed(src, 'thirst', 25)
    TriggerClientEvent('s_core:notify', src, { title = 'Thirst', description = 'You drink something.', type = 'success' })
end)
lib.addCommand('setneed', { help = '(admin) /setneed <id> <hunger|thirst> <0-100>' }, function(src, args)
    if not SC:IsAdmin(src) then return end
    local target, key, val = tonumber(args[1]), (args[2] or ''):lower(), tonumber(args[3])
    if target and (key == 'hunger' or key == 'thirst') and val then exports['s_needs']:SetNeed(target, key, val) end
end)
