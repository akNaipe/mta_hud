# BMN HUD (MTA:SA)

HUD convertida do projeto original (.lua) para o layout do Figma
**"Projects - Brasil Mundo Novo"**: painéis dark com cantos arredondados,
verde neon de destaque, dinheiro formatado em R$, barras animadas de
vida/colete/voz, ícones circulares de necessidade, relógio/data e
chatbox custom com tags coloridas.

## Instalação
1. Copie a pasta `hud_resource` para `mods/deathmatch/resources/` (pode renomear, ex.: `bmn_hud`).
2. (Opcional) Coloque suas fontes em `files/`:
   - `roboto.ttf` / `roboto-bold.ttf` → ajuste `Config.Fonts` em `cl_config.lua`
     (ex.: `regular = "files/roboto.ttf"`). Sem as fontes, usa as nativas do MTA.
3. No servidor: `refresh` + `start hud_resource`.

## Estrutura
| Arquivo | Descrição |
|---|---|
| `meta.xml` | Ordem de carregamento dos scripts |
| `cl_config.lua` | **Todas as posições, cores e tamanhos** (base 1920x1080, escala automática) |
| `lib/tf_lib.lua` | `dxDrawRoundedRectangle` / `dxDrawCircleFill` (adaptada da lib do projeto original) |
| `cl_functions.lua` | Formatação de moeda (pt-BR), lerp, sincronização de dados |
| `cl_hud.lua` | Desenho: dinheiro, barras, necessidades, relógio |
| `cl_chatbox.lua` | Chatbox custom (some a padrão do MTA ao iniciar) |
| `sv_main.lua` | Sync de dinheiro/necessidades + API exports |

## Integração (server-side)
Outros resources podem usar a API via `call`:

```lua
local hud = getResourceElement("hud_resource") -- ou use exports

-- Mensagem na chatbox custom (false = todos os jogadores)
exports.hud_resource:exportChat(false, "AVISO", {241,196,15}, "Servidor reinicia em 5 min!")

-- Necessidades (0-100): food / water / stamina
exports.hud_resource:setPlayerNeed(player, "food", 65)

-- Força refresh imediato (ex.: após dar dinheiro no seu economy)
exports.hud_resource:refreshHUD(player)
```

Dinheiro: por padrão lê `getPlayerMoney`. Para economia própria, edite
`MONEY_GETTER` em `sv_main.lua`.

Voz (barra amarela): qualquer resource de voice pode chamar no cliente:
`triggerServerEvent` não é necessário — dispare no client:
```lua
triggerClientEvent(localPlayer, "bmn:hud:setVoice", getResourceRootElement(getResourceFromName("hud_resource")), level) -- level 0..1
```

Comando de teste no jogo: `/bmnchat aviso Olá mundo!`

## Ajustes visuais
Tudo em `cl_config.lua`:
- `Config.Layout.*` — posições/tamanhos (px na base 1920x1080)
- `Config.Style.*` — cores, altura das barras, velocidade da animação
- `Config.DebugDraw = true` — mostra as caixas de layout para posicionar no Figma

> Nota: não consegui abrir o link do Figma (acesso bloqueado), então o
> visual seguiu o padrão descrito do design (dark + verde neon). Me envie
> screenshots do frame da HUD que eu ajusto posições, cores e componentes
> exatamente como no design.
