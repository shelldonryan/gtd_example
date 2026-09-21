# Visual diff — E6

Resultado registrado na campanha E6: **concluído**. A comparação usou a mesma máquina, Processing 4.5.6,
fonte Segoe UI, assets `assets@16d81f1`, viewport 1280×720, escala lógica 2×,
estado `seed=20260919;day=1;room=Comando` e as mesmas fixtures antes/depois.

As regiões permitidas foram HUD, rodapé, ordens, incidente, diálogo, painel
técnico, sono, mapa, ajuda, transmissão e textos editoriais. Salas, colisões,
recursos, controles, fallbacks e módulos opcionais ficaram protegidos. A
comparação foi aceita porque as diferenças ficaram nas regiões permitidas e
preservaram os valores mecânicos, os hit-tests e a topologia.

## Registro

| Campo | Valor |
| --- | --- |
| Baseline | `16d81f1` |
| Final | working tree E6 |
| Fixture | `visual__deterministic__20260919` |
| Viewport | 1280×720; lógica 640×360 |
| Regiões protegidas | salas, portas, escadas, colisões, recursos, controles, fallbacks |
| Resultado | PASS |

Esse diff compara o baseline com a working tree da campanha em 20/09/2026 e não
foi repetido para o checkout atual. As capturas transitórias não são retidas no repositório. A campanha final usa
`tools/cleanup-verification-artifacts.mjs` para remover `last_horizon/output/`
após a consolidação. O contrato funcional
continua em [verification.md](verification.md), o resultado de desempenho está
em [metrics.csv](metrics.csv) e a matriz estruturada está em
[e6-results.json](evidence/e6-results.json).
