--  ██████╗   ██████╗ ██████╗ ██████╗ ██╗██████╗ ██╗
--  ██╔══██╗ ██╔═══██╗██╔══██╗██╔══██╗██║██╔══██╗██║
--  ██████╔╝ ██║   ██║██████╔╝██████╔╝██║██████╔╝██║
--  ██╔═══╝  ██║   ██║██╔═══╝ ██╔═══╝ ██║██╔═══╝ ██║
--  ██║      ╚██████╔╝██║     ██║     ██║██║     ██║
--  ╚═╝       ╚═════╝ ╚═╝     ╚═╝     ╚═╝╚═╝     ╚═╝
--                   Rodri

local QBCore = exports['qb-core']:GetCoreObject()
local createdBlips = {}

-- Helper: comprobar admin
local function isAdmin(player)
    if not player or not player.PlayerData then return false end
    if player.PlayerData.job and player.PlayerData.job.name == 'admin' then return true end
    if player.PlayerData.group == 'admin' or player.PlayerData.permission == 'god' then return true end
    return false
end

-- Cargar blips desde DB al iniciar
AddEventHandler('onResourceStart', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    MySQL.query('SELECT * FROM blips', {}, function(rows)
        for _, row in ipairs(rows) do
            createdBlips[row.id] = {
                serverId = row.id,
                name = row.name,
                label = row.label,
                sprite = row.sprite,
                scale = row.scale,
                color = row.color,
                coords = { x = row.x, y = row.y, z = row.z },
                jobOnly = row.jobOnly == 1,
                jobName = row.jobName
            }
        end
        for _, playerId in ipairs(GetPlayers()) do
            TriggerClientEvent('qb-blipmanager:client:syncBlips', tonumber(playerId), createdBlips)
        end
    end)
end)

-- Sync al entrar un jugador
RegisterNetEvent('qb-blipmanager:server:requestSync', function()
    local src = source
    TriggerClientEvent('qb-blipmanager:client:syncBlips', src, createdBlips)
end)

-- Crear blip
RegisterNetEvent('qb-blipmanager:server:createBlip', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not isAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes permisos para crear blips.', 'error')
        return
    end

    MySQL.insert('INSERT INTO blips (name, label, sprite, scale, color, x, y, z, jobOnly, jobName) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        data.name, data.label, data.sprite, data.scale, data.color,
        data.coords.x, data.coords.y, data.coords.z,
        data.jobOnly and 1 or 0, data.jobName
    }, function(insertId)
        if insertId then
            data.serverId = insertId
            createdBlips[insertId] = data
            TriggerClientEvent('qb-blipmanager:client:createBlip', -1, data)
            TriggerClientEvent('QBCore:Notify', src, 'Blip creado correctamente.', 'success')
        end
    end)
end)

-- Eliminar blip
RegisterNetEvent('qb-blipmanager:server:deleteBlip', function(serverId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not isAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes permisos para eliminar blips.', 'error')
        return
    end

    serverId = tonumber(serverId)
    if createdBlips[serverId] then
        MySQL.update('DELETE FROM blips WHERE id = ?', { serverId })
        createdBlips[serverId] = nil
        TriggerClientEvent('qb-blipmanager:client:deleteBlip', -1, serverId)
        TriggerClientEvent('QBCore:Notify', src, 'Blip eliminado.', 'success')
    end
end)

-- Actualizar blip
RegisterNetEvent('qb-blipmanager:server:updateBlip', function(serverId, newData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not isAdmin(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes permisos para actualizar blips.', 'error')
        return
    end

    serverId = tonumber(serverId)
    if not createdBlips[serverId] then
        TriggerClientEvent('QBCore:Notify', src, 'Blip no encontrado.', 'error')
        return
    end

    MySQL.update('UPDATE blips SET name=?, label=?, sprite=?, scale=?, color=?, x=?, y=?, z=?, jobOnly=?, jobName=? WHERE id=?', {
        newData.name, newData.label, newData.sprite, newData.scale, newData.color,
        newData.coords.x, newData.coords.y, newData.coords.z,
        newData.jobOnly and 1 or 0, newData.jobName, serverId
    })

    createdBlips[serverId] = newData
    newData.serverId = serverId
    TriggerClientEvent('qb-blipmanager:client:updateBlip', -1, newData)
    TriggerClientEvent('QBCore:Notify', src, 'Blip actualizado correctamente.', 'success')
end)

-- Comando solo admin
QBCore.Commands.Add('createblips', 'Abrir menú de Blips (Solo Admins)', {}, false, function(source)
    TriggerClientEvent('qb-blipmanager:client:openMenu', source)
end, 'admin')