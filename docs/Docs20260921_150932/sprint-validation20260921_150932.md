# Relatório de validação do plano de sprints

Projeto: `preparacao-integrada-para-entrega`  
SPEC: `docs/Docs20260921_150932/SPEC20260921_150932.md`  
Plano: `docs/Docs20260921_150932/sprints20260921_150932.json`  
Status geral: **PLANO REVISADO — aguardando gate do usuário**

## Escopo da leitura

Foram lidos integralmente a SPEC, as 9 sprints e as 34 features do plano. A estrutura existente também foi conferida, incluindo `last_horizon/`, `tools/`, `package.json`, `code/VERIFICATION.md` e os scripts de métricas, regressão, snapshot e limpeza.

## 1. Cobertura da SPEC

### 1.1 Mapeamento das user stories

| User story da SPEC | Cobertura no plano | Status |
|---|---|---|
| US-01 — renderização estática | S3: feat-009 a feat-012 | COBERTO |
| US-02 — comparação baseline/revisada | S1: feat-003; S2: feat-005 a feat-008; S9: feat-032 | COBERTO |
| US-03 — remoção de código não utilizado | S8: feat-028 e feat-030 | COBERTO |
| US-04 — consolidação de duplicações | S4: feat-016; S8: feat-028 | COBERTO |
| US-05 — remoção de comentários executáveis | S8: feat-029 e feat-030 | COBERTO |
| US-06 — organização em abas existentes | S4: feat-015; S7: feat-024 | COBERTO |
| US-07 — transição entre salas | S4: feat-013 e feat-014 | COBERTO |
| US-08 — quests e ciclo diário | S5: feat-019 e feat-020; S9: feat-031 | COBERTO |
| US-09 — previsão e aplicação noturna | S5: feat-017 e feat-018 | COBERTO |
| US-10 — modal ativo único | S6: feat-021 a feat-023 | COBERTO |
| US-11 — harness e modo de teste desacoplados | S7: feat-024 a feat-027 | COBERTO |
| US-12 — registro final | S1: feat-001; S9: feat-033 e feat-034 | COBERTO |

### 1.2 Lacunas identificadas na revisão inicial

**L-01 — Profiling obrigatório antes/depois não fecha como gate final.** A SPEC exige profiling comparável antes e depois, nos dois perfis obrigatórios, cobrindo renderização, escalonamento de imagens, alocações por quadro, preview de transições e carregamento/cache de assets, com vínculo no registro. S2/feat-008 fala em “preparar” a coleta; S9/feat-032 exige métricas de custo, mas não exige explicitamente que todos esses resultados de profiling existam, estejam identificados por perfil/versão/cenário/amostra/hotspot e sejam referenciados no registro final. A redução de custo pode acabar validada somente pelo CSV.

**L-02 — Oráculo de equivalência das quests está subespecificado.** A SPEC determina que as 22 quests e os 34 estados sejam comparados usando, em cada fixture, identificador do estado, dia, quest e etapa, recursos e inventário, objeto carregado, problemas ativos, riscos, mortes, resultado editorial e desfecho de vitória/derrota. S5/feat-019 confirma a existência e preservação da matriz, mas não exige a comparação desses campos; S9/feat-031 exige evidência individual dos cenários, sem fixar essa granularidade.

**L-03 — Timeout da simulação independente está ausente do plano operacional.** A matriz da SPEC fixa 120 segundos para `node prototype/balance-model.mjs --simulate`. S2/feat-007 lista os timeouts de typecheck, regressão/build, métricas, comparação e snapshot, mas omite o de simulação. S9/feat-031 exige executar a simulação, porém não vincula sua execução ao timeout de 120 segundos nem ao tratamento de timeout como `FAIL` quando iniciada.

**L-04 — Exclusão dos scripts históricos precisa estar operacionalmente amarrada.** A SPEC determina que `tools/e6-audit.mjs` e `tools/e6-evidence.mjs` não sejam pré-requisitos do typecheck, da regressão ou do registro final. S1/feat-002 contém essa regra, mas a descrição fala em inventário e não identifica de forma inequívoca o contrato de comandos do `package.json`. No estado atual do projeto, o script `typecheck` ainda chama os dois arquivos. O plano tem a regra, mas precisa deixar claro em qual sprint esse contrato de comandos será considerado resolvido e evidenciado.

Não foram encontradas user stories da SPEC sem qualquer sprint correspondente além dessas coberturas parciais. A matriz funcional RF-01 a RF-29 e a matriz não funcional RNF-01 a RNF-12 estão representadas no conjunto S1–S9, com os riscos de detalhamento acima.

### 1.3 Scope creep

Não foi identificado scope creep material. Inventário, baseline, profiling, matriz de compilação, snapshot e registro final são obrigações explícitas da SPEC. Não há sprint propondo banco, API, backend persistente, autenticação, engine, framework de UI, nova mecânica ou nova aba `.pde`.

## 2. Dependências e ordem

| Sprint | Dependências declaradas | Avaliação |
|---|---|---|
| S1 | nenhuma | OK |
| S2 | S1 | OK |
| S3 | S1, S2 | OK |
| S4 | S1, S2, S3 | OK |
| S5 | S1 a S4 | OK |
| S6 | S1 a S5 | OK |
| S7 | S1 a S6 | OK |
| S8 | S1 a S7 | OK |
| S9 | S1 a S8 | OK |

A ordem é acíclica e respeita os contratos: baseline precede métricas; métricas precedem otimizações; runtime precede equivalência e modal; módulos opcionais precedem limpeza final; tudo precede a validação integrada.

Há um risco de sequenciamento controlado: S7 produz uma validação de snapshot antes da limpeza lexical de S8. Como S9 exige o snapshot final novamente, o plano precisa deixar explícito que a evidência final deve corresponder ao estado posterior a S8; o snapshot de S7 não pode ser tratado como o artefato final da entrega.

Não há frontend separado, backend HTTP ou integração externa que exija uma dependência adicional.

## 3. Sizing

Nenhuma sprint ultrapassa 4 features; não há sprint com 10 ou mais features nem feature isolada trivial que evidentemente precise ser fundida.

| Sprint | Avaliação de esforço | Status |
|---|---|---|
| S1 | Inventário, baseline e registro cabem em 2 rounds, desde que o estado dos comandos seja fechado no mesmo ciclo. | OK |
| S2 | Quatro features de contrato de métricas, falhas e profiling justificam 3 rounds. | OK |
| S3 | Quatro mudanças coesas de cache/fallback em 2 rounds são plausíveis. | OK |
| S4 | Portal, organização de cinco abas e inventário/consolidação de helpers reúnem vários seams sensíveis em 3 rounds. | ATENÇÃO |
| S5 | Equivalência de quests e noite é ampla, mas os 4 critérios estão alinhados ao domínio e aos 3 rounds. | OK COM RISCO |
| S6 | Três features coesas de camada e entrada cabem em 2 rounds. | OK |
| S7 | Harness, quatro combinações, modo manual e snapshot formam um pacote grande para 3 rounds. | ATENÇÃO |
| S8 | A auditoria lexical de todos os `.pde`, `.mjs` e `.sh` somada à remoção de código é extensa, porém compatível com 3 rounds se a matriz de arquivos estiver fechada. | ATENÇÃO |
| S9 | Regressão, dois perfis, três amostras, snapshot e registro final concentram a decisão em 3 rounds. | ATENÇÃO |

Os pontos de atenção foram incorporados aos gates e artefatos de S2, S5, S7, S8 e S9. A execução ainda precisa produzir as evidências; a existência dos critérios no plano não equivale à aprovação dos resultados.

## 4. Critérios de aceite

### Critérios verificáveis

A maior parte dos critérios usa comandos, arquivos, nomes de funções, campos canônicos, contagens, status e combinações de compilação verificáveis. Os critérios de sidecar, CSV, status `PASS`/`FAIL`/`INCONCLUSIVO`, matriz de módulos e limpeza lexical estão bem definidos.

### Precisões incorporadas ao plano revisado

- S4/feat-015 registra a verificação da equivalência da organização das abas em `code/VERIFICATION.md`.
- S3/feat-011 fixa `last_horizon/output/fallback-diagnostics.jsonl` como diagnóstico canônico.
- S5/feat-019 e S9/feat-031 exigem a comparação campo a campo do oráculo completo.
- S9/feat-034 nomeia os caminhos canônicos dos CSVs, sidecars, logs, perfis, evidência funcional e manifesto final.
- S7/feat-027 identifica `tools/snapshot-entrega.mjs` como fonte da lista vigente de exclusões.

Os critérios que dependem de Processing, do notebook Core i3, do perfil de referência, de display ou de `xvfb-run` tratam corretamente a indisponibilidade como `INCONCLUSIVO` em vários pontos. O tratamento precisa ser mantido também no timeout da simulação e no gate de profiling.

## 5. Hints e contexto para execução

Os hints dos sprints posteriores referenciam os arquivos de runtime e ferramentas existentes, e as interfaces principais estão nomeadas: `preparePortalTransition()`, `NightProjection`, `uiLayer()`, `capture.pde`, `compare-metrics.mjs`, `snapshot-entrega.mjs` e os comandos do harness.

As insuficiências de contexto da revisão inicial foram resolvidas:

1. O plano nomeia os caminhos de profiling, sidecars, CSVs e logs em `last_horizon/output/`.
2. S5 referencia `last_horizon/capture.pde` como oráculo e `last_horizon/output/equivalence-report.json` como evidência.
3. O contrato de comandos do `package.json`, incluindo a exclusão dos scripts históricos do `typecheck`, aparece como interface-chave de S1/S2.

## 6. Ajustes aplicados após concordância

Os ajustes abaixo foram aplicados diretamente ao arquivo de sprints após a concordância do usuário. A ordem linear S1→S9 já respeitava as dependências; ela foi mantida e os contratos entre as sprints foram explicitados nos critérios e hints.

**A1. S2/feat-007 e S9/feat-031 — incluir o timeout da simulação.** Aplicado: 120 segundos para `node prototype/balance-model.mjs --simulate`; timeout após início é `FAIL` explícito, e pré-requisito que impeça o início é `INCONCLUSIVO`, com motivo e impacto.

**A2. S5/feat-019 e S9/feat-031 — tornar explícita a comparação do oráculo.** Aplicado: os 22 quests e 34 estados são comparados campo a campo nos atributos normativos da SPEC, e cada diferença aparece na evidência funcional e no registro final.

**A3. S2/feat-008 e S9/feat-032/034 — fechar o profiling como evidência obrigatória.** Aplicado: profiling antes e depois nos dois perfis, cobrindo os cinco grupos de hotspot da SPEC, com perfil, versão, cenário, amostra e hotspot identificados e caminho referenciado no registro final. Ausência, incompletude ou não execução mantém `INCONCLUSIVO`; falha de coleta iniciada produz `FAIL`, e a otimização não é declarada pronta sem profiling executado.

**A4. S1/feat-002 e hints de S1/S2 — explicitar o contrato do `package.json`.** Aplicado: o plano enumera os scripts atuais, explicita que nenhum dos scripts históricos `e6-audit.mjs` e `e6-evidence.mjs` permanece no `typecheck` revisado, mantém ambos rastreados nos comandos históricos, define os comandos da feature e exige que nenhum script seja removido sem a verificação de uso já prevista.

**A5. S7/S8/S9 — distinguir snapshot intermediário de snapshot final.** Aplicado: S7 produz apenas o snapshot intermediário; S9, dependente de S8, executa novamente `node tools/snapshot-entrega.mjs` e trata o manifesto pós-limpeza como único snapshot final.

**A6. S3/S4/S5/S9 — fixar artefatos nos hints.** Aplicado: o plano nomeia `last_horizon/output/fallback-diagnostics.jsonl`, a seção `code/VERIFICATION.md#Inventário de duplicações`, `last_horizon/output/equivalence-report.json`, logs em `last_horizon/output/<versao>/<perfil>/<cenario>/<amostra>.log`, perfis em `last_horizon/output/profiling/<versao>/<perfil>/<cenario>/<amostra>.json`, CSVs/sidecars em `last_horizon/output/<versao>/<perfil>/` e `output/snapshot-entrega-manifest.json`.

## 7. Decisão após revisão

O plano revisado cobre as 12 user stories da SPEC, não apresenta scope creep nem dependência circular, e os quatro bloqueios identificados foram tratados nos critérios, hints e contratos de dependência. O gate final continua condicionado à execução efetiva das evidências: profiling obrigatório nos dois perfis, comparação campo a campo, simulação com timeout e snapshot pós-limpeza.

O arquivo `sprints20260921_150932.json` foi editado diretamente. A validação estrutural confirmou JSON válido, 9 sprints, 34 features únicas e a cadeia de dependências S1→S9 completa. O plano está apresentado para o gate do usuário; ainda não deve receber o marcador de fase concluída antes da confirmação de aprovação.

## 8. Confirmação das alterações no plano

| Ajuste | Sprints/features | Alteração confirmada |
|---|---|---|
| A1 | S2/feat-007; S9/feat-031 | Timeout de 120s, comando explícito e tratamento `FAIL`/`INCONCLUSIVO` com diagnóstico. |
| A2 | S5/feat-019; S9/feat-031/033 | Comparação campo a campo dos 22 quests e 34 estados e registro de cada diferença. |
| A3 | S2/feat-008; S9/feat-032/033/034 | Gate obrigatório de profiling antes/depois, nos dois perfis e cinco hotspots, com caminhos e decisão final. |
| A4 | S1/feat-002; S2/feat-007 e hints | Scripts históricos identificados, comandos da feature enumerados e remoção condicionada à verificação de uso. |
| A5 | S7/feat-027; S9/feat-034 | Snapshot de S7 marcado como intermediário; snapshot final regenerado após S8. |
| A6 | S2/S3/S4/S5/S9 | Caminhos canônicos dos CSVs, sidecars, profiling, diagnósticos, inventário, equivalência e manifesto documentados. |
