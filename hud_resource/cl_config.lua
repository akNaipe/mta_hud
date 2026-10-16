--[[
    ============================================
    BMN HUD - Configurações (cl_config.lua)
    Projeto: Brasil Mundo Novo (Figma)
    ============================================
    Todas as posições/tamanhos estão em valores
    absolutos de uma tela 1920x1080 e são
    convertidos automaticamente para qualquer
    resolução via interpolateBetween.
]]

Config = {}

---------------------------------------------------------------------
-- Fonte (tf_lib)
---------------------------------------------------------------------
-- Coloque os arquivos .ttf na pasta /files e registre no meta.xml.
Config.Fonts = {
    regular   = "default",      -- troque para "files/roboto.ttf" ao adicionar a fonte
    bold      = "default-bold", -- troque para "files/roboto-bold.ttf"
    icons     = "default",      -- troque para "files/icons.ttf" (fonte de ícones, ex: FontAwesome)
}

---------------------------------------------------------------------
-- Aparência geral
---------------------------------------------------------------------
Config.Style = {
    -- Cores base (RGBA 0-255)
    panelBg       = { 17, 19, 26, 230 },   -- fundo dos painéis (quase preto, estilo dark do Figma)
    panelBorder   = { 46, 51, 66, 255 },   -- borda sutil dos painéis
    accent        = { 0, 200, 120, 255 },  -- cor de destaque (verde neon)
    textPrimary   = { 255, 255, 255, 255 },
    textSecondary = { 160, 168, 184, 255 },

    -- Barras (vida / colete / voz / fome...)
    barHeight     = 8,
    barRadius     = 4,          -- cantos arredondados (px na base 1920)
    healthColor   = { 231, 76, 60, 255 },   -- vermelho
    armorColor    = { 52, 152, 219, 255 },  -- azul
    voiceColor    = { 241, 196, 15, 255 },  -- amarelo
    foodColor     = { 230, 126, 34, 255 },  -- laranja
    waterColor    = { 26, 188, 156, 255 },  -- turquesa
    staminaColor  = { 155, 89, 182, 255 },  -- roxo

    -- Animação
    lerpSpeed     = 8,          -- velocidade do preenchimento suave das barras
    fadeTime      = 0.3,        -- segundos para fade in/out da HUD
}

---------------------------------------------------------------------
-- Posições (base 1920x1080)
---------------------------------------------------------------------
Config.Layout = {
    -- Grupo principal (canto inferior esquerdo): dinheiro + vida/colete
    money = {
        x = 30, y = 985, w = 260, h = 55,
        icon = "+",                     -- caractere da fonte de ícones
        prefix = "R$ ",
        fontSize = 22,
    },
    statusBars = {
        x = 30, y = 1045, w = 260,      -- bloco abaixo do dinheiro
        spacing = 18,                   -- distância vertical entre barras
        rows = { "health", "armor", "voice" },
    },

    -- Ícones circulares de estado (fome, sede, stamina...) acima do dinheiro
    needs = {
        x = 30, y = 930,
        size = 40,
        spacing = 12,
        items = { "food", "water", "stamina" },
    },

    -- Relógio / data (canto inferior direito)
    clock = {
        x = 1660, y = 985, w = 230, h = 55,
        showSeconds = false,
        dateFormat = "%d/%m/%Y",
        timeFormat = "%H:%M",
    },

    -- Info do servidor (logo/nome) topo esquerdo — opcional
    serverInfo = {
        enabled = false,
        x = 30, y = 30,
    },
}

---------------------------------------------------------------------
-- Chatbox (estilo Figma: linhas com tag colorida + texto)
---------------------------------------------------------------------
Config.Chat = {
    enabled     = true,
    maxLines    = 8,            -- mensagens visíveis
    lineLife    = 25,           -- segundos até a mensagem sumir (fade)
    width       = 620,          -- base 1920
    x           = 30,           -- canto superior esquerdo
    y           = 100,
    lineHeight  = 26,
    fontSize    = 15,
    bgAlpha     = 180,          -- alpha do fundo escuro por linha
    defaultTag  = { "INFO", { 0, 200, 120 } },
}

---------------------------------------------------------------------
-- Comportamento
---------------------------------------------------------------------
Config.ShowInMenus = false      -- esconde a HUD quando há cursor visible (CEFs/menu)
Config.DebugDraw   = false      -- mostra caixas azuis nas áreas de layout
