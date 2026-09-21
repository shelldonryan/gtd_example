# Verificação do sketch

## Comandos no Windows

Execute na raiz do repositório, em PowerShell:

```powershell
npm.cmd run typecheck
npm.cmd run regression:windows
node prototype/balance-model.mjs --simulate
```

O runner localiza `Processing.exe` pelo PATH ou em
`C:\Program Files\Processing\Processing.exe`. Para informar outro local,
configure `PROCESSING_BIN`. A validação registrada usou Processing 4.5.6.

`regression:windows` executa quatro cenários do harness Processing:

| Cenário | Cobertura |
| --- | --- |
| `--capture` | ciclo, quests, noite, riscos, menus e cenas do harness |
| `--hit-test` | cartões de sala e transformação da janela/letterbox |
| `--ladder-test` | movimento e uso das escadas |
| `--asset-pipeline-test` | carregamento de PNG por `loadImage()` |

Para executar um cenário específico:

```powershell
npm.cmd run regression:windows -- --hit-test
```

O runner copia o sketch para uma pasta temporária dentro de
`last_horizon/output/`, executa os cenários e remove os artefatos ao terminar.
O pipeline prepara um PNG sintético de 16×16 na cópia temporária e confirma o
carregamento da imagem. Modos executados diretamente no Processing gravam
capturas em `last_horizon/output/`.

`typecheck` usa `node --check` nos módulos JavaScript do projeto. A simulação
independente avalia as sequências de incidentes com a estratégia de reserva de
peças.

## Resultados registrados em 21/09/2026

- `npm.cmd run typecheck`: passou.
- `npm.cmd run regression:windows`: passou em 4/4 cenários.
- `node prototype/balance-model.mjs --simulate`: passou em 2.520/2.520
  sequências.

## Modos adicionais

O harness pode ser executado diretamente no Processing com `--capture`,
`--hit-test`, `--ladder-test`, `--asset-pipeline-test` ou `--metrics`. Sem
argumentos, o sketch abre o jogo. O modo `--metrics` grava medições em
`last_horizon/output/`.

Para Linux, o repositório contém `tools/run-headless.sh` e
`tools/regression-final.sh`.
