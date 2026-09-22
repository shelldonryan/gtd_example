# Architecture Candidates: Last Horizon
**Data:** 2026-09-21
**Run:** 20260921_141345-12a70d
**Source:** /home/ubuntu/pessoal/01-projetos/gtd_example/.lionclaw/pipelines/architecture-review/20260921_141345-12a70d/ArchitectureMap-20260921_141345-12a70d.md

**Escopo alvo:** otimização de performance; remoção segura de código não usado ou duplicado; remoção de comentários desnecessários; melhor organização estrutural; preservação do comportamento funcional.

## Candidato 1 — Otimizar o preview noturno e as alocações por frame
- **Files:** `last_horizon/night_projection.pde`, `last_horizon/tasks.pde`, `last_horizon/hud.pde`, `last_horizon/ui.pde`, `last_horizon/capture.pde`
- **Problema:** Enquanto o modal de fim do dia está aberto, `drawEndDayPanel` chama `recalculateEndDayPanel`, que chama `projectNight` durante o render. Isso cria `NightSnapshot`, copia arrays e reconstrói textos derivados repetidamente; `drawStars` também aloca arrays a cada frame. A Interface de renderização paga o custo completo da simulação mesmo sem mudança de estado.
- **Deletion test:** Se a organização do resultado derivado e da invalidação for removida, a simulação completa e as alocações voltam a ocorrer em cada frame entre `hud.pde`, `tasks.pde`, `night_projection.pde` e `ui.pde`; o papel concentra complexidade real.
- **Solução:** Manter um resultado derivado reutilizável, invalidado quando o estado relevante muda, e mover dados visuais fixos para uma construção fora do frame. Preservar a pureza do preview, a regra de aplicação única e os contadores já medidos pelo harness; a Interface de cache ainda não é proposta.
- **Benefícios (locality/leverage/testes):** Locality para invalidação e cálculo derivado; Leverage para o HUD, que recebe um preview pronto; testes de comportamento e performance podem verificar equivalência, p50/p95 e redução de alocações.
- **Payoff:** high
- **Risco:** medium
- **Por que agora:** O custo ocorre em um fluxo recorrente de render e `capture.pde` já possui métricas de performance e cache para demonstrar ganho sem alterar o comportamento funcional.

## Candidato 2 — Remover código duplicado ou sem uso entre regras do runtime
- **Files:** `last_horizon/night_projection.pde`, `last_horizon/game.pde`, `last_horizon/tasks.pde`, `last_horizon/hud.pde`, `last_horizon/capture.pde`
- **Problema:** Regras de riscos, deadlines, perdas e alertas aparecem em mais de um caminho do runtime: `night_projection.pde` contém o caminho canônico de simulação, projeção e aplicação, enquanto `game.pde` ainda define `processSurvivorRisks` e `processProblemDeadlines`; o primeiro aparece somente em testes do harness e o segundo não tem chamada no runtime verificado. `dailyProblemLoss`, `nightCrisisLoss` e `nightFatalWarning` formam outro caminho para calcular aviso e perda, enquanto o HUD consulta esse cálculo separado.
- **Deletion test:** Se o Module da transição noturna for removido, ordenação, consumo, riscos, deadlines, alertas e aplicação reaparecem em `game.pde`, `tasks.pde`, `hud.pde` e no harness; o papel não é pass-through.
- **Solução:** Fazer um único Module profundo concentrar as regras duplicadas, seus efeitos e diagnósticos, com preview, alerta, aplicação e harness consumindo o mesmo resultado. Remover rotinas antigas, caminhos sem uso, cálculo duplicado e comentários históricos somente depois de preservar os comportamentos observados; a Interface final fica para a fase de aprofundamento.
- **Benefícios (locality/leverage/testes):** Locality para ordenação, consumo, riscos e deadlines; Leverage para HUD e telas que deixam de recalcular regras; testes cobrem uma transição e sua aplicação, reduzindo código não usado e duplicado.
- **Payoff:** high
- **Risco:** medium
- **Por que agora:** Há evidência concreta de caminhos antigos e cálculos duplicados que podem divergir, incluindo o Seam `simulateNightTransition(NightSnapshot)` já existente.

## Candidato 3 — Organizar ownership do estado e limpar o shell do runtime
- **Files:** `last_horizon/last_horizon.pde`, `last_horizon/screens.pde`, `last_horizon/game.pde`, `last_horizon/tasks.pde`, `last_horizon/hud.pde`, `last_horizon/ui.pde`, `last_horizon/movement.pde`, `last_horizon/portals.pde`
- **Problema:** O shell mantém muitos globais, hooks de harness, entrada e ciclo de desenho, enquanto telas, regras, HUD, movimento e portais leem e mutam o mesmo estado. A Interface efetiva fica implícita e grande, reduzindo Depth e Locality; comentários históricos ou óbvios e hooks opcionais misturam contexto de manutenção com a Implementation corrente.
- **Deletion test:** Se a ownership concentrada for removida, as mesmas invariantes, flags, precedências e limpeza de estado reaparecem em vários chamadores do shell; a complexidade apenas se distribui novamente.
- **Solução:** Reorganizar a ownership entre os Modules existentes, deixando o shell responsável por ciclo de vida, entrada e despacho, e concentrando invariantes nos Modules que os possuem. Remover hooks sem consumidor e comentários que não expliquem Interface, invariantes, ordenação ou formato; a Interface final ainda não é definida.
- **Benefícios (locality/leverage/testes):** Locality maior para estado e invariantes; Leverage para telas e harnesses que deixam de conhecer mutações internas; testes podem exercitar Modules por Interfaces menores, preservando um shell runtime mínimo.
- **Payoff:** high
- **Risco:** high
- **Por que agora:** A organização estrutural é a base para tratar performance, remoção de duplicações e corte de entrega sem espalhar novas dependências pelo sketch.

## Candidato 4 — Saneiar assets, fallbacks e caches derivados
- **Files:** `last_horizon/assets.pde`, `last_horizon/ship.pde`, `last_horizon/hud.pde`, `last_horizon/animation.pde`, `last_horizon/ui.pde`, `last_horizon/capture.pde`
- **Problema:** Carregamento, fallback, cache e uso de arte estão distribuídos. `assets.pde` procura `objects/`, `rooms/`, `portraits/`, `screens/` e `stations/casco_sheet`, ausentes no catálogo atual de `last_horizon/data`; `ship.pde` tenta `../assets/PNG`, e `floorArtForDeck(int deck_index)` ignora o argumento. Isso mantém caminhos possivelmente sem uso e faz consumidores conhecerem detalhes de caminho, ausência e cache.
- **Deletion test:** Se o Module de assets for removido, carregamento, recorte, fallback, invalidação e construção de imagens reaparecem em vários renderizadores; a complexidade não desaparece.
- **Solução:** Concentrar catálogo entregue, fallback e ownership dos caches em um Module de assets. Remover caminhos inatingíveis, arrays sem uso e comentários históricos somente após confirmar os fallbacks usados; não introduzir Seam sem variação real entre Adapters.
- **Benefícios (locality/leverage/testes):** Locality para disponibilidade e invalidação de arte; Leverage para Modules visuais que consultam uma regra única; testes verificam catálogo, fallback, cache e ausência de reconstrução desnecessária.
- **Payoff:** medium
- **Risco:** medium
- **Por que agora:** A inspeção do filesystem mostrou diferença entre caminhos procurados pelo código e assets entregues, enquanto o harness acompanha contadores de cache.

## Candidato 5 — Reduzir a duplicação entre runtime e modelo de balanceamento
- **Files:** `last_horizon/tasks.pde`, `last_horizon/game.pde`, `last_horizon/night_projection.pde`, `prototype/balance-model.mjs`, `last_horizon/capture.pde`
- **Problema:** O runtime Processing e `prototype/balance-model.mjs` mantêm Implementations paralelas de ordens preventivas, problemas, consumo e ciclo diário. O Map registra que não houve comparação função a função; uma alteração pode corrigir um modelo e deixar o outro divergente.
- **Deletion test:** Se o Module ou contrato canônico for removido, catálogo, custos, perdas e ciclos continuam duplicados nas duas Implementations; a complexidade apenas volta a ser mantida separadamente.
- **Solução:** Definir uma direção para fonte rastreável das regras ou contrato verificável entre as duas Implementations. A escolha entre dados compartilhados, geração ou comparação deve vir depois da análise semântica; a Interface final não é proposta nesta triagem.
- **Benefícios (locality/leverage/testes):** Locality para regras de balanceamento; Leverage para runtime e modelo de validação; testes de comparação detectam divergência e permitem remover duplicação com preservação funcional.
- **Payoff:** high
- **Risco:** high
- **Por que agora:** A entrega depende de duas Implementations do mesmo vocabulário de domínio, e a equivalência semântica completa ainda não foi verificada.

## Candidato 6 — Isolar a resolução física de quests e navegação
- **Files:** `last_horizon/tasks.pde`, `last_horizon/movement.pde`, `last_horizon/portals.pde`, `last_horizon/ship.pde`, `last_horizon/screens.pde`, `last_horizon/capture.pde`
- **Problema:** Validação de ações, pontos de interação, portas, escadas e transições físicas usam arrays e estado compartilhados em Modules diferentes. A Interface de uma ação expõe detalhes de coordenadas, ocupação e navegação, reduzindo Depth e tornando mudanças estruturais mais arriscadas.
- **Deletion test:** Se esse Module for removido, regras de etapa, item, ponto, distância, cômodo e conclusão reaparecem entre `tasks.pde`, `ship.pde`, `movement.pde`, `portals.pde` e fixtures do harness.
- **Solução:** Aprofundar um Module que resolva a intenção de uma ação e seu resultado físico, mantendo desenho e movimento como consumidores. Identificar primeiro as regras comuns e os Adapters concretos; criar Seam apenas com variação real entre pelo menos dois Adapters.
- **Benefícios (locality/leverage/testes):** Locality para ocupação, pontos e navegação; Leverage para quests e telas; testes verificam resolução física sem depender do desenho do navio.
- **Payoff:** medium
- **Risco:** high
- **Por que agora:** É uma reorganização estrutural com impacto direto em vários chamadores e deve preservar os resultados observáveis já cobertos pelo harness.

## Candidato 7 — Separar o runtime entregue dos hooks de verificação
- **Files:** `last_horizon/last_horizon.pde`, `last_horizon/capture.pde`, `last_horizon/test_mode.pde`, `tools/snapshot-entrega.mjs`
- **Problema:** O runtime carrega hooks como `harness_setup`, `harness_update` e `harness_scene`, além de estado opcional de teste, enquanto o snapshot de entrega exclui `capture.pde` e `test_mode.pde`. A Interface do shell fica condicionada a consumidores que não fazem parte do corte final.
- **Deletion test:** Se o Module de separação for removido, lógica de verificação reaparece dentro do runtime ou é duplicada nos scripts de entrega; o papel concentra uma dependência real entre execução e validação.
- **Solução:** Definir a separação estrutural entre o Module runtime e os consumidores de verificação, mantendo o harness como Adapter de execução e validando o corte de entrega por uma rotina explícita. Remover hooks sem consumidor e comentários de histórico apenas após confirmar que o harness e a entrega preservam o mesmo comportamento.
- **Benefícios (locality/leverage/testes):** Locality para hooks e estado de teste; Leverage para o runtime entregue, que expõe menos conhecimento incidental; testes de harness e de entrega podem verificar cortes diferentes do mesmo comportamento.
- **Payoff:** medium
- **Risco:** medium
- **Por que agora:** O snapshot já define exclusões concretas, mas o shell ainda conhece hooks opcionais e a entrega precisa preservar comportamento com uma estrutura menor.

## Ranking payoff/risco
| # | Título | Payoff | Risco |
|---|---|---|---|
| 1 | Candidato 3 — Organizar ownership do estado e limpar o shell do runtime | high | high |
| 2 | Candidato 1 — Otimizar o preview noturno e as alocações por frame | high | medium |
| 3 | Candidato 2 — Remover código duplicado ou sem uso entre regras do runtime | high | medium |
| 4 | Candidato 5 — Reduzir a duplicação entre runtime e modelo de balanceamento | high | high |
| 5 | Candidato 4 — Saneiar assets, fallbacks e caches derivados | medium | medium |
| 6 | Candidato 7 — Separar o runtime entregue dos hooks de verificação | medium | medium |
| 7 | Candidato 6 — Isolar a resolução física de quests e navegação | medium | high |

## Recomendação
Candidato 3 — Organizar ownership do estado e limpar o shell do runtime. Ele é o candidato mais abrangente para o alvo informado: concentra a organização estrutural, cria um lugar verificável para remover hooks e comentários incidentais e reduz o acoplamento que dificulta otimizações e remoções posteriores. A recomendação define somente a ordem de início; a revisão completa continua incluindo performance e remoção de duplicações e código sem uso.

## Limites verificados
- A execução real do Processing e dos scripts Windows não foi repetida nesta triagem.
- Não foi feita análise completa do grafo de chamadas nem comparação função a função entre `prototype/balance-model.mjs` e o runtime Processing.
- A limpeza de comentários foi tratada como higiene dentro de Modules com papel arquitetural; comentários e documentação não foram considerados candidatos isolados.
- Nenhuma Interface final, mudança de código ou novo Adapter foi definido nesta fase.
