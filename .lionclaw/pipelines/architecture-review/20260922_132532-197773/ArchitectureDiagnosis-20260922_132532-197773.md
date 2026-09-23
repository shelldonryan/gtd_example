# Architecture Diagnosis: Last Horizon
**Data:** 2026-09-22
**Run:** 20260922_132532-197773
**Candidato escolhido:** C6 — Aprofundar o Module de frame e o relógio de movimento

## Causa raiz
O Module de frame não possui uma Interface temporal: `draw()` é simultaneamente o relógio implícito da simulação, o orquestrador do render pass e o ponto de instrumentação. Como movimento e áudio avançam por quantidade de callbacks enquanto animação e HUD consultam relógios globais (`millis()`/`frameCount`), a variação da taxa de frames atravessa várias Implementations e distribui a política entre Modules; os caches e hooks existentes são Seams parciais, mas não dão Leverage e Locality para controlar tempo, ordem e orçamento.

## Evidencias por arquivo
### last_horizon/last_horizon.pde:252-273
- **Finding:** `setup()` apenas solicita `frameRate(60)` na linha 252. O callback `draw()` executa, em sequência, `updateInput()`, `updateRoom()`, `drawBase()`, `updateCursor()`, `drawWindow()` e o hook `harness_update`.
- **Impact:** A taxa de frames é o relógio implícito de atualização, renderização e instrumentação. Não existe um `FrameContext` ou delta explícito que permita separar duração da simulação, fases do render e orçamento por frame; a conclusão sobre o efeito de frames longos é estrutural, pois a execução real não foi repetida nesta fase.

### last_horizon/movement.pde:17-50
- **Finding:** `updateRoom()` não recebe tempo decorrido e chama `updatePlayerOnLadder()` ou `updatePlayerOnDeck()` uma vez por invocação, depois limpa `jump_queued`.
- **Impact:** A atualização física, o consumo de input e a progressão de uma ação estão acoplados à quantidade de callbacks de `draw()`. Um teste precisa montar o estado global e repetir chamadas do loop para representar passagem de tempo.

### last_horizon/movement.pde:110-146
- **Finding:** A velocidade horizontal é escolhida como `PLAYER_SPEED` ou `PLAYER_RUN_SPEED` e aplicada diretamente em `player_x + horizontal`; a corrida acumula `abs(horizontal)` para decidir passos, enquanto a caminhada usa `millis()` e `WALK_STEP_HALF_CYCLE_MS` para emitir áudio.
- **Impact:** Distância de movimento e eventos de corrida são contados por chamada, mas a fase sonora da caminhada é contada por relógio de parede. Uma queda de frames altera a relação entre distância, animação e áudio; a política fica espalhada entre movimento e relógio global sem um Seam temporal comum.

### last_horizon/movement.pde:208-226
- **Finding:** A subida de escada aplica `vertical * LADDER_SPEED` por invocação, acumula `dy` e chama `playLadderStepSound()` quando o limiar é atingido.
- **Impact:** A viagem na escada e a cadência de passos dependem do número de atualizações. Em taxa baixa, menos callbacks produzem menos deslocamento e menos eventos por segundo; não há política explícita para compensar um frame longo, descartar eventos acumulados ou limitar trabalho.

### last_horizon/animation.pde:53-105
- **Finding:** `playerCurrentFrame()` reinicia `player_animation_started_at` com `millis()` quando o estado muda e calcula `raw_elapsed` com `millis() - player_animation_started_at`; a seleção do frame percorre as durações do take.
- **Impact:** A animação usa tempo de parede independente do avanço físico por callback. Um frame longo pode avançar vários frames visuais entre duas atualizações de movimento, e o teste da animação precisa manipular diretamente `player_animation_started_at` em vez de fornecer um relógio controlado.

### last_horizon/audio.pde:139-169
- **Finding:** Cada `playDeckStepSound()` e `playLadderStepSound()` chama `stopStepSounds()` antes de tocar o clip. `stopStepSounds()` percorre os arrays de passos de caminhada, corrida e escada e chama `stopSound()` para cada posição.
- **Impact:** A emissão de um evento de movimento também executa a política de interrupção de todo o conjunto de clips. Como o evento nasce dentro de `movement.pde`, não existe um Adapter de áudio com fila, timestamp ou regra de comportamento para frames longos; o custo e a cadência ficam no mesmo caminho quente da física.

### last_horizon/last_horizon.pde:277-305
- **Finding:** `drawBase()` abre o buffer, chama `resetButtons()`, desenha a tela, desenha HUD e modais conforme a camada ativa, executa o overlay opcional e fecha o buffer em todo callback.
- **Impact:** O render pass, a reconstrução do registro de hit-test e os hooks de teste compartilham a mesma cadência da simulação. Uma otimização ou teste de uma fase exige atravessar o grafo global do sketch porque não há um Module de frame que prepare dados e imponha orçamento entre atualização, renderização e instrumentação.

### last_horizon/ship.pde:320-343
- **Finding:** `drawRoom()` resolve o backdrop ou desenha paredes, decoração, conveses e escadas; em seguida desenha título, portas, percorre todos os pontos da sala e chama `drawPlayer()`.
- **Impact:** A apresentação da nave percorre geometria, pontos físicos, arte e animação a cada frame. A ausência de uma Interface entre dados preparados e desenho deixa decisões de seleção e trabalho visual dentro do callback que também controla o relógio do jogo.

### last_horizon/hud.pde:38-50
- **Finding:** `drawHeader()` monta valores como `day + "/" + trip_days` e `str(survivors)` e percorre `HUD_RESOURCE_ORDER` para desenhar os seis cartões de recurso, consultando valor, label, cor e preenchimento a cada chamada.
- **Impact:** Formatação e consultas de estado são refeitas no render pass. O custo residual de frame e suas alocações ficam misturados com desenho de nave e modais; o cache de ícones não cria Locality para a preparação de todo o HUD.

### last_horizon/hud.pde:95-117
- **Finding:** `drawResourceCard()` chama `millis()` para calcular o pulso de alerta e formata o valor e o label durante o desenho de cada cartão.
- **Impact:** O HUD mantém um segundo uso direto do relógio global e uma política visual dependente do frame. Um Module de frame aprofundado precisaria fornecer o tempo visual de modo coerente com animação, movimento e pausa, além de separar preparação de dados do desenho.

### last_horizon/ui.pde:36-77
- **Finding:** `resetButtons()` zera os contadores de todas as camadas no começo de cada render; `addButton()` atualiza arrays globais, contadores por camada e o registro global durante o desenho dos controles.
- **Impact:** Renderização e hit-test são dois efeitos do mesmo passe. O contrato de UI é útil como Seam de observação, mas não permite medir ou limitar independentemente o trabalho de registro por frame; mudanças no render pass continuam afetando interação e performance juntas.

### last_horizon/assets.pde:235-266
- **Finding:** `loadArt()` mantém `art_cache`, consulta o filesystem por `artExists()`, chama `loadImage()`, registra fallback e grava inclusive resultados nulos no cache.
- **Impact:** Há um Adapter parcial para assets, com boa reutilização após o primeiro carregamento, mas a resolução, fallback e cache continuam acoplados ao estado global do sketch. A política não é uma dependência substituível pelo Module de frame.

### last_horizon/ship.pde:409-438
- **Finding:** `roomDetail()` mantém um `room_detail_cache`, tenta `loadArt()` e, se falhar, monta um caminho legado e chama `loadImage(legacy_path)` diretamente, com seu próprio fallback.
- **Impact:** O caminho visual possui uma segunda política de carregamento e fallback fora de `loadArt()`. A primeira renderização de decoração pode executar filesystem e decodificação dentro de `drawRoom()`, e qualquer aprofundamento de cache precisa coordenar `ship.pde` com `assets.pde`.

### last_horizon/assets.pde:656-715
- **Finding:** `prepareDeckStrips()` invalida entradas quando fonte, largura, escala ou geração mudam e, em um miss, cria `PGraphics`, copia tiles com `tile.get()`, cria um bitmap e o adiciona ao cache.
- **Impact:** O projeto já tem um Seam real de cache e contadores de builds, mas a criação de bitmaps e a invalidação são políticas de assets fora do Module de frame. Sem uma fase explícita de preparação, o render pass não define quando esse trabalho pode ocorrer nem como ele compete com atualização e áudio.

### last_horizon/hud.pde:225-275
- **Finding:** `ensureResourceIconCache()` invalida e reconstrói o cache por fonte e escala; em um miss cria `PGraphics`, copia a imagem para um bitmap e registra builds e memória.
- **Impact:** O HUD tem um cache paralelo ao de faixas e ao de assets gerais. Os Seams de cache existem, mas a falta de uma política temporal e de orçamento comum distribui alocações e invalidações entre renderizadores.

### last_horizon/capture.pde:92-101
- **Finding:** `installHarness()` instala `harness_setup`, `harness_update` e `harness_scene`; o primeiro lê argumentos e fixtures, o segundo chama `updateCapture()` e o terceiro substitui a cena desenhada.
- **Impact:** Este é um Seam atual de verificação e de composição de cena, mas o harness observa ou substitui partes do fluxo sem injetar um relógio para `updateRoom()`, `playerCurrentFrame()` ou o áudio. Os testes continuam dependentes do estado global e das funções reais.

### last_horizon/capture.pde:637-664
- **Finding:** `updatePerformanceMetrics()` calcula o tempo entre frames com `System.nanoTime()`, armazena cada `frame_ms` e finaliza a amostra de 30 segundos; `updateCapture()` chama essa rotina quando `performance_mode` está ativo.
- **Impact:** A medição captura o intervalo real entre callbacks e calcula p95, mas não controla esse intervalo nem o divide em atualização, renderização, cache e áudio. O Seam de métricas prova que o custo pode ser observado, não que a execução tenha uma Interface temporal testável.

### last_horizon/capture.pde:2281-2320
- **Finding:** Os testes chamam `updatePlayerOnDeck()` diretamente, repetem a função 11 vezes para corrida e até 64 vezes para o pulo, e verificam `sound_step_play_count` por quantidade de chamadas.
- **Impact:** A superfície existente valida a semântica por frame e por evento, mas não compara dois intervalos de tempo equivalentes com taxas de atualização diferentes. Isso deixa sem cobertura a fricção arquitetural que C6 precisa resolver.

## Call sites afetados
- `last_horizon/last_horizon.pde:261-273`: `draw()` coordena input, movimento, renderização, cursor, janela e harness em uma única cadência.
- `last_horizon/movement.pde:77-146`: pulo, aterrissagem, corrida e caminhada chamam diretamente `playDeckStepSound()`.
- `last_horizon/movement.pde:209-226`: movimento em escada chama diretamente `playLadderStepSound()`.
- `last_horizon/animation.pde:1-15`: `drawPlayer()` consulta o frame e atualiza a camada renderizada a partir do estado global.
- `last_horizon/ship.pde:320-343`: `drawRoom()` percorre o mundo físico, pontos e jogador em cada render pass.
- `last_horizon/hud.pde:38-117`: o HUD reconsulta estado, relógio visual e dados de recursos em cada frame.
- `last_horizon/ui.pde:36-77`: o registro de controles é limpo e reconstruído durante a apresentação.
- `last_horizon/capture.pde:637-664`: a medição observa o intervalo entre callbacks após o frame, sem comandar a duração da atualização.

## Seams atuais
- **Callback `setup()`/`draw()`:** separa o runtime Processing do sketch e define a ordem atual de input, movimento, renderização e captura; não separa relógio, atualização e render.
- **Hooks `harness_setup`, `harness_update` e `harness_scene`:** em `capture.pde:92-101`, permitem fixtures, cenários e substituição de cena; não substituem `millis()`, `frameCount`, `Clip` ou a duração do frame.
- **`loadArt()` e caches de faixas/ícones:** `assets.pde:235-266`, `assets.pde:656-715` e `hud.pde:225-275` concentram parte do carregamento e da invalidação; `ship.pde` ainda mantém um caminho legado separado.
- **`playerCurrentFrame()` e `updatePlayerFrameLayer()`:** oferecem funções separadas para seleção e materialização do frame; ambas dependem de estado global e o relógio continua sendo lido diretamente.
- **`playDeckStepSound()` e `playLadderStepSound()`:** são pontos nomeados para escolha e reprodução de clips; funcionam como Seam parcial, pois não recebem evento temporal nem permitem um Adapter em memória.
- **Contadores de performance:** `capture.pde:527-536` e `capture.pde:637-664` oferecem uma superfície de observação para tempo de frame, memória, alocações, builds e invalidações.

## Seams ausentes
- **Interface de relógio/frame:** um Module de frame deveria fornecer tempo decorrido, timestamp lógico, pausa e limite de trabalho; hoje `draw()` e chamadas diretas a `millis()`/`frameCount` ocupam esse papel implicitamente.
- **Seam de integração de movimento:** `updateRoom()` e os integradores deveriam receber delta controlado para que convés e escada sejam testáveis com o mesmo tempo lógico em diferentes taxas de callback.
- **Seam movimento-áudio:** movimento deveria emitir eventos normalizados para um Adapter de áudio real e um recorder em memória; hoje chama funções que manipulam `Clip` diretamente e interrompem todos os sons.
- **Seam entre preparação e render pass:** nave, HUD, UI, animação e caches deveriam receber dados preparados dentro de fases explícitas; hoje o desenho consulta estado, formata strings, registra hit-test e pode disparar construção de cache.
- **Seam único de resolução de assets:** `roomDetail()` deveria compartilhar a política de `loadArt()` antes de qualquer novo aprofundamento; o caminho legado de `ship.pde` mantém filesystem, fallback e cache fora do Adapter existente.
- **Seam de teste temporal:** o harness deveria conseguir fornecer uma sequência de deltas e frames longos e capturar eventos sem depender do relógio real, da execução de Processing ou de hardware de áudio.

## Categoria de dependencias
| Dep | Categoria | Estratégia de teste recomendada |
|---|---|---|
| Estado global de movimento, animação e geometria em memória | in-process | Fixtures determinísticas; testar integradores, transições e seleção de frame como funções do estado fornecido. |
| Ciclo `draw()`, `millis()` e `frameCount` do Processing | local-substitutable | Criar um relógio/frame fake para testes do futuro Module; manter um teste de integração com callbacks reais. |
| `PGraphics`, `createGraphics()` e desenho Processing | local-substitutable | Usar superfície headless ou harness de pixels com fixtures; verificar equivalência visual em cenários selecionados. |
| Filesystem local de assets, `File`, `loadImage()` e `loadJSONObject()` | local-substitutable | Usar catálogo/fake de assets ou diretório temporário; reservar a leitura de `data/` para integração. |
| Java Sound `Clip` e `AudioSystem` | external | Injetar recorder/mock de eventos; verificar tipo, ordem, cadência e descarte sem abrir dispositivo de áudio. |
| `System.nanoTime()`, `ThreadMXBean` e arquivos de métricas | local-substitutable | Fornecer sampler e saída temporários/fakes; testar agregação de p95 e alocações separadamente da captura real. |

Não foi identificada dependência `remote-owned` no candidato nem nos arquivos reexplorados; o Map também registra ausência de rede, IPC, backend e banco de dados.

## Impacto em testes/manutencao/performance
- **Testabilidade:** a verificação existente consegue repetir `updatePlayerOnDeck()` e manipular `player_animation_started_at`, mas não consegue fornecer um delta comum a movimento, animação e áudio. O teste de um frame longo exige o runtime Processing e torna difícil distinguir atraso de renderização, atualização ou áudio.
- **Manutenção:** uma mudança na política temporal atravessa `last_horizon.pde`, `movement.pde`, `animation.pde`, `audio.pde`, `hud.pde` e os renderizadores. O baixo Leverage da Interface atual aparece na dependência de estado global, relógios globais e arrays de clips compartilhados.
- **Performance:** o render pass redesenha nave, HUD, UI e jogador a cada callback; caches reduzem parte do trabalho, mas podem construir `PGraphics` e bitmaps em miss ou invalidação. O contrato de `capture.pde` já mede p95, memória, builds, invalidações e alocações, porém não atribui custo às fases nem controla o orçamento.
- **Limite da prova:** não foram coletados valores de p95, `allocations_per_frame` ou contagem de passos em execução real nesta fase. Os efeitos de queda de frames são consequências inferidas das unidades de avanço e dos relógios usados no código, não uma alegação de benchmark.

## Riscos se nada for feito
- Movimento de convés e escada pode variar com a taxa de callbacks, enquanto animação e pulsos visuais seguem `millis()`, criando divergência temporal difícil de reproduzir.
- A cadência de passos pode ficar atrasada ou irregular em frames longos, e cada evento ainda percorre e interrompe todos os clips de movimento.
- O custo de renderização, formatação, hit-test e reconstrução de cache continua competindo no mesmo callback da atualização física, elevando p95 e alocações sem uma política de orçamento.
- Testes continuarão validando repetições de frame e contagens globais, deixando sem prova o comportamento sob deltas equivalentes, pausas e baixa taxa de frames.
- Mudanças futuras precisarão coordenar vários Modules e Seams parciais, aumentando a chance de regressões cruzadas entre movimento, áudio, animação e apresentação e reduzindo a Locality para onboarding.
