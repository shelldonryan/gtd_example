# Baseline reconciliado — E0

Data da inspeção: 2026-09-19
Referência versionada: `prototype/sketch-architecture` em `16d81f1`
Árvore inspecionada: working tree local no mesmo diretório
Diretório temporário de evidências: `last_horizon/output/` (ignorado pelo Git durante a execução)

Este documento separa o que foi confirmado na referência versionada, o que existe
na árvore de trabalho e o que continua sendo contrato proposto pela SPEC. As
alterações que já estavam no working tree foram preservadas; a confirmação do
baseline não as transforma em parte da referência.

## Escopo e arquitetura confirmados

O baseline é um sketch local em Processing 4.5.6/Java Mode, composto por abas
`.pde`, com estado global em memória, atualização separada de desenho, tabelas
paralelas por domínio e fallbacks geométricos para assets ausentes. O render
confirmado é 1280×720, com grade lógica 640×360, escala inteira 2×, letterbox,
Segoe UI suavizada e pixel art sem interpolação.

A verificação numérica é independente em
`prototype/balance-model.mjs`. Não existem banco de dados, persistência,
backend, API HTTP, autenticação, autorização, serviço remoto ou dependência de
aplicação. O `package.json` atual é posterior ao baseline e contém somente
scripts locais de verificação; não adiciona dependências de runtime. Não há
biblioteca de UI ou asset obrigatório para executar as regras: imagem,
spritesheet ou áudio ausente deve cair no fallback existente ou em silêncio.

A entrega é gerada por `tools/snapshot-entrega.mjs`; a branch de entrega não é
fonte de edição. O snapshot final exclui `capture.pde` e `test_mode.pde`,
conforme `docs/snapshot-manifest.json`; os hooks opcionais do runtime são
inertes quando os módulos de desenvolvimento não estão presentes.

## Arquivos e módulos

### Baseline confirmado em `16d81f1`

As abas de gameplay confirmadas são:

- `last_horizon/last_horizon.pde`: constantes, ciclo de vida, input e hooks inertes;
- `last_horizon/game.pde`: ciclo diário, incidentes, consumo, consequências, crises e desfechos;
- `last_horizon/tasks.pde`: IDs, tabelas mecânicas, quests, ofertas, pontos e ações;
- `last_horizon/ship.pde`: salas, conveses, pontos, portas, escadas, cenário, player e animação;
- `last_horizon/hud.pde`: cartões de recursos, HUD e objetivo;
- `last_horizon/ui.pde`: camadas, botões, texto, modais e hit-test;
- `last_horizon/screens.pde`: telas, vinhetas e desfechos;
- `last_horizon/assets.pde`: carregamento, cache visual e fallbacks;
- `last_horizon/audio.pde`: carregamento, aquecimento e reprodução de áudio;
- `last_horizon/capture.pde`: harness e fixtures de desenvolvimento;
- `last_horizon/test_mode.pde`: modo manual de desenvolvimento;
- `prototype/balance-model.mjs`: modelo numérico independente;
- `tools/snapshot-entrega.mjs`: geração do snapshot de entrega.

Também fazem parte do baseline confirmado os contratos em
`mechanics/ACTIONS.md`, `interface/`, `events/`, `characters/`,
`history/`, `docs/adr/`, `code/`, `assets/INVENTORY.md`, os arquivos de
`last_horizon/data/`, `README.md`, `SESSION_START.md` e a configuração
versionada listada no manifesto abaixo.

### Divergências da árvore de trabalho

| Caminho | Situação observada | Classificação para a E0 |
| --- | --- | --- |
| `last_horizon/editorial.pde` | Existe como arquivo não rastreado na árvore atual. | Presente localmente; módulo proposto, fora do baseline confirmado. |
| `last_horizon/navigation.pde` | Existe como arquivo não rastreado na árvore atual. | Presente localmente; módulo proposto, fora do baseline confirmado. |
| `last_horizon/portals.pde` | Não existe na árvore atual nem na referência. | Módulo proposto; ainda ausente. |
| `last_horizon/movement.pde` | Não existe na árvore atual nem na referência. | Módulo proposto; ainda ausente. |
| `last_horizon/animation.pde` | Não existe na árvore atual nem na referência. | Módulo proposto; ainda ausente. |
| `SPEC_PROGRESS.md` | Não encontrado em nenhum caminho da árvore. | Fonte ausente; a SPEC fornecida e `code/VERIFICATION.md` são as referências locais disponíveis. |
| `docs/Docs20260919_145427/` | Pacote documental não rastreado, com SPEC/PRD, validações e plano de sprints. | Evidência de execução; não altera a referência `16d81f1`. |
| `.codegraph/` | Diretório não rastreado. | Índice local de ferramenta; fora do baseline funcional. |

A árvore também contém alterações prévias em
`assets.pde`, `game.pde`, `hud.pde`, `last_horizon.pde`,
`screens.pde`, `ship.pde`, `tasks.pde` e `ui.pde`. Elas não são
atribuídas à E0. A única alteração de runtime de verificação feita nesta E0 é a
restauração transacional das fixtures em `capture.pde` e a padronização dos
nomes temporários de captura.

### Helpers observados e contratos propostos

Helpers presentes no baseline ou confirmados no código atual incluem
`findButton`, `uiLayer`, `drawShadowText`, `drawModalFooter`,
`enterRoomThroughDoor`, `choosePreventive`, `acceptPreventive`,
`collectQuestObject`, `deliverQuest`, `rescueUrgentSurvivor`,
`openRescuePanel`, `mapTargetPoint`, `calculateMapRoute`,
`findNextMapLadder`, `recordEditorialResult`, `recordEditorialRisk` e
`resetEditorialMemory`. A presença de um helper na árvore atual não significa
que seu contrato futuro da SPEC esteja completo.

Continuam propostos ou não confirmados como operação com o contrato da SPEC:
`preparePortalTransition`, `beginNpcConversation`,
`simulateNightTransition`, `projectNight` e `pendingQuestReason`.
Em particular, o `editorialContextLine` atual ainda chama
`editorialRecognition`, que muta memória, e `editorialPhaseLine` incrementa
contador; isso é uma divergência registrada para E4, não uma decisão silenciosa
da E0.

## Matriz reconciliada de fontes

Os valores mecânicos continuam em uma única fonte de regra. O catálogo editorial
liga texto a `quest_id`, mas não repete custo, recompensa, perda, prazo, crise,
recurso, origem, destino ou responsável.

| Informação | Fonte canônica | Implementação observada | Uso documental |
| --- | --- | --- | --- |
| IDs das quests: 8 preventivas + 14 soluções = 22 | `mechanics/ACTIONS.md` e arrays `quest_id[]` em `tasks.pde` | `tasks.pde` | `editorial.pde` referencia os IDs por posição/ligação lógica; não redefine IDs. |
| Responsável, objeto, origem, destino e recurso | Tabelas das quests em `mechanics/ACTIONS.md`; `quest_owner[]`, `quest_object[]`, `quest_origin[]`, `quest_destination[]`, `preventive_resource[]` em `tasks.pde` | `tasks.pde` | Cards e falas consultam os dados mecânicos. |
| Custos das soluções | Matriz de soluções em `mechanics/ACTIONS.md`; `solution_resource[]` e `solution_cost[]` em `tasks.pde` | `deliverQuest()` em `tasks.pde` | O editorial só apresenta o custo consultado. |
| Recompensas | Tabela de preventivas em `mechanics/ACTIONS.md`; `preventiveReward()` em `tasks.pde` | `deliverQuest()` em `tasks.pde` | Não duplicar números no catálogo editorial. |
| Perdas por falha e negligência | Tabela de regras em `mechanics/ACTIONS.md`; `preventiveFailure()`, `preventiveNeglect()` e `preventiveNightLoss()` em `tasks.pde` | `applyQuestConsequences()` em `game.pde` | Resumo editorial lê o resultado; não cria consequência. |
| Consumo diário | Regras base em `mechanics/ACTIONS.md`; constantes `*_PER_DAY` em `last_horizon.pde` | `processNight()` em `game.pde` | Referência normativa do ciclo; sem cópia editorial. |
| Perdas diárias, prazos e crises dos incidentes | Matriz de incidentes em `mechanics/ACTIONS.md`; arrays `problem_loss_*`, `problem_initial_deadline[]`, `problem_crisis[]` em `tasks.pde` | `processNight()`, `processProblemDeadlines()` e `applyProblemCrisis()` | `game.pde` aplica; o UI consulta. |
| Calendário e cinco incidentes sorteados de sete | Regras de calendário em `mechanics/ACTIONS.md`; `incident_sequence[]`, `incidentForDay()` e `shuffleIncidentSequence()` | `game.pde`/ `tasks.pde` | Fixtures fixam cópia local e restauram a sequência. |
| Ordem de aplicação da noite e desfechos | Seções “Calendário”, “Agravamento” e “Sobreviventes” em `mechanics/ACTIONS.md` | `processNight()`, `checkEndConditions()`, `endDay()` em `game.pde` | Baseline funcional; não deve ser reescrito por texto de UI. |
| Títulos, motivações, vozes e variantes | `editorial.pde` atual, presente localmente e fora do baseline | Catálogo editorial local | Conteúdo editorial sem números ou regras mecânicas. |
| Fluxo, HUD, salas, eventos, personagens e decisões | `interface/`, `events/`, `characters/`, `docs/adr/`, `history/` | Código correspondente em `last_horizon/` | Contratos de apresentação e domínio; divergências devem ser explicitadas. |

## Inventário de referência versionada

O manifesto literal abaixo é a saída de
`git ls-tree -r --name-only 16d81f1`. Ele é a lista de arquivos do baseline
confirmado; arquivos que só aparecem no working tree não entram aqui.

```text
.gitignore
.obsidian/app.json
.obsidian/appearance.json
.obsidian/core-plugins.json
.obsidian/graph.json
.obsidian/workspace.json
README.md
SESSION_START.md
assets/INVENTORY.md
assets/PNG/Alert 1.png
assets/PNG/Baril 1.png
assets/PNG/Baril 2.png
assets/PNG/Baril 3.png
assets/PNG/Bed-1.png
assets/PNG/Bed.png
assets/PNG/Beds and walls.png
assets/PNG/BioComputer.png
assets/PNG/Biorganic device copie 2.png
assets/PNG/Biorganic device copie.png
assets/PNG/Biorganic device.png
assets/PNG/Bloody bed.png
assets/PNG/Board 1.png
assets/PNG/Books 2.png
assets/PNG/Calque 17.png
assets/PNG/Calque 18 copie 3.png
assets/PNG/Calque 18.png
assets/PNG/Ceiling lamp.png
assets/PNG/Chair 2.png
assets/PNG/Chair copie.png
assets/PNG/Chair.png
assets/PNG/Character 1.png
assets/PNG/Character 2.png
assets/PNG/Character 3.png
assets/PNG/Character 4 Blue.png
assets/PNG/Chunk1.png
assets/PNG/Chunk10.png
assets/PNG/Chunk2.png
assets/PNG/Chunk3.png
assets/PNG/Chunk4.png
assets/PNG/Chunk5.png
assets/PNG/Chunk6.png
assets/PNG/Chunk7.png
assets/PNG/Chunk8.png
assets/PNG/Chunk9.png
assets/PNG/Computer 1.png
assets/PNG/Computer 2.png
assets/PNG/Computer station 1.png
assets/PNG/Computer station 2.png
assets/PNG/CryoBox destroyed.png
assets/PNG/CryoBox.png
assets/PNG/CryoBoxOFF.png
assets/PNG/Desk 1.png
assets/PNG/Desk Lamp 2.png
assets/PNG/Door 2.png
assets/PNG/Doors 1.png
assets/PNG/Doors 2.png
assets/PNG/Electric wall.png
assets/PNG/Enter 1.png
assets/PNG/Enter 2.png
assets/PNG/Evil computer.png
assets/PNG/Floor 1.png
assets/PNG/Floor 2.png
assets/PNG/Floor 3.png
assets/PNG/Floor 4.png
assets/PNG/Floor 5.png
assets/PNG/Floor 6.png
assets/PNG/Green Barrel.png
assets/PNG/Gun 1.png
assets/PNG/Hand scanner.png
assets/PNG/Health Pack 1.png
assets/PNG/Health Pack 2.png
assets/PNG/Health pack 3.png
assets/PNG/Laboratory device.png
assets/PNG/Ladder .png
assets/PNG/Ladder.png
assets/PNG/Lamp 1.png
assets/PNG/Locker blood.png
assets/PNG/Locker open.png
assets/PNG/Locker.png
assets/PNG/Lockers 1.png
assets/PNG/Machine 1.png
assets/PNG/Machine 2.png
assets/PNG/Machine 3.png
assets/PNG/Mark 1.png
assets/PNG/Medical Device.png
assets/PNG/Metal wall 1.png
assets/PNG/Mural patch 1.png
assets/PNG/Mural patch 2.png
assets/PNG/Neon.png
assets/PNG/Neutral screen.png
assets/PNG/Open Door 2.png
assets/PNG/Open Door.png
assets/PNG/Phone 1.png
assets/PNG/Pillar destroyed.png
assets/PNG/Pillars 1.png
assets/PNG/Pillars.png
assets/PNG/Pipe.png
assets/PNG/Pipe2.png
assets/PNG/Pipe3.png
assets/PNG/Props 1.png
assets/PNG/Props 2.png
assets/PNG/Props 3.png
assets/PNG/Props 4.png
assets/PNG/Random Device 2.png
assets/PNG/Random Device 3.png
assets/PNG/Random device.png
assets/PNG/Screen device.png
assets/PNG/Screen info 1.png
assets/PNG/Screen info 2.png
assets/PNG/Screen info 3.png
assets/PNG/Semi-wall 1.png
assets/PNG/Semi-wall 2 copie.png
assets/PNG/Semi-wall 2.png
assets/PNG/Separation 1.png
assets/PNG/Separation 2.png
assets/PNG/Separation 3.png
assets/PNG/Seperation wall 2.png
assets/PNG/Small Device.png
assets/PNG/Small Machine 1.png
assets/PNG/Small Machine 2.png
assets/PNG/Small Machine 3.png
assets/PNG/Small machine 3-1.png
assets/PNG/Socle 1.png
assets/PNG/Stairs 2.png
assets/PNG/Stairs 3.png
assets/PNG/Stairs.png
assets/PNG/Sticker 1.png
assets/PNG/Sticker 2.png
assets/PNG/Surprised screen.png
assets/PNG/Teleportation copie.png
assets/PNG/Teleportation.png
assets/PNG/Wall 1.png
assets/PNG/Wall 2.png
assets/PNG/Wall 3.png
assets/PNG/Wall 4 Light.png
assets/PNG/Wall 5.png
assets/PNG/Wall 6.png
assets/PNG/Wall 7 Light.png
assets/PNG/Wall 7.png
assets/PNG/Wall Separation 1.png
assets/PNG/Wall and window.png
assets/PNG/Wall cover 2 copie.png
assets/PNG/Wall cover 2.png
assets/PNG/Wall cover 3.png
assets/PNG/Wall cover copie.png
assets/PNG/Wall cover.png
assets/PNG/Wall device.png
assets/PNG/Wall electric pannel 1.png
assets/PNG/Wall pipes.png
assets/PNG/Wall with glass 1.png
assets/PNG/Wallbox 1.png
assets/PNG/Window 1.png
assets/PNG/Window 2.png
assets/PNG/Window 5.png
assets/PNG/Window special 1.png
assets/PNG/books.png
assets/PNG/door.png
assets/PNG/post it.png
assets/PNG/wall 4.png
assets/concept_arts/BEDROOM.png
assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png
assets/concept_arts/COMMAND_ROOM_EDITED.png
assets/concept_arts/HUD.jpg
assets/concept_arts/HUD_CONCEPT_ART.png
assets/concept_arts/MACHINE_ROOM.png
assets/concept_arts/WAREHOUSE.png
assets/concept_arts/sala_comando_screen.jpg
characters/PLAYER.md
characters/npcs/NPC_1.md
characters/npcs/NPC_2.md
characters/npcs/NPC_3.md
characters/npcs/NPC_4.md
code/SKETCH_ARCHITECTURE.md
code/VERIFICATION.md
docs/adr/0001-ordens-e-incidentes-como-quests.md
docs/adr/0002-simplificacao-do-ciclo-diario.md
events/CREW_ISSUES.md
events/HAZARDS.md
events/SYSTEM_FAULTS.md
history/CONTEXT.md
interface/FLOW.md
interface/HUD.md
interface/MENU_GAME_OVER.md
interface/MENU_INIT.md
interface/MENU_PAUSE.md
interface/MENU_VICTORY.md
interface/ROOMS.md
interface/TEXT_FONTS.md
last_horizon/assets.pde
last_horizon/audio.pde
last_horizon/capture.pde
last_horizon/data/audio/door/LICENSE.txt
last_horizon/data/audio/door/door.wav
last_horizon/data/audio/ladder/LICENSE.txt
last_horizon/data/audio/ladder/ladder.wav
last_horizon/data/audio/ladder/step_01.wav
last_horizon/data/audio/ladder/step_02.wav
last_horizon/data/audio/ladder/step_03.wav
last_horizon/data/audio/ladder/step_04.wav
last_horizon/data/audio/run/LICENSE.txt
last_horizon/data/audio/run/step_01.wav
last_horizon/data/audio/run/step_02.wav
last_horizon/data/audio/run/step_03.wav
last_horizon/data/audio/run/step_04.wav
last_horizon/data/audio/walk/LICENSE.txt
last_horizon/data/audio/walk/step_01.wav
last_horizon/data/audio/walk/step_02.wav
last_horizon/data/audio/walk/step_03.wav
last_horizon/data/audio/walk/step_04.wav
last_horizon/data/doors/door_sheet.json
last_horizon/data/doors/door_sheet.png
last_horizon/data/environment/COMMAND_ROOM_EDITED.aseprite
last_horizon/data/environment/dorm_bunk.png
last_horizon/data/environment/floor_1.png
last_horizon/data/environment/floor_2.png
last_horizon/data/environment/floor_3.png
last_horizon/data/environment/floor_4.png
last_horizon/data/environment/floor_5.png
last_horizon/data/environment/floor_6.png
last_horizon/data/environment/wall_deck_0.png
last_horizon/data/environment/wall_deck_1.png
last_horizon/data/environment/wall_deck_2.png
last_horizon/data/environment/wall_dorm_deck_0.png
last_horizon/data/environment/wall_dorm_deck_1.png
last_horizon/data/environment/wall_dorm_deck_2.png
last_horizon/data/icons/agua.aseprite
last_horizon/data/icons/agua.png
last_horizon/data/icons/comida.aseprite
last_horizon/data/icons/comida.png
last_horizon/data/icons/energia.aseprite
last_horizon/data/icons/energia.png
last_horizon/data/icons/moral.aseprite
last_horizon/data/icons/moral.png
last_horizon/data/icons/oxigenio.aseprite
last_horizon/data/icons/oxigenio.png
last_horizon/data/icons/pecas.aseprite
last_horizon/data/icons/pecas.png
last_horizon/data/npc/LICENSE.txt
last_horizon/data/npc/bento.png
last_horizon/data/npc/bento_portrait.png
last_horizon/data/npc/neusa.png
last_horizon/data/npc/neusa_portrait.png
last_horizon/data/npc/silvia.png
last_horizon/data/npc/silvia_portrait.png
last_horizon/data/npc/vera.png
last_horizon/data/npc/vera_portrait.png
last_horizon/data/pipeline_probe.aseprite
last_horizon/data/pipeline_probe_frame_1.png
last_horizon/data/player/LICENSE.txt
last_horizon/data/player/player_sheet.json
last_horizon/data/player/player_sheet.png
last_horizon/data/portraits/bento.png
last_horizon/data/portraits/neusa.png
last_horizon/data/portraits/silvia.png
last_horizon/data/portraits/vera.png
last_horizon/data/stations/antena.png
last_horizon/data/stations/bancada_motor.png
last_horizon/data/stations/beliche_socorro.png
last_horizon/data/stations/beliche_tecnico.png
last_horizon/data/stations/console_rota.png
last_horizon/data/stations/estoque_comida.png
last_horizon/data/stations/mesa_comum.png
last_horizon/data/stations/mesa_grupo.png
last_horizon/data/stations/painel_distribuicao.png
last_horizon/data/stations/painel_suporte.png
last_horizon/data/stations/prateleira_reserva.png
last_horizon/game.pde
last_horizon/hud.pde
last_horizon/last_horizon.pde
last_horizon/screens.pde
last_horizon/ship.pde
last_horizon/tasks.pde
last_horizon/test_mode.pde
last_horizon/ui.pde
mechanics/ACTIONS.md
prototype/balance-model.mjs
skills-lock.json
tools/snapshot-entrega.mjs
```

## Retenção de evidências

- Todas as evidências temporárias ficam em `last_horizon/output/`. Imagens usam
  `etapa__estado__viewport.ext`, logs usam `etapa__execucao.log` e medições
  usam `etapa__metricas.csv`, exatamente conforme a SPEC. O nome `metrics.csv`
  deste pacote documental é o relatório consolidado permanente e não substitui
  o padrão dos arquivos temporários de medição.
- A captura permanente não é padrão. Nesta E0 nenhuma imagem foi retida como
  evidência final; intermediários de execução devem ser removidos após a
  consolidação.
- `last_horizon/data/pipeline_probe.aseprite` e
  `last_horizon/data/pipeline_probe_frame_1.png` são fixtures versionadas do
  pipeline, não capturas de gameplay. Destino: `last_horizon/data/`. Motivo:
  provar o caminho Aseprite → PNG → `loadImage()`. Ambiente: Processing
  4.5.6, render lógico 640×360 e saída 1280×720. Retenção: permanente enquanto
  o modo `--asset-pipeline-test` existir; remover somente junto com a fixture e
  sua verificação.
- O pacote persistente desta execução fica em
  `docs/Docs20260919_145427/`, com índice, baseline, verificação, métricas,
  playtest e visual diff. Nenhum log bruto ou PNG temporário deve ser copiado
  para esse diretório sem registrar destino, motivo, ambiente e política de
  retenção.

## Referências

- [SPEC detalhada](../../SPEC_ENXUGAMENTO_E_IMERSAO.md)
- [SPEC gerada da execução](SPEC20260919_145427.md)
- [Verificação vigente](../../code/VERIFICATION.md)
- [Índice documental](README.md)
