# Arquitetura do sketch

Este documento descreve o esqueleto inicial do ticket [#9](https://github.com/shelldonryan/gtd_example/issues/9).
Ele continua válido para o viewport, o HUD e o estado global. O mapa macro agora
abre salas 2D jogáveis, e o técnico é controlável dentro delas.


A especificação vigente das salas e quests está em `interface/ROOMS.md`.
O sketch permanece plano e executa o contrato das issues #25 e #26.

## Onde o código mora

`last_horizon/` na branch `prototype/sketch-architecture`. A pasta é o pacote da
disciplina: `last_horizon.pde` + abas + `data/` (fonte) + `output/` (PNGs de prova).
O sketch já foi validado pelo CLI e permanece pronto para a próxima etapa de arte.

## Abas

| Aba | O que tem |
| --- | --- |
| `last_horizon.pde` | canvas, telas, ações, regras, paleta, estado da partida, viewport, input |
| `ui.pde` | painéis, diálogos, retratos procedurais, texto, botões, hit-test e AABB |
| `hud.pde` | cartões do topo, faixa do problema mais urgente e rodapé |
| `screens.pde` | máquina de estados, camadas modais, menus, vinheta, pausa e desfechos |
| `ship.pde` | hub, quatro salas, portais configuráveis, mapa consultável, plataformas, escadas, NPCs e estações |
| `game.pde` | calendário, turno, incidentes, consumo, crises e condições de término |
| `tasks.pde` | catálogo e estado de ordens, soluções, retomadas, problemas, sobreviventes, risco e objetos |
| `capture.pde` | captura visual das quests e verificações de ciclo, campanhas, hub, clique e escada |

## Pipeline de assets

- A origem Aseprite, quando disponível, pode permanecer em `last_horizon/data/`
  junto das exportações. O runtime não depende do arquivo `.aseprite`.
- Para qualquer animação do jogo, a exportação oficial usa uma spritesheet única
  em PNG com JSON de metadados; não há PNG separado por quadro.
- O sketch carrega os assets de produção com `loadImage()` e
  `loadJSONObject()` em `loadPlayerAssets()` durante `setup()`. A pasta `data/`
  é o diretório de assets do Processing.
- `player_sheet.png` mede 640×64 e contém 10 quadros de 64×64.
- `player_sheet.json` registra `idle` nos quadros 0–1 e `walk` nos quadros 2–9,
  com 500 ms por quadro parado e 100 ms por quadro em movimento.
- `playerCurrentFrame()` soma as durações da faixa selecionada e usa módulo
  pelo total para repetir `idle` e `walk` continuamente.
- A física mantém o personagem em 16×24 na grade lógica. O quadro visual é
  desenhado em 32×32 lógicos e centralizado sobre a caixa de colisão.
- A direção usa `player_facing`: `1` para a direita e `-1` para a esquerda.
  O valor acompanha A/D e setas, é espelhado na camada sem interpolação e é
  redefinido conforme a entrada pela porta ou o reinício da sala.
- Se o carregamento falhar, `drawPlayerFallback()` preserva a execução e a
  caixa física, sem alterar o contrato de movimento.
- O modo de prova `--asset-pipeline-test` continua separado dos assets do jogo.
- `pipeline_probe.aseprite` e `pipeline_probe_frame_1.png` são o fixture do
  ticket #10, não assets finais nem convenção de produção. O probe tem 16×16
  pixels e é exibido duas vezes na grade lógica, no render físico 1280×720.
- O modo de prova prepara uma camada `PGraphics` sem interpolação antes de
  `beginDraw()`. A camada é composta no buffer principal, preservando a
  suavização do texto.
- A prova do pipeline é:
  `"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --asset-pipeline-test`
  Ela salva `last_horizon/output/pipeline_probe.png` e
  `pipeline_probe_window.png`.


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
estão em `mechanics/ACTIONS.md` e `events/` e são executados no sketch.

## Implementação do ciclo

O sketch usa as mesmas regras do modelo `prototype/balance-model.mjs`.
Hub, mapa consultável, física, spritesheet e viewport foram preservados.
A migração foi solicitada explicitamente antes do inventário de assets #8;
as estações e objetos usam a representação geométrica do protótipo.

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
definidos em `mechanics/ACTIONS.md` e `events/`. Não há contenção separada,
economia, racionamento, acelerador, bônus de NPC ou coleta livre.

Números do movimento (grade lógica 640×360; render 1280×720 / 720p): personagem
16×24, andar 1,5 px/quadro, pulo de 48 px, gravidade 0,5, escada 1,0 e
plataformas atravessáveis por baixo.

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
As escadas declaram `ladder_room` e `ladder_x`. Transmissões usam
`transmission_open`, `transmission_text` e as travas `earth_engine_sent`,
`earth_hull_sent` e `earth_loss_sent`; a mensagem de Marte depende de
`survivors` e de `engine_repaired_at_limit`. O modal de ajuda usa `help_open`.
NPCs vivos respondem sempre: `interactNpc` escolhe entre diálogo com retrato e
painel técnico conforme o estado do dia.

`ORDENS` abre comparação ou detalhes. O aceite preventivo valida presença junto
ao responsável; coleta, entrega e sono validam o ponto físico. `E` apenas abre
o painel; `ENTER` confirma. Fechar o painel não cancela a ordem aceita.

O estado de risco individual mantém no máximo uma pessoa em risco. Sobreviventes
mortos deixam de oferecer ordens, mas não alteram custos.

Nenhuma tela recebe parâmetro: as abas compartilham o mesmo estado do sketch.

## Números

`mechanics/ACTIONS.md` é a fonte de regras. Os valores antigos do modelo da
issue #20 estão **SUPERSEDED** pela estrutura de quests. Os valores vigentes do
novo ciclo estão consolidados em `mechanics/ACTIONS.md` e no modelo executável;
o sketch os utiliza sem recalibração local.

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
  `VOLTAR (ESC)` e `FECHAR (ESC)`.
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
`-1` marca uma abertura livre. A porta responde por proximidade horizontal e
vertical; a chegada configurada vale na primeira travessia e o retorno imediato
reaproveita a posição de saída.


O HUD implementa os seis cartões de recurso com **ícone de 16×16 + número +
rótulo + barra**; os rótulos (`ENERGIA`, `OXIGÊNIO`, `ÁGUA`, `COMIDA`, `PEÇAS`,
`MORAL`) são texto provisório e o inventário #8 troca apenas os ícones por
assets. O cartão de quantos estão a bordo usa **A BORDO**; o recurso crítico
pisca a borda e ganha ícone de aviso, sem linha de texto de alerta. A faixa
inferior tem quatro linhas de campos fixos e o rodapé tem `MAPA`, `ORDENS` e o
botão `?`, que abre o modal de ajuda. O mapa macro não imprime nome de nave.
O botão `ORDENS` recebe o selo `!` quando há oferta ou retomada. Círculo e
exclamação geométrica compartilham escala, cor e centro durante o pulso de 1,4 s.

As capturas atualizadas ficam em `last_horizon/output/` na branch do protótipo.

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
| Vitória e derrota | continuam conforme `MENU_VICTORY.md` e `MENU_GAME_OVER.md` |

Os valores exatos e o processamento numérico estão consolidados em
`mechanics/ACTIONS.md`, simulados em `prototype/balance-model.mjs` e executados
em `last_horizon/game.pde` e `last_horizon/tasks.pde`.

Nenhum sobrevivente vivo encerra a partida com mensagem própria: é a quinta causa
de derrota. O técnico não entra na conta dos quatro.

## Como rodar

Na instalação usada, `processing-java` não existe e também não existe
`C:\Program Files\Processing\runtime\bin\java.exe`. O launcher suportado é o
CLI embutido no `Processing.exe`. Os comandos abaixo são executados a partir da
raiz do repositório:

```
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --capture
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --hit-test
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --ladder-test
```

`--capture`, `--hit-test` e `--ladder-test` são a fronteira pública de
verificação. `--capture` salva 34 estados do novo ciclo, os cartões e HUDs do
catálogo, `orders_badge_pulse.png` e as capturas do modal de ajuda e da
transmissão da Terra; exerce aceite presencial, coleta, entrega, custo inviável,
falha, negligência, retomada pela interface, exclusividade diária, crises,
socorro, morte e filtragem do pool. As asserções cobrem também os seis portais
pela tabela, uma porta fora da borda, uma abertura sem deck, limiar acima de
um deck, chegada independente em outro canto, retorno imediato à posição de
entrada, porta coincidente com ponto de quest, escada em x arbitrário, as falas
de NPC por estado, transmissões (motor, casco, primeira perda, uma vez por
partida) e as três variações da mensagem de Marte. Asserção falha imprime
`FALHOU`, marca o resultado como reprovado e encerra o harness:
`QUEST CHECK: PASS` só aparece quando nenhuma asserção falhou.
As verificações de campanha executam uma etapa por frame; enquanto elas rodam,
o sketch mostra uma tela estável de verificação sem expor os recursos mutáveis
dos cenários internos. O mesmo modo executa três estratégias vencedoras,
omissão derrotada e 2.520/2.520 sequências vencidas pela reserva de peças no
próprio Processing. Os modos de hit-test e escada continuam cobrindo as quatro
salas, o letterbox e as rotas físicas.

Limitações observadas:

- A rota manual solicitada pelo ticket seria verificada com
  `Test-Path 'C:\Program Files\Processing\runtime\bin\java.exe'`. O resultado
  nesta instalação é `False`; portanto não há comando manual executável de
  compilação usando esse runtime. O launcher suportado é o CLI do Processing.
- A captura não usa bibliotecas externas do sketch: usa somente o core carregado
  pelo CLI e a família Segoe UI instalada no Windows. Não há biblioteca adicional
  ausente bloqueando o harness.
- O CLI emite os avisos `display count needs to be implemented for non-AWT` e
  `AWT disabled`, mas compila, executa, salva as imagens e encerra com sucesso.
  A execução headless não foi validada nesta sessão.

## Estado da revisão

- **Código atual:** `last_horizon/*.pde` executa as issues #25, #26 e #27, não
  apenas o modelo Node.
- **Contrato:** cinco incidentes nos dias 2, 4, 6, 8 e 10; oito ordens
  preventivas e quatorze soluções físicas; uma conclusão por dia.
- **Mecânicas removidas:** contenção separada, políticas, bônus numéricos,
  acelerador, coleta livre e contador paralelo de intervenção.
- **Espaço preservado:** Comando em hub, mapa consultável, quatro salas,
  portas, escadas, física e animação.
- **Ajustes desta rodada:** vinheta do #11, transmissões da Terra e mensagem de
  Marte, portais com limiar e chegada configurável (retorno imediato à posição
  de saída), porta das Máquinas no Comando validada manualmente no centro do deck
  inferior (`x = 320`), escadas em tabela
  (qualquer ponto configurável), NPCs com fala por estado, cartões de recurso
  rotulados, faixa inferior em campos fixos e modal de ajuda `?`; o nome vazio
  mantém `INICIAR` bloqueado.
- **Evidência:** `--capture` retorna 140 asserções `OK` e `QUEST CHECK: PASS`,
  incluindo a prioridade de quest sobre portal coincidente e a cobertura
  incremental de 2.520 campanhas; `--hit-test` e `--ladder-test` passam; o
  modelo Node retorna `BALANCE CHECK: PASS`.
- **Capturas conferidas:** ofertas, confirmação presencial, coleta/entrega,
  objeto carregado, mapa, incidentes de motor/casco/suporte, retomada, socorro,
  resumo noturno denso, vitória e derrota em `last_horizon/output/`.
- **Limite visual:** a arte final dos objetos e estações permanece no inventário
  #8; a lógica física já funciona com a representação geométrica existente.
