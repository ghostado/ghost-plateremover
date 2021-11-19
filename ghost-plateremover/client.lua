ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

local ultimoVeiculo = nil
local matricula = {}
matricula.Index = false
matricula.Numero = false

RegisterNetEvent('ghost-plateremover:RemoverMatricula')
AddEventHandler('ghost-plateremover:RemoverMatricula', function()
    ESX.TriggerServerCallback('ghost-plateremover:VerificarItems', function(quantidadeFerramentas, quantidadeMatriculas)
        if quantidadeFerramentas > 0 then
            if quantidadeMatriculas == 0 then

                -- jogador
                local jogador = GetPlayerPed(-1)
                -- coordenadas do jogador
                local coordsJogador = GetEntityCoords(jogador)

                -- veiculo mais proximo
                local veiculo = GetClosestVehicle(coordsJogador.x, coordsJogador.y, coordsJogador.z, 3.0, 0, 70)
                -- coords do veiculo
                local coordsVeiculo = GetEntityCoords(veiculo)

                -- distancia entre o jogador e o veiculo
                local distanciaCarroJogador = Vdist(coordsVeiculo.x, coordsVeiculo.y, coordsVeiculo.z, coordsJogador.x, coordsJogador.y, coordsJogador.z)
                
                if distanciaCarroJogador <= 3.0 and not IsPedInAnyVehicle(jogador, false) then
                    -- guarda o ultimo veiculo
                    ultimoVeiculo = veiculo

                    -- animação
                    Animacao()

                    -- tempo de remover matricula
                    exports['progressBars']:startUI(6000, "A remover matrícula...")

                    -- parar animação
                    StopAnimTask(jogador, "mini@repair", "fixing_a_player", 1.0)
                    -- tempo de remover matricula
                    Citizen.Wait(6000)

                    -- guardar o tipo de matricula (cor, ex.: azul + amarelo) 
                    matricula.Index = GetVehicleNumberPlateTextIndex(veiculo)
                    -- guardar a matricula
                    matricula.Numero = GetVehicleNumberPlateText(veiculo)

                    -- remover matricula do veiculo
                    SetVehicleNumberPlateText(veiculo, " ")

                    -- dar item de matricula ao jogador
                    TriggerServerEvent('ghost-plateremover:Matricula', true)
                else
                    -- notificação, nenhum veiculo por perto
                    exports['mythic_notify']:SendAlert('error', 'Nenhum veículo por perto', 1500, {['background-color'] = '#ff0000', ['color'] = '#ffffff'})
                end         
            else
                -- notificação, já contém uma matrícula
                exports['mythic_notify']:SendAlert('error', 'Já tens uma matrícula na mala', 1500, {['background-color'] = '#ff0000', ['color'] = '#ffffff'})
            end
        else
            -- notificação, não tem a ferramenta
            exports['mythic_notify']:SendAlert('error', 'Não tens uma chave de fendas', 1500, {['background-color'] = '#ff0000', ['color'] = '#ffffff'})
        end
    end)
end)

-- Remover Matricula
RegisterCommand("rmatricula", function()
    TriggerEvent('ghost-plateremover:RemoverMatricula')
end)

RegisterNetEvent('ghost-plateremover:ColocarMatricula')
AddEventHandler('ghost-plateremover:ColocarMatricula', function()
    ESX.TriggerServerCallback('ghost-plateremover:VerificarItems', function(quantidadeFerramentas, quantidadeMatriculas)
        if quantidadeFerramentas > 0 then
            if quantidadeMatriculas > 0 then

                -- jogador
                local jogador = GetPlayerPed(-1)
                -- coordenadas do jogador
                local coordsJogador = GetEntityCoords(jogador)

                -- veiculo mais proximo
                local veiculo = GetClosestVehicle(coordsJogador.x, coordsJogador.y, coordsJogador.z, 3.0, 0, 70)
                -- coords do veiculo
                local coordsVeiculo = GetEntityCoords(veiculo)

                -- distancia entre o jogador e o veiculo
                local distanciaCarroJogador = Vdist(coordsVeiculo.x, coordsVeiculo.y, coordsVeiculo.z, coordsJogador.x, coordsJogador.y, coordsJogador.z)

                if distanciaCarroJogador <= 3.0 and not IsPedInAnyVehicle(jogador, false) then

                    if veiculo == ultimoVeiculo then
                        -- Resetar variavel
                        ultimoVeiculo = nil

                        -- animação
                        Animacao()

                        -- tempo de colocar matricula
                        exports['progressBars']:startUI(6000, "A colocar matrícula...")

                        -- parar animação
                        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
                        -- tempo de colocar matricula
                        Citizen.Wait(6000)

                        -- Colocar o tipo de matricula no veiculo 
                        SetVehicleNumberPlateTextIndex(veiculo, matricula.Index)
                        -- Colocar a matricula do veiculo
                        SetVehicleNumberPlateText(veiculo, matricula.Numero)

                        -- Resetar variaveis
                        matricula.Index = false
                        matricula.Numero = false

                        -- retirar item de matricula ao jogador
                        TriggerServerEvent('ghost-plateremover:Matricula', false)
                    else
                        -- notificação, matrícula no veiculo errado
                        exports['mythic_notify']:SendAlert('error', 'A matrícula não pertence a este veículo', 1500, { ['background-color'] = '#ff0000', ['color'] = '#ffffff' })
                    end
                else
                    -- notificação, nenhum veiculo por perto
                    exports['mythic_notify']:SendAlert('error', 'Nenhum veículo por perto', 1500, { ['background-color'] = '#ff0000', ['color'] = '#ffffff' })
                end
            else
                -- notificação, sem matrículas no inventario
		        exports['mythic_notify']:SendAlert('error', 'Não tens matrículas na mala', 1500, { ['background-color'] = '##ff0000', ['color'] = '#ffffff' })
            end
        else
            -- notificação, não tem a ferramenta
            exports['mythic_notify']:SendAlert('error', 'Não tens uma chave de fendas', 1500, {['background-color'] = '#ff0000', ['color'] = '#ffffff'})
        end 
    end)
end)

-- Colocar Matricula
RegisterCommand("cmatricula", function()
    TriggerEvent('ghost-plateremover:ColocarMatricula')     
end)

function Animacao()
    -- jogador
    local jogador = GetPlayerPed(-1)
    
    -- dicionario de animação
    RequestAnimDict("mini")
    -- animação do dicionário
    RequestAnimDict("mini@repair")

    while not HasAnimDictLoaded("mini@repair") do 
		Citizen.Wait(10) 
	end

    -- executar animação
    TaskPlayAnim(jogador, 'mini@repair','fixing_a_player',1.0,-1.0, 5000, 0, 1, true, true, true)
end