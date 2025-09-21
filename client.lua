local QBCore = exports['qb-core']:GetCoreObject()
local createdBlips = {}

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 🔹 FUNCIONES LOCALES
-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

--- Crea un blip localmente
local function createLocalBlip(data)
    if createdBlips[data.id] then
        RemoveBlip(createdBlips[data.id])
    end

    local blip = AddBlipForCoord(data.x, data.y, data.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipScale(blip, data.scale + 0.0)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)

    createdBlips[data.id] = blip
end

--- Borra un blip localmente
local function deleteLocalBlip(id)
    if createdBlips[id] then
        RemoveBlip(createdBlips[id])
        createdBlips[id] = nil
    end
end

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 🔹 EVENTOS DE SINCRONIZACIÓN
-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

RegisterNetEvent('qb-blipmanager:client:syncBlips', function(blips)
    -- Primero limpiar todos los existentes
    for id, blip in pairs(createdBlips) do
        RemoveBlip(blip)
    end
    createdBlips = {}

    -- Crear los nuevos
    for _, blipData in pairs(blips) do
        createLocalBlip(blipData)
    end
end)

RegisterNetEvent('qb-blipmanager:client:addBlip', function(blipData)
    createLocalBlip(blipData)
end)

RegisterNetEvent('qb-blipmanager:client:updateBlip', function(blipData)
    createLocalBlip(blipData)
end)

RegisterNetEvent('qb-blipmanager:client:removeBlip', function(id)
    deleteLocalBlip(id)
end)

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 🔹 MENÚ PRINCIPAL
-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

local function openMainMenu()
    lib.registerContext({
        id = 'blipmanager_main',
        title = 'Blip Manager',
        options = {
            {
                title = '➕ Crear Blip',
                description = 'Crear un nuevo blip en el mapa',
                onSelect = function()
                    openCreateMenu()
                end
            },
            {
                title = '✏️ Editar Blip',
                description = 'Editar un blip existente',
                onSelect = function()
                    openEditMenu()
                end
            },
            {
                title = '🗑️ Eliminar Blip',
                description = 'Eliminar un blip existente',
                onSelect = function()
                    openDeleteMenu()
                end
            },
        }
    })
    lib.showContext('blipmanager_main')
end

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 🔹 CREAR BLIP
-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

function openCreateMenu()
    local input = lib.inputDialog('Crear Blip', {
        {type = 'input', label = 'Nombre interno', required = true},
        {type = 'input', label = 'Label (nombre visible)', required = true},
        {type = 'number', label = 'Sprite ID', required = true, default = 1},
        {type = 'number', label = 'Tamaño (scale)', default = 0.8},
        {type = 'number', label = 'Color', default = 0},
        {type = 'checkbox', label = 'Solo visible para un trabajo'},
        {type = 'input', label = 'Trabajo (si aplica)', description = 'ejemplo: police'},
        {type = 'checkbox', label = 'Usar mis coordenadas actuales'},
        {type = 'input', label = 'Coordenadas personalizadas (x,y,z)', description = 'Ej: 200.0,300.0,40.0'}
    })

    if not input then return openMainMenu() end

    local coords
    if input[8] then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        coords = {x = pos.x, y = pos.y, z = pos.z}
    elseif input[9] and input[9] ~= '' then
        local x, y, z = input[9]:match("([^,]+),([^,]+),([^,]+)")
        coords = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
    else
        QBCore.Functions.Notify('Debes elegir coordenadas.', 'error')
        return
    end

    local data = {
        name = input[1],
        label = input[2],
        sprite = input[3],
        scale = input[4],
        color = input[5],
        jobOnly = input[6] and 1 or 0,
        jobName = input[7],
        x = coords.x,
        y = coords.y,
        z = coords.z,
    }

    TriggerServerEvent('qb-blipmanager:server:createBlip', data)
end

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 🔹 EDITAR BLIP
-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

function openEditMenu()
    QBCore.Functions.TriggerCallback('qb-blipmanager:server:getBlips', function(blips)
        if not blips or #blips == 0 then
            QBCore.Functions.Notify('No hay blips creados.', 'error')
            return openMainMenu()
        end

        local opts = {}
        for _, blip in pairs(blips) do
            opts[#opts+1] = {
                title = blip.label,
                description = ('Sprite: %s | Color: %s'):format(blip.sprite, blip.color),
                onSelect = function()
                    openEditForm(blip)
                end
            }
        end

        lib.registerContext({
            id = 'blipmanager_edit_list',
            title = 'Editar Blip',
            menu = 'blipmanager_main',
            options = opts
        })
        lib.showContext('blipmanager_edit_list')
    end)
end

function openEditForm(blip)
    local input = lib.inputDialog('Editar Blip', {
        {type = 'input', label = 'Nombre interno', default = blip.name, required = true},
        {type = 'input', label = 'Label (nombre visible)', default = blip.label, required = true},
        {type = 'number', label = 'Sprite ID', default = blip.sprite, required = true},
        {type = 'number', label = 'Tamaño (scale)', default = blip.scale},
        {type = 'number', label = 'Color', default = blip.color},
        {type = 'checkbox', label = 'Solo visible para un trabajo', checked = (blip.jobOnly == 1)},
        {type = 'input', label = 'Trabajo (si aplica)', default = blip.jobName or ''},
        {type = 'input', label = 'Coordenadas (x,y,z)', default = string.format("%.2f,%.2f,%.2f", blip.x, blip.y, blip.z)}
    })

    if not input then return openEditMenu() end

    local x, y, z = input[8]:match("([^,]+),([^,]+),([^,]+)")
    local coords = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}

    local data = {
        id = blip.id,
        name = input[1],
        label = input[2],
        sprite = input[3],
        scale = input[4],
        color = input[5],
        jobOnly = input[6] and 1 or 0,
        jobName = input[7],
        x = coords.x,
        y = coords.y,
        z = coords.z,
    }

    if lib.alertDialog({
        header = 'Confirmar edición',
        content = '¿Seguro que deseas actualizar este blip?',
        centered = true,
        cancel = true
    }) == 'confirm' then
        TriggerServerEvent('qb-blipmanager:server:updateBlip', data)
    else
        openEditForm(blip)
    end
end

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 🔹 ELIMINAR BLIP
-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

function openDeleteMenu()
    QBCore.Functions.TriggerCallback('qb-blipmanager:server:getBlips', function(blips)
        if not blips or #blips == 0 then
            QBCore.Functions.Notify('No hay blips creados.', 'error')
            return openMainMenu()
        end

        local opts = {}
        for _, blip in pairs(blips) do
            opts[#opts+1] = {
                title = blip.label,
                description = ('Sprite: %s | Color: %s'):format(blip.sprite, blip.color),
                onSelect = function()
                    if lib.alertDialog({
                        header = 'Eliminar Blip',
                        content = '¿Seguro que deseas eliminar este blip?',
                        centered = true,
                        cancel = true
                    }) == 'confirm' then
                        TriggerServerEvent('qb-blipmanager:server:deleteBlip', blip.id)
                    else
                        openDeleteMenu()
                    end
                end
            }
        end

        lib.registerContext({
            id = 'blipmanager_delete_list',
            title = 'Eliminar Blip',
            menu = 'blipmanager_main',
            options = opts
        })
        lib.showContext('blipmanager_delete_list')
    end)
end

-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
-- 🔹 COMANDO
-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬

RegisterCommand('createblips', function()
    QBCore.Functions.TriggerCallback('qb-blipmanager:server:isAdmin', function(isAdmin)
        if isAdmin then
            openMainMenu()
        else
            QBCore.Functions.Notify('No tienes permisos para usar este comando.', 'error')
        end
    end)
end)