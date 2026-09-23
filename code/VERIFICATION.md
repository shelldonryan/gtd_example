# Registro de verificação — Fundação de rastreabilidade e baseline

## Sidecar temporal do profiling

Cada CSV canônico mantém o cabeçalho e a janela já aprovados. Para cada amostra,
`capture.pde` também grava `<sample_id>.temporal.json`, e o artefato de profiling
vincula esse arquivo pelo campo `temporal_json`.

O sidecar identifica versão, perfil, cenário, amostra e cadência lógica de 15,
30 ou 60 FPS. Registra deltas observados, passos planejados e executados, tempo
aceito, acumulador remanescente, tempo descartado, distância, eventos lógicos e
os campos de diagnóstico de cada `FrameContext`. O relógio sintético avança em
cadências lógicas sobre o callback de apresentação; assim as três cadências usam
a mesma janela real de captura e não alteram a apresentação de 60 FPS usada pelo
CSV canônico.

`System.nanoTime()` mede callback, simulação, renderização, `drawBase()`,
`drawWindow()` e despacho de áudio. Essas fronteiras são independentes; o tempo
de renderização cobre o trecho entre `drawBase()` e o fim de `drawWindow()`. O
sidecar calcula p95 sobre os callbacks capturados na mesma janela do CSV e
registra status de relógio, áudio, assets e caches. Campo, sequência ou status
ausente resulta em `INCONCLUSIVO` no comparador. Os p95 temporais são evidência
adicional; os limites canônicos de 33,3 ms, regressão de 10% e ruído de alocação
de 1% permanecem aplicados sem exigir ganho nas métricas novas.

`bash tools/run-headless.sh --temporal-test` executa as fixtures temporais sem
interação. O runner exige Processing, `xvfb-run` no modo headless e o módulo de
captura antes de iniciar. O comparador valida os sidecars temporais dos dois
perfis e das três cadências e os inclui no relatório sem mudar o CSV.

## Executar o sketch Processing

O sketch de produção está em `last_horizon/` e sua entrada é
`last_horizon/last_horizon.pde`. Abra esse arquivo no Processing 4.5.6 para
executar pelo editor. As outras abas `.pde` da pasta pertencem ao mesmo sketch.

- `bash tools/run-processing.sh`: executa o jogo pelo Processing CLI.
- `npm run build`: compila o sketch sem iniciar a janela do jogo.

O launcher usa `tools/processing-cli.sh`. Ele aceita o caminho do executável
pela variável `PROCESSING_BIN`; sem ela, procura `/opt/processing/bin/Processing`
e depois `Processing` ou `processing` no `PATH`. Exemplo quando o executável
está instalado em outro local: `PROCESSING_BIN="/caminho/para/Processing"
bash tools/run-processing.sh`.

## Sprint 009 — validação integrada e registro de conclusão

### Estado desta entrega

| Decisão | Status | Evidência e impacto |
| --- | --- | --- |
| Validação integrada da entrega completa | FAIL | O último `integrated-verification-report.json` é anterior a esta correção e registrou falha no snapshot final. A verificação integrada ainda não foi reexecutada. |
| Gate de performance e profiling | PASS local | Em 23/09/2026, a coleta Windows produziu 12 amostras válidas de `HEAD` contra o working tree; o comparador aprovou p95 máximo revisado de 19,065 ms. Os dois rótulos de perfil foram executados na mesma máquina. |
| Snapshot final pós-limpeza | FAIL | O último manifesto registrou `output/snapshot-entrega/package.json` ausente e falha de compilação porque `last_horizon/frame.pde` não entrou na cópia. O seletor do snapshot foi corrigido depois dessa execução e aguarda validação. |
| Decisão geral | FAIL | A regressão de captura, a compilação de produção e o profiling local passaram; o relatório integrado e o snapshot final ainda aguardam nova validação. |

### Runner canônico

`npm run verification:final` executa typecheck, compilação, os quatro cenários
Processing individualmente, a matriz `base`/`capture`/`manual`/`complete`, a
simulação com timeout de 120 segundos, a coleta de profiling antes/depois, o
runner Windows, a comparação, a limpeza seletiva e o snapshot final. A coleta
usa `tools/profile-runner.mjs` com timeout de 1.500 segundos, três amostras de
30 segundos por perfil e grava o manifesto exato em
`last_horizon/output/profiling-run-manifest.json`. Cada comando preserva stdout,
stderr, código de saída, timeout e diagnóstico em
`last_horizon/output/integrated/<comando>.log`. O relatório consolidado fica em
`last_horizon/output/integrated-verification-report.json`.

O resultado de um comando iniciado que termina com erro é `FAIL`; um
pré-requisito ausente antes do início é `INCONCLUSIVO`. O relatório final usa a
mesma precedência para impedir que uma execução parcial seja apresentada como
aprovação.

Cada comando registra se foi iniciado, seu código de saída e um diagnóstico.
Código 2 só recebe `INCONCLUSIVO` quando o log ou o manifesto identifica o
pré-requisito ausente; código 2 sem motivo nomeado é `FAIL`. O relatório também
lista os 16 critérios de aceite de `feat-026` a `feat-029`, cada um com status,
checks e evidências. A feature só pode ser encerrada quando todos os seus
critérios forem `PASS`; `FAIL` bloqueia a entrega e `INCONCLUSIVO` permanece
fora da contagem de aprovação.

### Equivalência funcional

`last_horizon/output/equivalence-report.json` deve existir depois de
`--capture`, usar o schema `night-equivalence-v1`, conter exatamente 22 quests,
34 estados e 748 entradas únicas, e registrar em cada entrada o identificador,
dia, quest, etapa, snapshots de referência e revisado, campos comparados,
diferenças, validade da aplicação e status. O runner verifica a estrutura e
trata qualquer diferença declarada, campo ausente ou relatório inválido como
`FAIL`; a ausência do relatório antes da captura é `INCONCLUSIVO`.

### Gate de performance

`tools/profile-runner.mjs` executa a matriz e `tools/compare-profiling.mjs` exige
os caminhos
`last_horizon/output/<versao>/<perfil>/<sample_id>.csv`,
`last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json` e
`last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json` para
as três amostras de `baseline` e `revised`, nos perfis
`core-i3-integrated` e `reference`. Ele valida os cinco hotspots obrigatórios,
reconcilia seus valores com o CSV, verifica janelas de 30 segundos, calcula
medianas e rejeita regressão acima de 10%, p95 revisado acima de 33,3 ms ou
crescimento persistente acima de 1% de `allocations_per_frame` nos dois perfis. Os hotspots
são rendering, image scaling, alocações por quadro, preview de transições e
carregamento/cache de assets.

`PASS` exige evidência válida em todos os perfis, cenários, amostras e hotspots,
p95 revisado de no máximo 33,3 ms, nenhuma regressão de custo acima de 10% e
nenhum crescimento persistente de `allocations_per_frame` acima da tolerância
de ruído de 1%. Uma redução reproduzível pode ser registrada como dado
descritivo, mas não é um gate adicional. Manifesto incompatível, amostra,
cadência, sidecar ou métrica obrigatória ausente mantém o resultado
`INCONCLUSIVO`; dados completos que excedem qualquer limite produzem `FAIL`.

No Windows, o runner usa `Processing.exe cli`, verifica os clips pelo sketch e
mantém os temporários em `last_horizon/output` até o fim da coleta. A baseline
padrão é o `HEAD` confirmado, comparado ao working tree. `--baseline-ref=<ref>`
permite escolher outra revisão; uma revisão sem sidecar temporal recebe
`INCONCLUSIVO` antes da coleta. Os rótulos `core-i3-integrated` e `reference`
não representam dois hardwares quando ambos são coletados na mesma máquina.

### Tabela final de métricas de custo

Os valores da tabela abaixo pertencem a uma execução anterior. A coleta local de
23/09/2026 está em [profiling-comparison.json](../last_horizon/output/profiling-comparison.json):
12 amostras válidas, p95 máximo revisado de 19,065 ms, variação de p95 de
-2,81% em `core-i3-integrated` e -0,41% em `reference`. Essa comparação mede
`HEAD` contra a correção atual, não o refactor do último commit contra seu pai.

| Perfil | Hotspot / métrica | Baseline | Revisada | Variação | Status |
| --- | --- | ---: | ---: | ---: | --- |
| core-i3-integrated | rendering / frame_time_median_ms | 17.029 | 16.937 | -0,54% | PASS |
| core-i3-integrated | rendering / frame_time_p95_ms | 18.478 | 18.557 | 0,42% | PASS |
| core-i3-integrated | asset_loading_and_cache / load_time_ms | 1080.000 | 1045.000 | -3,24% | PASS |
| core-i3-integrated | asset_loading_and_cache / additional_memory_bytes | 123731968 | 108352 | -99,91% | PASS |
| core-i3-integrated | image_scaling / icon_builds | 0 | 0 | 0,00% | PASS |
| core-i3-integrated | image_scaling / floor_band_builds | 0 | 0 | 0,00% | PASS |
| core-i3-integrated | transition_preview / cache_invalidations | 0 | 0 | 0,00% | PASS |
| core-i3-integrated | per_frame_allocations / allocations_per_frame | 146156.770 | 146166.160 | 0,01% | PASS |
| reference | rendering / frame_time_median_ms | 16.881 | 16.880 | -0,01% | PASS |
| reference | rendering / frame_time_p95_ms | 18.738 | 18.455 | -1,51% | PASS |
| reference | asset_loading_and_cache / load_time_ms | 1083.000 | 1021.000 | -5,72% | PASS |
| reference | asset_loading_and_cache / additional_memory_bytes | 111218936 | 108352 | -99,90% | PASS |
| reference | image_scaling / icon_builds | 0 | 0 | 0,00% | PASS |
| reference | image_scaling / floor_band_builds | 0 | 0 | 0,00% | PASS |
| reference | transition_preview / cache_invalidations | 0 | 0 | 0,00% | PASS |
| reference | per_frame_allocations / allocations_per_frame | 146007.360 | 146166.310 | 0,11% | PASS |

Os números da tabela histórica não devem ser usados para avaliar a correção
atual; as amostras e variações atuais estão no JSON vinculado acima.

O manifesto atual identifica a baseline por `fea5e946af69ccb87edfcdc2b91f7231019a7f62`
e a versão revisada por `working-tree:<digest>`. Os valores completos dos dois
manifestos, incluindo cada arquivo e SHA-256, ficam em
`last_horizon/output/profiling-run-manifest.json`. O relatório integrado aponta
para `profiling-collection-report.json`, `profiling-comparison.json`, os logs,
os CSVs, os sidecars, o relatório de equivalência e o manifesto do snapshot.

Cada captura de métricas também preserva o log individual em
`last_horizon/output/<versao>/<perfil>/<cenario>/<amostra>.log`; uma falha ou
timeout mantém o log com o código de saída e não cria um CSV aprovado.

### Limpeza e snapshot final

`tools/cleanup-verification-artifacts.mjs` remove somente imagens de captura,
diretórios temporários de regressão Windows e o nome legado de métricas. Ele
preserva `equivalence-report.json`, `fallback-diagnostics.jsonl`, CSVs,
sidecars, profiling, logs e o relatório integrado.

Depois da limpeza, `tools/snapshot-entrega.mjs` gera
`output/snapshot-entrega/` e `output/snapshot-entrega-manifest.json` com
`final: true`, a lista exata de exclusões, o runtime compilável, a matriz de
módulos opcionais, a ausência de controles de desenvolvimento e o resultado
da execução. O script não altera refs Git. O manifesto intermediário da sprint
007 não é usado como evidência final.

## Sprint 008 — remoção auditada de código e comentários

### Símbolos removidos

As buscas foram feitas no worktree com `git grep -n -F`, cobrindo todas as
abas Processing, os módulos JavaScript e os scripts shell rastreados. A
ausência de uma referência textual foi combinada com a inspeção dos
entrypoints `settings()`, `setup()`, `draw()`, entrada de mouse e teclado,
hooks opcionais do harness, modo manual, compilação implícita das abas e
scripts do `package.json`. As funções abaixo tinham somente a própria
declaração ou eram um grupo de mapeamento sem consumidores.

| Arquivo | Símbolo | Busca de referências antes/depois | Entradas examinadas | Justificativa, validação posterior e resultado |
| --- | --- | --- | --- | --- |
| `last_horizon/game.pde` | `processProblemDeadlines()` | `git grep -n -F 'processProblemDeadlines' -- '*.pde' '*.mjs' '*.sh'`: 1 declaração antes; nenhuma ocorrência depois | `draw()`, `updateRoom()`, `endDay()`, `capture.pde`, modo manual, `night_projection.pde` | Duplicava a ordem de crises que agora pertence à projeção pura e não era chamado por nenhum entrypoint ou hook. `git diff --check`: saída 0; busca posterior sem ocorrências. Remoção PASS. |
| `last_horizon/hud.pde` | bloco de inicialização tardia de `HUD_RESOURCE_ORDER` (consolidado na declaração); `HUD_ICON_BY_RESOURCE` é a nova tabela de mapeamento | `HUD_RESOURCE_ORDER`: declaração e inicialização antes; declaração única depois. `HUD_ICON_BY_RESOURCE`: nenhuma ocorrência antes; referências em `hudResourceIcon()` e `validHudResource()` depois | `drawHeader()`, `drawResourceCard()`, `hudResourceIcon()`, fallback de ícones, `capture.pde` e package scripts | A inicialização lazy foi consolidada na declaração de `HUD_RESOURCE_ORDER`; o mapeamento novo é alcançado pelo HUD e não foi removido. `git diff --check`: saída 0; busca posterior confirmou a declaração consolidada e os consumidores do novo mapeamento. Consolidação PASS. |
| `last_horizon/ui.pde` | `textShadow()` | `git grep -n -F 'textShadow(' -- '*.pde'`: 1 declaração antes; nenhuma depois | renderizadores de tela, HUD, nave, diálogo, modais e harness | Nenhum consumidor usava o wrapper; `drawShadowText()` e `drawCenteredShadowText()` continuam sendo os helpers alcançados. `git diff --check`: saída 0; busca posterior sem ocorrências. Remoção PASS. |
| `last_horizon/assets.pde` | `crewArtFrames(String)` | `git grep -n -F 'crewArtFrames(String' -- '*.pde'`: 1 declaração antes; nenhuma depois | `loadArtAssets()`, `drawNpc()`, resolução por índice, harness e modo manual | O overload por nome não tinha consumidores. Os overloads documentados de `resolveNpcArt()` e `drawNpc()` foram preservados. `git diff --check`: saída 0; busca posterior sem ocorrências. Remoção PASS. |

Nenhuma fixture, estado de captura, comando, evidência ou entrada documentada
do harness foi removida. `capture.pde` permanece opcional e `test_mode.pde`
continua sendo examinado como entrada indireta quando a matriz de compilação
inclui o módulo manual.

### Auditoria lexical

As cópias versionadas em `output/snapshot-entrega/` herdam a auditoria do
caminho-fonte correspondente; a verificação final mapeia esses caminhos para a
mesma entrada lexical, sem omitir o runtime compilado.

A contagem abaixo considera um comentário de linha por `//` ou `#` fora de
strings e um comentário de bloco por abertura `/*`; shebangs e marcadores
dentro de strings foram excluídos. A contagem inicial foi recalculada no
conteúdo da baseline com a mesma varredura lexical usada no estado revisado.
Para cada caminho, a busca candidata foi
`git grep -n -E '/\\*|\\*/|(^|[^[:alnum:]_])//' -- <caminho>`; a inspeção
lexical removeu os falsos positivos de strings e shebangs. Código de saída 1
significa que não restou comentário lexical. Nos scripts shell, a checagem
adicional `git grep -n '^#!' -- <caminho>` terminou com saída 0 e confirmou a
preservação do shebang.

| Caminho | Extensão | Antes | Depois | Comando e saída |
| --- | --- | ---: | ---: | --- |
| `last_horizon/animation.pde` | `.pde` | 3 | 0 | busca lexical; 1 |
| `last_horizon/assets.pde` | `.pde` | 15 | 0 | busca lexical; 1 |
| `last_horizon/audio.pde` | `.pde` | 4 (3 blocos + 1 `//`) | 0 | busca lexical; 1 |
| `last_horizon/capture.pde` | `.pde` | 7 | 0 | busca lexical; 1 |
| `last_horizon/editorial.pde` | `.pde` | 3 | 0 | busca lexical; 1 |
| `last_horizon/game.pde` | `.pde` | 4 | 0 | busca lexical; 1 |
| `last_horizon/hud.pde` | `.pde` | 7 (1 bloco + 6 `//`) | 0 | busca lexical; 1 |
| `last_horizon/last_horizon.pde` | `.pde` | 15 | 0 | busca lexical; 1 |
| `last_horizon/movement.pde` | `.pde` | 5 | 0 | busca lexical; 1 |
| `last_horizon/night_projection.pde` | `.pde` | 3 | 0 | busca lexical; 1 |
| `last_horizon/portals.pde` | `.pde` | 1 | 0 | busca lexical; 1 |
| `last_horizon/screens.pde` | `.pde` | 24 (1 bloco + 23 `//`) | 0 lexical; string preservada | busca lexical com inspeção da string editorial; 1 após filtrar a string |
| `last_horizon/ship.pde` | `.pde` | 34 (22 blocos + 12 `//`) | 0 | busca lexical; 1 |
| `last_horizon/tasks.pde` | `.pde` | 4 | 0 | busca lexical; 1 |
| `last_horizon/test_mode.pde` | `.pde` | 4 (1 bloco + 3 `//`) | 0 | busca lexical; 1 |
| `last_horizon/ui.pde` | `.pde` | 6 (2 blocos + 4 `//`) | 0 | busca lexical; 1 |
| `prototype/balance-model.mjs` | `.mjs` | 4 | 0 | busca lexical; 1 |
| `tools/cleanup-verification-artifacts.mjs` | `.mjs` | 1 | 0 | busca lexical; 1 |
| `tools/compare-metrics.mjs` | `.mjs` | 5 (5 blocos JSDoc) | 0 | busca lexical; 1 |
| `tools/e6-audit.mjs` | `.mjs` | 5 | 0 | busca lexical; 1 |
| `tools/e6-evidence.mjs` | `.mjs` | 7 | 0 | busca lexical; 1 |
| `tools/regression-windows.mjs` | `.mjs` | 1 `//` | 0 | busca lexical; 1 |
| `tools/snapshot-entrega.mjs` | `.mjs` | 2 (2 blocos) | 0 | busca lexical; 1 |
| `tools/compare-profiling.mjs` | `.mjs` | 0 | 0 | nenhuma exceção; busca lexical; 1 |
| `tools/optional-modules.mjs` | `.mjs` | 2 blocos `/* ... */` | 0 | shebang `#!/usr/bin/env node` preservado; busca lexical; 1 |
| `tools/profile-runner.mjs` | `.mjs` | 0 | 0 | busca lexical e `node --check`; 1 |
| `tools/typecheck.mjs` | `.mjs` | 0 | 0 | shebang `#!/usr/bin/env node` preservado; busca lexical; 1 |
| `tools/verify-delivery.mjs` | `.mjs` | 0 | 0 | busca lexical e `node --check`; 1 |
| `tools/build.sh` | `.sh` | 0 | 0 | shebang preservado; busca de comentários; 1 |
| `tools/processing-cli.sh` | `.sh` | 1 `#` | 0 | shebang preservado; busca de comentários; 1 |
| `tools/regression-final.sh` | `.sh` | 0 | 0 | shebang preservado; busca de comentários; 1 |
| `tools/run-headless.sh` | `.sh` | 0 | 0 | shebang preservado; busca de comentários; 1 |
| `tools/run-processing.sh` | `.sh` | 0 | 0 | shebang preservado; busca de comentários; 1 |

Exceções preservadas: os cinco shebangs `#!/usr/bin/env bash`, os cinco
shebangs `#!/usr/bin/env node` e a sequência `//` dentro da string
`REGISTRO DE PARTIDA // TRANSMISSÃO TERRESTRE`. Não houve edição lexical em
`docs/`, `code/`, `mechanics/`, `events/` ou `interface/` por esta sprint;
esta seção foi adicionada ao registro de verificação, conforme exigido.

### Validação da sprint

As validações posteriores desta sprint foram executadas depois das remoções e
da consolidação do HUD:

| Comando | Resultado | Código de saída e evidência |
| --- | --- | --- |
| `git diff --check` | PASS | 0; nenhum erro de whitespace. |
| `npm run typecheck` | PASS | 0; `node --check` passou nos oito módulos `.mjs` cobertos pelo runner. |
| `for file in $(find last_horizon prototype tools -type f -name '*.mjs' -print | sort); do node --check "$file"; done` | PASS | 0; os dez módulos `.mjs` presentes no worktree foram aceitos pelo parser. |
| `for file in tools/*.sh; do bash -n "$file"; done` | PASS | 0; todos os scripts shell mantiveram sintaxe e shebang. |
| auditoria lexical dos 33 caminhos-fonte `.pde`, `.mjs` e `.sh` | PASS | 0; nenhum comentário lexical restante, 5 shebangs Bash e 5 shebangs Node preservados. |
| `npm run build` | PASS | 0; `PROCESSING REGRESSION: PASS`. |
| `npm run modules:matrix` | PASS | 0; combinações `base`, `capture`, `manual` e `complete` compiladas. |
| `bash tools/regression-final.sh` | PASS | 0; captura, hit-test, escadas, pipeline de imagem e limpeza terminaram em PASS. O áudio registrou INCONCLUSIVE apenas pela indisponibilidade do backend `Clip`. |
| `node prototype/balance-model.mjs --simulate` | PASS | 0; `BALANCE CHECK: PASS`, 2.520/2.520 sequências. |
| `node tools/snapshot-entrega.mjs` | PASS | 0; manifesto intermediário com `final: false`, nenhum arquivo rastreado ausente, cópia compilada e matriz opcional aprovadas. |

## Sprint 007 — harness, módulos opcionais e snapshot intermediário

### Contratos

`last_horizon/last_horizon.pde` contém somente hooks opcionais inertes. A
compilação não depende de `capture.pde` nem de `test_mode.pde`. O runner aceita
`--module-set=base`, `--module-set=capture`, `--module-set=manual` e
`--module-set=complete`; antes de chamar o Processing ele remove da cópia
temporária os arquivos que não pertencem à combinação.

| Combinação | Arquivos opcionais | Superfície esperada |
| --- | --- | --- |
| `base` | nenhum | jogo normal, sem harness e sem controles manuais |
| `capture` | `capture.pde` | `--capture`, `--hit-test`, `--ladder-test`, `--asset-pipeline-test` e `--metrics` |
| `manual` | `test_mode.pde` | Ctrl+K, teleporte e destaque visual |
| `complete` | `capture.pde`, `test_mode.pde` | harness e modo manual simultaneamente |

`tools/optional-modules.mjs` normaliza saída 0 como PASS, código 1 ou outro
erro de execução como FAIL e código 2 como INCONCLUSIVO por pré-requisito
ausente. `npm run modules:matrix` é o comando canônico da matriz.

O destaque manual é visual. `pointIsAvailable()` não consulta o override de
visualização; pagamento, aceite, coleta, entrega e conclusão continuam sujeitos
às regras de `tasks.pde`.

### Snapshot de entrega

`node tools/snapshot-entrega.mjs` gera:

- `output/snapshot-entrega/`, cópia intermediária somente com arquivos
  rastreados e com `capture.pde`, `test_mode.pde`, `tools/`, `prototype/`,
  `code/VERIFICATION.md` e artefatos transitórios excluídos;
- `output/snapshot-entrega-manifest.json`, com `excluded`, `runtimeFiles`, a
  matriz de compilação, as verificações do runtime e `final: false`.

O script não usa `commit`, `commit-tree`, `update-ref`, `reset`, `merge` ou
qualquer outra operação que altere refs Git. A compilação da cópia usa apenas o
runtime base e registra INCONCLUSIVO quando Processing ou outro pré-requisito
não estiver disponível. A lista fica centralizada em
`tools/snapshot-entrega.mjs`, e o campo `regenerateAfter` exige nova execução
depois da sprint-008; este manifesto não é evidência final.

## Identificação

Este registro é a referência normativa da baseline funcional anterior às
sprints de performance, organização e limpeza.

| Campo | Valor |
| --- | --- |
| Entrega | Fundação de rastreabilidade e baseline |
| Data do registro | 21/09/2026 |
| Referência baseline | commit `31bb14fd1512669769b2e6be0651b1deb3ace9c3` (`feat(ui): aprimorar menu inicial e HUD com telemetria procedural e feedback visual`) |
| Manifesto de código usado | `git ls-files` da referência baseline |
| Manifesto de comandos usado | `package.json` na referência baseline, revisado nesta sprint para retirar os scripts históricos do `typecheck` |
| Contratos consultados | `docs/CURRENT_IMPLEMENTATION.md`, `code/SKETCH_ARCHITECTURE.md`, `mechanics/ACTIONS.md`, `interface/FLOW.md` e ADRs em `docs/adr/` |
| Ambiente da tentativa | Linux, Node.js, Processing 4.5.6 em modo headless com `xvfb-run` |

O inventário abaixo é autoritativo para a superfície da entrega.

## Verificação da sprint 005 — 22/09/2026

A execução atual cobre a projeção noturna, a aplicação da instância exibida, a
matriz de equivalência e os cenários funcionais. Os resultados históricos da
baseline permanecem registrados na seção de comandos e limitações abaixo.

| Comando | Resultado atual | Evidência |
| --- | --- | --- |
| `bash tools/run-headless.sh --capture` | PASS | `QUEST CHECK: PASS`; relatório canônico com 22 quests × 34 estados, 748/748 entradas PASS. |
| `node prototype/balance-model.mjs --simulate` | PASS | `BALANCE CHECK: PASS`; a reserva de peças venceu 2.520/2.520 sequências. |
| `npm run typecheck` | PASS | `TYPECHECK: PASS`; todos os módulos JavaScript listados foram aceitos pelo parser. |
| `npm run build` | PASS | `PROCESSING REGRESSION: PASS`; o sketch compilou pelo Processing CLI. |
| `bash tools/regression-final.sh` | PASS | Captura, hit-test, escadas e pipeline de imagem terminaram com `PROCESSING REGRESSION: PASS`; a limpeza terminou com `CLEANUP CHECK: PASS`. |
| lint | INCONCLUSIVO | Não há script `lint` configurado no `package.json`; não foi introduzida dependência para criar um novo gate. |

O backend de áudio do ambiente permaneceu INCONCLUSIVO; o harness registra essa
condição sem transformar a indisponibilidade de `Clip` em falha das mecânicas.
O relatório canônico atual foi gerado em
`last_horizon/output/equivalence-report.json` e permanece como artefato de
execução ignorado pelo Git.

## Sprint — Camada modal e interação unificadas

`uiLayer()` mantém a prioridade normativa em dez posições: pausa, transmissão,
incidente, ordens, mapa, diálogo, painel técnico, sono, ajuda e cena. O render
de modais, o bloqueio de movimento, os roteadores de ENTER/ESC, o cursor e o
hit-test consultam o mesmo resultado; uma ação direta também é rejeitada quando
pertence a outra camada.

O registro de controles comporta até 24 botões por camada. A geometria é
compartilhada por desenho, hover e hit-test, e cada excesso é descartado e
registrado com camada, limite e contagem descartada. O fechamento preserva o
estado de ordem aceito, limpa paginação e detalhes de Ordens, mantém o incidente
ao fechar transmissão e conserva a `NightProjection` ao fechar o painel de
sono; a confirmação aplica a mesma projeção uma única vez.

O harness ganhou `checkModalLayerContract()`, cobrindo flags sobrepostos,
transmissão sobre incidente, ESC no detalhe e na comparação, ações encobertas,
limpeza seletiva de Ordens, preservação da prévia de sono, limite por camada e
bordas do hit-test. A execução desta sprint permanece INCONCLUSIVA nesta sessão
porque a restrição operacional permite somente comandos iniciados por `git`;
`git diff --check` passou.

### Abas do sketch

As 16 abas existentes em `last_horizon/` são:

`animation.pde`, `assets.pde`, `audio.pde`, `capture.pde`,
`editorial.pde`, `game.pde`, `hud.pde`, `last_horizon.pde`, `movement.pde`,
`night_projection.pde`, `portals.pde`, `screens.pde`, `ship.pde`,
`tasks.pde`, `test_mode.pde` e `ui.pde`.

`capture.pde` e `test_mode.pde` são módulos opcionais do harness. O runtime
continua sendo o sketch Processing local; `editorial.pde` permanece incluída
na lista autoritativa e não pode ser omitida do inventário.

### Ferramentas operacionais

Os scripts operacionais presentes no worktree em `tools/` são:

| Script | Uso |
| --- | --- |
| `tools/build.sh` | compilação do sketch pelo CLI do Processing |
| `tools/cleanup-verification-artifacts.mjs` | remoção dos artefatos transitórios em `last_horizon/output/` |
| `tools/compare-metrics.mjs` | validação e comparação de três CSVs/sidecars baseline e versão revisada |
| `tools/compare-profiling.mjs` | validação do registro de profiling nos dois perfis e versões |
| `tools/verify-delivery.mjs` | runner integrado, relatório final e precedência FAIL/INCONCLUSIVO/PASS |
| `tools/e6-audit.mjs` | auditoria estática histórica da etapa E6 |
| `tools/e6-evidence.mjs` | auditoria histórica dos artefatos de evidência da etapa E6 |
| `tools/optional-modules.mjs` | matriz de compilação dos módulos opcionais do harness |
| `tools/processing-cli.sh` | cópia temporária, fixture do pipeline, build e execução do Processing |
| `tools/regression-final.sh` | sequência Linux dos quatro cenários funcionais |
| `tools/regression-windows.mjs` | execução Windows dos quatro cenários pelo Processing CLI |
| `tools/run-headless.sh` | atalho headless para um modo do harness |
| `tools/run-processing.sh` | wrapper operacional para executar o sketch pelo Processing CLI |
| `tools/snapshot-entrega.mjs` | montagem do snapshot da branch de entrega |
| `tools/typecheck.mjs` | `node --check` dos módulos JavaScript com limite operacional de 60 segundos |

O `processing-cli.sh` mantém a origem do sketch livre de fixtures geradas e
propaga como código não zero um `FALHOU` emitido pelo harness. Essa propagação
é parte da evidência: uma falha observada não pode terminar como PASS por causa
do código de saída do processo Java.

### Comandos do package.json

O contrato atual é:

| Script | Comando e papel |
| --- | --- |
| `build` | `bash tools/build.sh`, compilação do sketch com timeout operacional de 300 s |
| `typecheck` | `node tools/typecheck.mjs`, que executa `node --check` nos módulos alterados com timeout total de 60 s |
| `e6:audit` | `node tools/e6-audit.mjs`; histórico, não é pré-requisito de regressão ou do registro final |
| `e6:compare` / `metrics:compare` | `node tools/compare-metrics.mjs <baseline-dir> <revised-dir>`; comparação canônica de três amostras por referência |
| `metrics:profiling` | `node tools/compare-profiling.mjs`; gate de profiling nos dois perfis obrigatórios |
| `e6:evidence` | `node tools/e6-evidence.mjs`; histórico, não é pré-requisito de regressão ou do registro final |
| `regression:windows` | `node tools/regression-windows.mjs`; runner Windows dos quatro cenários |

`tools/e6-audit.mjs` e `tools/e6-evidence.mjs` continuam rastreados neste
inventário e nos comandos históricos `e6:audit` e `e6:evidence`. Nenhum dos
dois permanece no comando `typecheck`.

## Comandos e pré-requisitos

Os limites de registro adotados são 60 segundos para typecheck, 300 segundos
para regressão e build, 180 segundos por captura de métricas, 60 segundos para
comparação e snapshot e 120 segundos para a simulação numérica. O runner de Processing exige uma instalação
compatível com Processing 4.5.6; o modo headless exige também `xvfb-run`.

| Comando | Pré-requisito | Timeout | Resultado da baseline | Evidência e impacto |
| --- | --- | ---: | --- | --- |
| `npm run typecheck` | Node.js | 60 s | PASS, saída 0 | Todos os módulos JavaScript listados foram aceitos pelo parser. |
| `node prototype/balance-model.mjs --simulate` | Node.js | 120 s | PASS, saída 0 | `BALANCE CHECK: PASS`; 2.520/2.520 sequências da reserva de peças. |
| `bash tools/run-headless.sh --capture` | Processing 4.5.6, `xvfb-run` | 60 s | FAIL, saída 1 | `QUEST CHECK: FALHOU`; falharam os checks de take de caminhada, primeiro passo, contato do pé e meio do ciclo visual. |
| `bash tools/run-headless.sh --hit-test` | Processing 4.5.6, `xvfb-run` | 60 s | PASS, saída 0 | Quatro cartões de sala e o caso de letterbox terminaram com `OK` e `Finished.` |
| `bash tools/run-headless.sh --ladder-test` | Processing 4.5.6, `xvfb-run` | 60 s | PASS, saída 0 | Seis checks de escada terminaram com `OK` e `Finished.` |
| `bash tools/run-headless.sh --asset-pipeline-test` | Processing 4.5.6, `xvfb-run` | 60 s | PASS, saída 0 | Fixture PNG 16×16 carregada por `loadImage()`; saída `pipeline: OK`. |
| `bash tools/run-headless.sh --metrics` | Processing 4.5.6, `xvfb-run` | 180 s | PASS, saída 0 | Três amostras de 30 segundos; CSV e sidecar canônicos por amostra. |
| `node tools/compare-metrics.mjs <baseline-dir> <revised-dir>` | Node.js | 60 s | INCONCLUSIVO | Depende de três CSVs e três sidecars válidos por referência. |
| `node tools/profile-runner.mjs` | Processing 4.5.6, `xvfb-run` | 1500 s | PASS, saída 0 | 12 coletas: baseline/revisada, dois perfis, um cenário e três amostras; manifesto, CSVs, sidecars e logs canônicos preservados. |
| `node tools/compare-profiling.mjs` | Node.js | 60 s | PASS, saída 0 | Cinco hotspots comparados; p95 revisado máximo 18,504 ms; nenhuma regressão superior a 10% e nenhuma elevação persistente de alocações. |
| `node tools/snapshot-entrega.mjs` | Git e Node.js | 300 s | PASS, saída 0 | Manifesto final com `final: true`, cópia compilada, matriz opcional e controles de desenvolvimento ausentes. |
| `node tools/cleanup-verification-artifacts.mjs` | Node.js | 60 s | PASS, saída 0 | Somente saídas transitórias previstas foram removidas; CSVs, sidecars, profiling, logs e relatórios foram preservados. |
| `npm.cmd run regression:windows` | Windows e Processing.exe | 300 s (60 s por cenário) | INCONCLUSIVO | Não executado neste Linux: o runner recusa `process.platform !== "win32"`. O impacto é a ausência de confirmação do caminho Windows; os quatro modos foram tentados pelo runner headless equivalente. |

Os comandos históricos `npm run e6:audit` e `npm run e6:evidence` não foram
usados como pré-requisitos. Seus artefatos e documentos de entrada históricos
não fazem parte da baseline desta sprint. `e6:compare` permanece como alias de
compatibilidade para o comparador canônico e exige os diretórios de três
amostras; a comparação sem versão revisada é INCONCLUSIVA.

Nenhum resultado INCONCLUSIVO acima é contado como PASS.

## Auditoria de remoção de código

| Arquivo | Símbolo removido | Referências e entradas examinadas | Justificativa | Validação posterior | Resultado |
| --- | --- | --- | --- | --- | --- |
| `last_horizon/hud.pde` | `resourceIconLabel(int)` | A busca na baseline (`git grep -n "resourceIconLabel" HEAD -- last_horizon`) encontrou somente a declaração em `hud.pde:329-336`, sem chamadas. A busca no estado revisado (`git grep -n "resourceIconLabel" -- last_horizon`) não encontrou referências. Foram examinados os entrypoints `setup()`, `draw()`, `drawHeader()`, `drawResourceIcon()` e os caminhos de fallback de ícones; todos usam o mapeamento atual de recursos e `hudResourceLabel()` diretamente. | Wrapper sem referências estáticas nem entrada indireta no sketch; sua remoção não altera o mapeamento de recursos, o HUD, os fallbacks ou os valores dinâmicos. | `npm run typecheck` passou; `bash tools/run-headless.sh --metrics` compilou e executou três amostras de 30 segundos com `PROCESSING REGRESSION: PASS`. | PASS |

## Inventário de duplicações

Este inventário foi registrado antes da refatoração da sprint “Transições,
helpers e organização estrutural”. A decisão vale para os símbolos atuais do
sketch; helpers que permanecem separados têm contratos diferentes e não devem
ser unidos por semelhança visual.

| Arquivo | Símbolo ou grupo | Categoria | Referências | Decisão |
| --- | --- | --- | --- | --- |
| `last_horizon/ui.pde` | `drawShadowText`, `textCenteredShadow`, `textPromptShadow` | texto com sombra | `ship.pde` e `ui.pde` | Consolidar o cálculo de centralização em um helper compartilhado; preservar os dois wrappers públicos. |
| `last_horizon/ui.pde` | `drawButton`, `drawModalFooterButton` | botões | telas, HUD, quests e modais | Manter separados: o botão geral aceita uma linha e o botão de rodapé mede quebra de texto e layout de duas ações. |
| `last_horizon/ui.pde` | `drawModalFooter` sobrecarregado | rodapé | `game.pde`, `tasks.pde`, `ui.pde`, `ship.pde` | Manter uma implementação de layout e um wrapper de limites padrão. |
| `last_horizon/assets.pde` | `prepareNpcGlow`, `prepareDoorGlow`, `prepareStationGlow` | preparação de imagens | `loadArtAssets()` | Consolidar o loop de preparação de glow em helper 1D; manter as entradas de NPC por direção. |
| `last_horizon/assets.pde` / `last_horizon/ship.pde` | `loadNpcArtFrames`, `drawNpc` e overloads | arte de NPC | `loadArtAssets()` e `drawRoomPoint()` | Consolidar resolução de frame/fallback em `resolveNpcArt()`; preservar overloads de nome e índice. |
| `last_horizon/hud.pde` | `hudResourceIcon`, `hudResourceValue`, `hudResourceLabel`, `hudResourceAccent`, `hudResourceFill`, `resourceIconLabel` | mapeamento de recursos | `drawHeader()` e fallback de ícones | Centralizar metadados de recurso e manter leitura dos globais de gameplay no helper de valor. |
| `last_horizon/assets.pde` | `loadArtFrames`, leitura de JSON em `loadNpcArtFrames` | preparação de imagens | portas, casco e NPCs | Manter caminhos de layout distintos: portas/casco usam lista linear; NPCs precisam de orientação e espelhamento. Compartilhar somente leitura segura de frame. |

Itens semelhantes mantidos separados não autorizam alteração de gameplay,
ordem de desenho ou contrato de fallback.

## Equivalência funcional

### Portal e ordem do ciclo

`updateRoom()` continua executando a guarda da transição antes da entrada
modal, da atualização de direção, da física de convés ou escada e dos sons de
passo. `useNearbyDoor()` conserva o hit-test de porta e delega a travessia a
`enterRoomThroughDoor()`. Essa função prepara destino, retorno, saída, chegada
e direção uma única vez; a mesma preparação alimenta o caminho imediato e as
fases `OPENING`/`CLOSING` quando os dois quadros de arte da porta existem.

Durante qualquer fase ativa, novas entradas são ignoradas. Ao entrar na sala ou
encerrar o fechamento, o registro preparado e os campos transitórios são
limpos. Uma porta inválida, destino inexistente ou retorno sem porta produz um
diagnóstico `portal:` e deixa a sala e a posição do jogador intactas. Falha ou
ausência do efeito sonoro é tolerada pelo helper de áudio e não interrompe a
travessia.

O harness mantém os seguintes modos verificáveis:

| Modo | Superfície preservada |
| --- | --- |
| `--capture` | ciclo diário, ofertas preventivas, aceite presencial, coleta, entrega, mapa, noite, incidentes, riscos, menus, vozes, caches, portais, animação, transmissão e campanhas |
| `--hit-test` | cartões das quatro salas e transformação da janela com letterbox |
| `--ladder-test` | saída lateral, travessia, estabilidade, rearme, encaixe e escada em posição configurável |
| `--asset-pipeline-test` | fixture PNG sintética de 16×16 carregada por `loadImage()` |
| `--metrics` | fixture aprovada, aquecimento, três janelas de 30 segundos, CSV/sidecar canônicos e profiling por amostra |

### Matriz de fixtures de quests

O catálogo mecânico contém 22 IDs, todos preservados para comparação:

`V-01`, `V-02`, `B-01`, `B-02`, `N-01`, `N-02`, `S-01`, `S-02`,
`ENG-A`, `ENG-B`, `HUL-A`, `HUL-B`, `FOOD-A`, `FOOD-B`, `CON-A`, `CON-B`,
`LIFE-A`, `LIFE-B`, `PWR-A`, `PWR-B`, `COM-A`, `COM-B`.

Cada fixture mantém o contrato de coleta e entrega, um objeto carregado por
vez, origem, destino, custo, consequência e limite de uma conclusão diária.
O catálogo editorial em `last_horizon/editorial.pde` mantém uma entrada
correspondente para cada um dos 22 IDs.

### Matriz de estados de captura

Os 34 estados de captura preservados são:

`menu_init`, `vignette_1`, `vignette_2`, `vignette_3`, `preventive_offers`,
`preventive_selected`, `preventive_confirmation`, `quest_collect_route`,
`quest_map`, `quest_collect_confirmation`, `quest_carrying`,
`quest_delivery_confirmation`, `preventive_reward`, `night_forecast`,
`incident_choices`, `incident_confirmation`, `urgent_collect`,
`urgent_carrying`, `urgent_delivery`, `urgent_solved`, `preventive_failure`,
`preventive_neglect`, `urgent_retry`, `survivor_risk`, `rescue_confirmation`,
`survivor_rescued`, `pause`, `defeat`, `victory`, `dense_night_forecast`,
`day_3_night_modal`, `help_panel`, `day_2_free_dormitory`,
`earth_transmission`.

Essa matriz não pode ser reduzida, removida ou transformada em um caminho
sem diagnóstico equivalente. A captura da baseline percorreu os estados até
os checks de regras; o resultado normativo do cenário é FAIL pelas quatro
asserções de caminhada descritas acima.

O modo `--capture` também executa a matriz de equivalência noturna definida em
`last_horizon/capture.pde`. Para cada combinação das 22 quests e dos 34 estados,
duas simulações recebem snapshots equivalentes e são comparadas nos campos de
dia, etapa, recursos, inventário, objeto carregado, problemas ativos, riscos,
mortes, resultado editorial e vitória/derrota. A segunda projeção passa ainda
pela aplicação da instância exibida e compara o estado global aplicado com o
estado projetado. O contrato verifica os 22 IDs e os 34 identificadores
versionados; qualquer alteração de quantidade ou identificador, divergência ou
falha de aplicação recebe `FAIL` e a lista de campos divergentes. O artefato
canônico é `last_horizon/output/equivalence-report.json`.

O painel de sono guarda a prévia exibida. `processNight()` só aplica essa
instância quando a assinatura do snapshot de origem e a assinatura da projeção
continuam válidas; confirmação repetida, mudança de estado, restauração ou
fechamento do painel invalida a prévia e não repete efeitos.

## Contrato canônico de métricas

O modo `--metrics` aplica automaticamente a fixture aprovada
`approved-metrics-fixture-v1`, na sala `command`, no estado
`day-1-command-ready`, com os mesmos assets e Processing durante a coleta. Ele
aquece por 120 frames e coleta três amostras independentes. Cada amostra para
no primeiro frame cujo relógio atinge ou ultrapassa 30 segundos; a tolerância
aceita é de ±0,5 s. Uma duração fora desse intervalo invalida a amostra.

O CSV de cada amostra tem exatamente os campos
`sample_id`, `duration_real_s`, `frame_count`, `frame_time_median_ms`,
`frame_time_p95_ms`, `load_time_ms`, `additional_memory_bytes`, `icon_builds`,
`floor_band_builds`, `cache_invalidations` e `allocations_per_frame`.

O sidecar de cada amostra tem exatamente
`environment`, `machine`, `assets`, `room`, `state`, `nominal_window_s`,
`processing`, `hardware`, `gpu` e `os`. Campos indisponíveis causam falha de
captura; não são convertidos em valores padrão. Os artefatos ficam em:

`last_horizon/output/<versao>/<perfil>/<sample_id>.csv`

`last_horizon/output/<versao>/<perfil>/<sample_id>.sidecar.json`

O profiling correspondente fica em
`last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json` e
registra rendering, image scaling, alocações por quadro, preview de transições
e carregamento/cache de assets, com links ao CSV, ao sidecar e a este contrato.

## Sprint — Otimização de renderização estática e assets

O runtime prepara os seis ícones do HUD durante o carregamento e compartilha as
faixas de piso quando a fonte, a largura, a escala e a geração coincidem.
Valores, barras, estados críticos, piscadas e objetivo continuam fora dos
caches estáticos. A substituição de uma referência de `PImage` invalida apenas
as entradas dependentes; a mutação do bitmap compartilhado não é usada como
sinal de alteração.

Ausências, PNGs inválidos e spritesheets incompletos usam o fallback geométrico
do item afetado. O diagnóstico JSONL canônico é gravado em
`last_horizon/output/fallback-diagnostics.jsonl` e cada linha identifica
`file`, `asset_type`, `failure` e `fallback`. A carga de arte não interrompe a
partida quando uma imagem, uma porta, uma estação, um sprite ou um detalhe de
ambiente não está disponível.

O CSV canônico mantém `icon_builds`, `floor_band_builds`,
`cache_invalidations` e `additional_memory_bytes`; indisponibilidade de
alocação, memória ou duração fora da janela nominal encerra a captura com
falha e não converte a métrica em zero.

O check `checkCacheContract` confirma que a preparação dos seis ícones fica
estável após a primeira construção, que os três conveses compartilham a faixa
quando a chave coincide e que mudanças independentes de largura, escala e
referência de `PImage` reconstruem somente a entrada afetada. Recortes de
spritesheets e metadados JSON inválidos são diagnosticados antes do fallback
geométrico, sem interromper a partida.

Para gerar cada combinação, defina explicitamente `METRICS_VERSION` como
`baseline` ou `revised`, `METRICS_PROFILE` como `core-i3-integrated` ou
`reference`, `METRICS_ENVIRONMENT`, `METRICS_MACHINE` e `METRICS_GPU` antes de
executar `bash tools/run-headless.sh --metrics`. A ausência de qualquer um desses
metadados torna a captura INCONCLUSIVA antes de iniciar o Processing; nenhum
valor de ambiente ou de máquina é derivado ou preenchido pelo runner.

`node tools/compare-metrics.mjs <baseline-dir> <revised-dir>` exige três
amostras e três sidecars por referência, rejeita campos ausentes, valores
inválidos, divergências estruturais e nomes legados sem conversão explícita.
As métricas agregáveis usam a mediana das três amostras. O status tem a
precedência FAIL, INCONCLUSIVO e PASS: PASS exige redução mensurável na
mediana e em pelo menos duas amostras correspondentes de algum custo, sem
regressão superior a 10% em qualquer custo, p95 agregado revisado de no máximo
33,3 ms e nenhum crescimento persistente acima de 1% na mediana de
`allocations_per_frame`.

## Limitações e cenários não executados

- A execução Windows de `npm.cmd run regression:windows` é INCONCLUSIVA neste
  ambiente Linux. O motivo é a guarda explícita do runner para `win32`; o
  impacto é não validar `Processing.exe`, `where.exe`, o caminho padrão de
  instalação e a janela Windows.
- A captura funcional da baseline histórica foi FAIL por quatro checks de
  animação de caminhada. A execução atual terminou com `QUEST CHECK: PASS`;
  a diferença histórica continua registrada para comparação e não foi apagada.
- O headless reportou que Segoe UI não está disponível e aplicou fallback de
  fonte. A equivalência visual tipográfica exata permanece INCONCLUSIVA.
- O backend de áudio do ambiente não carregou os 14 WAV por incompatibilidade
  do formato PCM com a interface `Clip`. A funcionalidade audiovisual de áudio
  permanece INCONCLUSIVA; isso não altera o resultado dos checks de lógica,
  hit-test, escadas ou pipeline de imagem.
- A carga reportou 33 de 57 imagens disponíveis; os caminhos ausentes usam o
  fallback geométrico já previsto pelo runtime. A validação do pipeline cobre
  especificamente a fixture PNG 16×16 e não constitui inventário de todos os
  assets artísticos.
- `e6:audit` e `e6:evidence` não foram necessários para o registro final. São
  scripts históricos e podem depender de documentos de evidência de etapas
  anteriores; sua ausência de execução não é pré-requisito da regressão.
- `snapshot-entrega.mjs` foi executado depois da limpeza e gerou o manifesto
  final aceito em `output/snapshot-entrega-manifest.json`. A cópia compilada
  fica em `output/snapshot-entrega/`; o manifesto intermediário da sprint 007
  não participa da decisão final.

## Decisão

| Decisão normativa | Status | Base |
| --- | --- | --- |
| Registro de verificação com referência, comandos, evidências, limites e decisão | PASS | Este documento identifica o commit baseline, o manifesto usado, os comandos, timeouts e impactos. |
| Inventário da superfície existente | PASS | As 16 abas, 14 scripts operacionais, scripts do package, cinco modos e as matrizes de 22 quests/34 estados estão listados. |
| Evidência funcional anterior às refatorações | PASS | Os quatro cenários históricos receberam resultado individual; a captura da baseline falhou com diagnóstico e saída 1, hit-test/escadas/pipeline passaram. |
| Baseline numérica | PASS | A simulação venceu 2.520/2.520 sequências e o modo `--metrics` concluiu três amostras. |
| Verificação Windows | INCONCLUSIVO | Pré-requisito de plataforma ausente; não contado como PASS. |
| Guarda de escopo arquitetural | PASS | A entrega continua como aplicação Processing local, com estado global em memória, funções procedurais, constantes, tabelas e classes pontuais. Não foram adicionados banco, endpoint HTTP, backend persistente, autenticação, framework de UI, engine, dependência de runtime ou nova aba `.pde`. |

A sprint estabelece a baseline e pode servir de ponto de comparação para as
seguintes. A falha de captura e a indisponibilidade Windows permanecem
registradas como condições normativas que qualquer alteração posterior deve
reavaliar; nenhuma delas foi mascarada como PASS.
