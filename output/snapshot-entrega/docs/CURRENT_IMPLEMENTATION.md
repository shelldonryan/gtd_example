# Estado atual da implementação

Esta página resume o sketch Processing em `last_horizon/`, suas mecânicas e a
validação registrada em [`../code/VERIFICATION.md`](../code/VERIFICATION.md).
Os requisitos de produto estão em
[`SPEC_ENXUGAMENTO_E_IMERSAO.md`](SPEC_ENXUGAMENTO_E_IMERSAO.md).

## Validação histórica registrada em 21/09/2026

- `npm.cmd run typecheck`: passou.
- `npm.cmd run regression:windows`: passou em quatro cenários — captura,
  hit-test, escadas e pipeline de imagem.
- `node prototype/balance-model.mjs --simulate`: passou em 2.520 sequências.
- O pipeline carrega um PNG sintético 16×16 por `loadImage()` na cópia
  temporária do sketch.

Os resultados normativos da sprint e suas limitações estão no registro de
verificação. A execução Windows permanece inconclusiva neste ambiente Linux.

## Sprint 009 — validação integrada e registro de conclusão

`BASELINE_REVISION=<commit-ou-hash> BASELINE_MANIFEST=<manifesto-exato> npm run verification:final`
é o runner canônico da entrega. Ele preserva uma
evidência individual por comando em `last_horizon/output/integrated/`, valida o
relatório de equivalência de 22 quests × 34 estados, compara três amostras nos
perfis `core-i3-integrated` e `reference`, executa a limpeza seletiva e regenera
o snapshot final.

O estado desta sessão é `INCONCLUSIVO`: a restrição operacional permitiu apenas
comandos iniciados por `git`, portanto Node.js, Bash e Processing não foram
executados. O profiling obrigatório não foi declarado pronto e o manifesto em
`output/snapshot-entrega-manifest.json` ainda é o snapshot intermediário
produzido antes da sprint 008; ele deve ser substituído pela execução final do
runner em ambiente compatível.

## Validação da sprint 005 em 22/09/2026

- `npm run typecheck`, `npm run build` e `node prototype/balance-model.mjs --simulate`: passaram.
- `bash tools/regression-final.sh`: passou nos quatro cenários headless e na limpeza.
- `last_horizon/output/equivalence-report.json`: `night-equivalence-v1`, 22 quests × 34 estados, 748/748 entradas PASS.
- O modo `--capture` confirmou projeção pura, aplicação única, invalidação de prévia obsoleta e equivalência do estado editorial e da transmissão projetada.

## Sprint 007 — harness, módulos opcionais e snapshot final

- `tools/optional-modules.mjs` define as quatro combinações de compilação:
  `base`, `capture`, `manual` e `complete`.
- `last_horizon.pde` fornece hooks inertes; `capture.pde` e `test_mode.pde`
  só entram quando a combinação os inclui. Os modos do harness continuam
  disponíveis com `capture.pde`.
- Ctrl+K, teleporte e o overlay manual continuam restritos a `test_mode.pde`.
  O destaque visual não altera `pointIsAvailable()` e não cria autorização de
  gameplay.
- `node tools/snapshot-entrega.mjs` gera a cópia final em
  `output/snapshot-entrega/` e o manifesto em
  `output/snapshot-entrega-manifest.json`. O manifesto lista exclusões,
  arquivos de runtime, a matriz de compilação, a ausência de controles de
  desenvolvimento e o estado de compilação da cópia. A execução deve ocorrer
  depois de `node tools/cleanup-verification-artifacts.mjs`.

## Jogo

- A partida dura dez dias e começa no Comando; os dias seguintes começam no
  Dormitório. A equipe tem quatro sobreviventes além do técnico.
- Os recursos iniciais são energia 80, oxigênio 85, água 80, comida 70, moral
  80 e quatro peças. Energia, oxigênio, água, comida e moral variam entre 0 e
  100; peças são contagem inteira.
- O técnico explora Comando, Sala de máquinas, Depósito e Dormitório usando
  movimento, corrida, salto, escadas, portas e pontos de interação.
  A entrada por porta prepara destino, saída, chegada, direção e retorno uma
  vez; portas com arte completa passam por abertura e fechamento, enquanto
  portas sem arte seguem pela chegada imediata. Reentradas durante a transição
  são ignoradas e o estado preparado é limpo ao entrar ou fechar.
- Dias sem incidente oferecem duas ordens preventivas. Incidentes aparecem nos
  dias 2, 4, 6, 8 e 10 e apresentam duas soluções. Uma quest pode ser concluída
  por dia; ordens e soluções usam objetos, origens e destinos definidos no
  catálogo de mecânicas.
- O encerramento do dia processa consequências da ordem, consumo, perdas dos
  problemas, riscos, prazos, crises e condições de vitória ou derrota. A
  previsão e a aplicação usam `simulateNightTransition()`; o painel guarda a
  `NightProjection` exibida e a confirmação valida sua assinatura de origem
  antes de aplicá-la uma única vez.
- O modo `--capture` grava
  `last_horizon/output/equivalence-report.json` com 22 quests × 34 estados,
  comparação campo a campo de recursos, inventário, objeto carregado,
  problemas, riscos, mortes, resultado editorial e desfecho. Cada entrada
  também valida que a projeção exibida foi aplicada ao estado global sem
  recalcular a noite; a alteração ou redução das fixtures versionadas marca a
  matriz como FAIL.
- O HUD mostra dia, tripulação, recursos, objetivo e alerta. O mapa mostra a
  nave em quatro cartões e marca sala atual, objetivo e contagem de problemas.
- `uiLayer()` resolve a prioridade única entre pausa, transmissão, incidente,
  ordens, mapa, diálogo, painel técnico, sono, ajuda e cena. O desenho, o
  cursor, o teclado, o mouse e o hit-test usam essa camada; o registro aceita
  até 24 controles por camada e registra overflow como diagnóstico.

## Código e conteúdo

- O render usa buffer 1280×720, grade lógica 640×360 e ampliação inteira. O
  texto usa Segoe UI; sprites e pixel art são desenhados sem interpolação.
- Os assets usados pelo sketch estão catalogados em
  [`../assets/INVENTORY.md`](../assets/INVENTORY.md). `assets.pde` carrega arte
  e áudio, enquanto os componentes de interface são desenhados pelo sketch.
  Os seis ícones do HUD e as faixas de piso são preparados e reutilizados por
  cache seletivo; falhas individuais usam geometria e são registradas em
  `last_horizon/output/fallback-diagnostics.jsonl`.
- As tabelas numéricas estão em [`../mechanics/ACTIONS.md`](../mechanics/ACTIONS.md)
  e os fluxos de interface em [`../interface/FLOW.md`](../interface/FLOW.md).
