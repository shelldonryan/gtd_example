# E6 — Playtest, desempenho e documentação final

Data da consolidação: 2026-09-20
Baseline: `16d81f1`, reconciliado em [baseline.md](Docs20260919_145427/baseline.md)
Resultado registrado naquela campanha: **PASS — evidência E6 consolidada**.

**Limite atual:** este relatório descreve a campanha de 20/09/2026 e não valida
automaticamente o checkout de 21/09/2026. A revisão estática atual encontrou
diferenças entre os resultados narrados e o código, inclusive a ausência da
orientação por escadas descrita em A2. Nenhum build, harness, playtest ou diff
visual foi repetido nesta revisão. Consulte o
[estado atual do código](CURRENT_IMPLEMENTATION.md) antes de usar este PASS como
critério de aceite vigente.

Os artefatos permanentes são [baseline](baseline.md), [verification](verification.md),
[metrics](metrics.csv), [playtest](playtest.md) e [visual-diff](visual-diff.md).
Os dados estruturados que alimentam as verificações estão em
[e6-results.json](evidence/e6-results.json); o verificador é
[`tools/e6-evidence.mjs`](../tools/e6-evidence.mjs).

## Método e ambiente

A campanha usou Processing 4.5.6/Java Mode, Linux x86_64, Segoe UI, os assets
`assets@16d81f1`, viewport 1280×720, grade lógica 640×360, escala inteira 2×,
sala Comando, dia 1 e seed 20260919. Baseline e final usaram a mesma máquina,
assets, sala, estado determinístico e janela. Não foram instaladas dependências;
`package.json` contém apenas scripts nativos de verificação Node.js 20+.

As verificações executáveis da consolidação são:

```text
npm run typecheck
npm run e6:audit
npm run e6:evidence
npm run e6:compare -- docs/metrics-baseline.csv docs/metrics-final.csv
node prototype/balance-model.mjs --simulate
git diff --check
```

O relatório registra resultados numéricos em `docs/metrics.csv`, os três
participantes e observações em `docs/playtest.md`, e as fixtures funcionais em
`docs/evidence/e6-results.json`. O método de comparação visual e suas regiões
protegidas estão em [visual-diff.md](visual-diff.md).

## Resultados por critério

| Critério | Evidência | Resultado |
| --- | --- | --- |
| Três participantes, tarefas e observações | [playtest.md](playtest.md) | **PASS** — P1/P2/P3, tempos, erros, reaberturas, voltas, notas e comentários |
| Cinco critérios de compreensão | [playtest.md](playtest.md), `successCriteria` | **PASS** — 2/3, 3/3, 2/3, 2/3 e 2/3 |
| Ajustes editoriais | [playtest.md](playtest.md), `editorialAdjustments` | **PASS** — quatro ajustes, todos ≤160 caracteres, sem mudança mecânica |
| Três amostras de desempenho | [metrics.csv](metrics.csv) | **PASS** — três amostras de 30 s por fase, mediana, p95, carga, memória e caches |
| Comparação equivalente | [metrics.csv](metrics.csv) | **PASS** — mesma máquina, assets, sala, estado e janela |
| Regressão p95 | [metrics-baseline.csv](metrics-baseline.csv), [metrics-final.csv](metrics-final.csv) | **PASS** — mediana do p95 caiu de 22,4 ms para 21,8 ms (-2,68%); investigação não acionada |
| Caches | `checkCacheContract()`, `cacheContract` | **PASS** — seis ícones, uma faixa imutável compartilhada e invalidação seletiva |
| Matriz funcional | [verification.md](Docs20260919_145427/verification.md), `functionalCoverage` | **PASS** — salas, sobreviventes, recursos, dias, incidentes, quests, limite diário e objeto |
| Cenários especiais | `specialScenarios`, harness Processing | **PASS** — V-02, N-02, retomada, casco, socorro, NPC morto, alvo/rota, porta, asset, modais e input |
| Snapshot | [snapshot-manifest.json](snapshot-manifest.json), `snapshot-entrega.mjs` | **PASS** — `capture.pde` e `test_mode.pde` excluídos; quatro combinações opcionais compilam |
| Modelo e fixtures | `prototype/balance-model.mjs`, `e6-results.json` | **PASS** — modelo, restauração e contratos de preview/noite sem resíduos |
| Documentação e índices | [README](Docs20260919_145427/README.md), SPEC e fontes de domínio | **PASS** — T01–T10, E0–E6, 27 user stories e matriz ligados |

## Implementação validada

- `capture.pde` restaura tabelas, arte, flags, posição e sequência em cada
  fixture, inclusive no caminho de falha; `checkCacheContract()` verifica seis
  fontes e a faixa compartilhada.
- `--metrics` grava três janelas de 30 segundos após aquecimento, com mediana,
  p95, carga, memória e `resource_icon_builds`, `deck_strip_builds` e
  `cache_invalidations`.
- `tools/compare-metrics.mjs` calcula as medianas das amostras e falha com
  `INVESTIGATE` quando o p95 final excede o baseline em mais de 10%.
- `tools/e6-audit.mjs` valida 33 contratos estáticos. `tools/e6-evidence.mjs`
  valida os resultados de playtest, métricas, caches, matriz, cenários e
  snapshot.
- O snapshot final exclui os módulos de desenvolvimento e está descrito em
  `snapshot-manifest.json`; o runtime mantém hooks inertes para compilar com
  zero, um ou dois módulos opcionais.

O limite de regressão é explícito: `tools/compare-metrics.mjs` imprime
`INVESTIGATE` e falha quando a variação consistente do p95 ultrapassa 10%. A
comparação desta rodada ficou em -2,68%, por isso a investigação condicional
não foi acionada; o resultado e o método estão registrados nos dois CSVs e no
relatório.

## Rastreabilidade e documentação

Os contratos T01–T10 estão na [SPEC normalizada](Docs20260919_145427/SPEC20260919_145427.md);
as etapas E0–E6 estão na [SPEC detalhada](../SPEC_ENXUGAMENTO_E_IMERSAO.md).
O arquivo `SPEC_PROGRESS.md` citado em versões anteriores não existe neste
checkout. As 27 user stories e a matriz de rastreabilidade permanecem na seção
5.6 da SPEC normalizada.

O índice aponta para `mechanics/`, `interface/`, `events/`, `characters/`,
`code/`, `assets/` e `docs/adr/`. Os ADRs históricos foram preservados. A
referência ao `package.json` foi reconciliada: ele existe como ferramenta de
verificação local e não introduz dependências de aplicação. Capturas, logs e
arquivos temporários não fazem parte do pacote final. A consolidação executa
`tools/cleanup-verification-artifacts.mjs` no início e na saída da campanha;
as fixtures de pipeline e os documentos acima são as únicas evidências retidas.
