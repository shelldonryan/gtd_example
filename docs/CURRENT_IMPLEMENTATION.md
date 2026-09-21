# Estado atual da implementação

Esta página resume o sketch Processing em `last_horizon/`, suas mecânicas e a
validação registrada no Windows. Os requisitos de produto estão em
[`SPEC_ENXUGAMENTO_E_IMERSAO.md`](SPEC_ENXUGAMENTO_E_IMERSAO.md).

## Validação registrada em 21/09/2026

- `npm.cmd run typecheck`: passou.
- `npm.cmd run regression:windows`: passou em quatro cenários — captura,
  hit-test, escadas e pipeline de imagem.
- `node prototype/balance-model.mjs --simulate`: passou em 2.520 sequências.
- O pipeline carrega um PNG sintético 16×16 por `loadImage()` na cópia
  temporária do sketch.

## Jogo

- A partida dura dez dias e começa no Comando; os dias seguintes começam no
  Dormitório. A equipe tem quatro sobreviventes além do técnico.
- Os recursos iniciais são energia 80, oxigênio 85, água 80, comida 70, moral
  80 e quatro peças. Energia, oxigênio, água, comida e moral variam entre 0 e
  100; peças são contagem inteira.
- O técnico explora Comando, Sala de máquinas, Depósito e Dormitório usando
  movimento, corrida, salto, escadas, portas e pontos de interação.
- Dias sem incidente oferecem duas ordens preventivas. Incidentes aparecem nos
  dias 2, 4, 6, 8 e 10 e apresentam duas soluções. Uma quest pode ser concluída
  por dia; ordens e soluções usam objetos, origens e destinos definidos no
  catálogo de mecânicas.
- O encerramento do dia processa consequências da ordem, consumo, perdas dos
  problemas, riscos, prazos, crises e condições de vitória ou derrota. A
  previsão e a aplicação usam `simulateNightTransition()`.
- O HUD mostra dia, tripulação, recursos, objetivo e alerta. O mapa mostra a
  nave em quatro cartões e marca sala atual, objetivo e contagem de problemas.

## Código e conteúdo

- O render usa buffer 1280×720, grade lógica 640×360 e ampliação inteira. O
  texto usa Segoe UI; sprites e pixel art são desenhados sem interpolação.
- Os assets usados pelo sketch estão catalogados em
  [`../assets/INVENTORY.md`](../assets/INVENTORY.md). `assets.pde` carrega arte
  e áudio, enquanto os componentes de interface são desenhados pelo sketch.
- As tabelas numéricas estão em [`../mechanics/ACTIONS.md`](../mechanics/ACTIONS.md)
  e os fluxos de interface em [`../interface/FLOW.md`](../interface/FLOW.md).
