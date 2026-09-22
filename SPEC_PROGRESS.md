# SPEC_PROGRESS - preparacao-integrada-para-entrega

## Status: 8/9 sprints implementadas; sprint 009 com validação pendente
Ultima atualizacao: 2026-09-22T06:30:00.000Z

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
