# Arquitetura do sketch

Este documento descreve a arquitetura do sketch: as abas, o pipeline de assets,
o contrato de gameplay, o estado da partida, o viewport, o input e a
legibilidade. Ele continua válido para o viewport, o HUD e o estado global. O
mapa macro agora abre salas 2D jogáveis, e o técnico é controlável dentro delas.

A especificação vigente das salas e quests está em [[ROOMS]]. O sketch permanece
plano e executa o contrato descrito em [[ACTIONS]] e nas notas de `events/`.

## Onde o código mora

`last_horizon/` é o pacote da disciplina: `last_horizon.pde` + abas + `data/`
(fonte). A pasta `data/` é o diretório de assets do Processing.

## Abas

| Aba | O que tem |
| --- | --- |
| `last_horizon.pde` | canvas, telas, ações, regras, paleta, estado da partida, viewport, input |
| `assets.pde` | camada de arte: catálogo por arquivo, carregamento com fallback geométrico e desenho 1:1 |
| `ui.pde` | painéis, diálogos, retratos procedurais, texto, botões, hit-test e AABB |
| `hud.pde` | cartões do topo, faixa do problema mais urgente e rodapé |
| `screens.pde` | máquina de estados, camadas modais, menus, vinheta, pausa e desfechos |
| `ship.pde` | hub, quatro salas, portais configuráveis, mapa consultável, plataformas, escadas, NPCs e estações |
| `game.pde` | calendário, turno, incidentes, consumo, crises e condições de término |
| `tasks.pde` | catálogo e estado de ordens, soluções, retomadas, problemas, sobreviventes, risco e objetos |
| `editorial.pde` | catálogo factual, vozes, memória editorial e abertura única de conversa |
| `night_projection.pde` | snapshot puro, preview e aplicação equivalente da transição noturna |
| `navigation.pde`, `portals.pde`, `movement.pde`, `animation.pde` | consulta do mapa e blocos procedurais coesos extraídos do runtime |

`capture.pde` e `test_mode.pde` são módulos de desenvolvimento. Seus hooks têm
defaults inertes em `last_horizon.pde`, e os dois arquivos ficam fora do
snapshot de entrega.

## Pipeline de assets

- A origem Aseprite, quando disponível, pode permanecer em `last_horizon/data/`
  junto das exportações. O runtime não depende do arquivo `.aseprite`.
- Para as animações do jogo, o sketch suporta dois formatos transparentemente:
  - **Aseprite:** tira horizontal em PNG com JSON de metadados (`"frames": [...]`);
  - **Universal LPC:** matriz em PNG (células 64×64) com JSON do gerador LPC
    (`"version"`, `"layers"`).
- O sketch carrega os assets com `loadImage()` e `loadJSONObject()` durante
  `setup()`: `loadPlayerAssets()` traz o técnico e `loadArtAssets()` traz o
  restante pela camada de arte. A pasta `data/` é o diretório de assets do
  Processing.
- Para o técnico (`player_sheet.*`), o formato LPC extrai `idle` (2 quadros, linha 25),
  `walk` (8 quadros, linha 11), `climb` (6 quadros, linha 21), `jump` (sequência
  canônica LPC 0-1-2-3-4-1, 6 quadros a 75 ms, linha 29) e `run` (8 quadros a
  75 ms, linha 41, ativo com `Shift` no convés). No Aseprite, o formato mantém
  fallback gracioso de climb, jump e run para idle e walk (D-140, D-151, D-152,
  D-153).
- Para os NPCs em `last_horizon/assets.pde`, o formato LPC extrai a visão frontal
  (Sul / linha 24, 2 quadros de respiração), enquanto o Aseprite lê as coordenadas
  do array `"frames"` (D-141). O destaque de proximidade usa máscaras cyan
  pré-calculadas a partir da transparência dos frames e não altera os PNGs.
- `playerCurrentFrame()` e `playerCurrentAnimationState()` gerenciam o ciclo de
  animação conforme o estado (idle, walk, run no convés com `Shift`, climb na
  escada, jump no ar). `playerIsRunning()` é o predicado único que decide o passo
  acelerado e o estado `run`, então sprite e velocidade não divergem.
- A física mantém o personagem em 16×24 na grade lógica. O quadro visual é
  desenhado em 32×32 lógicos e centralizado sobre a caixa de colisão.
- A direção usa `player_facing`: `1` para a direita e `-1` para a esquerda.
  O valor acompanha A/D e setas, é espelhado na camada sem interpolação e é
  redefinido conforme a entrada pela porta ou o reinício da sala.
- Se o carregamento falhar, `drawPlayerFallback()` preserva a execução e a
  caixa física, sem alterar o contrato de movimento.
### Contrato de drop-in da arte

- A camada `last_horizon/assets.pde` carrega a arte por arquivo, sem mudar
  código: `data/icons`, `data/stations`, `data/objects`, `data/npc`,
  `data/doors`, `data/rooms`, `data/portraits`, `data/screens` e `data/map`.
- Sem o arquivo, a peça cai no desenho geométrico do protótipo e o jogo continua
  rodando; por isso o sketch pode ser entregue antes da arte ficar pronta.
- O canvas de cada peça é o tamanho que ela ocupa na tela, em pixels do render
  1280×720: o desenho é 1:1, sem escala. A lista por arquivo está em
  [[INVENTORY]].


## Contrato de gameplay implementado

O ciclo usa cinco incidentes nos dias 2, 4, 6, 8 e 10, escolhidos sem
reposição entre sete tipos organizados em falhas técnicas, suprimentos e
tripulação. Cada incidente oferece duas soluções físicas em formato de quest.

Nos dias sem incidente, os sobreviventes oferecem duas ordens preventivas. O
jogador escolhe uma, confirma a ordem presencialmente e deve concluí-la antes de
dormir para evitar o prejuízo maior de negligência. Uma ordem aceita não pode ser
cancelada.

Toda ordem informa objeto, origem, destino, recompensa e consequência de falha.
Coleta e entrega são as duas etapas leves; componentes são objetos de quest
carregados um por vez. Uma solução urgente não concluída deixa o problema ativo
com perda, prazo e crise normais.

Os seis recursos e o consumo diário permanecem. Economia, racionamento e bônus
numéricos dos sobreviventes foram removidos. Há no máximo uma pessoa em risco
por vez, com uma quest simples de socorro; sua morte reduz `A BORDO` sem
recalcular custos.

O hub, as quatro salas, o mapa consultável, o dano no casco alcançável e o
objetivo de chegar a Marte permanecem. O catálogo e o balanceamento das quests
estão em [[ACTIONS]] e nas notas de `events/` e são executados no sketch.

## Implementação do ciclo

O sketch usa as mesmas regras de [[ACTIONS]].
Hub, mapa consultável, física, spritesheet e viewport foram preservados.
As estações e objetos carregam PNGs quando disponíveis e mantêm a representação
geométrica como fallback do protótipo.

O ciclo implementado contém:

- **Ordens:** duas ofertas preventivas em dias sem incidente e duas soluções
  físicas nos dias com incidente; apenas uma quest concluída por dia.
- **Objetos:** coleta e entrega como duas etapas leves, com um item carregado por
  vez e sem coleta livre.
- **NPCs:** ofertas e confirmação presencial, sem bônus numérico.
- **Problemas:** solução urgente não concluída mantém perda, prazo e crise.
- **Riscos:** no máximo uma pessoa em risco, com quest simples de socorro.
- **Políticas:** economia e racionamento removidos.
- **Ciclo:** consumo diário, resultado da ordem e condições de término processados
  ao dormir.

O catálogo, os textos, as rotas e os valores numéricos das quests estão
definidos em [[ACTIONS]] e nas notas de `events/`. Não há contenção separada,
economia, racionamento, acelerador, bônus de NPC ou coleta livre.

Números do movimento (grade lógica 640×360; render 1280×720 / 720p): personagem
16×24, andar 1,0 px/quadro, correr 2,4 px/quadro com `Shift` no convés, pulo de
48 px, gravidade 0,5, escada 1,0 e plataformas atravessáveis por baixo. O andar
foi calibrado pelo ciclo de 800 ms da animação de caminhada (D-154). O estado
de animação do técnico (`idle`, `walk`, `climb`, `jump`, `run`) decide quadro e
velocidade pelo mesmo predicado, então sprite e passo nunca discordam; sem a
faixa de `run` na spritesheet, a corrida cai para a caminhada.

**Sem classes e sem hierarquia.** O Processing junta todas as abas numa classe
só; o estilo permanece em globais agrupadas, funções curtas e `update` separado
de `draw`.
## Estado da partida

Globais planas mantêm recursos, dia, sala e movimento. `daily_offers` contém as
duas ofertas; `selected_order` é a seleção ainda não confirmada; `active_quest`
e `quest_stage` controlam coleta e entrega. `held_item` identifica o único
objeto carregado. `quest_completed` é o limite diário; `preventive_committed`
distingue falha de preventiva de negligência, inclusive após socorro ou retomada.

`problem_solution` guarda a escolha urgente durante as noites; retomadas não
reiniciam `problem_deadline`. `opened_day` impede reinicializar o mesmo turno.
O custo urgente é validado e pago apenas na entrega; a falta de recursos nunca
trava a escolha inicial nem força uma crise imediata.

Portais e escadas vivem em tabelas. Cada porta declara `door_room`, `door_target`,
`door_x` e `door_y`; `door_deck` documenta o convés ou recebe `-1` para uma
abertura sem deck. `door_arrival_x`, `door_arrival_y` e `door_arrival_facing`
definem a chegada padrão na sala destino; `enterRoomThroughDoor` reaproveita a
posição `x/y` de saída quando o jogador retorna imediatamente pela sala anterior.
As escadas declaram `ladder_room` e `ladder_x`; o par final é 127/532 (Comando),
114/526 (Máquinas), 120/489 (Depósito) e 127/482 (Dormitório), com folga mínima
de 40 px entre estação e eixo de escada. Transmissões usam
`transmission_open`, `transmission_text` e as travas `earth_engine_sent`,
`earth_hull_sent` e `earth_loss_sent`; a mensagem de Marte depende de
`survivors` e de `engine_repaired_at_limit`. O modal de ajuda usa `help_open`.
NPCs vivos respondem sempre: `interactNpc` escolhe entre diálogo com retrato e
painel técnico conforme o estado do dia.

`ORDENS` abre comparação ou detalhes. O aceite preventivo valida presença junto
ao responsável; quando o responsável é também a origem da quest (como V-02 e N-02),
a confirmação já entrega o objeto em mãos (`held_item = active_quest + 1`), avançando
direto para `QUEST_DELIVER`. Coleta, entrega e sono validam o ponto físico. `E` apenas
abre o painel; `ENTER` confirma. Fechar o painel não cancela a ordem aceita.
O estado de risco individual mantém no máximo uma pessoa em risco. Sobreviventes
mortos deixam de oferecer ordens, mas não alteram custos.

Nenhuma tela recebe parâmetro: as abas compartilham o mesmo estado do sketch.

## Números

[[ACTIONS]] é a fonte de regras. Os valores vigentes do ciclo estão
consolidados nessa nota e no modelo executável; o sketch os utiliza sem
recalibração local.

## Viewport e input

- O buffer de render é 1280×720 (720p). A grade lógica 640×360 é usada apenas
  para posicionamento e é transformada por 2×; a janela mantém ampliação inteira
  e letterbox centralizado.
- `view_scale = max(1, int(min(width / 1280, height / 720)))`; a conversão da
  janela para a grade lógica divide também pelo fator 2.
- O mouse aciona controles da interface, como `MAPA`, `ORDENS` e opções modais. O
  mapa preserva a sala e a posição; a movimentação entre cômodos usa portas e
  interação por `E`.
- **Teclas modais:** `ENTER` avança diálogos, confirma ordens e soluções,
  entrega objetos e confirma o sono; `E` interage com os pontos da sala.
- Os botões repetem no próprio rótulo os atalhos disponíveis: `INICIAR (ENTER)`,
  `CONTINUAR (ENTER)`, `CONTINUAR (ESC)`, `CONFIRMAR (ENTER)`,
  `ACEITAR ORDEM (ENTER)`, `ENTREGAR (ENTER)`, `ENCERRAR DIA (ENTER)`,
  `AGORA NÃO (ESC)` e `FECHAR (ESC)`.
- **Camadas de input**: menu, ofertas de ordem, sala jogável, mapa, diálogo,
  painel técnico, evento e pausa. Todas as camadas modais bloqueiam movimento
  e interação da sala.
- **ESC** é consumido pelo sketch (`key = 0`) antes de alternar a pausa; não
  encerra mais a janela.
- Enquanto há incidente pendente, o modal técnico mostra as duas soluções e
  bloqueia exploração até a escolha.
- **Cursor**: `HAND` sobre controles ativos, `WAIT` sobre controles desabilitados
  e `ARROW` no restante.

## Legibilidade

O playtest inicial mostrou que 8–10 px na base eram microtexto na janela 2×. A
tipografia visível é **Segoe UI**, instalada no Windows, criada com suavização e
renderizada no buffer 1280×720 (720p); a grade lógica 640×360 continua
organizando as posições.
Assets pixel art, quando entrarem, devem usar amostragem sem interpolação. A
regra de suavização do texto não se aplica a esses assets.
Os helpers tipográficos usam **16 px** para leitura, com **entrelinha de 18 px**.
Os botões tentam 16 px e reduzem somente quando a frase não cabe na largura
disponível; o limite é 10 px. `COL_MUTED` e `COL_DIM` também foram clareados
para manter contraste com o fundo.
Nenhum desenho de texto chama `g.textSize` direto: o HUD, as salas e os modais
passam por `text`, `textCentered` ou `drawTextWrapped`, que aplicam o piso de
16 px. Só `drawButton` reduz, pelo `fitTextSize`, e só quando a frase não cabe.

O contrato de portais usa `door_room`, `door_target`, `door_x`, `door_y`,
`door_deck`, `door_arrival_x`, `door_arrival_y` e `door_arrival_facing`. O
`door_y` é o limiar dos pés e não precisa coincidir com um deck; `door_deck`
`-1` marca uma abertura livre. No Comando, a porta das Máquinas fica no centro
do deck inferior (`x = 320`). A porta responde por proximidade horizontal e
vertical; a chegada configurada vale na primeira travessia e o retorno imediato
reaproveita a posição de saída.


O HUD implementa os seis cartões de recurso com **ícone de 16×16 + número +
rótulo + barra**; os rótulos (`ENERGIA`, `OXIGÊNIO`, `ÁGUA`, `COMIDA`, `PEÇAS`,
`MORAL`) usam as fontes PNG de `data/icons/` quando disponíveis, com fallback
geométrico. O cartão de quantos estão a bordo usa **A BORDO**; o recurso crítico
pisca a borda e ganha ícone de aviso, sem linha de texto de alerta. A faixa
inferior tem quatro linhas de campos fixos e o rodapé tem `MAPA`, `ORDENS` e o
botão `?`, que abre o modal de ajuda. O mapa macro não imprime nome de nave.
O botão `ORDENS` recebe o selo `!` quando há oferta ou retomada. Círculo e
exclamação geométrica compartilham escala, cor e centro durante o pulso de 1,4 s.

Os seis ícones são preparados em `prepareResourceIconCache()`; as faixas de
piso são preparadas em `prepareDeckStrips()` e compartilham entradas quando a
fonte, a largura e a geração são iguais. `resource_icon_builds`,
`deck_strip_builds` e `cache_invalidations` são expostos ao modo `--metrics`.

## Leitura das regras do contrato novo

| Ponto | Leitura vigente |
| --- | --- |
| Calendário | cinco incidentes de sete tipos, nos dias 2, 4, 6, 8 e 10 |
| Dias sem incidente | duas ordens preventivas; uma deve ser concluída para evitar negligência maior |
| Dias com incidente | duas soluções físicas; uma deve ser escolhida e executada |
| Limite diário | uma quest concluída por dia, sem contador paralelo |
| Componentes | objetos de quest, carregados um por vez, sem coleta livre |
| Políticas | economia e racionamento removidos |
| Bônus | sobreviventes não alteram custos ou recompensas |
| Risco | no máximo uma pessoa em risco, com socorro simples |
| Falha urgente | problema permanece com perda, prazo e crise normais |
| Vitória e derrota | continuam conforme [[MENU_VICTORY]] e [[MENU_GAME_OVER]] |

Os valores exatos e o processamento numérico estão consolidados em [[ACTIONS]]
e executados em `last_horizon/game.pde` e `last_horizon/tasks.pde`.

Nenhum sobrevivente vivo encerra a partida com mensagem própria: é a quinta causa
de derrota. O técnico não entra na conta dos quatro.

## Referências

- [#9 Arquitetura do sketch](https://github.com/shelldonryan/gtd_example/issues/9)
- [#27 Corrigir desfechos, transmissões e parametrizar portas, escadas, NPCs e HUD](https://github.com/shelldonryan/gtd_example/issues/27)
- [#29 Camada de assets: sketch pronto para receber a arte](https://github.com/shelldonryan/gtd_example/issues/29)
- [#30 Desacoplar o harness do jogo para a entrega](https://github.com/shelldonryan/gtd_example/issues/30)
