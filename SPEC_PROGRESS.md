# SPEC_PROGRESS - last-horizon-enxugamento-imersao

## Status: 9/9 sprints concluídas; E6 consolidada com evidências reproduzíveis
Última atualização: 2026-09-20

---

## Sprint 001 - E0 — Reconciliação documental e baseline [CONCLUIDA]
- Inventário reconciliado de fontes e módulos: Documentar os arquivos versionados, os módulos propostos, os helpers realmente existentes e as divergências observadas entre a árvore de trabalho e o baseline confirmado.
- Baseline determinístico e fixtures de restauração: Preparar a base de verificação funcional, visual e numérica que será reutilizada pelas sprints posteriores.
- Pacote inicial de evidências e retenção: Criar os artefatos auditáveis obrigatórios para o ciclo de implementação.

## Sprint 002 - E1 — Fundamentos visuais compartilhados [CONCLUIDA]
- Núcleo comum de tipografia e sombras: Consolidar a renderização de texto com sombra e fazer os wrappers existentes delegarem ao mesmo núcleo.
- Seleção única de arte e direção de NPC: Garantir que sprite, halo cyan e halo laranja usem a mesma identidade e direção resolvidas para cada NPC.
- Rodapé comum de modais e hit-test: Consolidar o desenho e a geometria de rodapés para modais com uma ou duas ações.
- Mapeamento explícito de recursos do HUD: Implementar a ordem e o desenho dos seis recursos por mapeamento explícito.

## Sprint 003 - E2 — Portais e caches de renderização [CONCLUIDA]
- Preparação de transição de portal: Consolidar o cálculo da saída, destino, chegada, direção e retorno antes da troca de tela ou sala.
- Cache seletivo de ícones de recursos: Preparar os seis ícones na carga ou recarga explícita e manter valores dinâmicos fora do cache.
- Cache compartilhado de faixas de piso: Compartilhar faixas imutáveis de piso quando tile e largura renderizada forem iguais e invalidar apenas a faixa afetada.

## Sprint 004 - E3 — Camada modal, organização e módulos opcionais [CONCLUIDA]
- Resolvedor puro de camada modal: `uiLayer()` concentra a prioridade pausa, transmissão, incidente, ordens, mapa, diálogo, técnico, sono, ajuda e cena; renderização, teclado, mouse, cursor e hit-test usam a mesma camada.
- Separação procedural: `portals.pde`, `movement.pde` e `animation.pde` concentram a transição de portais, a coordenação do movimento e o desenho do técnico sem alterar a física ou a ordem do ciclo.
- Isolamento opcional: hooks inertes permitem compilar o runtime com ambos os módulos de desenvolvimento, apenas um deles ou nenhum; o snapshot exclui `capture.pde` e `test_mode.pde`.

## Sprint 004 - E3 — Camada modal, organização e módulos opcionais [CONCLUIDA]
- Resolvedor puro de camada modal: Criar uma única consulta de camada ativa e fazer renderização, teclado, mouse, cursor e hit-test consultarem o mesmo resultado.
- Separação procedural de abas coesas: Extrair ou criar portals.pde, movement.pde e animation.pde somente quando o inventário confirmar blocos coesos, preservando o comportamento do sketch.
- Isolamento de ferramentas de desenvolvimento: Desacoplar captura e modo de teste do runtime de entrega e validar todas as combinações de módulos opcionais.

## Sprint 005 - E4A — Catálogo editorial, memória e vozes [IMPLEMENTADA]
- Catálogo editorial completo: `last_horizon/editorial.pde` agora mantém 22 entradas ligadas por `quest_id`, com título, motivação, fala-base e fallback factual validado em até 160 caracteres.
- Memória determinística: resultados reais respeitam socorro, ajuda, falha e omissão; risco usa memória separada; reconhecimento expira após o dia seguinte e é resetado ao iniciar uma partida.
- Vozes e consultas puras: Vera, Bento, Neusa e Sílvia têm 24 variantes determinísticas por fase; `editorialContextLine`, `editorialPhaseLine` e `editorialRecognition` não mutam estado.
- Conversa opcional: `beginNpcConversation` concentra captura, contador e apresentação; narrativa e resultado mecânico usam áreas separadas; NPCs mortos não interagem.
- Verificação: o harness recebeu `checkEditorialContract()`; `e6-results.json` registra o contrato editorial como PASS e `git diff --check` passou.

## Sprint 005 - E4A — Catálogo editorial, memória e vozes [CONCLUIDA]
- Catálogo editorial 22/22 com fallback factual: Criar ou integrar o catálogo editorial ligado por quest_id ao catálogo mecânico existente.
- Memória editorial e reconhecimento de resultados: Registrar resultados reais, riscos separados e reset de memória sem alterar regras mecânicas.
- Vozes e variações determinísticas: Implementar as vozes de Vera, Bento, Neusa e Sílvia com variantes por fase da viagem.
- Abertura única de conversa opcional: Integrar a interação E com NPCs vivos a uma abertura explícita de conversa, separando narrativa e resultado mecânico.

## Sprint 006 - E4B — Questline, retomada e socorro [IMPLEMENTADA]
- Seleção preventiva por ID: `choosePreventive` aceita somente IDs presentes nas ofertas do dia sem incidente e altera apenas a seleção pendente; a UI fecha o painel depois da seleção válida.
- Razões estruturadas: `QuestActionReason` e `pendingQuestReason` cobrem recurso insuficiente, confirmação pendente, NPC/ponto incorreto, distância, estado obsoleto, limite diário, incidente bloqueante e ausência de risco.
- Revalidação atômica: aceite presencial, coleta, entrega, retomada e socorro consultam as mesmas condições da execução e preservam recursos, objeto, prazo e conclusão em qualquer falha.
- Retomada e socorro: problemas conservam solução e prazo; incidentes novos têm prioridade; o beliche de socorro permanece consultável enquanto houver risco, mesmo bloqueado por estado diário, incidente ou recursos.
- Verificação: `node --check prototype/balance-model.mjs`, `node prototype/balance-model.mjs --simulate`, a matriz Processing documentada em `e6-results.json` e `git diff --check` passaram.

## Sprint 006 - E4B — Questline, retomada e socorro [CONCLUIDA]
- Seleção preventiva e razões estruturadas: Implementar a seleção consultiva de preventivas e as consultas compartilhadas que explicam por que uma ação está ou não disponível.
- Aceite, coleta e entrega física: Implementar o fluxo de aceitar presencialmente, coletar, entregar e concluir uma quest com revalidação no instante da ação.
- Incidentes e retomada de pendências: Preservar o fluxo de soluções, perdas, prazos e retomada sem reiniciar estado ou criar segunda conclusão diária.
- Socorro urgente: Implementar a consulta e a ação de socorro com custo, prazo, bloqueios e memória editorial corretos.

## Sprint 007 - E4C/E5 — Projeção noturna e equivalência do ciclo [IMPLEMENTADA]
- Simulação pura: `simulateNightTransition` clona o estado completo e aplica uma passagem ordenada de quest, consumo, perdas, riscos, prazos, crises, clamp e desfecho, retornando estado projetado, deltas, efeitos e condições fatais.
- Preview e aplicação: `projectNight` usa somente a simulação; `processNight` simula uma vez e aplica a projeção, preservando memória editorial e transmissão apenas na confirmação.
- Equivalência: `endDay` prepara o novo dia somente depois de um resultado contínuo; o dia 10 projeta vitória e a derrota por morte só ocorre sem sobreviventes.
- Verificação: `node --check prototype/balance-model.mjs`, `node prototype/balance-model.mjs --simulate`, teste de pureza/equivalência Node, a matriz Processing e `git diff --check` passaram.

## Sprint 007 - E4C/E5 — Projeção noturna e equivalência do ciclo [CONCLUIDA]
- Simulação pura de transição noturna: snapshot profundo com entradas determinísticas, efeitos únicos, deltas, riscos, prazos, crises e condições fatais.
- Preview e aplicação real compartilhados: modal e confirmação usam a mesma projeção sem reprocessamento ou efeitos colaterais no preview.
- Equivalência numérica e desfechos: fixtures do harness cobrem pureza, arrays independentes, RNG, memória editorial, aplicação única, vitória no dia 10 e derrota por ausência de sobreviventes.

## Sprint 007 - E4C/E5 — Projeção noturna e equivalência do ciclo [CONCLUIDA]
- Simulação pura de transição noturna: Criar simulateNightTransition com snapshot completo, entradas determinísticas e uma única passagem de efeitos.
- Preview e aplicação real compartilhados: Fazer projectNight adaptar somente a simulação pura e processNight confirmar exatamente o resultado calculado.
- Equivalência numérica e desfechos: Validar o núcleo Processing contra fixtures determinísticas e preservar o modelo independente de balanceamento.

## Sprint 008 - E6 — Playtest, desempenho e documentação final [CONCLUÍDA]
- Playtest: três participantes, ordem alternada, tarefas, tempos, erros,
  reaberturas, voltas, notas, comentários e cinco critérios calculados estão em
  `docs/playtest.md`; os quatro ajustes editoriais respeitam 160 caracteres,
  vozes e balanceamento.
- Desempenho: `--metrics` registra três janelas de 30 segundos com aquecimento,
  mediana, p95, carga, memória e contadores de cache; baseline e final usam a
  mesma máquina, assets, sala, estado e janela.
- Regressão: `tools/e6-audit.mjs` passou 33 contratos estáticos,
  `tools/e6-evidence.mjs` passou a evidência E6 e o modelo Node passou sintaxe,
  simulação e 2.520/2.520 sequências. A matriz Processing, fixtures de
  restauração, preview/noite e as quatro combinações do snapshot estão em
  `docs/evidence/e6-results.json`.
- Documentação: `docs/E6_REPORT.md`, `docs/{baseline,verification,metrics,playtest,visual-diff}.*`,
  o índice da execução E0 e as fontes de regras, interface, eventos, personagens
  e arquitetura foram sincronizados; ADRs históricos foram preservados.

## Sprint 008 - E5 — HUD, painéis, mapa e sono [CONCLUIDA]
- HUD guiado por objetivo e alerta: Exibir o próximo passo e o alerta prioritário em duas linhas físicas, com consultas puras e linguagem acionável.
- Ordens, comparação e detalhes progressivos: Apresentar preventivas, soluções, pendências, custos, benefícios e consequências sem esconder dados decisivos.
- Painéis técnicos e de socorro: Integrar coleta, entrega e socorro em painéis compactos, com bloqueios factuais e feedback de sucesso.
- Mapa consultivo derivado da topologia real: Exibir salas, portas, conveses, escadas, posição, alvo e rota sem inventar geometria nem mutar gameplay.
- Introdução, sono e legibilidade em 720p: Aplicar os textos e estados de introdução e encerramento do dia respeitando o design system e os controles existentes.

## Sprint 009 - E6 — Playtest, desempenho e documentação final [CONCLUIDA]
- Playtest de compreensão e orientação: Executar e registrar o playtest com participantes que não conhecem o código, alternando a ordem das versões.
- Medição de desempenho e caches: Medir carga, quadros estabilizados, memória e contadores de cache em ambiente comparável ao baseline.
- Regressão final e snapshot de entrega: Executar a matriz completa de regressão e validar o corte final sem ferramentas de desenvolvimento.
- Documentação sincronizada e relatório auditável: Atualizar a documentação de regras, interface, eventos, personagens, arquitetura e evidências com o estado final implementado.
