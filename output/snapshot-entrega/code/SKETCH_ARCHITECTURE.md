# Arquitetura do sketch

O jogo está implementado como um sketch Processing único em `last_horizon/`.
As abas `.pde` compartilham o estado global do sketch e são compiladas juntas
pelo Processing.

## Módulos

| Arquivo | Responsabilidade |
| --- | --- |
| `last_horizon.pde` | constantes, estado global, inicialização, loop, viewport e entrada |
| `screens.pde` | estados de tela, camadas modais, menu, vinheta, pausa e desfechos |
| `ship.pde` | cômodos, pontos de interação, mapa, casco, plataformas, escadas e NPCs |
| `movement.pde`, `portals.pde`, `animation.pde`, `audio.pde` | movimento, transições, animação e efeitos sonoros |
| `tasks.pde` | catálogo e estado de quests, recursos cobrados, riscos e problemas |
| `game.pde` | calendário, incidentes, início de dia e encerramento da partida |
| `night_projection.pde` | snapshot, previsão e aplicação dos efeitos noturnos |
| `hud.pde`, `ui.pde` | cartões, objetivo/alerta, painéis, texto, botões e hit-test |
| `editorial.pde` | falas e resultados editoriais associados às quests |
| `assets.pde` | caminhos, carregamento, cache e fallback de imagens |
| `capture.pde`, `test_mode.pde` | harness e controles opcionais de verificação |

O código de domínio usa principalmente funções e tabelas globais. Classes de
dados organizam a projeção noturna, motivos de ação, caches e hooks.

## Execução e estado

`setup()` cria o buffer 1280×720, inicializa Segoe UI e carrega assets. `draw()`
calcula o fator inteiro de escala, centraliza a imagem na janela e encaminha o
desenho para a camada ativa. A grade lógica é 640×360; o render aplica 2× e o
letterbox mantém a proporção quando a janela tem outras dimensões.

O estado da partida fica em variáveis globais e tabelas. `game.pde` abre cada
dia uma vez; `tasks.pde` controla seleção, confirmação, coleta, entrega e limite
diário; `ship.pde` resolve os pontos físicos das interações. O fluxo e os
valores estão documentados em [`../interface/FLOW.md`](../interface/FLOW.md),
[`../interface/ROOMS.md`](../interface/ROOMS.md) e
[`../mechanics/ACTIONS.md`](../mechanics/ACTIONS.md).

`projectNight()` consulta `simulateNightTransition()`, que cria uma projeção a
partir de um snapshot e guarda sua assinatura de origem. O painel reutiliza a
mesma instância; `processNight()` valida a assinatura, aplica a projeção uma
única vez e invalida a prévia após a confirmação, restauração ou fechamento.

## Interface e navegação

O jogo tem quatro cômodos 2D ligados por portas. Escadas, portas, pontos e
chegadas são mantidos em tabelas no código. `E` interage com o ponto próximo;
teclado e mouse são filtrados pela camada de interface ativa.

O mapa é uma sobreposição: mostra a imagem da nave e quatro cartões de cômodo
com sala atual, objetivo e contagem de problemas.

## Assets

O loader de `assets.pde` carrega as categorias catalogadas em
[`../assets/INVENTORY.md`](../assets/INVENTORY.md). Retratos e sprites de NPC
ficam em `data/npc/`; o código também compõe painéis, cenários e objetos de
interface.

Para o técnico, o loader reconhece metadados de spritesheet Aseprite e o
formato de matriz Universal LPC. O runtime usa a spritesheet PNG e o JSON em
`data/player/`.

## Verificação

Os hooks de harness têm valores inertes no sketch base. `capture.pde` instala
os cenários automatizados e `test_mode.pde` fornece controles de teste. O
runner de Processing remove fisicamente os módulos opcionais ausentes antes da
compilação e a matriz `base`, `capture`, `manual` e `complete` fica registrada
por `tools/optional-modules.mjs`. Comandos e limites estão em
[`VERIFICATION.md`](VERIFICATION.md).

`test_mode.pde` é a única origem de Ctrl+K, teleporte e overlay manual. O
predicado visual pode destacar um ponto para inspeção, mas a disponibilidade de
interação continua sendo calculada por `tasks.pde`; o destaque não concede
pagamento, aceite, coleta, entrega ou conclusão de quest.

`tools/snapshot-entrega.mjs` cria a cópia final em `output/snapshot-entrega/`
e grava `output/snapshot-entrega-manifest.json` depois da limpeza. Ele copia
somente arquivos rastreados, aplica a lista de exclusões herdada, compila o
runtime base, verifica a ausência de controles de desenvolvimento e não altera
branches, refs ou commits. Pré-requisitos ausentes ficam registrados como
INCONCLUSIVO no manifesto.
