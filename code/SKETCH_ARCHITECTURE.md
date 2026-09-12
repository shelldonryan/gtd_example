# Arquitetura do sketch

Decisão do ticket [#9](https://github.com/shelldonryan/gtd_example/issues/9). Como o
código do Last Horizon se organiza, onde vivem os números do jogo e como o clique
chega aos botões com a janela escalada.

## Onde o código mora

`last_horizon/` na branch `prototype/sketch-architecture`. A pasta é o pacote da
disciplina: `last_horizon.pde` + abas + `data/` (fonte) + `output/` (PNGs de prova).
Quando a arquitetura for validada com playtest, a pasta sobe para a `main` como está.

## Abas

| Aba | O que tem |
| --- | --- |
| `last_horizon.pde` | canvas, telas, ações, regras, paleta, estado da partida, viewport, input |
| `ui.pde` | painéis, texto, texto com quebra de linha, botões, hit-test e AABB |
| `hud.pde` | cartões do topo, painel de alertas, rodapé |
| `screens.pde` | máquina de estados, menu inicial, vinheta, pausa, vitória, derrota |
| `ship.pde` | nave em vista lateral com os 4 cômodos clicáveis e o interior de cada sala |
| `game.pde` | ciclo do dia, consumo, ações, eventos, fim de jogo |
| `capture.pde` | prova: um PNG por estado e o teste de clique fora da IDE |

**Sem classes e sem hierarquia.** O Processing junta todas as abas numa classe só, então
o estilo do professor continua valendo: globais agrupadas por seção, funções curtas,
`update` separado de `draw`, `loadAssets()` centralizado quando a arte entrar.

## Estado da partida

Globais planas, todas em `last_horizon.pde`: `day`, `trip_days`, `survivors`, `energy`,
`oxygen`, `water`, `food`, `morale`, `parts`, `engine_state`, `engine_damaged_days`,
`leak_on`, `saving_on`, `rationing_on`, `action_used`, `boost_count`, `game_over_reason`.
Nenhuma tela recebe parâmetro: todas leem e escrevem as mesmas globais — é assim que o
dia, os recursos e o motor atravessam as telas.

## Números

`mechanics/ACTIONS.md` continua a fonte única. O código copia os valores numa seção
`/* regras - mechanics/ACTIONS.md */` no topo de `last_horizon.pde`, em constantes
`UPPER_SNAKE` — mexeu no vault, mexe no código. O ajuste fino é do ticket de
balanceamento.

## Clique e viewport

- Desenho num `PGraphics` de 640×360 (`noSmooth()`, `pixelDensity(1)`) ampliado por
  **fator inteiro** na janela, com letterbox centralizado.
- `view_scale = max(1, int(min(width / 640, height / 360)))`; a conversão que o exemplo do
  professor não tem: `base = (mouseX - offset) / view_scale`.
- Botões registram o **centro** e o teste é o `checkRectOverlap()` (AABB por centro) do
  professor. Os botões são remontados a cada quadro durante o `draw`; o clique do quadro
  seguinte testa a lista montada.
- **Camadas de input**: cena, evento e pausa. O cartão de evento bloqueia as ações do dia
  e a pausa bloqueia todo o resto — só os botões da camada do topo respondem.
- **ESC** é consumido pelo sketch (`key = 0`) antes de alternar a pausa; não encerra mais a janela.
- Enquanto há evento pendente, os cômodos e `PASSAR DIA` ficam apagados, o título vira
  `EVENTO PENDENTE` e a cena mostra `RESPONDA O EVENTO PARA CONTINUAR`.

## Legibilidade

O playtest inicial mostrou que 8–10 px na base eram microtexto na janela 2×. A fonte
`m5x7` e a base 640×360 continuam iguais, mas os helpers tipográficos agora usam
**16 px** para rótulos e textos quebrados. Os botões tentam 16 px e reduzem somente
quando a frase não cabe na largura disponível; o limite é 10 px.
`COL_MUTED` e `COL_DIM` também foram clareados para manter contraste com o fundo.

As capturas atualizadas ficam em `last_horizon/output/` na branch do protótipo.

## Leitura das regras (onde o vault deixou em aberto)

| Ponto | Leitura adotada |
| --- | --- |
| Moral −1 por recurso em vermelho | energia, oxigênio, água e comida entre 1 e 29 |
| Oxigênio caro (10/dia) | vale a energia do começo do dia, antes do consumo |
| Dia final com motor danificado | derrota por motor (`MENU_VICTORY.md` exige motor operante) |
| Sorteio de eventos | uniforme entre os 4, sem repetir dois dias seguidos (provisório) |
| Nome vazio no `MENU_INIT` | `INICIAR` desabilitado; "Técnico" só quando o campo tem espaços |

Nenhum sobrevivente vivo também encerra a partida (a vitória exige 1 ou mais vivos).

## Como rodar

```
"C:\Program Files\Processing\Processing.exe" cli --sketch="<caminho>\last_horizon" --run
"C:\Program Files\Processing\Processing.exe" cli --sketch="<caminho>\last_horizon" --run --capture
"C:\Program Files\Processing\Processing.exe" cli --sketch="<caminho>\last_horizon" --run --hit-test
```

`--capture` salva um PNG por estado em `output/` (o nativo 640×360 e a janela ampliada) e
encerra sozinho; `--hit-test` abre a janela em 1400×900 (fora de 16:9) e imprime a conversão
do clique para as coordenadas da base.

## O que ainda não é definitivo

- **Arte:** tudo é retângulo e painel. Sprites entram com o ticket de assets e o pipeline.
- **Textos:** provisórios, escritos a partir do `history/CONTEXT.md`. A redação é do ticket
  de roteiro e textos.
- **Números:** cópia fiel do `ACTIONS.md` de hoje; o balanceamento ainda vai mexer neles.
