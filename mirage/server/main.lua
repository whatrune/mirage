local QBCore = exports['qb-core']:GetCoreObject()
local ActiveCooldowns = {}

local function notify(src, msg, typ)
    TriggerClientEvent('QBCore:Notify', src, msg, typ or 'primary')
end

local function onCooldown(src)
    local now = GetGameTimer()
    return ActiveCooldowns[src] and ActiveCooldowns[src] > now
end

local function setCooldown(src)
    ActiveCooldowns[src] = GetGameTimer() + (Config.CooldownMs or 25000)
end

local function canUse(Player, source)
    if not Player then return false, 'player missing' end
    if onCooldown(source) then return false, 'cooldown' end

    local ped = GetPlayerPed(source)
    if ped == 0 then return false, 'ped missing' end
    if GetVehiclePedIsIn(ped, false) ~= 0 then return false, 'in vehicle' end

    local metadata = Player.PlayerData.metadata or {}

    if metadata['isdead'] or metadata['inlaststand'] then
        return false, 'dead/laststand'
    end

    local hunger = metadata['hunger'] or 100
    if hunger <= 50 then
        return false, 'not enough hunger'
    end

    return true
end

local function consumeHunger(Player, source)
    local metadata = Player.PlayerData.metadata or {}
    local hunger = metadata['hunger'] or 100
    local thirst = metadata['thirst'] or 100

    hunger = math.max(0, hunger - 50)
    Player.Functions.SetMetaData('hunger', hunger)

    TriggerClientEvent('hud:client:UpdateNeeds', source, hunger, thirst)
end

local function consumeItem(Player, source, item)
    local ok = Player.Functions.RemoveItem(Config.ItemName, 1, item and item.slot or nil)
    if ok == false then
        return false
    end

    local sharedItem = QBCore.Shared.Items and QBCore.Shared.Items[Config.ItemName]
    if sharedItem then
        TriggerClientEvent('inventory:client:ItemBox', source, sharedItem, 'remove', 1)
    end
    return true
end

local function startEffect(source)
    setCooldown(source)
    TriggerClientEvent('mirage:client:start', source)
end

RegisterNetEvent('mirage:server:useOxItem', function(slot)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local ok, reason = canUse(Player, src)

    if not ok then
        if reason == 'cooldown' then
            notify(src, 'まだ連続では使えない。', 'error')
        elseif reason == 'in vehicle' then
            notify(src, '車両内では使えない。', 'error')
        elseif reason == 'not enough hunger' then
            notify(src, '空腹で使えない。', 'error')
        else
            notify(src, 'この状態では使えない。', 'error')
        end
        return
    end

    local removed = Player.Functions.RemoveItem(Config.ItemName, 1, slot)
    if removed == false then
        notify(src, 'アイテム消費に失敗した。', 'error')
        return
    end

    local sharedItem = QBCore.Shared.Items and QBCore.Shared.Items[Config.ItemName]
    if sharedItem then
        TriggerClientEvent('inventory:client:ItemBox', src, sharedItem, 'remove', 1)
    end

    consumeHunger(Player, src)
    startEffect(src)
end)

QBCore.Functions.CreateUseableItem(Config.ItemName, function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    local ok, reason = canUse(Player, source)

    if not ok then
        if reason == 'cooldown' then
            notify(source, 'まだ連続では使えない。', 'error')
        elseif reason == 'in vehicle' then
            notify(source, '車両内では使えない。', 'error')
        elseif reason == 'not enough hunger' then
            notify(source, '空腹が足りない。', 'error')
        else
            notify(source, 'この状態では使えない。', 'error')
        end
        return
    end

    if not consumeItem(Player, source, item) then
        notify(source, 'アイテム消費に失敗した。', 'error')
        return
    end

    consumeHunger(Player, source)
    startEffect(source)
end)