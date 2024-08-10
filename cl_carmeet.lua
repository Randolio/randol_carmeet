local Config = lib.require('config')
local entities = {}
local isTping = false

local function initTeleport(coords)
    local x, y, z, w = coords.x, coords.y, coords.z or coords.z + 1.0, coords.w
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(25) end

    RequestCollisionAtCoord(x, y, z)
    NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)

    local sceneLoadTimer = GetGameTimer()
    while not IsNewLoadSceneLoaded() do
        if GetGameTimer() - sceneLoadTimer > 2000 then break end
        Wait(0)
    end

    SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    sceneLoadTimer = GetGameTimer()

    while not HasCollisionLoadedAroundEntity(cache.ped) do
        if GetGameTimer() - sceneLoadTimer > 2000 then break end
        Wait(0)
    end

    local foundNewZ, newZ = GetGroundZFor_3dCoord(x, y, z, 0, 0)
    if foundNewZ and newZ > 0 then z = newZ end

    SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    if cache.seat == -1 then
        SetEntityHeading(cache.vehicle, w)
    end

    NewLoadSceneStop()
    isTping = false
    DoScreenFadeIn(1000)
end

local function clearEntities()
    for i = 1, #entities do
        SetEntityAsMissionEntity(entities[i], false, true)
        DeleteEntity(entities[i])
    end
    table.wipe(entities)
end

local function createPrizeVehicleScene()
    lib.requestModel(Config.Prize.slamtruck.model, 10000)
    local coords = Config.Prize.slamtruck.coords
    local vehicle = CreateVehicle(Config.Prize.slamtruck.model, coords.x, coords.y, coords.z, coords.w, false, true)
    SetVehicleColours(vehicle, 73, 132)
    SetVehicleExtraColours(vehicle, 132, 132)
    SetVehicleWindowTint(vehicle, 3)
    SetVehicleNeonLightsColour(vehicle, 255, 255, 255)
    for i = 0, 3 do
        SetVehicleNeonLightEnabled(vehicle, i, true)
    end
    SetVehicleModKit(vehicle, 0)
    local mods = {[1] = 5, [3] = 1, [6] = 2, [7] = 3, [9] = 1, [23] = 19, [24] = 3, [48] = 12,}
    for mod, id in pairs(mods) do
        SetVehicleMod(vehicle, mod, id - 1, false)
    end
    SetVehicleIsConsideredByPlayer(vehicle, false)
    SetVehicleDoorsLocked(vehicle, 10)
    SetVehicleLights(vehicle, 2)
    SetVehicleNumberPlateText(vehicle, 'RANDOLIO')
    SetEntityInvincible(vehicle, true)
    SetEntityCanBeDamaged(vehicle, false)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleOnGroundProperly(vehicle)
    FreezeEntityPosition(vehicle, true)

    entities[#entities+1] = vehicle

    lib.requestModel(Config.Prize.zr350.model, 10000)
    local _coords = Config.Prize.zr350.coords
    local prizeVehicle = CreateVehicle(Config.Prize.zr350.model, _coords.x, _coords.y, _coords.z, _coords.w, false, true)
    SetVehicleColours(prizeVehicle, 73, 27)
    SetVehicleExtraColours(prizeVehicle, 0, 0)
    SetVehicleWindowTint(prizeVehicle, 3)
    SetVehicleModKit(prizeVehicle, 0)
    SetVehicleMod(prizeVehicle, 48, 11, false)

    local mods = {[0] = 4, [1] = 3, [2] = 1, [3] = 13, [4] = 6, [5] = 1, [6] = 2, [7] = 7, [9] = 3, [10] = 1, [15] = 2, [23] = 9, [26] = 4, [29] = 3, [30] = 3, [31] = 5, [32] = 5, [33] = 3, [47] = 2, [48] = 14,}
    for mod, id in pairs(mods) do
        SetVehicleMod(prizeVehicle, mod, id - 1, false)
    end

    SetVehicleIsConsideredByPlayer(prizeVehicle, false)
    SetVehicleDoorsLocked(prizeVehicle, 10)
    SetVehicleNumberPlateText(prizeVehicle, 'RANDOLIO')
    SetEntityInvincible(prizeVehicle, true)
    SetEntityCanBeDamaged(prizeVehicle, false)
    FreezeEntityPosition(prizeVehicle, true)
    AttachEntityToEntity(prizeVehicle, vehicle, -1, 0.0, -1.52, 0.98, -2.7, 0.0, 180.0, false, false, false, false, 2, true, 0)
    entities[#entities+1] = prizeVehicle
    SetModelAsNoLongerNeeded(Config.Prize.slamtruck.model)
    SetModelAsNoLongerNeeded(Config.Prize.zr350.model)
end

local function carmeetPeds()
    for i = 1, #Config.Peds do
        local v = Config.Peds[i]
        lib.requestModel(v.model, 10000)
        local ped = CreatePed(0, v.model, v.coords.x, v.coords.y, v.coords.z-1.0, v.coords.w, false, false)
        SetEntityProofs(ped, true, true, true, true, true, false, false, false)
        if v.default then
            SetPedDefaultComponentVariation(ped)
        else
            SetPedRandomComponentVariation(ped)
            SetPedRandomProps(ped)
        end
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        if v.anim then
            lib.requestAnimDict(v.dict, 2000)
            TaskPlayAnim(ped, v.dict, v.anim, 4.0, 5.0, -1, v.flag, 1.0, false, false, false)
            if v.animType == 'phone' then
                local obj = CreateObject(`prop_npc_phone`, v.coords.x, v.coords.y, v.coords.z, false, false, false)
                AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.035, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                SetModelAsNoLongerNeeded(`prop_npc_phone`)
                entities[#entities+1] = obj
            elseif v.animType == 'smoke' then
                local obj = CreateObject(`prop_cs_ciggy_01`, v.coords.x, v.coords.y, v.coords.z, false, false, false)
                AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), 0.02, 0.0025, 0.01, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                SetModelAsNoLongerNeeded(`prop_cs_ciggy_01`)
                entities[#entities+1] = obj
            elseif v.animType == 'drink' then
                local obj = CreateObject(`apa_prop_cs_plastic_cup_01`, v.coords.x, v.coords.y, v.coords.z, false, false, false)
                AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), -0.005, 0.0, -0.065, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                SetModelAsNoLongerNeeded(`apa_prop_cs_plastic_cup_01`)
                entities[#entities+1] = obj
            end
            RemoveAnimDict(v.dict)
        end
        if v.scenario then
            TaskStartScenarioInPlace(ped, v.scenario, 0, false)
        end
        SetModelAsNoLongerNeeded(v.model)
        entities[#entities+1] = ped
    end

    createPrizeVehicleScene()
end

local function carmeetVehicles()
    for i = 1, #Config.Vehicles do
        local v = Config.Vehicles[i]
        lib.requestModel(v.model, 10000)
        
        local vehicle = CreateVehicle(v.model, v.coords.x, v.coords.y, v.coords.z, v.coords.w, false, true)
        SetVehicleModKit(vehicle, 0)
        SetVehicleColours(vehicle, v.colors[1], v.colors[2])
        SetVehicleExtraColours(vehicle, v.extraColors[1], v.extraColors[2])
        SetVehicleWindowTint(vehicle, 3)
        SetVehicleInteriorColor(vehicle, v.intColor)
        
        if v.neons then
            SetVehicleNeonLightsColour(vehicle, v.neons[1], v.neons[2], v.neons[3])
            for i = 0, 3 do
                SetVehicleNeonLightEnabled(vehicle, i, true)
            end
        end

        if v.livery then
            SetVehicleMod(vehicle, 48, v.livery, false)
            SetVehicleLivery(vehicle, v.livery)
        end

        for mod, id in pairs(v.modKits) do
            SetVehicleMod(vehicle, mod, id - 1, false)
        end

        SetVehicleIsConsideredByPlayer(vehicle, false)
        SetVehicleDoorsLocked(vehicle, 10)
        SetVehicleLights(vehicle, 2)
        SetVehicleNumberPlateText(vehicle, 'RANDOLIO')
        SetEntityInvincible(vehicle, true)
        SetEntityCanBeDamaged(vehicle, false)
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleOnGroundProperly(vehicle)
        FreezeEntityPosition(vehicle, true)
        if v.door then
            SetVehicleDoorOpen(vehicle, v.door, false, true)
        end
        SetModelAsNoLongerNeeded(v.model)
        entities[#entities+1] = vehicle
    end

    carmeetPeds()
end

local function createMimi()
    local coords = Config.Mimi.coords
    local rot = Config.Mimi.rot
    local models = Config.Mimi.models
    local dict = 'ANIM@SCRIPTED@CARMEET@TUN_MEET_IG1_MIMI@'
    lib.requestAnimDict(dict, 2000)

    for i = 1, #models do 
        lib.requestModel(models[i], 10000)
    end

    local mimi = CreatePed(5, models[1], coords.x, coords.y, coords.z, coords.w, false, false)
    SetEntityProofs(mimi, true, true, true, true, true, false, false, false)
    SetPedDefaultComponentVariation(mimi)
    SetPedPropIndex(mimi, 2, 0, 0, false)
    SetPedPropIndex(mimi, 1, 0, 0, false)
    SetBlockingOfNonTemporaryEvents(mimi, true)
    FreezeEntityPosition(mimi, true)
    SetModelAsNoLongerNeeded(models[1])
    entities[#entities+1] = mimi

    local phone = CreateObject(models[2], coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(phone, true, false)
    SetModelAsNoLongerNeeded(models[2])
    RemoveAnimDict(dict)
    entities[#entities+1] = phone

    local scene = CreateSynchronizedScene(coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, 2)
    TaskSynchronizedScene(mimi, scene, dict, "BASE_mimi", 8.0, -8.0, 0, 0, 1000.0, 0)
    PlaySynchronizedEntityAnim(phone, scene, "BASE_npcphone", dict, 8.0, -8.0, 0, 1000.0)
    SetSynchronizedSceneLooped(scene, true)

    carmeetVehicles()
end

local function initScene()
    local coords = Config.RaceOrg.coords
    local rot = Config.RaceOrg.rot
    local model = Config.RaceOrg.model
    local dict = 'ANIM@SCRIPTED@CARMEET@TUN_MEET_IG2_RACE@'

    lib.requestAnimDict(dict, 10000)
    lib.requestModel(model, 10000)

    local ped = CreatePed(5, model, coords.x, coords.y, coords.z, coords.w, false, false)
    SetEntityProofs(ped, true, true, true, true, true, false, false, false)
    SetPedDefaultComponentVariation(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(model)
    RemoveAnimDict(dict)
    entities[#entities+1] = ped

    local scene = CreateSynchronizedScene(coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, 2)
    TaskSynchronizedScene(ped, scene, dict, 'BASE', 8.0, -8.0, 0, 0, 1000.0, 0)
    SetSynchronizedSceneLooped(scene, true)

    createMimi()
end

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() == resourceName then
        clearEntities()
    end 
end)

local zone = lib.points.new({
    coords = Config.CenterZone,
    distance = 80,
    onEnter = initScene,
    onExit = clearEntities,
})

if Config.EnableTeleport then
    for i = 1, #Config.Teleports do
        local data = Config.Teleports[i]
        local ENTER_EXIT = lib.zones.box({
            coords = vec3(data.zone.x, data.zone.y, data.zone.z),
            size = vector3(6, 6, 2),
            rotation = data.zone.w,
            debug = false,
            onEnter = function()
                lib.showTextUI(data.label, {position = 'left-center', })
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustPressed(0, 38) and not isTping then
                    isTping = true
                    initTeleport(data.set)
                end
            end,
        })
    end
end
