# Contexto de sessão

## Estado do projeto

- O runtime é o sketch Processing em `last_horizon/`.
- A implementação atual está resumida em [`docs/CURRENT_IMPLEMENTATION.md`](docs/CURRENT_IMPLEMENTATION.md); requisitos de produto ficam em [`docs/SPEC_ENXUGAMENTO_E_IMERSAO.md`](docs/SPEC_ENXUGAMENTO_E_IMERSAO.md).
- O mapa desenha a nave e quatro cartões com sala atual, objetivo e contagem de problemas.
- A partida tem quatro cômodos, quatro sobreviventes além do técnico, seis recursos e dez dias. Incidentes aparecem nos dias 2, 4, 6, 8 e 10; cada dia permite concluir uma quest.
- Assets usados pelo sketch estão listados em [`assets/INVENTORY.md`](assets/INVENTORY.md).

## Validação registrada em 21/09/2026

- Windows: `npm.cmd run typecheck` passou.
- Windows: `npm.cmd run regression:windows` passou em 4/4 modos (`--capture`, `--hit-test`, `--ladder-test`, `--asset-pipeline-test`).
- `node prototype/balance-model.mjs --simulate` passou em 2.520/2.520 sequências.
- O modo de pipeline carrega um PNG sintético por `loadImage()`.

## Continuidade

- Antes de editar, confira `git status --short --branch` e preserve as alterações existentes.
- Use o código em `last_horizon/*.pde` e os arquivos existentes em `last_horizon/data/` para afirmar comportamento atual. Trate ADRs como decisões registradas e a SPEC como requisitos, não como prova de implementação.
