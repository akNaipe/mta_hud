--[[
    BMN HUD - Funções auxiliares client-side
]]

local screenW, screenH = guiGetScreenSize()

-- Converte coordenadas da base 1920x1080 para a resolução atual
function px(v) return v * screenW / 1920 end
function py(v) return v * screenH / 1080 end
function ps(size) return math.max(1, size * screenH / 1080) end -- escala de fonte

-- Formata números com separador de milhar brasileiro: 1234567 -> 1.234.567
function formatNumber(n)
    n = math.floor(tonumber(n) or 0)
    local sign = n < 0 and "-" or ""
    n = math.abs(n)
    local s = tostring(n)
    local out = ""
    local len = #s
    for i = 1, len do
        out = out .. s:sub(i, i)
        local remaining = len - i
        if remaining > 0 and remaining % 3 == 0 then
            out = out .. "."
        end
    end
    return sign .. out
end

function formatMoney(n)
    return (Config.Layout.money.prefix or "") .. formatNumber(n)
end

-- Interpolação linear suave (para animação de barras)
function lerp(current, target, speed, dt)
    return current + (target - current) * math.min(1, speed * dt)
end

-- Esconde HUD quando algum painel CEF/cursor está aberto
function isHudHidden()
    if Config.ShowInMenus then return false end
    return isCursorShowing() or isChatBoxInputActive() or isConsoleActive()
end

-- Desenha um retângulo arredondado (usa dxDrawRoundedRectangle do tf_lib)
function drawRoundedRect(x, y, w, h, radius, color)
    dxDrawRoundedRectangle(x, y, x + w, y + h, radius, tocolor(color[1], color[2], color[3], color[4]))
end

-- Texto com sombra padrão do projeto
function drawStyledText(text, x, y, scale, color, font, alignX, alignY, clipW, clipH)
    dxDrawText(text, x + ps(1), y + ps(1), x + (clipW or 0), y + (clipH or 0),
        tocolor(0, 0, 0, 160), scale, font, alignX or "left", alignY or "top",
        false, false, false, false, false)
    dxDrawText(text, x, y, x + (clipW or 0), y + (clipH or 0),
        tocolor(color[1], color[2], color[3], color[4]), scale, font, alignX or "left", alignY or "top",
        false, false, false, false, false)
end

---------------------------------------------------------------------
-- Valores dinâmicos do jogador (cacheados por tick)
---------------------------------------------------------------------
HUD = HUD or {}
HUD.data = {
    money   = 0,
    health  = 100,
    armor   = 0,
    voice   = 0,       -- 0-100 (proximidade de fala / mics)
    food    = 100,
    water   = 100,
    stamina = 100,
}
HUD.anim = {}         -- valores animados (lerped)
HUD.fade = 0          -- alpha global da hud (fade in/out)

-- Recebe dados do servidor (dinheiro, necessidades etc.)
addEvent("bmn:hud:sync", true)
addEventHandler("bmn:hud:sync", resourceRoot, function(key, value)
    if HUD.data[key] ~= nil then
        local v = tonumber(value) or 0
        HUD.data[key] = v
        -- dinheiro nunca anima para CIMA (evita o valor "subir" a cada sync
        -- do servidor quando o jogador ganha dinheiro no jogo)
        if key == "money" and (HUD.anim.money or 0) < v then
            HUD.anim.money = v
        end
    end
end)

-- Voz: proximidade de conversa (se houver resources de voz, dispare este evento)
addEvent("bmn:hud:setVoice", true)
addEventHandler("bmn:hud:setVoice", resourceRoot, function(level)
    local v = (tonumber(level) or 0) * 100
    HUD.data.voice = math.max(0, math.min(100, v))
end)
