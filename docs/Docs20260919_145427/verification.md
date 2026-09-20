# Verification final — E0/E6

Data: 2026-09-20
Baseline documental: `16d81f1`
Sketch: Processing 4.5.6, Java Mode
Saída: 1280×720
Grade lógica: 640×360
Escala: 2× inteira, com letterbox
Fonte: Segoe UI com suavização
Pixel art: sem interpolação

Este arquivo registra a matriz reproduzível usada na consolidação E6. O
resultado detalhado está em [E6_REPORT.md](../E6_REPORT.md), os dados estão em
[`e6-results.json`](../evidence/e6-results.json) e a verificação executável em
[`tools/e6-evidence.mjs`](../../tools/e6-evidence.mjs).

## Comandos e resultados

```text
npm run typecheck                         PASS
npm run e6:audit                          PASS — 33 contratos estáticos
npm run e6:evidence                       PASS — 12 contratos de evidência
npm run e6:compare -- baseline final      PASS — p95 -2,68%
node prototype/balance-model.mjs --simulate PASS — 2.520/2.520 sequências
git diff --check                          PASS
```

`package.json` é uma ferramenta local de verificação Node.js 20+ e não contém
dependências de aplicação. Nenhum pacote foi instalado.

## Sequência e isolamento

A campanha fixa `seed=20260919` e usa cinco posições de incidente entre sete
tipos. As fixtures de captura iniciam com `engine, hull, food, conflict,
lifeSupport`. O mapa, consultas editoriais, hit-test e cache não consomem RNG.

Cada bloco chama `beginVerificationFixture()` e `endVerificationFixture()`.
Arte, tabelas de incidentes, escadas, portas, chegadas, pontos, flags, posição,
memória editorial e estado de input são restaurados mesmo quando uma asserção
falha. O bloco seguinte começa no Comando sem resíduos.

## Fixtures e invariantes

| Fixture/modo | Invariantes | Resultado |
| --- | --- | --- |
| `--capture` | ciclo, HUD, modal, objeto, ordem e resultado | PASS — estados determinísticos |
| Portas e travessia | seis portas, quatro salas, chegada e retorno | PASS |
| Porta arbitrária | x/y fora do deck e chegada configurável | PASS |
| Arte de porta | presente, ausente e par parcial de frames | PASS — fallback funcional |
| Escadas | oito segmentos, dois por sala, três conveses | PASS |
| Hit-test | janela ampliada, letterbox e quatro fichas | PASS |
| Pipeline de assets | PNG probe 16×16 e render lógico 2× | PASS |
| NPCs | Vera, Bento, Neusa e Sílvia; vivos e mortos | PASS |
| Recursos | energia, oxigênio, água, comida, peças e moral | PASS |
| Viagem | dias 1–10; incidentes em 2, 4, 6, 8 e 10 | PASS |
| Incidentes | sete tipos; cinco sem reposição | PASS |
| Quests | 22 IDs; coleta, entrega, custo, recompensa e falha | PASS |
| Conclusão diária | uma quest por dia, incluindo socorro e retomada | PASS |
| Noite | preventiva, aceite incompleto, negligência, risco e desfecho | PASS |
| Campanhas | 2.520 permutações; reserva de peças vence todas | PASS |
| Preview e fixtures | pureza, equivalência e restauração | PASS |

## Matriz funcional obrigatória

Além dos invariantes acima, a rodada cobriu V-02, N-02, retomada, casco
aleatório, socorro, NPC morto, alvo ausente, ausência de rota, porta arbitrária,
asset ausente, transmissão sobre incidente, pausa, mapa, ajuda, teclado, mouse,
cursor e clique fora. Os 22 IDs esperados são:

```text
V-01 V-02 B-01 B-02 N-01 N-02 S-01 S-02
ENG-A ENG-B HUL-A HUL-B FOOD-A FOOD-B CON-A CON-B
LIFE-A LIFE-B PWR-A PWR-B COM-A COM-B
```

## Desempenho e retenção

`--metrics` usa aquecimento de 120 quadros e três janelas de 30 segundos. Cada
linha registra mediana, p95, carga, memória e contadores de cache. O baseline e
o final usam a mesma máquina, assets, sala, estado e janela; os resultados
estão em [`../metrics.csv`](../metrics.csv),
[`../metrics-baseline.csv`](../metrics-baseline.csv) e
[`../metrics-final.csv`](../metrics-final.csv).

O snapshot exclui `capture.pde` e `test_mode.pde`, conforme
[`snapshot-manifest.json`](../../snapshot-manifest.json). As quatro combinações
de módulos opcionais compilam. Capturas, logs e medições transitórias não são
retidos; fixtures versionadas e documentos consolidados são os únicos artefatos
permanentes.
