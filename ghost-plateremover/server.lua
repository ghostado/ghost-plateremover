ESX = nil

TriggerEvent('esx:getSharedObject', function(object) ESX = object end)

ESX.RegisterServerCallback('ghost-plateremover:VerificarItems', function(source, cb)
    -- source
	local _source = source
    -- jogador
	local xPlayer = ESX.GetPlayerFromId(_source)

    -- ver inventario do jogador e procurar por chave de fendas
    local quantidadeFerramentas = xPlayer.getInventoryItem('screwdriver').count
    -- ver inventario do jogador e procurar por matricula
    local quantidadeMatriculas = xPlayer.getInventoryItem('plate').count

    cb(quantidadeFerramentas, quantidadeMatriculas)
end)

RegisterServerEvent('ghost-plateremover:Matricula')
AddEventHandler('ghost-plateremover:Matricula', function(nTemMatricula)
    -- source
	local _source = source
    -- jogador
	local xPlayer = ESX.GetPlayerFromId(_source)
    
    if nTemMatricula == true then
        xPlayer.addInventoryItem('plate', 1)
    else
        xPlayer.removeInventoryItem('plate', 1)
    end
end)

ESX.RegisterUsableItem('plate', function(source)
    -- source
	local _source = source
    -- jogador
	local xPlayer = ESX.GetPlayerFromId(_source)

    TriggerClientEvent('ghost-plateremover:ColocarMatricula', source)
end)

ESX.RegisterUsableItem('screwdriver', function(source)
    -- source
	local _source = source
    -- jogador
	local xPlayer = ESX.GetPlayerFromId(_source)

    TriggerClientEvent('ghost-plateremover:RemoverMatricula', source)
end)