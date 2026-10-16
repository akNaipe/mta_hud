--[[
    BMN HUD - Servidor (sv_main.lua)
    Sincroniza dinheiro/necessidades com o cliente e expõe uma API
    para outros resources enviarem mensagens à chatbox custom.
]]

---------------------------------------------------------------------
-- Config de dinheiro: como obter o valor do jogador.
-- Por padrão usa getPlayerMoney (padrão MTA). Se você usa um recurso
-- próprio de economia, ajuste MONEY_GETTER para buscá-lo.
---------------------------------------------------------------------
local MONEY_GETTER = function(player)
    return getPlayerMoney(player)
end

-- Tabela de necessidades por jogador (integre com seu gamemode via
-- setPlayerNeed(player, "food", 80) )
local playerNeeds = {}

local NEED_KEYS = { "food", "water", "stamina" }

---------------------------------------------------------------------
-- Sincronização
---------------------------------------------------------------------
local function syncValue(player, key, value)
    triggerClientEvent(player, "bmn:hud:sync", getResourceRootElement(getThisResource()), key, value)
end

local function syncAll(player)
    syncValue(player, "money", MONEY_GETTER(player) or 0)
    local needs = playerNeeds[player]
    if needs then
        for _, k in ipairs(NEED_KEYS) do
            syncValue(player, k, needs[k] or 100)
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    -- cliente pediu dados ao iniciar este resource
    syncAll(client)
end)

addEventHandler("onPlayerJoin", root, function()
    playerNeeds[source] = { food = 100, water = 100, stamina = 100 }
end)

addEventHandler("onPlayerQuit", root, function()
    playerNeeds[source] = nil
end)

-- Poll leve: dinheiro pode mudar por qualquer script sem evento,
-- então sincronizamos a cada 2s (troque por eventos do seu economy se houver)
setTimer(function()
    for _, player in ipairs(getElementsByType("player")) do
        if isElement(player) then
            syncValue(player, "money", MONEY_GETTER(player) or 0)
        end
    end
end, 2000, 0)

---------------------------------------------------------------------
-- API exports (outros resources usam via call / broadcast)
---------------------------------------------------------------------

-- Envia mensagem formatada para a chatbox custom
-- exportChat(player|false, tag, tagColor{r,g,b}, text, textColor{r,g,b})
function exportChat(target, tag, tagColor, text, textColor)
    local players = {}
    if target == false or target == nil then
        players = getElementsByType("player")
    else
        players = { target }
    end
    for _, p in ipairs(players) do
        if isElement(p) then
            triggerClientEvent(p, "bmn:chat:add", getResourceRootElement(getThisResource()),
                tag, tagColor, text, textColor)
        end
    end
end

-- Define uma necessidade do jogador (0-100): "food", "water", "stamina"
function setPlayerNeed(player, key, value)
    if not playerNeeds[player] then
        playerNeeds[player] = { food = 100, water = 100, stamina = 100 }
    end
    value = math.max(0, math.min(100, tonumber(value) or 100))
    playerNeeds[player][key] = value
    syncValue(player, key, value)
end

-- Força re-sincronização imediata (ex.: após evento de dinheiro)
function refreshHUD(player)
    syncAll(player)
end

addExports("exportChat", exportChat)
addExports("setPlayerNeed", setPlayerNeed)
addExports("refreshHUD", refreshHUD)

---------------------------------------------------------------------
-- Intercepta mensagens comuns do chat do jogo e redireciona para a
-- chatbox custom (opcional; remova se preferir só chamadas diretas)
---------------------------------------------------------------------
local TAGS = {
    info   = { "INFO",   { 0, 200, 120 } },
    aviso  = { "AVISO",  { 241, 196, 15 } },
    erro   = { "ERRO",   { 231, 76, 60 } },
    sistema= { "SISTEMA",{ 52, 152, 219 } },
}

addCommandHandler("bmnchat", function(player, cmd, tagKey, ...)
    local tagInfo = TAGS[tagKey and tagKey:lower()] or TAGS.info
    local msg = table.concat({ ... }, " ")
    if msg ~= "" then
        exportChat(false, tagInfo[1], tagInfo[2], msg)
    end
end)
