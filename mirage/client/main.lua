local QBCore = exports['qb-core']:GetCoreObject()

local Mirage = {
    decoyPed = nil
}

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(0)
        if GetGameTimer() > timeout then
            return nil
        end
    end
    return hash
end

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if GetGameTimer() > timeout then
            return false
        end
    end
    return true
end

local function playPillAnim()
    if not Config.UsePillAnim then return true end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return false
    end

    local dict = Config.PillAnimDict or 'mp_suicide'
    local clip = Config.PillAnimClip or 'pill'
    if not loadAnimDict(dict) then
        return false
    end

    ClearPedTasks(ped)
    TaskPlayAnim(
        ped,
        dict,
        clip,
        8.0,
        -8.0,
        Config.PillAnimDuration or 2200,
        49,
        0.0,
        false, false, false
    )

    local untilAt = GetGameTimer() + (Config.PillAnimDuration or 2200)
    while GetGameTimer() < untilAt do
        Wait(0)
        DisablePlayerFiring(PlayerId(), true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 23, true)
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
    end

    ClearPedTasks(ped)
    RemoveAnimDict(dict)
    return true
end

local function copyBasicAppearance(fromPed, toPed)
    SetPedDefaultComponentVariation(toPed)

    for i = 0, 11 do
        SetPedComponentVariation(
            toPed,
            i,
            GetPedDrawableVariation(fromPed, i),
            GetPedTextureVariation(fromPed, i),
            GetPedPaletteVariation(fromPed, i)
        )
    end

    for i = 0, 7 do
        local propIndex = GetPedPropIndex(fromPed, i)
        local propTexture = GetPedPropTextureIndex(fromPed, i)
        if propIndex ~= -1 then
            SetPedPropIndex(toPed, i, propIndex, propTexture, true)
        else
            ClearPedProp(toPed, i)
        end
    end
end

local function clearDecoy()
    if Mirage.decoyPed and DoesEntityExist(Mirage.decoyPed) then
        DeleteEntity(Mirage.decoyPed)
    end
    Mirage.decoyPed = nil
end

local function spawnDecoyRunner()
    clearDecoy()

    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local hash = loadModel(model)
    if not hash then
        QBCore.Functions.Notify('デコイ生成に失敗した。', 'error')
        return
    end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local headingRad = math.rad(heading)

    local spawnOffset = 0.8
    local spawnX = coords.x - math.sin(headingRad) * spawnOffset
    local spawnY = coords.y + math.cos(headingRad) * spawnOffset
    local spawnZ = coords.z

    local spawnCoords = coords
    if Config.DecoyGroundFix then
        local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 1.0, false)
        if foundGround then
            spawnCoords = vector3(coords.x, coords.y, groundZ + (Config.DecoyGroundOffset or 0.02))
        end
    end

    local targetX = coords.x - math.sin(headingRad) * (Config.DecoyForwardDistance or 18.0)
    local targetY = coords.y + math.cos(headingRad) * (Config.DecoyForwardDistance or 18.0)
    local targetZ = spawnCoords.z

    local decoy = CreatePed(4, hash, spawnX, spawnY, spawnZ, heading, true, false)
    if decoy == 0 then
        QBCore.Functions.Notify('デコイ生成に失敗した。', 'error')
        return
    end

    copyBasicAppearance(ped, decoy)

    if Config.DecoyGroundFix then
        PlaceObjectOnGroundProperly(decoy)
    end

    SetEntityAsMissionEntity(decoy, true, true)
    SetBlockingOfNonTemporaryEvents(decoy, true)
    SetPedCanRagdoll(decoy, false)
    SetEntityInvincible(decoy, true)
    SetEntityCollision(decoy, true, true)
    SetPedFleeAttributes(decoy, 0, false)
    SetPedKeepTask(decoy, true)

    RemoveAllPedWeapons(decoy, true)
    SetCurrentPedWeapon(decoy, `WEAPON_UNARMED`, true)

    RequestAnimSet('move_m@brave')
    while not HasAnimSetLoaded('move_m@brave') do
        Wait(0)
    end

    SetPedMovementClipset(decoy, 'move_m@brave', 1.0)
    SetPedMoveRateOverride(decoy, Config.DecoyRunSpeed or 2.0)
    ClearPedTasksImmediately(decoy)
    SetPedDesiredHeading(decoy, heading)
    SetEntityHeading(decoy, heading)
    TaskTurnPedToFaceCoord(decoy, targetX, targetY, targetZ, 0)
    Wait(50)

    TaskGoStraightToCoord(
        decoy,
        targetX,
        targetY,
        targetZ,
        Config.DecoyRunSpeed or 2.0,
        Config.DecoyCleanupMs or 4500,
        0.0,
        0.0
    )

    Mirage.decoyPed = decoy
    SetModelAsNoLongerNeeded(hash)

    CreateThread(function()
        Wait(Config.DecoyCleanupMs or 4500)
        clearDecoy()
    end)
end

exports('useItem', function(data, slot)
    TriggerServerEvent('mirage:server:useOxItem', slot)
end)

RegisterNetEvent('mirage:client:start', function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        QBCore.Functions.Notify('車両内では使えない。', 'error')
        return
    end

    local ok = playPillAnim()
    if not ok then
        QBCore.Functions.Notify('この状態では飲めない。', 'error')
        return
    end

    spawnDecoyRunner()
    QBCore.Functions.Notify('Mirage が走り出した。', 'primary')
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    clearDecoy()
end)
