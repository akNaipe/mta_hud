--[[
    tf_lib (adaptado) - dxDrawRoundedRectangle / dxDrawCircleFill
    Baseado na lib do projeto original "MTA SA HUD". Versão limpa,
    apenas com as funções usadas por este resource.
]]

---------------------------------------------------------------------
-- dxDrawRoundedRectangle(left, top, right, bottom, radius, color, postGUI)
-- Desenha um retângulo com cantos arredondados sobrepondo primitivas dx.
---------------------------------------------------------------------
function dxDrawRoundedRectangle(left, top, right, bottom, radius, color, postGUI)
    local width, height = right - left, bottom - top
    if width <= 0 or height <= 0 then return end

    radius = math.max(0, math.min(radius or 0, math.min(width, height) / 2))
    if radius == 0 then
        dxDrawRectangle(left, top, width, height, color, postGUI)
        return
    end

    -- Corpo central (sem os cantos)
    dxDrawRectangle(left + radius, top, width - radius * 2, height, color, postGUI)
    dxDrawRectangle(left, top + radius, width, height - radius * 2, color, postGUI)

    -- Quatro cantos: preenchidos com fatias verticais (sem esticar textura)
    local slices = 8
    for i = 0, slices - 1 do
        local t0, t1 = i / slices, (i + 1) / slices
        local x0, x1 = radius * t0, radius * t1
        local h0 = radius - math.sqrt(math.max(0, radius * radius - (radius - x0) * (radius - x0)))
        local h1 = radius - math.sqrt(math.max(0, radius * radius - (radius - x1) * (radius - x1)))
        local hh = math.max(h0, h1)
        local sw = x1 - x0 + 1
        -- canto superior esquerdo
        dxDrawRectangle(left + x0, top + hh, sw, radius - hh, color, postGUI)
        -- canto superior direito
        dxDrawRectangle(right - x1 - sw + 1, top + hh, sw, radius - hh, color, postGUI)
        -- canto inferior esquerdo
        dxDrawRectangle(left + x0, bottom - radius, sw, radius - hh, color, postGUI)
        -- canto inferior direito
        dxDrawRectangle(right - x1 - sw + 1, bottom - radius, sw, radius - hh, color, postGUI)
    end
end

---------------------------------------------------------------------
-- dxDrawCircleFill(x, y, radius, color, postGUI, segments)
-- Círculo cheio desenhado por fatias (ícones de necessidade).
---------------------------------------------------------------------
function dxDrawCircleFill(x, y, radius, color, postGUI, segments)
    segments = segments or 24
    for i = 0, segments - 1 do
        local a0 = (i / segments) * math.pi * 2
        local a1 = ((i + 1) / segments) * math.pi * 2
        dxDrawLine(x, y,
            x + math.cos(a0) * radius, y + math.sin(a0) * radius,
            color, radius * 2 / segments + 1.5, false, postGUI)
    end
end
