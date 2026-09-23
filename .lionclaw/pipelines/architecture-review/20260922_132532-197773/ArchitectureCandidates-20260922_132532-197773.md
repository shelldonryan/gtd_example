# Architecture Candidates: Last Horizon — Performance no notebook
**Data:** 2026-09-22  
**Run:** 20260922_132532-197773  
**Source:** /home/ubuntu/pessoal/01-projetos/gtd_example/.lionclaw/pipelines/architecture-review/20260922_132532-197773/ArchitectureMap-20260922_132532-197773.md

## Escopo desta triagem

O alvo é o caminho de execução por frame no notebook real: renderização, atualização frame-bound, alocações, caches, assets e a cadência de áudio quando a taxa de frames cai. A análise exclui aprofundamento de regras de domínio, remoção de código, comentários, reorganização estrutural e qualquer alteração funcional que não seja necessária para medir ou melhorar performance. `capture.pde` aparece como superfície de medição e teste; a toolchain existente é evidência do contrato de métricas, não alvo de mudança.

## Candidato C5 — Aprofundar o Adapter de assets e caches do caminho quente
- **Files:** `last_horizon/assets.pde`, `last_horizon/ship.pde`, `last_horizon/hud.pde`, `last_horizon/animation.pde`, `last_horizon/portals.pde`, `last_horizon/capture.pde`
- **Problema:** `assets.pde` mantém `art_cache`, diagnósticos, frames, glows e cache de faixas; `ship.pde` mantém `room_detail_cache` e também chama `loadImage` diretamente no caminho legado; `hud.pde` mantém cache próprio de ícones. Há cache de `PGraphics` para faixas e ícones, mas a resolução de assets, a invalidação e a representação de ausência continuam distribuídas entre Modules. **Deletion test:** sem esse Adapter, carregamento, recorte, fallback e invalidação reaparecem em cada renderer e no fluxo de portas, portanto ele concentra complexidade real.
- **Solucao:** Aprofundar o Adapter existente para que resolução de paths, metadados, fallback e invalidação seletiva fiquem concentrados, preservando os caches por fonte, escala e geração que já existem. Os renderizadores devem continuar recebendo arte pronta para desenhar, sem introduzir ainda uma Interface final. Este candidato é evidência parcial: sozinho não cobre o relógio de movimento, o loop `draw()` nem a cadência de áudio em baixa taxa de frames.
- **Beneficios (locality/leverage/testes):** Locality: mudanças de PNG, spritesheet, fallback e cache ficam em um lugar. Leverage: `ship.pde`, `hud.pde`, `animation.pde` e `portals.pde` compartilham uma política de carregamento e invalidação. Testes: os contadores de builds, `cache_invalidations`, diagnósticos de fallback e cenários de pipeline em `capture.pde` tornam o efeito mensurável.
- **Payoff:** medium
- **Risco:** medium
- **Por que agora:** O Map já identifica assets e caches como hotspot, e o contrato de métricas já registra tempo de carga, builds de ícones, builds de faixas e invalidações. O ganho esperado é localizado no caminho de renderização e não explica sozinho a degradação temporal do movimento e do áudio.

## Candidato C6 — Aprofundar o Module de frame e o relógio de movimento
- **Files:** `last_horizon/last_horizon.pde`, `last_horizon/movement.pde`, `last_horizon/animation.pde`, `last_horizon/audio.pde`, `last_horizon/ship.pde`, `last_horizon/hud.pde`, `last_horizon/ui.pde`, `last_horizon/assets.pde`, `last_horizon/capture.pde`
- **Problema:** `draw()` em `last_horizon.pde` executa `updateInput`, `updateRoom`, `drawBase`, `updateCursor` e `drawWindow` uma vez por frame. `movement.pde` aplica `PLAYER_SPEED`, `PLAYER_RUN_SPEED`, gravidade e `LADDER_SPEED` por chamada, sem um delta de tempo explícito; `animation.pde` calcula frames com `millis()`, enquanto `audio.pde` dispara passos a partir dessas atualizações de movimento. Assim, uma queda de frames altera a distância percorrida por segundo e a cadência percebida de passos. No mesmo frame, `drawBase` percorre nave, pontos, HUD, modais e sprites, com strings e decisões de cache no caminho quente. **Deletion test:** sem um Module de frame e tempo que concentre ordem, duração e orçamento da atualização, essas regras reaparecem de forma incompatível em `last_horizon.pde`, `movement.pde`, `animation.pde`, `audio.pde` e nos renderizadores.
- **Solucao:** Aprofundar o Module de execução por frame para tornar explícitos o tempo decorrido, as fases de atualização e renderização e o limite de trabalho por frame. O relógio deve permitir que movimento e animação mantenham comportamento temporal controlado, que os eventos de áudio sejam derivados de avanço de movimento em vez de simplesmente da quantidade de frames e que uma pausa de renderização não gere rajadas de sons; o caminho de renderização deve reutilizar caches e dados preparados. A forma final da Interface, o tratamento exato de frames longos e os limites de atualização ficam para a fase seguinte.
- **Beneficios (locality/leverage/testes):** Locality: regras de tempo, ordem de atualização, renderização e emissão de áudio ficam concentradas no caminho de frame. Leverage: movimento, animação, áudio, nave e HUD passam a obedecer ao mesmo relógio e ao mesmo orçamento de trabalho. Testes: `capture.pde` já verifica movimento, animação e contagem de passos, enquanto o modo de performance mede p95 de frame, `allocations_per_frame`, memória e builds/invalidações de cache.
- **Payoff:** high
- **Risco:** high
- **Por que agora:** `frameRate(60)` apenas define a meta do Processing; o movimento ainda avança por chamada de frame e os passos de áudio são emitidos dentro desse avanço. Este é o único candidato que cobre conjuntamente loop de renderização, atualização frame-bound, alocações, caches, assets e o efeito da baixa taxa de frames na cadência de áudio.

## Candidato C7 — Aprofundar o Module de apresentação com dados preparados e menos alocações
- **Files:** `last_horizon/last_horizon.pde`, `last_horizon/ship.pde`, `last_horizon/hud.pde`, `last_horizon/ui.pde`, `last_horizon/animation.pde`, `last_horizon/assets.pde`, `last_horizon/capture.pde`
- **Problema:** O caminho `drawBase` é refeito a cada frame e chama desenho de sala, pontos físicos, HUD, footer, modais e jogador. O HUD reconstrói linhas com concatenação de `String`, usa `millis()` para pulsos e consulta regras de domínio durante a apresentação; `ship.pde` recalcula disponibilidade, labels, frames e glows de pontos a cada desenho. Existem caches úteis — `player_frame_layer`, `resource_icon_cache` e `art_deck_strip` — mas eles não cobrem todo o trabalho de decisão e formatação do frame. **Deletion test:** sem um Module de apresentação que prepare e recicle esses dados, a formatação, seleção de arte e decisões de desenho reaparecem em cada chamador visual.
- **Solucao:** Aprofundar o Module de apresentação para preparar dados estáveis fora do caminho quente, reutilizar texto, geometria, frames e bitmaps enquanto suas fontes não mudarem e invalidar apenas o que depende de estado ou escala alterado. A otimização deve ser medida por frame time e alocações e preservar a ordem visual e as regras funcionais; a Interface final não é definida nesta triagem.
- **Beneficios (locality/leverage/testes):** Locality: decisões de preparação, reutilização e invalidação ficam concentradas no caminho visual. Leverage: nave, HUD, UI e animação compartilham o mesmo orçamento de renderização. Testes: `capture.pde` fornece `frame_time_p95_ms`, `allocations_per_frame`, builds de ícones/faixas e verificações de pixels e pipeline para separar ganho real de mudança visual.
- **Payoff:** high
- **Risco:** medium
- **Por que agora:** Os caches existentes mostram que o código já tem Seams de preparação, mas a medição de alocações por frame indica que o custo residual precisa ser localizado no render pass completo, e não apenas no carregamento inicial de assets.

## Candidato C8 — Aprofundar o Adapter de áudio de movimento com cadência independente do frame
- **Files:** `last_horizon/movement.pde`, `last_horizon/audio.pde`, `last_horizon/animation.pde`, `last_horizon/last_horizon.pde`, `last_horizon/capture.pde`
- **Problema:** `updateRoom` chama o movimento uma vez por frame; corrida emite passos por `player_step_accum`, caminhada alterna fase com `millis()` e escada acumula distância por chamada. Cada `playDeckStepSound` ou `playLadderStepSound` chama `stopStepSounds`, que percorre e para todos os `Clip`s antes de reiniciar um som. Em baixa taxa de frames, o evento sonoro pode atrasar, mudar de cadência ou concentrar trabalho no frame que recupera o atraso. **Deletion test:** sem o Adapter de áudio de movimento, a escolha de clip, rotação, interrupção, cadência e tolerância a atraso reaparecem em `movement.pde`, `animation.pde` e no shell.
- **Solucao:** Aprofundar o Adapter de áudio para receber eventos temporais de movimento já normalizados, manter a rotação dos clips pré-carregados e evitar que um frame longo produza uma sequência de interrupções ou sons acumulados. O comportamento audível deve continuar coerente com caminhada, corrida, escada e salto; a Interface final e a política de descarte de eventos ficam para a fase seguinte.
- **Beneficios (locality/leverage/testes):** Locality: a política de emissão, interrupção e tolerância a atraso fica em um lugar. Leverage: os três modos de movimento usam a mesma cadência temporal e não dependem diretamente da taxa de renderização. Testes: `sound_step_play_count`, os cenários de caminhada/corrida/escada/salto e o cenário de baixa taxa de frames podem verificar a cadência sem exigir inspeção do áudio interno.
- **Payoff:** medium
- **Risco:** high
- **Por que agora:** O carregamento dos `Clip`s já é feito no `setup()` e o problema observado está na emissão por evento de movimento e no `stopStepSounds()`; isso permite aprofundar o Adapter sem transformar carregamento de assets em regra de gameplay.

## Ranking payoff/risco
| # | Titulo | Payoff | Risco |
|---|---|---|---|
| C6 | Aprofundar o Module de frame e o relógio de movimento | high | high |
| C7 | Aprofundar o Module de apresentação com dados preparados e menos alocações | high | medium |
| C5 | Aprofundar o Adapter de assets e caches do caminho quente | medium | medium |
| C8 | Aprofundar o Adapter de áudio de movimento com cadência independente do frame | medium | high |

## Recomendacao
**Candidato C6 — Aprofundar o Module de frame e o relógio de movimento.** Ele é o único alvo que cobre o conjunto obrigatório: loop de renderização, atualização frame-bound, alocações, caches, assets e a alteração da cadência de áudio quando o notebook perde frames. O risco é alto porque movimento e áudio são observáveis pelo jogador, mas o projeto já possui uma superfície de medição em `capture.pde` capaz de comparar p95, alocações, caches e eventos de passos antes de qualquer mudança funcional.

## Limites da triagem
- A execução real do Processing no notebook e a coleta de métricas não foram repetidas nesta triagem; os contratos de medição foram inspecionados no código.
- Não foi feita uma separação função a função do custo de cada operação de desenho; os candidatos apontam os caminhos reais e os contadores existentes para a próxima medição.
- A transição noturna e outros Modules de domínio ficaram fora do escopo, assim como documentação, toolchain, remoção de código e reorganização estrutural.
