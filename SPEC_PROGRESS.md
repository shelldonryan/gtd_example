# SPEC_PROGRESS - preparacao-integrada-para-entrega

## Status: 8/9 sprints implementadas; sprint 009 com validação pendente
Ultima atualizacao: 2026-09-23T01:56:04.773Z

---

## Sprint 009 - Validação integrada e registro de conclusão [IMPLEMENTADA — validação pendente]
- Runner integrado: `npm run verification:final` preserva logs individuais, códigos, timeouts e diagnósticos para typecheck, build, quatro cenários Processing, matriz opcional, simulação, runner Windows, profiling, limpeza e snapshot.
- Equivalência auditável: o runner valida `last_horizon/output/equivalence-report.json` com 22 quests × 34 estados, 748 identificadores únicos e diferenças campo a campo.
- Gate robusto: `tools/compare-profiling.mjs` valida CSVs, sidecars, cinco hotspots, três amostras por perfil, p95, regressões, allocations e redução reproduzível nos perfis `core-i3-integrated` e `reference`.
- Limpeza preservada: `tools/cleanup-verification-artifacts.mjs` remove somente saídas transitórias e mantém equivalência, fallback, métricas, profiling e logs.
- Snapshot final: `tools/snapshot-entrega.mjs` exige limpeza, gera manifesto `final: true`, compila a cópia base e verifica a ausência de controles de desenvolvimento sem alterar refs Git.
- Verificação desta sessão: `git diff --check` PASS; Node.js, Bash e Processing INCONCLUSIVOS porque a restrição operacional permite somente comandos iniciados por `git`. O snapshot disponível ainda é intermediário e precisa ser regenerado em ambiente compatível.

---

## Sprint 007 - Harness, módulos opcionais e snapshot de entrega [IMPLEMENTADA — validação pendente]
- Matriz de compilação: `tools/optional-modules.mjs` e `tools/processing-cli.sh` validam `base`, `capture`, `manual` e `complete`, removendo fisicamente os módulos ausentes antes da compilação; falha é FAIL e pré-requisito ausente é INCONCLUSIVO.
- Harness desacoplado: `last_horizon.pde` mantém hooks inertes; `capture.pde` continua reconhecendo `--capture`, `--hit-test`, `--ladder-test`, `--asset-pipeline-test` e `--metrics` apenas quando incluído.
- Modo manual: `test_mode.pde` instala Ctrl+K, teleporte e overlay somente na combinação manual/completa; `pointIsAvailable()` não consulta mais o destaque forçado, preservando as autorizações de gameplay.
- Snapshot intermediário: `tools/snapshot-entrega.mjs` copia somente arquivos rastreados, exclui a lista vigente, cria `output/snapshot-entrega/` e grava `output/snapshot-entrega-manifest.json` sem alterar refs Git; o manifesto marca `final: false` e requer regeneração após sprint-008.
- Verificação: `git diff --check` será registrado após a revisão dos arquivos; Node.js e Processing permanecem INCONCLUSIVOS nesta sessão porque a solicitação restringe o terminal a comandos iniciados por `git`.

---

## Sprint 006 - Camada modal e interação unificadas [IMPLEMENTADA — validação pendente]
- Resolução única: `uiLayer()` mantém a prioridade normativa de pausa, transmissão, incidente, ordens, mapa, diálogo, painel técnico, sono, ajuda e cena; desenho e entrada não atravessam a camada ativa.
- Geometria compartilhada: desenho, hover, cursor e hit-test usam o mesmo predicado retangular; o registro aceita 24 controles por camada e anota excessos com diagnóstico.
- Fechamento seletivo: ESC no incidente retorna do detalhe à comparação e depois pausa preservando o incidente; transmissão revela o incidente; Ordens limpa paginação/detalhes sem cancelar ordem; sono preserva a `NightProjection` até a confirmação.
- Verificação: `checkModalLayerContract()` cobre prioridade, ações encobertas, limpeza, preview e limites. `git diff --check` passou; typecheck, build e harness Processing permanecem INCONCLUSIVOS nesta sessão porque a solicitação restringe o terminal a comandos iniciados por `git`.

---

## Sprint 005 - Equivalência de quests e ciclo noturno [CONCLUIDA]
- Projeção pura: `simulateNightTransition()` trabalha sobre snapshots copiados, sem random, modais ou memória editorial global, e mantém a ordem normativa de consequências, consumo, perdas, riscos, prazos, crises e condições fatais.
- Aplicação única: `projectNight()` guarda a instância exibida; `processNight()` valida assinaturas de origem e projeção, aplica uma única vez e invalida a prévia em confirmação, obsolescência, restauração ou fechamento.
- Equivalência preservada: `capture.pde` protege os 22 IDs e 34 estados, compara campos de resultado e valida a aplicação do objeto exibido; qualquer alteração recebe FAIL.
- Calendário e modelo: o ciclo de dez dias, quatro sobreviventes, quatro cômodos, seis recursos, quests físicas, riscos e modelo independente permanecem preservados.
- Verificação: `npm run typecheck`, `npm run build`, `node prototype/balance-model.mjs --simulate` e `bash tools/regression-final.sh` passaram. O relatório canônico registra 748/748 entradas PASS; lint não possui script configurado e a regressão Windows permanece inconclusiva fora de Windows.

---

## Sprint 001 - Fundação de rastreabilidade e baseline [CONCLUIDA]
- Registro inicial de verificação: Estruturar o registro de verificação com a identificação da referência baseline, comandos, pré-requisitos, timeouts, evidências, limitações e status normativos.
- Inventário autoritativo da entrega: Registrar a superfície atual do sketch, das ferramentas, dos módulos opcionais, dos comandos do package.json e das fixtures de equivalência que não podem ser removidos ou enfraquecidos.
- Baseline funcional: Executar ou registrar a tentativa dos cenários funcionais existentes antes da refatoração, preservando as evidências necessárias para comparação posterior.
- Guarda de escopo arquitetural: Fixar os limites que todas as sprints seguintes devem respeitar: aplicação local Processing, estado global em memória, ferramentas CLI independentes e ausência de novas camadas de produto.

---

## Sprint 002 - Contrato de métricas e comparação baseline [IMPLEMENTADA]
- Captura canônica: `--metrics` grava três amostras individuais com CSV, sidecar estrutural, fixture aprovada, janela nominal de 30 segundos e profiling vinculado.
- Comparação auditável: `tools/compare-metrics.mjs` exige três amostras por referência, valida os contratos e aplica medianas, precedência de status, redução reproduzível e limite de regressão de 10%.
- Operação rastreável: os runners preservam stdout/stderr, códigos de saída e timeouts normativos para typecheck, regressão, build, captura, comparação, snapshot, cleanup e simulação.
- Profiling comparável: `tools/compare-profiling.mjs` valida baseline e versão revisada nos perfis `core-i3-integrated` e `reference`, incluindo os cinco hotspots obrigatórios.
- Validação técnica: `git diff --check` passou; os comandos Node/Processing não foram executados porque as restrições desta solicitação permitem somente comandos iniciados por `git` no terminal.

## Sprint 003 - Otimização de renderização estática e assets [CONCLUIDA]
- Cache dos seis ícones de recursos: Preparar e reutilizar as representações estáticas de energia, oxigênio, água, comida, peças e moral no fluxo normal do HUD.
- Cache seletivo de faixas de piso: Reutilizar faixas de piso entre conveses quando tile, largura e geração da fonte forem iguais, mantendo a imagem compartilhada imutável.
- Fallback individual de assets: Preservar a execução quando ícones, faixas, sprites, portas, estações ou imagens do pipeline estiverem ausentes, parciais ou inválidos.
- Instrumentação de custo dos caches: Integrar as construções, invalidações e memória adicional dos caches ao contrato de métricas estabelecido na sprint anterior.

---

## Sprint 004 - Transições, helpers e organização estrutural [IMPLEMENTADA]
- Preparação única de transição: Resolver destino, saída, chegada, direção e retorno antes da escolha entre travessia animada e imediata.
- Robustez do ciclo de portal: Ignorar reentrada, manter abertura/fechamento com arte completa, tolerar ausência ou falha de áudio e diagnosticar portas inválidas.
- Organização nas abas existentes: Preservar responsabilidades em `ship.pde`, `portals.pde`, `movement.pde`, `animation.pde` e `audio.pde`, mantendo `editorial.pde` no inventário.
- Consolidação de helpers: Centralizar texto com sombra, resolução de arte de NPC, preparação de imagens e mapeamento de recursos, mantendo contratos de fallback e sem mover regras de gameplay.
- Verificação: Registrar a equivalência funcional e o inventário de duplicações em `code/VERIFICATION.md`; `git diff --check` passou sob a restrição de comandos somente leitura do Git.

## Sprint 004 - Transições, helpers e organização estrutural [CONCLUIDA]
- Preparação única de transição: Centralizar em preparePortalTransition() a resolução de destino, saída, chegada, direção e retorno antes da escolha entre transição animada e imediata.
- Robustez do ciclo de portal: Preservar fases, áudio, fallback e bloqueio de reentrada durante transições animadas, imediatas ou inválidas.
- Organização nas abas existentes: Manter cenário, nave, portais, movimento, animação e áudio identificáveis nas abas atuais, com movimentações mínimas e rastreáveis.
- Consolidação de helpers inventariados: Consolidar somente duplicações previamente listadas, incluindo texto com sombra, rodapé, arte de NPC, preparação de imagens e mapeamento de recursos, mantendo contratos explícitos.

## Sprint 002 - Contrato de métricas e comparação baseline [CONCLUIDA]
- Captura canônica de métricas: Adequar o modo --metrics para produzir o manifesto sidecar obrigatório e o CSV numérico canônico para cada captura.
- Comparador de três amostras: Implementar ou ajustar tools/compare-metrics.mjs para validar contratos, agregar amostras e calcular variações com a precedência de status definida na SPEC.
- Contrato operacional de falhas: Alinhar os comandos de captura e comparação ao comportamento operacional de stdout, stderr, código de saída e timeout por ambiente.
- Registro de profiling comparável: Definir a coleta e o vínculo do profiling antes e depois da revisão para o notebook Core i3 com vídeo integrado e para o perfil de referência, deixando o gate final executável e rastreável.

## Sprint 003 - Otimização de renderização estática e assets [CONCLUIDA]
- Cache dos seis ícones de recursos: Preparar e reutilizar as representações estáticas de energia, oxigênio, água, comida, peças e moral no fluxo normal do HUD.
- Cache seletivo de faixas de piso: Reutilizar faixas de piso entre conveses quando tile, largura e geração da fonte forem iguais, mantendo a imagem compartilhada imutável.
- Fallback individual de assets: Preservar a execução quando ícones, faixas, sprites, portas, estações ou imagens do pipeline estiverem ausentes, parciais ou inválidos.
- Instrumentação de custo dos caches: Integrar as construções, invalidações e memória adicional dos caches ao contrato de métricas estabelecido na sprint anterior.

## Sprint 004 - Transições, helpers e organização estrutural [CONCLUIDA]
- Preparação única de transição: Centralizar em preparePortalTransition() a resolução de destino, saída, chegada, direção e retorno antes da escolha entre transição animada e imediata.
- Robustez do ciclo de portal: Preservar fases, áudio, fallback e bloqueio de reentrada durante transições animadas, imediatas ou inválidas.
- Organização nas abas existentes: Manter cenário, nave, portais, movimento, animação e áudio identificáveis nas abas atuais, com movimentações mínimas e rastreáveis.
- Consolidação de helpers inventariados: Consolidar somente duplicações previamente listadas, incluindo texto com sombra, rodapé, arte de NPC, preparação de imagens e mapeamento de recursos, mantendo contratos explícitos.

## Sprint 003 - Otimização de renderização estática e assets [CONCLUIDA]
- Cache dos seis ícones de recursos: Preparar e reutilizar as representações estáticas de energia, oxigênio, água, comida, peças e moral no fluxo normal do HUD.
- Cache seletivo de faixas de piso: Reutilizar faixas de piso entre conveses quando tile, largura e geração da fonte forem iguais, mantendo a imagem compartilhada imutável.
- Fallback individual de assets: Preservar a execução quando ícones, faixas, sprites, portas, estações ou imagens do pipeline estiverem ausentes, parciais ou inválidos.
- Instrumentação de custo dos caches: Integrar as construções, invalidações e memória adicional dos caches ao contrato de métricas estabelecido na sprint anterior.

## Sprint 004 - Transições, helpers e organização estrutural [CONCLUIDA]
- Preparação única de transição: Centralizar em preparePortalTransition() a resolução de destino, saída, chegada, direção e retorno antes da escolha entre transição animada e imediata.
- Robustez do ciclo de portal: Preservar fases, áudio, fallback e bloqueio de reentrada durante transições animadas, imediatas ou inválidas.
- Organização nas abas existentes: Manter cenário, nave, portais, movimento, animação e áudio identificáveis nas abas atuais, com movimentações mínimas e rastreáveis.
- Consolidação de helpers inventariados: Consolidar somente duplicações previamente listadas, incluindo texto com sombra, rodapé, arte de NPC, preparação de imagens e mapeamento de recursos, mantendo contratos explícitos.

## Sprint 005 - Equivalência de quests e ciclo noturno [CONCLUIDA]
- Projeção noturna sem efeitos colaterais: Garantir que simulateNightTransition() produza uma projeção completa sem alterar estado global, aleatoriedade, modais ou memória editorial.
- Aplicação única da projeção: Fazer processNight() aplicar exatamente a NightProjection exibida, invalidando prévias obsoletas e evitando recálculo ou repetição de perdas.
- Preservação de quests e calendário: Preservar ofertas preventivas, incidentes, soluções, seleção, confirmação presencial, coleta, entrega, retomada, socorro e o ciclo diário existente.
- Ordem normativa e verificação noturna: Validar a ordem das consequências noturnas, condições fatais e precedência de derrota, relacionando o resultado ao harness e ao modelo independente.

## Sprint 005 - Equivalência de quests e ciclo noturno [CONCLUIDA]
- Projeção noturna sem efeitos colaterais: Garantir que simulateNightTransition() produza uma projeção completa sem alterar estado global, aleatoriedade, modais ou memória editorial.
- Aplicação única da projeção: Fazer processNight() aplicar exatamente a NightProjection exibida, invalidando prévias obsoletas e evitando recálculo ou repetição de perdas.
- Preservação de quests e calendário: Preservar ofertas preventivas, incidentes, soluções, seleção, confirmação presencial, coleta, entrega, retomada, socorro e o ciclo diário existente.
- Ordem normativa e verificação noturna: Validar a ordem das consequências noturnas, condições fatais e precedência de derrota, relacionando o resultado ao harness e ao modelo independente.

## Sprint 005 - Equivalência de quests e ciclo noturno [CONCLUIDA]
- Projeção noturna sem efeitos colaterais: Garantir que simulateNightTransition() produza uma projeção completa sem alterar estado global, aleatoriedade, modais ou memória editorial.
- Aplicação única da projeção: Fazer processNight() aplicar exatamente a NightProjection exibida, invalidando prévias obsoletas e evitando recálculo ou repetição de perdas.
- Preservação de quests e calendário: Preservar ofertas preventivas, incidentes, soluções, seleção, confirmação presencial, coleta, entrega, retomada, socorro e o ciclo diário existente.
- Ordem normativa e verificação noturna: Validar a ordem das consequências noturnas, condições fatais e precedência de derrota, relacionando o resultado ao harness e ao modelo independente.

## Sprint 006 - Camada modal e interação unificadas [CONCLUIDA]
- Resolução única de camada: Centralizar em uiLayer() a prioridade entre pausa, transmissão, incidente, ordens, mapa, diálogo, painel técnico, sono, ajuda e cena.
- Geometria compartilhada de controles: Usar a mesma geometria para desenho, cursor, mouse, teclado e hit-test, respeitando o limite de registros por camada.
- Fechamento e limpeza de modais: Preservar retornos, pendências e limpeza de estado para ESC, fechamento de transmissão, incidente, ordens, mapa, diálogo, painel técnico, sono, ajuda e cena.

## Sprint 007 - Harness, módulos opcionais e snapshot de entrega [CONCLUIDA]
- Matriz de compilação opcional: Validar o sketch como unidade nas combinações base, captura, manual e completa com os módulos capture.pde e test_mode.pde.
- Harness preservado e desacoplado: Manter os modos de captura e validação disponíveis sem tornar os hooks obrigatórios ao runtime normal.
- Segurança do modo manual: Preservar Ctrl+K, teleporte e destaque visual apenas no modo manual incluído explicitamente, sem transformar destaque em autorização de gameplay.
- Contrato de snapshot de entrega: Adequar snapshot-entrega.mjs para aplicar as exclusões vigentes e produzir o manifesto intermediário dos arquivos excluídos e do runtime mantido antes da limpeza final.

## Sprint 001 - Fundação do relógio de simulação [CONCLUIDA]
- Baseline técnico e funcional: Registrar a referência anterior à migração, os pré-requisitos disponíveis e os resultados dos checks e métricas já existentes.
- Contrato temporal central: Criar o Frame Module com relógio substituível, contexto do callback, passo fixo, acumulador limitado e diagnóstico de amostras inválidas.
- Integração do Frame Module ao shell: Fazer o callback draw() usar o Frame Module como única origem dos passos de sala, mantendo a coordenação do input, apresentação, janela e harness no shell.

## Sprint 002 - Fronteiras de callback, pausa e transições [CONCLUIDA]
- Snapshot de input por callback: Amostrar o input uma vez e disponibilizar estados contínuos e ações de borda aos passos do mesmo callback.
- Congelamento e rebase da simulação: Impedir acúmulo de tempo simulado durante pausa ou fora de telas de sala, mantendo o relógio de apresentação ativo.
- Barreiras de controle e portas: Interromper os passos restantes quando uma atualização abre modal, inicia uma porta ou muda a tela, preservando a semântica de parede das transições.

## Sprint 003 - Movimento determinístico por passo fixo [CONCLUIDA]
- Integração de caminhada e corrida: Fazer o deslocamento horizontal usar o tempo lógico do passo mantendo as velocidades observadas na referência de 60 FPS.
- Salto, gravidade e aterrissagem: Migrar o avanço vertical e as transições de salto para o passo fixo sem repetir ações de borda.
- Movimento de escada: Migrar subida, descida, entrada e saída de escadas para o passo explícito.
- Cadência lógica de movimento: Associar fases e limiares de contato do movimento ao avanço simulado para posterior emissão de animação e áudio.

## Sprint 004 - Animação vinculada ao tempo simulado [CONCLUIDA]
- Estado de animação confirmado: Definir a transição do take e seu instante lógico durante o avanço simulado.
- Seleção determinística de frames: Calcular os frames dos takes existentes a partir do estado confirmado e do relógio fake ou de produção.
- Invalidação da camada do jogador: Preservar a reutilização de player_frame_layer entre apresentações equivalentes.

## Sprint 005 - Eventos e adapter de áudio de movimento [CONCLUIDA]
- Contrato de evento sonoro: Representar caminhada, corrida, escada, decolagem e aterrissagem como eventos produzidos pelos passos executados.
- Recorder de áudio em memória: Disponibilizar um adapter substituível que registre eventos sem abrir dispositivo de áudio.
- Despacho físico coalescido: Concentrar a reprodução concreta e limitar rajadas sem alterar o registro lógico.
- Instrumentação de stopStepSounds: Medir o custo e a visita aos clips antes de aceitar qualquer mudança de desempenho.

## Sprint - Apresentação, HUD, UI e política de assets [VALIDADA]

### Inventário do relógio visual

| Arquivo/linha | Efeito inventariado | Relógio atribuído |
| --- | --- | --- |
| `last_horizon/hud.pde:105` | Pulso do destaque de recurso crítico | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/hud.pde:394` | Pulso do ícone de alerta | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/hud.pde:412,483,518` | Prazo de exibição da mensagem temporária do objetivo/alerta | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/hud.pde:556` | Pulso do selo de Ordens | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/ship.pde:955` | Brilho pulsante do alvo de quest em estação | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/ship.pde:1020` | Brilho pulsante do alvo de quest em NPC | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/ui.pde:643` | Cintilação das estrelas da tela de vinheta | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/screens.pde:364` | Pulso luminoso do título da tela inicial | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/screens.pde:499` | Pulso do comando para continuar a vinheta | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/assets.pde:1129` | Seleção temporal de frame de arte animada de NPC/casco | `presentationTimeMillis()` do `FrameContext` |
| `last_horizon/frame.pde:56` | Amostragem de tempo lógico do relógio de produção | `millis()` como fonte do relógio de simulação; separado do relógio visual |
| `last_horizon/portals.pde:154,175,179` | Fases de abrir/fechar porta (`ART_DOOR_PHASE_MS`) | `millis()`/relógio de parede, preservado intencionalmente |
| `last_horizon/capture.pde:764,769,774,779-780,813` | Agendamento legado dos cenários do harness | `frameCount`, restrito ao harness; não controla simulação ou movimento |

### Evidência e status por critério de aceite

| Critério | Evidência no workspace | Status |
| --- | --- | --- |
| feat-018.C1 — Inventário das chamadas visuais e relógio atribuído | Inventário acima; HUD, nave, UI e telas consultam o relógio central; chamadas de porta e fonte do relógio lógico estão classificadas separadamente. | PASS |
| feat-018.C2 — Pulsos avançam durante pausa; simulação, movimento e áudio congelam | `checkPresentationClockAndTelemetry()` confirma avanço do pulso, zero passos planejados e tempo/versão simulados constantes. `draw()` só chama movimento dentro dos passos confirmáveis; eventos de áudio de movimento são emitidos nesses passos. `bash tools/run-headless.sh --capture` executado: `QUEST CHECK: PASS` e `PROCESSING REGRESSION: PASS`. | PASS |
| feat-018.C3 — Portas continuam no relógio de parede | `last_horizon/portals.pde:154,175,179` permanece usando `millis()` para as fases de porta. | PASS |
| feat-018.C4 — `frameCount` fora de simulação/movimento | As ocorrências restantes estão nos agendamentos legados de `last_horizon/capture.pde`. | PASS |
| feat-019.C1 — Desenho consome a versão confirmada | `FrameContext.beginPresentation()`, `recordPresentationSurface()` e `finishPresentation()` comparam a versão consumida à versão confirmada; `checkCurrentPresentationCallback()` verifica cada superfície em execução. `bash tools/run-headless.sh --capture`: `PRESENTATION CHECK: PASS`, 2.631 callbacks e zero falhas. | PASS |
| feat-019.C2 — Desenho sem passo adicional, interpolação, extrapolação ou mutação temporal do jogador | A apresentação ocorre depois dos passos em `drawBase()`; desenho da camada do jogador seleciona/renderiza a representação confirmada, sem invocar avanço de simulação; `FrameClock` bloqueia confirmação de passo durante a apresentação. Typecheck/build aprovados. | PASS |
| feat-019.C3 — Ordem, composição e telemetria de fases, superfícies e viewport | `drawBase()`/`drawWindow()` registram fases, superfícies, versão, viewport e letterbox; `checkCurrentPresentationCallback()` valida a sequência por callback. A captura dinâmica passou com 2.631 callbacks, zero falhas e viewport 1280x720, escala 1, offset 0,0. | PASS |
| feat-019.C4 — `harness_scene` não incrementa a versão simulada | `drawBase()` trava a apresentação antes do hook. `checkPresentationClockAndTelemetry()` tenta confirmar um passo enquanto a trava está ativa, confirma a rejeição e a versão inalterada. A captura executada passou; registrou 2.524 callbacks de `harness_scene`. | PASS |
| feat-019.C5 — Evidência cobre telas, nave, HUD e UI na mesma versão | A captura exige ao menos um callback real de sala e agrega superfícies observadas. Resultado: 87 callbacks de sala; `screens`, `screen_content`, `room`, `player`, `hud` e `ui` registrados em conjunto, sem divergência de versão ou falha. | PASS |
| feat-020.C1 — Preparação de botões uma vez por render pass | `resetButtons()`/`addButton()` contam chamadas no `FrameContext`; `checkCurrentPresentationCallback()` verifica uma limpeza por callback e os registros do pass. `bash tools/run-headless.sh --capture` passou com zero falhas de apresentação. | PASS |
| feat-020.C2 — Hit-test, hover, cursor, camadas, modais e limite de 24 controles | A captura passou nos contratos de prioridade modal, ESC, limite por camada e hit-test. `bash tools/run-headless.sh --hit-test` também passou, incluindo letterbox e controles da tela inicial. | PASS |
| feat-020.C3 — Conteúdo e layout do HUD preservados | Desenho continua apresentando dia, tripulação, seis recursos, objetivo, alertas, pulso e layout existentes; alterações limitadas a relógio e instrumentação. Build aprovado. | PASS |
| feat-020.C4 — Preparação, desenho e builds de cache observáveis | `FrameContext` registra passagens/duração, hit/miss/invalidação/fallback, memória adicional e builds de ícones, faixas de piso e camada do jogador. | PASS |
| feat-021.C1 — `roomDetail()` consulta `loadArt()` antes do fallback legado | `roomDetail()` chama `loadArt(data_path, "legacy_image")` e só então tenta o caminho compatível legado. | PASS |
| feat-021.C2 — Falhas não repetem tentativa de filesystem sem invalidação | `checkCacheContract()` confirma que `roomDetail()` memoriza miss sem novo acesso ao filesystem e só repete após invalidação explícita. `bash tools/run-headless.sh --capture` terminou com `QUEST CHECK: PASS`. | PASS |
| feat-021.C3 — Falha preserva última arte válida ou fallback geométrico sem mutar simulação | `checkCacheContract()` verifica retenção da última imagem válida e fallback de ícones/faixas; o harness cobre falhas de preparação. Captura e `bash tools/run-headless.sh --asset-pipeline-test` passaram. | PASS |
| feat-021.C4 — Métricas de assets/caches observáveis | Contadores cobrem hit, miss, invalidação, fallback, carregamento/tempo, memória, ícones, faixas, jogador e detalhe de sala, com deltas por callback no `FrameContext`. | PASS |
| feat-021.C5 — Fechamento registra todos os critérios e explicita inconclusivos | Esta tabela registra os 18 critérios de feat-018 a feat-021 com evidência e status. Todos passaram após execução; não há FAIL nem INCONCLUSIVO. | PASS |

### Validação técnica

- `npm run typecheck`: PASS.
- `npm run build`: PASS — Processing compilou o sketch; o runner reportou `PROCESSING REGRESSION: PASS`.
- `bash tools/run-headless.sh --capture`: PASS — `QUEST CHECK: PASS`; apresentação validada em 2.631 callbacks, 87 callbacks de sala, superfícies reais de telas/nave/player/HUD/UI, zero falhas e viewport registrado.
- `bash tools/run-headless.sh --hit-test`: PASS.
- `bash tools/run-headless.sh --ladder-test`: PASS.
- `bash tools/run-headless.sh --asset-pipeline-test`: PASS.
- Lint: N/A — não há script de lint no `package.json`.
- Fechamento feat-018 a feat-021: 18/18 critérios PASS; nenhum critério inconclusivo.

## Sprint 006 - Apresentação, HUD, UI e política de assets [CONCLUIDA]
- Relógio de apresentação: Direcionar os efeitos visuais de HUD, nave e UI para o tempo de apresentação fornecido pelo Frame Module.
- Apresentação do último estado confirmado: Fazer nave, jogador, HUD, UI e overlays desenharem uma vez a versão final produzida pelos passos do callback.
- Preparação de HUD e UI: Manter conteúdo e hit-test equivalentes, evitando preparação repetida por passo.
- Assets, fallbacks e caches compartilhados: Alinhar roomDetail() à política comum de assets e preservar caches e fallbacks mensuráveis.

## Sprint - Harness temporal determinístico [VALIDADA]

### Evidência e status por critério de aceite

| Critério | Evidência no workspace | Status |
| --- | --- | --- |
| feat-022.C1 — Cadências de 15, 30 e 60 FPS confirmam 60 passos em um segundo | `simulateDeckCadence()` e `simulateLadderCadence()` dirigem `FrameClock` com fonte fake e deltas de 1/15, 1/30 e 1/60 s; `sameCadenceBudget()` verifica os 60 passos, 1 s e acumulador abaixo do passo fixo. | PASS |
| feat-022.C2 — Caminhada, corrida, gravidade, salto e escadas terminam equivalentes | `checkFixedStepMovementCadence()` compara estado, posição e distância com tolerância de 0,01, contatos e aterrissagem para caminhada, corrida, queda, salto, subida e descida. | PASS |
| feat-022.C3 — Eventos mantêm sequência, timestamps e intervalos entre cadências | `sameCadenceEvents()` compara família, variante, ordem, instante lógico e intervalo entre eventos das fixtures. | PASS |
| feat-022.C4 — Takes são reproduzíveis sem relógio real | `checkAnimationContract()` e a fixture de cadência selecionam idle, walk, run, climb e jump por relógio fake/tempo lógico; repetição de entradas reproduz take, quadro e início lógico. | PASS |
| feat-023.C1 — Frame longo limita passos e separa tempo observado, aceito e descartado | `checkLongFrameAudioContract()` injeta 0,25 s, confirma quatro passos, valida os três tempos e exige acumulador menor que 1/60 s. | PASS |
| feat-023.C2 — Tempo descartado não vira dívida nem gera eventos retroativos | O callback seguinte executa somente um passo correspondente ao novo delta; seu tempo observado é 1/60 s, descarte é zero e nenhum evento antigo reaparece. | PASS |
| feat-023.C3 — Primeira leitura, delta negativo e leitura não finita preservam o estado com diagnóstico | `checkFrameClockContract()` exige zero passos, estado/versão preservados e diagnóstico para os três casos. | PASS |
| feat-023.C4 — Frame longo não provoca rajadas físicas | A fixture despacha eventos por adapter coalescido e verifica no máximo um disparo físico de cada família no callback, preservando o registro lógico. | PASS |
| feat-024.C1 — Ações de borda são consumidas no máximo uma vez | A fixture de salto envia uma borda em callback de quatro passos; a fixture de interação envia E em callback de dois passos. Ambas verificam consumo único no passo inicial. | PASS |
| feat-024.C2 — Modal, porta animada e troca de tela interrompem os passos restantes | `checkTemporalPauseAndBarriers()` confirma interrupção após modal e início da porta; uma porta sem animação troca para Dormitório no primeiro passo e não executa os três restantes. | PASS |
| feat-024.C3 — Pausa e telas externas congelam simulação sem recuperar atraso | As fixtures pausada/fora da sala verificam zero acúmulo e rebase explícito antes do passo seguinte, sem recuperação retroativa. | PASS |
| feat-024.C4 — Relógio visual avança durante a pausa com simulação e áudio congelados | O contrato compara tempo de apresentação crescente com tempo/versão simulados, posição e eventos lógicos constantes durante callbacks pausados. | PASS |
| feat-025.C1 — Falhas de áudio preservam evento lógico e estado físico | O teste com clip ausente e playback que lança exceção conserva distância/estado e o evento do recorder, registrando separadamente o resultado físico. | PASS |
| feat-025.C2 — Assets ausentes ou inválidos usam fallback e não repetem builds por quadro | `checkCacheContract()` verifica fallback, memoização da falha e contadores de hit, miss, invalidação e build para ícones e faixas. | PASS |
| feat-025.C3 — Camada do jogador é reutilizada para quadro e direção iguais | `checkPlayerAnimationLayerCache()` confirma que consultas equivalentes incrementam reuse sem reconstruir `player_frame_layer`; mudança de quadro/direção reconstrói uma vez. | PASS |
| feat-025.C4 — Portas preservam ordem e limitam atualização por callback | `checkDoorAnywhere()` cobre arte completa/incompleta, destino inválido e reentrada; a captura verifica abertura, troca, fechamento e rejeita uma segunda atualização no mesmo callback. | PASS |

### Validação técnica

- `npm run typecheck`: PASS.
- `npm run build`: PASS — Processing compilou o sketch e reportou `PROCESSING REGRESSION: PASS`.
- `bash tools/run-headless.sh --capture`: PASS — `QUEST CHECK: PASS`; `PRESENTATION CHECK: PASS`, 2.631 callbacks, 87 callbacks de sala e zero falhas.
- Lint: N/A — não há script configurado no `package.json`.
- `git diff --check`: PASS.
- Fechamento feat-022 a feat-025: 16/16 critérios PASS; nenhum critério INCONCLUSIVO.

## Sprint 007 - Harness temporal determinístico [CONCLUIDA]
- Fixtures equivalentes de 15, 30 e 60 FPS: Executar a mesma entrada por um segundo simulado nas três cadências e comparar os estados produzidos.
- Frames longos e amostras inválidas: Verificar descarte imediato, ausência de dívida e tratamento seguro de leituras inválidas.
- Pausa, input e barreiras de execução: Cobrir consumo único de bordas, congelamento fora de salas e interrupção dos passos restantes.
- Falhas, caches, áudio e portas: Cobrir adapters indisponíveis, invariantes de cache, camada do jogador e transições de porta.

## Sprint 008 - Profiling, toolchain e regressão integrada [IMPLEMENTADA — profiling INCONCLUSIVO]

### Evidência e status por critério de aceite

| Critério | Evidência no workspace | Status |
| --- | --- | --- |
| feat-026-c1 — identidade e sequência temporal por amostra | `capture.pde` serializa versão, perfil, cenário, `sample_id`, `cadence_fps`, deltas, passos, tempos aceito/remanescente/descartado, distância e eventos em `<sample_id>.temporal.json`. | INCONCLUSIVO — coleta não iniciada: pré-requisito ausente, dispositivo de áudio (`/proc/asound/cards`). |
| feat-026-c2 — seis métricas p95 por fase | O sidecar temporal prevê callback, simulação, render, `drawBase()`, `drawWindow()` e despacho de áudio com fronteiras distintas. | INCONCLUSIVO — coleta não iniciada: pré-requisito ausente, dispositivo de áudio (`/proc/asound/cards`). |
| feat-026-c3 — mesma janela e amostras do CSV canônico | `compare-profiling.mjs` compara duração e callbacks do sidecar temporal com o CSV de cada amostra. | INCONCLUSIVO — coleta não iniciada: pré-requisito ausente, dispositivo de áudio (`/proc/asound/cards`). |
| feat-026-c4 — estados de relógio, áudio, assets e cache | O sidecar exige estados `clock`, `audio`, `asset` e `cache`; métrica ou estado ausente resulta em `INCONCLUSIVO`. | INCONCLUSIVO — coleta não iniciada: pré-requisito ausente, dispositivo de áudio (`/proc/asound/cards`). |
| feat-026-c5 — campos mínimos do `FrameContext` por callback | `readTemporalSidecar()` exige tela/cômodo, camada, pausa, relógio, harness, callback, passos, bordas, porta, versão confirmada e eventos. | INCONCLUSIVO — coleta não iniciada: pré-requisito ausente, dispositivo de áudio (`/proc/asound/cards`). |
| feat-026-c6 — p95 separado nas cadências 15/30/60 FPS | `validateVersion()` exige as três cadências; a comparação produz seis métricas para cada perfil e cadência, calculadas sobre os callbacks daquela cadência. | INCONCLUSIVO — coleta não iniciada: pré-requisito ausente, dispositivo de áudio (`/proc/asound/cards`). |
| feat-027-c1 — CSV canônico inalterado | `PERFORMANCE_METRICS_HEADER` continua com as onze colunas canônicas; métricas temporais são publicadas no sidecar. | INCONCLUSIVO — a coleta sem áudio não produziu amostras atuais para verificar o CSV. |
| feat-027-c2 — comparação rejeita evidência ausente ou incompatível | `compare-profiling.mjs` valida amostras, manifestos, sidecars, vínculos CSV/sidecar e identidade baseline/revisada antes de comparar. | INCONCLUSIVO — comparação não iniciada porque a coleta declara ausente o dispositivo de áudio (`/proc/asound/cards`). |
| feat-027-c3 — gates canônicos preservados | `compare-profiling.mjs` mantém p95 máximo de 33,3 ms, regressão máxima de 10% e ruído de 1% em `allocations_per_frame`. | INCONCLUSIVO — o gate de comparação não iniciou por falta do dispositivo de áudio (`/proc/asound/cards`). |
| feat-027-c4 — métricas novas não criam requisito de ganho | Os p95 temporais são reportados separadamente; os gates de regressão usam somente `COST_FIELDS` canônicos, sem exigir ganho adicional. | INCONCLUSIVO — a comparação que confirma os gates não iniciou por falta do dispositivo de áudio (`/proc/asound/cards`). |
| feat-028-c1 — cenário temporal headless e pré-requisitos | `run-headless.sh` e `processing-cli.sh` encaminham `--temporal-test` sem interação e nomeiam os pré-requisitos obrigatórios antes de iniciar o cenário. | PASS — `last_horizon/output/integrated/temporal-test.log`. |
| feat-028-c2 — matriz de módulos opcionais | `optional-modules.mjs` verifica as combinações `base`, `capture`, `manual` e `complete`. | PASS — `last_horizon/output/integrated/optional-module-matrix.log`. |
| feat-028-c3 — runtime base sem dependências permanentes do harness | A matriz confirma a separação de relógio fake, recorder e cena de captura; hooks sem cenário ativo permanecem inertes. | PASS — matriz opcional e verificações da fronteira em `optional-modules.mjs`. |
| feat-028-c4 — harness inerte sem cenário ativo | Captura, cenário temporal e matriz verificam que a presença do harness não muda a ordem, os passos, o áudio ou a apresentação do caminho de produção. | PASS — logs de `capture`, `temporal-test` e `optional-module-matrix`. |
| feat-029-c1 — comandos da regressão integrada executados por pré-requisito | `COMMANDS` registra typecheck, build, capture, temporal-test, hit-test, ladder-test, pipeline de assets, matriz opcional, simulação, profiling, comparação e snapshot. | PASS — resultados anteriores registram execução; Windows e profiling ficam individualmente INCONCLUSIVOS pelos pré-requisitos nomeados. |
| feat-029-c2 — classificação de cada comando | `runCommand()` vincula status a processo, código de saída e diagnóstico; o contrato rejeita PASS sem código zero e INCONCLUSIVO sem pré-requisito nomeado. | PASS — resultado `command-status-contract` no relatório integrado corrigido. |
| feat-029-c3 — equivalência e fronteira funcional preservadas | `equivalence-report` compara 22 quests × 34 estados; `domain-boundary` verifica os cinco arquivos protegidos. | PASS — relatório de equivalência (748 entradas) e resultado `domain-boundary`. |
| feat-029-c4 — busca final de callers temporais | `validateTemporalCallers()` verifica assinaturas de `updateRoom`, updates de convés/escada, `playerCurrentFrame()`, `stopStepSounds()` e ausência dos callers removidos de áudio em todos os `.pde`. | PASS — resultado `temporal-callers` e arquivos Processing listados como evidência. |
| feat-029-c5 — decisões D1–D5 e opções rejeitadas | A matriz relaciona cada decisão às features e evidências; delta variável, dívida temporal, passo comprimido, interpolação, extrapolação e refatoração funcional ampla seguem fora dos requisitos ativos. | PASS — `decisionCoverage` e `rejectedOptions` do relatório integrado. |
| feat-029-c6 — fechamento integral sem encerramento parcial | A matriz contém os 20 critérios das quatro features, evidencia cada status e só permite `canClose` quando todos os critérios daquela feature são PASS; FAIL bloqueia e INCONCLUSIVO exige pré-requisito nomeado. | PASS — `feature-coverage-definition`, `feature-closure` e `featureCoverage` no relatório integrado corrigido. |

### Matriz de decisões

| Decisão | Features | Evidência prevista |
| --- | --- | --- |
| D1 | feat-026 | Sidecar temporal por amostra e p95 por fase. |
| D2 | feat-026, feat-027 | Sequências de delta, descarte e remanescente validadas pelo comparador. |
| D3 | feat-026, feat-027 | Cadências 15/30/60, quantidade de passos e cobertura de amostras. |
| D4 | feat-026, feat-029 | Versão confirmada por callback e harness temporal/capture. |
| D5 | feat-028, feat-029 | Matriz opcional, toolchain headless e relatório de regressão integrada. |

Delta variável, dívida temporal, passo comprimido, interpolação, extrapolação e refatoração funcional ampla não foram introduzidos como requisitos ativos.

### Validação desta sessão

- `git diff --check`: PASS.
- `npm run typecheck`, `npm run build`, capture, temporal-test, hit-test, ladder-test, asset-pipeline-test, matriz opcional e `balance-model --simulate`: PASS no relatório integrado anterior.
- Regressão Windows: INCONCLUSIVO — pré-requisito ausente: plataforma Windows.
- Coleta e comparação de profiling: INCONCLUSIVO — pré-requisito ausente: dispositivo de áudio em `/proc/asound/cards`; métricas temporais ausentes não contam como PASS.
- Equivalência 22 × 34 e snapshot final: PASS no relatório integrado anterior.
- `verification:final` após corrigir o contrato da matriz: ainda não reexecutado. A restrição desta sessão permite somente comandos iniciados por `git`; `git diff --check` foi executado novamente e passou.
- O relatório integrado anterior associava limpeza de comentários às features temporais e falhava por esse critério fora de escopo. Esse gate foi removido da sprint; o status geral continua INCONCLUSIVO pelos pré-requisitos de Windows e áudio.

## Sprint 008 - Profiling, toolchain e regressão integrada [CONCLUIDA]
- Sidecar temporal e métricas por fase: Produzir artefatos versionados com os dados temporais, eventos e custos p95 exigidos.
- Compatibilidade do profiling canônico: Preservar o CSV atual e ampliar a validação sem relaxar seus gates.
- CLI e módulos opcionais: Expor o cenário temporal no toolchain quando necessário e preservar todas as combinações opcionais.
- Verificação final e relatório de execução: Executar a matriz de regressão e registrar resultados rastreáveis sem alterar regras de campanha.
