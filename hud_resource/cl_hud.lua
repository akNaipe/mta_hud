--[[
    BMN HUD - Desenho principal (cl_hud.lua)
    Elementos: dinheiro, barras (vida/colete/voz), ícones de necessidade,
    relógio/data. Estilo dark com cantos arredondados (Figma).
]]

local screenW, screenH = guiGetScreenSize()
local lastTick = 0

---------------------------------------------------------------------
-- Inicializa valores animados
---------------------------------------------------------------------
local function initAnim()
    for k, v in pairs(HUD.data) do
        HUD.anim[k] = v
    end
end
addEventHandler("onClientResourceStart", resourceRoot, initAnim)

---------------------------------------------------------------------
-- Atualização por frame (lerp das barras + fade)
---------------------------------------------------------------------
local function update(dt)
    local targetFade = isHudHidden() and 0 or 1
    local fadeSpeed = 1 / math.max(0.05, Config.Style.fadeTime)
    HUD.fade = lerp(HUD.fade, targetFade, fadeSpeed, dt)

    for key, target in pairs(HUD.data) do
        HUD.anim[key] = lerp(HUD.anim[key] or target, target, Config.Style.lerpSpeed, dt)
    end

    -- Vida/colete sempre espelham o jogador (sincronização local imediata)
    local ped = localPlayer
    if isElement(ped) then
        HUD.data.health = getElementHealth(ped)
        HUD.data.armor  = getPedArmor(ped)
    end
end

---------------------------------------------------------------------
-- Painel base (fundo escuro + borda sutil, estilo Figma)
---------------------------------------------------------------------
local function drawPanel(x, y, w, h, alphaMul)
    local s = Config.Style
    drawRoundedRect(x, y, w, h, px(s.barRadius), {
        s.panelBg[1], s.panelBg[2], s.panelBg[3],
        math.floor(s.panelBg[4] * alphaMul)
    })
    -- borda interna superior clara (efeito de vidro)
    dxDrawRectangle(x + px(2), y + py(2), w - px(4), py(1),
        tocolor(s.panelBorder[1], s.panelBorder[2], s.panelBorder[3], math.floor(120 * alphaMul)))
end

---------------------------------------------------------------------
-- DINHEIRO (painel com ícone + valor formatado)
---------------------------------------------------------------------
local function drawMoney(alpha)
    local m = Config.Layout.money
    local x, y = px(m.x), py(m.y)
    local w, h = px(m.w), py(m.h)

    drawPanel(x, y, w, h, alpha)

    -- Ícone (círculo de destaque à esquerda)
    local cx, cy = x + h / 2, y + h / 2
    local r = h * 0.30
    dxDrawCircleFill(cx, cy, r, tocolor(Config.Style.accent[1], Config.Style.accent[2], Config.Style.accent[3], math.floor(255 * alpha)))
    dxDrawText("$", cx - r, cy - r, cx + r, cy + r,
        tocolor(255, 255, 255, math.floor(255 * alpha)), ps(r * 1.3),
        Config.Fonts.bold, "center", "center", false, false, false, false, false)

    -- Valor (animação apenas de contagem regressiva quando diminui)
    local text = formatMoney(math.floor(HUD.anim.money or 0))
    drawStyledText(text, cx + r + px(12), y, ps(m.fontSize) / 1.2,
        { 255, 255, 255, math.floor(255 * alpha) }, Config.Fonts.bold,
        "left", "center", x + w, y + h)
end

---------------------------------------------------------------------
-- BARRA DE STATUS genérica (vida / colete / voz)
---------------------------------------------------------------------
local barIcons = {
    health  = { label = "VIDA",   colorKey = "healthColor" },
    armor   = { label = "COLETE", colorKey = "armorColor" },
    voice   = { label = "VOZ",    colorKey = "voiceColor" },
}

local function drawBar(key, value, x, y, w, alpha)
    local info = barIcons[key]
    if not info then return end
    local s = Config.Style
    local bh = py(s.barHeight)
    local color = s[info.colorKey]

    -- Fundo da barra
    drawRoundedRect(x, y, w, bh, px(s.barRadius), { 40, 44, 58, math.floor(200 * alpha) })

    -- Preenchimento (pisca quando vida baixa)
    local pct = math.max(0, math.min(100, value)) / 100
    local fillW = math.max(bh, w * pct)
    local a = 255 * alpha
    if key == "health" and value < 25 then
        a = a * (0.55 + 0.45 * math.abs(math.sin(getTickCount() / 200)))
    end
    if pct > 0 then
        drawRoundedRect(x, y, fillW, bh, px(s.barRadius), { color[1], color[2], color[3], math.floor(a) })
    end

    -- Texto do valor à direita
    dxDrawText(string.format("%d", value), x + w + px(8), y - bh / 2, x + w + px(46), y + bh * 1.5,
        tocolor(s.textSecondary[1], s.textSecondary[2], s.textSecondary[3], math.floor(255 * alpha)),
        ps(11) / 1.1, Config.Fonts.regular, "left", "center", false, false, false, false, false)
end

local function drawStatusBars(alpha)
    local sb = Config.Layout.statusBars
    local x, y = px(sb.x), py(sb.y)
    local w = px(sb.w) - px(50) -- espaço para o texto do valor
    for i, key in ipairs(sb.rows) do
        drawBar(key, HUD.anim[key] or 0, x, y + (i - 1) * py(sb.spacing), w, alpha)
    end
end

---------------------------------------------------------------------
-- ÍCONES DE NECESSIDADE (círculos: fome / sede / stamina)
---------------------------------------------------------------------
local needInfo = {
    food    = { icon = "F", colorKey = "foodColor",    label = "FOME" },
    water   = { icon = "W", colorKey = "waterColor",   label = "SEDE" },
    stamina = { icon = "S", colorKey = "staminaColor", label = "STAMINA" },
}

local function drawNeeds(alpha)
    local n = Config.Layout.needs
    local size = py(n.size)
    local s = Config.Style
    for i, key in ipairs(n.items) do
        local info = needInfo[key]
        if info then
            local cx = px(n.x) + size / 2 + (i - 1) * (size + px(n.spacing))
            local cy = py(n.y) + size / 2
            local value = HUD.anim[key] or 100

            -- anel de fundo
            dxDrawCircleFill(cx, cy, size / 2, tocolor(40, 44, 58, math.floor(200 * alpha)))
            -- preenchimento proporcional (meia-lua simples via retângulo interno)
            local color = s[info.colorKey]
            local pct = math.max(0, math.min(100, value)) / 100
            if pct > 0.02 then
                dxDrawCircleFill(cx, cy, (size / 2 - py(3)) * pct,
                    tocolor(color[1], color[2], color[3], math.floor(230 * alpha)))
            end
            -- letra/ícone
            dxDrawText(info.icon, cx - size / 2, cy - size / 2, cx + size / 2, cy + size / 2,
                tocolor(255, 255, 255, math.floor(255 * alpha)), ps(size * 0.42) / 1.2,
                Config.Fonts.bold, "center", "center", false, false, false, false, false)
        end
    end
end

---------------------------------------------------------------------
-- RELÓGIO / DATA (canto inferior direito)
---------------------------------------------------------------------
local function drawClock(alpha)
    local c = Config.Layout.clock
    local x, y = px(c.x), py(c.y)
    local w, h = px(c.w), py(c.h)

    drawPanel(x, y, w, h, alpha)

    -- Hora do jogo (GMT)
    local hour, minute = 0, 0
    if getTime then
        local t = getTime(false, true)
        if t then
            hour, minute = t.hours, t.minutes
        end
    else
        local gt = getRealTime()
        hour, minute = gt.hour, gt.minute
    end

    local timeStr = string.format("%02d:%02d", hour, minute)
    if c.showSeconds then
        local gt = getRealTime()
        timeStr = timeStr .. string.format(":%02d", gt.second)
    end

    drawStyledText(timeStr, x + px(14), y, ps(22) / 1.2,
        { 255, 255, 255, math.floor(255 * alpha) }, Config.Fonts.bold,
        "left", "middle", x + w, y + h)

    local dateStr = os.date(c.dateFormat or "%d/%m/%Y")
    drawStyledText(dateStr, x + w - px(14), y, ps(13) / 1.2,
        { Config.Style.textSecondary[1], Config.Style.textSecondary[2], Config.Style.textSecondary[3], math.floor(255 * alpha) },
        Config.Fonts.regular, "right", "middle", x, y + h)
end

---------------------------------------------------------------------
-- Debug
---------------------------------------------------------------------
local function drawDebug()
    local areas = {
        Config.Layout.money, Config.Layout.statusBars,
        Config.Layout.needs, Config.Layout.clock,
    }
    for _, a in ipairs(areas) do
        dxDrawRectangle(px(a.x), py(a.y), px(a.w or 40), py(a.h or 40), tocolor(0, 100, 255, 70))
    end
end

---------------------------------------------------------------------
-- Loop principal
---------------------------------------------------------------------
addEventHandler("onClientRender", root, function()
    local now = getTickCount()
    local dt = math.min(0.1, (now - lastTick) / 1000)
    lastTick = now

    update(dt)

    local alpha = HUD.fade
    if alpha <= 0.01 then
        if Config.DebugDraw then drawDebug() end
        return
    end

    drawNeeds(alpha)
    drawMoney(alpha)
    drawStatusBars(alpha)
    drawClock(alpha)

    if Config.DebugDraw then drawDebug() end
end)
