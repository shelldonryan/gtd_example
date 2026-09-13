# Arquitetura do sketch

Este documento descreve o esqueleto inicial do ticket [#9](https://github.com/shelldonryan/gtd_example/issues/9).
Ele continua válido para o viewport, o HUD e o estado global, mas a direção de
gameplay foi revisada: o mapa macro abre salas 2D jogáveis, e o técnico é
controlável dentro delas. O sketch atual ainda é a prova da camada de menus e
botões; não é a implementação final dessa exploração.

A especificação das salas — pontos de interação, as cinco tarefas e os números de
movimento — está em `interface/ROOMS.md`. Este documento registra como o sketch
implementa isso e o que ainda falta.

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
| `tasks.pde` | (novo) tabela das tarefas, gates, custos, efeitos e o despachante |
| `capture.pde` | prova: um PNG por estado e o teste de clique fora da IDE |

## Camadas da revisão

- **Mapa macro:** clique seleciona um cômodo e abre a cena lateral correspondente.
- **Sala jogável:** teclado controla andar, pulo e uso de escadas; colisões
  mantêm o técnico nas plataformas. Todos os cômodos usam o mesmo esqueleto de
  **três conveses e duas escadas**, dentro dos 470×280 px disponíveis, e a sala
  inteira cabe na tela — **não existe câmera**.
- **Interação:** estações e sobreviventes parados respondem quando o técnico
  alcança o ponto correto — 12 px de alcance, na mesma altura, com o ponto
  destacado. Só a interação que **conclui** a tarefa gasta a ação do dia.
- **Tarefas como dado:** a tabela de `tasks.pde` declara rótulo, gate, cômodo da
  conclusão, custo, passo intermediário e efeito. Somar tarefa é somar uma linha
  e uma estação; só efeito inédito pede código novo.
- **Ciclo:** movimento é livre, a tarefa concluída usa a ação do dia e
  "Passar dia" aplica consumo, eventos e condições de término.

Números do movimento (base 640×360): personagem 16×24, andar 1,5 px/quadro, pulo
de 48 px, gravidade 0,5, escada 1,0, plataformas atravessáveis por baixo.

O código atual ainda não contém as camadas de sala jogável, movimento,
colisão, interação ou a tabela de tarefas. Elas substituem o modelo em que cada
ação era disparada diretamente por um botão.

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

## Viewport e input

- Desenho num `PGraphics` de 640×360 (`noSmooth()`, `pixelDensity(1)`) ampliado por
  **fator inteiro** na janela, com letterbox centralizado.
- `view_scale = max(1, int(min(width / 640, height / 360)))`; a conversão que o exemplo do
  professor não tem: `base = (mouseX - offset) / view_scale`.
- No mapa macro, o mouse seleciona um cômodo. Dentro da sala, o input de
  movimento e pulo passa a controlar o técnico; o mesmo viewport converte a
  posição do personagem e dos pontos de interação para a base.
- **Camadas de input**: menu, mapa, sala jogável, evento e pausa. O evento e
  a pausa bloqueiam o movimento e as interações da sala.
- **ESC** é consumido pelo sketch (`key = 0`) antes de alternar a pausa; não
  encerra mais a janela.
- Enquanto há evento pendente, a exploração e os objetivos ficam bloqueados,
  o título vira `EVENTO PENDENTE` e a cena mostra `RESPONDA O EVENTO PARA CONTINUAR`.
- **Cursor**: `HAND` sobre controles e interações ativas, `WAIT` sobre controles
  desabilitados e `ARROW` no restante. São cursores padrão do Processing;
  nenhuma imagem foi adicionada.

## Legibilidade

O playtest inicial mostrou que 8–10 px na base eram microtexto na janela 2×. A fonte
`m5x7` e a base 640×360 continuam iguais, mas os helpers tipográficos agora usam
**16 px** para rótulos e textos quebrados, com **entrelinha de 18 px**. Os botões
tentam 16 px e reduzem somente quando a frase não cabe na largura disponível; o
limite é 10 px. `COL_MUTED` e `COL_DIM` também foram clareados para manter contraste
com o fundo.

Pendente no HUD, conforme `interface/HUD.md`: os seis cartões de recurso passam a
**ícone de 16×16 + número + barra**, sem rótulo de texto; o cartão de quantos estão
a bordo vira **A BORDO**; e o recurso em vermelho pisca a borda e ganha ícone de
aviso. O letreiro "ARES-7" do mapa macro sai — a nave não tem nome.

As capturas atualizadas ficam em `last_horizon/output/` na branch do protótipo.

## Leitura das regras (onde o vault deixou em aberto)

| Ponto | Leitura adotada |
| --- | --- |
| Moral −1 por recurso em vermelho | energia, oxigênio, água e comida entre 1 e 29 |
| Oxigênio caro (10/dia) | vale a energia do começo do dia, antes do consumo |
| Dia final com motor danificado | derrota por motor (`MENU_VICTORY.md` exige motor operante) |
| Sorteio de eventos | uniforme entre os 4, sem repetir dois dias seguidos (provisório) |
| Nome vazio no `MENU_INIT` | `INICIAR` desabilitado; "Técnico" só quando o campo tem espaços |

Nenhum sobrevivente vivo encerra a partida com mensagem própria: é a quinta causa
de derrota, documentada em `README.md`, `mechanics/ACTIONS.md` e
`interface/MENU_GAME_OVER.md`. O técnico não entra na conta dos quatro.

## Como rodar

```
"C:\Program Files\Processing\Processing.exe" cli --sketch="<caminho>\last_horizon" --run
"C:\Program Files\Processing\Processing.exe" cli --sketch="<caminho>\last_horizon" --run --capture
"C:\Program Files\Processing\Processing.exe" cli --sketch="<caminho>\last_horizon" --run --hit-test
```

`--capture` salva um PNG por estado em `output/` (o nativo 640×360 e a janela ampliada) e
encerra sozinho; `--hit-test` abre a janela em 1400×900 (fora de 16:9) e imprime a conversão
do clique para as coordenadas da base.

## Estado da revisão

- **Código atual:** menus, mapa, salas estáticas, botões e captura automática
  continuam sendo o esqueleto existente; movimento de plataforma, interação e a
  tabela de tarefas ainda precisam ser implementados.
- **Decisões aplicadas nos documentos em 12/09:** roster (4 sobreviventes + técnico),
  quinta causa de derrota, tarefas em cadeia, layout de três conveses, números de
  movimento, nomes dos sobreviventes, vocabulário dos cômodos, ícones do HUD,
  tipografia e controles. Ver `interface/ROOMS.md` e `SESSION_START.md`.
- **Arte:** tudo é retângulo e painel. Sprites entram com o ticket de assets e o pipeline.
- **Textos:** provisórios, escritos a partir do `history/CONTEXT.md`. A redação é do ticket
  de roteiro e textos.
- **Números:** cópia fiel do `ACTIONS.md` de hoje; o balanceamento ainda vai mexer neles.
