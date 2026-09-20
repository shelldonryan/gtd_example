# Relatório de validação do plano de sprints

Projeto: `last-horizon-enxugamento-imersao`  
Data da revisão: 2026-09-19  
Status geral: **AJUSTES NECESSÁRIOS — plano ainda não aprovado**

## 1. Base da revisão

Foram lidos integralmente:

- SPEC: `/home/ubuntu/pessoal/01-projetos/gtd_example/docs/Docs20260919_145427/SPEC20260919_145427.md`
- Plano: `/home/ubuntu/pessoal/01-projetos/gtd_example/docs/Docs20260919_145427/sprints20260919_145427.json`
- Estrutura do projeto e documentação de arquitetura/verificação existentes.

O relatório persistente não existia no início desta revisão e foi criado neste caminho. A SPEC contém 27 user stories, os contratos locais T01–T10, as etapas E0–E6 e os requisitos de evidência, segurança, desempenho e playtest. O plano contém 9 sprints, 33 features e dependências lineares de S1 a S9.

## 2. Cobertura da SPEC

### 2.1 Mapeamento das user stories

| ID | Cobertura no plano | Status |
| --- | --- | --- |
| US-01 | S8/feat-029 e S8/feat-025 | COBERTA |
| US-02 | S6/feat-018 e S8/feat-026 | COBERTA |
| US-03 | S6/feat-019 | COBERTA |
| US-04 | S6/feat-019 e S8/feat-027 | COBERTA |
| US-05 | S6/feat-018, S6/feat-019 e S8/feat-027 | COBERTA |
| US-06 | S6/feat-020 e S7/feat-023–024 | COBERTA |
| US-07 | S6/feat-021 e S8/feat-027 | COBERTA |
| US-08 | S7/feat-022–024 e S8/feat-029 | COBERTA |
| US-09 | S5/feat-014 e S5/feat-016 | COBERTA |
| US-10 | S5/feat-015 e S5/feat-017 | COBERTA |
| US-11 | S5/feat-016 e S5/feat-017 | COBERTA |
| US-12 | S8/feat-025 | COBERTA |
| US-13 | S8/feat-026 | COBERTA |
| US-14 | S2/feat-006 e S8/feat-027 | COBERTA |
| US-15 | S4/feat-011 e S4/feat-013 | COBERTA |
| US-16 | S2/feat-004, S2/feat-007 e S8/feat-029 | COBERTA |
| US-17 | S8/feat-028 | COBERTA |
| US-18 | S8/feat-025 e S8/feat-028 | COBERTA |
| US-19 | S2/feat-004 e S2/feat-006 | COBERTA |
| US-20 | S2/feat-005 | COBERTA |
| US-21 | S3/feat-008 | COBERTA |
| US-22 | S3/feat-009 e S3/feat-010 | COBERTA |
| US-23 | S2/feat-007 | COBERTA |
| US-24 | S4/feat-011 | COBERTA |
| US-25 | S4/feat-012 | COBERTA |
| US-26 | S4/feat-013 | COBERTA |
| US-27 | S1/feat-001–003 e S9/feat-033 | COBERTA |

### 2.2 Lacunas de cobertura

Não há user story ou contrato principal da SPEC sem uma sprint correspondente. A cobertura funcional nominal é completa.

Há, porém, três lacunas de execução que impedem considerar a cobertura suficiente para um Coder:

1. **A1 — Diretório dos artefatos de evidência não está refletido nos hints.** A SPEC determina que `baseline.md`, `verification.md`, `metrics.csv`, `playtest.md` e `visual-diff.md` sejam gravados no diretório de documentos da execução, que é `/home/ubuntu/pessoal/01-projetos/gtd_example/docs/Docs20260919_145427/`. Vários hints usam `docs/baseline.md`, `docs/verification.md` e `docs/visual-diff.md`, caminhos que não existem na árvore atual.
2. **A2 — O plano referencia `SPEC_PROGRESS.md`, que não existe no projeto.** S1 e S9 instruem a leitura desse arquivo sem fornecer caminho ou alternativa. A fonte normativa disponível é a SPEC indicada acima, além de `code/VERIFICATION.md` para comandos e limites de execução.
3. **A3 — A evidência de S9 depende de participantes e ambiente externo sem pré-condição explícita.** O playtest com três pessoas, a medição de desempenho na mesma máquina e a comparação visual precisam ser registrados como evidência manual com ambiente, responsável e artefato definidos. O plano os apresenta como critérios de aceite do Coder sem indicar como essa entrada será fornecida ou como um resultado ausente será tratado.

### 2.3 Scope creep

Não foi identificado escopo funcional fora da SPEC. Harness, Node.js, modelo numérico, snapshot de entrega, caches, playtest e documentação aparecem explicitamente na SPEC. A referência à branch e à base no metadado do projeto também está alinhada ao contexto de execução e não cria uma feature nova.

## 3. Dependências e ordem

### S1 — E0 — Reconciliação documental e baseline — **AJUSTE NECESSÁRIO**

É a dependência correta para as demais etapas. O problema é que os artefatos que S1 deve produzir não são referenciados pelos caminhos usados em S2–S9, e a instrução para ler `SPEC_PROGRESS.md` aponta para um arquivo ausente.

### S2 — E1 — Fundamentos visuais compartilhados — **ORDEM CORRETA**

Depende de S1 e precede portais, caches e integração de UI. Não há dependência circular. Deve consumir os artefatos do diretório da execução após o ajuste A1.

### S3 — E2 — Portais e caches — **ORDEM CORRETA**

Depende de S1 e S2, conforme E2 depende de E1. A dependência documental `docs/baseline.md`/`docs/verification.md` está ausente e precisa ser corrigida junto com A1.

### S4 — E3 — Camada modal, organização e módulos opcionais — **ORDEM CORRETA**

Depende das bases visuais e dos portais. A ordem respeita a necessidade de consolidar o resolvedor de camada antes de integrar telas e input. A compilação das quatro combinações de módulos opcionais precisa ser explicitada como evidência executável.

### S5 — E4A — Catálogo editorial, memória e vozes — **ORDEM CORRETA**

Depende de S4 e fornece memória e diálogo para a questline. O plano distingue corretamente o catálogo editorial do catálogo mecânico.

### S6 — E4B — Questline, retomada e socorro — **ORDEM CORRETA**

Depende de S5 porque registra resultados e reconhecimentos editoriais. A seleção, o aceite, a coleta, a entrega, a retomada e o socorro estão na ordem lógica.

### S7 — E4C/E5 — Projeção noturna e equivalência do ciclo — **ORDEM CORRETA**

Depende de S6 porque o snapshot deve incluir o estado da questline. O plano respeita a regra de compartilhar a simulação pura entre previsão e noite real.

### S8 — E5 — HUD, painéis, mapa e sono — **ORDEM CORRETA, COM RISCO DE CONCENTRAÇÃO**

Depende de todos os contratos de domínio anteriores. Não há dependência faltante, mas a sprint concentra cinco blocos grandes de interface e integração, descritos na seção 4.

### S9 — E6 — Playtest, desempenho e documentação final — **DEPENDÊNCIA EXTERNA NÃO DECLARADA**

Depende corretamente de S8, mas também exige três participantes, uma máquina comparável ao baseline e um ambiente de execução do Processing. Essas pré-condições não aparecem na lista de dependências da sprint.

Não foram encontrados ciclos de dependência.

## 4. Sizing

| ID | Features | Rounds | Avaliação |
| --- | ---: | ---: | --- |
| S1 | 3 | 2 | Realista, desde que a reconciliação documental tenha caminhos definidos. |
| S2 | 4 | 2 | No limite: quatro contratos visuais transversais, mas ainda coesos. |
| S3 | 3 | 2 | Realista, com validação de cache e portal separadas por evidência. |
| S4 | 3 | 3 | Alto risco: resolvedor modal, extração de abas e isolamento de ferramentas afetam o sketch inteiro. |
| S5 | 4 | 3 | Alto risco: 22 entradas, memória de quatro NPCs, variantes de voz e integração da interação `E`. |
| S6 | 4 | 3 | Alto risco: reúne mutações críticas de domínio, falhas atômicas, retomada e socorro. |
| S7 | 3 | 3 | Grande, mas coerente; exige separar simulação pura, aplicação real e modelo independente na evidência. |
| S8 | 5 | 3 | **Grande demais para uma sprint de três rounds**: integra HUD, cartões, painéis, mapa, introdução, sono, legibilidade e todas as dependências anteriores. |
| S9 | 4 | 3 | Grande e parcialmente externo: playtest, desempenho, regressão completa e documentação final têm naturezas diferentes. |

O ajuste mínimo recomendado é dividir S8 em dois sprints: uma sprint para HUD, ordens, detalhes e painéis técnicos; outra para mapa, introdução, sono e integração de legibilidade. O E6 atual poderia ser renumerado para S10. S5 e S6 devem permanecer separados por domínio, mas precisam de critérios de evidência mais concretos; se o limite de três rounds for rígido, cada uma deve ter seus critérios reduzidos ao conjunto essencial da etapa.

## 5. Critérios de aceite

### Critérios verificáveis

A maior parte dos critérios de S1–S8 é objetiva: contagem de IDs, campos obrigatórios, prioridades, valores, flags, combinações de módulos, ausência de débito parcial, equivalência de estados e cobertura de casos determinados. Esses critérios estão alinhados à SPEC.

### Critérios que precisam de evidência ou definição adicional

1. **Equivalência visual e preservação do baseline:** S2/feat-004, S3/feat-008, S4/feat-012 e S8/feat-029 usam “equivalente”, “preserva” ou “mantém” sem indicar captura, fixture, comando e região de comparação. A SPEC exige `visual-diff.md` com regiões permitidas e método de comparação.
2. **Compilação das combinações opcionais:** S4/feat-013 diz “compilam ou executam”. O aceite precisa escolher o comando e o resultado esperado para cada combinação: captura + teste, somente captura, somente teste e nenhum módulo opcional.
3. **Evidência numérica:** S7/feat-024 cita as 2.520 sequências, mas não aponta o comando do modelo e o artefato que registra o resultado. `code/VERIFICATION.md` documenta `node --check prototype/balance-model.mjs` e `node prototype/balance-model.mjs --simulate`; o plano deve referenciá-los.
4. **Playtest:** S9/feat-030 exige participantes, observações e notas subjetivas. Isso é verificável por relatório manual, não por código isolado. O aceite precisa declarar o artefato obrigatório e a pré-condição de disponibilidade dos participantes.
5. **Performance:** S9/feat-031 exige mesma máquina, três amostras de 30 segundos, mediana, p95 e memória. O critério é válido, mas depende de ambiente externo e precisa declarar o arquivo de métricas e a regra para execução indisponível.
6. **Auditoria documental:** S9/feat-033 usa “não contradizem o comportamento validado”. Deve indicar a matriz ou relatório que será usado para concluir essa auditoria.

Esses pontos não contradizem a SPEC; eles tornam o aceite do plano auditável e evitam que uma decisão subjetiva seja confundida com uma passagem automática.

## 6. Hints e contexto para o Coder

### Problemas de caminho

- S1 e S9 citam `SPEC_ENXUGAMENTO_E_IMERSAO.md` na raiz, mas a fonte fornecida e a SPEC lida estão em `/home/ubuntu/pessoal/01-projetos/gtd_example/docs/Docs20260919_145427/SPEC20260919_145427.md`. A cópia da raiz está fora do baseline versionado e não deve ser tratada como fonte principal.
- S1 e S9 citam `SPEC_PROGRESS.md`, ausente na árvore.
- S2, S3, S4, S5, S6, S7, S8 e S9 citam documentos em `docs/` que não existem na árvore atual. Os artefatos de execução devem ser apontados para `/home/ubuntu/pessoal/01-projetos/gtd_example/docs/Docs20260919_145427/`.
- S8 cita `docs/visual-diff.md`, ausente; o plano precisa usar o caminho do diretório da execução.

### Interfaces propostas versus existentes

O inventário do working tree confirma que alguns nomes já aparecem em abas não versionadas ou em alterações locais, enquanto outros ainda são contratos propostos da SPEC. O plano está correto ao tratar vários deles como alvos, mas os hints devem declarar essa distinção para não prometer um baseline que não existe:

- Já encontrados na árvore de trabalho: `drawShadowText`, `drawModalFooter`, `findButton`, `HUD_RESOURCE_ORDER`, `uiLayer`, `choosePreventive`, `acceptPreventive`, `collectQuestObject`, `deliverQuest`, `rescueUrgentSurvivor`, `openRescuePanel`, `currentObjectiveLine`, `currentAlertLine`, `mapTargetPoint`, `calculateMapRoute`, `findNextMapLadder`, `recordEditorialResult`, `recordEditorialRisk` e `resetEditorialMemory`.
- Ainda ausentes como operações com o contrato da SPEC no inventário: `preparePortalTransition`, `beginNpcConversation`, `simulateNightTransition` e `projectNight`. `pendingQuestReason` também precisa ser confirmado como contrato alvo, pois não foi encontrado como função correspondente no inventário.
- `last_horizon/editorial.pde` e `last_horizon/navigation.pde` aparecem como arquivos não versionados no working tree. Os hints devem marcá-los como “presentes localmente, fora do baseline confirmado”, conforme a própria SPEC.

O contexto arquitetural de S5 reconhece corretamente a mutação indevida dentro de `editorialContextLine` e `editorialPhaseLine`; esse é um bom direcionamento e deve ser preservado após os ajustes de caminho.

## 7. Ajustes necessários para discussão

### A1 — Corrigir caminhos e fonte normativa dos hints

Substituir as referências genéricas a `docs/*.md` pelo diretório de documentos da execução e substituir `SPEC_PROGRESS.md` pela SPEC fornecida e por `code/VERIFICATION.md` quando o objetivo for comando de verificação.

### A2 — Tornar a evidência parte explícita do aceite

Para os critérios visuais, de compilação, do modelo numérico e de performance, acrescentar o artefato e o comando ou fixture esperado. Para o playtest, declarar que o aceite depende de `playtest.md` preenchido com os três participantes e os campos definidos na SPEC.

### A3 — Declarar pré-condições externas de S9

Registrar no plano a disponibilidade de Processing CLI/launcher compatível, máquina comparável ao baseline e participantes do playtest. A falta dessas condições deve aparecer como evidência pendente, sem ser mascarada como aprovação automática.

### A4 — Rebalancear a integração de E5

Dividir a atual S8 em duas sprints ou apresentar uma justificativa explícita para manter cinco features grandes em três rounds. A opção recomendada é separar a integração de HUD/ordens/painéis da integração de mapa/sono/legibilidade e renumerar o E6 atual para a sprint seguinte.

### A5 — Especificar a distinção de baseline nos hints

Marcar `editorial.pde` e `navigation.pde` como arquivos presentes no working tree, porém fora do baseline versionado confirmado, e marcar os helpers ausentes como contratos propostos. Isso evita que a primeira sprint seja interpretada como se já houvesse uma implementação aprovada desses contratos.

## 8. Decisão da validação

As features da SPEC estão cobertas por pelo menos uma sprint e não há scope creep funcional identificado. O plano **não deve ser aprovado ainda** porque A1–A3 são falhas de executabilidade e A4 é um risco de sizing relevante; A5 reduz ambiguidade nos hints.

A edição do arquivo de sprints deve ocorrer somente depois de o usuário concordar com os ajustes a aplicar. Após a concordância, cada alteração será registrada aqui e confirmada no arquivo `/home/ubuntu/pessoal/01-projetos/gtd_example/docs/Docs20260919_145427/sprints20260919_145427.json`.
