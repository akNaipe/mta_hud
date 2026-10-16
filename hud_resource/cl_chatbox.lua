--[[
    BMN HUD - Chatbox custom (cl_chatbox.lua)
    Estilo Figma: linhas escuras com tag colorida à esquerda,
    fade-in ao aparecer e fade-out após `lineLife` segundos.
]]

local chatLines = {}

---------------------------------------------------------------------
-- Esconde a chatbox padrão do MTA (restaura ao parar o resource)
---------------------------------------------------------------------
addEventHandler("onClientResourceStart", resourceRoot, function()
    if Config.Chat.enabled then
        showChat(false, false)
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    showChat(true, false)
end)

---------------------------------------------------------------------
-- Recebe mensagens do servidor
-- event: bmn:chat:add (tag, tagColor, text, textColor)
---------------------------------------------------------------------
addEvent("bmn:chat:add", true)
addEventHandler("bmn:chat:add", resourceRoot, function(tag, tagColor, text, textColor)
    if not Config.Chat.enabled then return end
    table.insert(chatLines, {
        tag = tag or Config.Chat.defaultTag[1],
        tagColor = tagColor or Config.Chat.defaultTag[2],
        text = text or "",
        color = textColor or { 255, 255, 255 },
        born = getTickCount(),
        alpha = 0,
    })
    -- limita número de linhas visíveis
    while #chatLines > Config.Chat.maxLines do
        table.remove(chatLines, 1)
    end
end)

---------------------------------------------------------------------
-- Render
---------------------------------------------------------------------
local lastTick = getTickCount()
addEventHandler("onClientRender", root, function()
    if not Config.Chat.enabled then return end

    local now = getTickCount()
    local dt = math.min(0.1, (now - lastTick) / 1000)
    lastTick = now

    if isHudHidden() then return end

    local c = Config.Chat
    local x, y = px(c.x), py(c.y)
    local lineH = py(c.lineHeight)
    local w = px(c.width)
    local fontScale = ps(c.fontSize) / 1.1

    -- atualiza alphas e remove linhas expiradas
    for i = #chatLines, 1, -1 do
        local line = chatLines[i]
        local age = (now - line.born) / 1000

        if age < 0.2 then
            -- fade in
            line.alpha = lerp(line.alpha, 1, 12, dt)
        elseif age > c.lineLife then
            -- expirou: fade out rápido
            line.alpha = lerp(line.alpha, 0, 6, dt)
            if line.alpha <= 0.02 then
                table.remove(chatLines, i)
            end
        else
            line.alpha = 1
        end
    end

    -- desenha de cima para baixo
    for i, line in ipairs(chatLines) do
        local ly = y + (i - 1) * (lineH + py(4))
        local a = line.alpha

        -- fundo da linha
        drawRoundedRect(x, ly, w, lineH, px(4), { 17, 19, 26, math.floor(c.bgAlpha * a) })

        -- tag colorida [TAG]
        local tc = line.tagColor
        dxDrawText("[" .. tostring(line.tag) .. "]", x + px(10), ly, x + px(160), ly + lineH,
            tocolor(tc[1], tc[2], tc[3], math.floor(255 * a)), fontScale,
            Config.Fonts.bold, "left", "center", false, false, false, false, false)

        -- texto (com clip para não ultrapassar a linha)
        dxDrawText(tostring(line.text), x + px(110), ly, x + w - px(10), ly + lineH,
            tocolor(line.color[1], line.color[2], line.color[3], math.floor(255 * a)), fontScale,
            Config.Fonts.regular, "left", "center", true, "clip", false, false, false)
    end
end)
