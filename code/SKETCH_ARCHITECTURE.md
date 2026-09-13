# Arquitetura do sketch

Este documento descreve o esqueleto inicial do ticket [#9](https://github.com/shelldonryan/gtd_example/issues/9).
Ele continua válido para o viewport, o HUD e o estado global. O mapa macro agora
abre salas 2D jogáveis, e o técnico é controlável dentro delas.


A especificação das salas — pontos de interação, as oito tarefas e os números de
movimento — está em `interface/ROOMS.md`. A implementação permanece plana e
registra esse contrato nas abas do sketch.

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
| `tasks.pde` | tabela das tarefas, gates, custos, variantes, efeitos e o despachante |
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
  e uma estação; só efeito inédito pede código novo. A tarefa de energia é o
  único caso em que o sorteio escreve na própria linha: a variante sorteada
  define item, custo, ponto de entrega e estação da conclusão.
- **Ciclo:** movimento é livre, a tarefa concluída usa a ação do dia e
  "Passar dia" aplica consumo, eventos e condições de término.

Números do movimento (base 640×360): personagem 16×24, andar 1,5 px/quadro, pulo
de 48 px, gravidade 0,5, escada 1,0, plataformas atravessáveis por baixo.

O código contém as camadas de sala jogável, movimento, colisão, interação e a
tabela de tarefas. Elas substituem o modelo em que cada ação era disparada
diretamente por um botão dentro da sala.
**Sem classes e sem hierarquia.** O Processing junta todas as abas numa classe só, então
o estilo do professor continua valendo: globais agrupadas por seção, funções curtas,
`update` separado de `draw`, `loadAssets()` centralizado quando a arte entrar.

## Estado da partida

Globais planas, todas em `last_horizon.pde`: `day`, `trip_days`, `survivors`, `energy`,
`oxygen`, `water`, `food`, `morale`, `parts`, `engine_state`, `engine_damaged_days`,
`leak_on`, `saving_on`, `rationing_on`, `life_support_emergency`, `power_fault_on`,
`comms_silent`, `power_variant`, `power_variant_used`, `action_used`, `boost_count`,
`game_over_reason`,
`current_room`, `player_x`, `player_y`, `player_velocity_y`, `player_grounded`,
`player_on_ladder`, `held_item`, `active_task` e `task_step_index`.
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

O HUD implementa os seis cartões de recurso com **ícone de 16×16 + número + barra**,
sem rótulo de texto; o cartão de quantos estão a bordo usa **A BORDO**; e o recurso
crítico pisca a borda e ganha ícone de aviso. O mapa macro não imprime nome de nave.

As capturas atualizadas ficam em `last_horizon/output/` na branch do protótipo.

## Leitura das regras (onde o vault deixou em aberto)

| Ponto | Leitura adotada |
| --- | --- |
| Moral −1 por recurso em vermelho | energia, oxigênio, água e comida entre 1 e 29 |
| Oxigênio caro (10/dia) | vale a energia do começo do dia, antes do consumo |
| Dia final com motor danificado | derrota por motor (`MENU_VICTORY.md` exige motor operante) |
| Sorteio de eventos | uniforme entre os 7, sem repetir o anterior; falha ativa fica fora do sorteio |
| Painel de distribuição | interruptor e conclusão no mesmo ponto: a conclusão vale quando o item da variante está na mão |
| Nome vazio no `MENU_INIT` | `INICIAR` desabilitado; "Técnico" só quando o campo tem espaços |

Nenhum sobrevivente vivo encerra a partida com mensagem própria: é a quinta causa
de derrota, documentada em `README.md`, `mechanics/ACTIONS.md` e
`interface/MENU_GAME_OVER.md`. O técnico não entra na conta dos quatro.

## Como rodar

Na instalação usada, `processing-java` não existe e também não existe
`C:\Program Files\Processing\runtime\bin\java.exe`. O launcher suportado é o
CLI embutido no `Processing.exe`. Os comandos abaixo são executados a partir da
raiz do repositório:

```
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --capture
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --hit-test
"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --ladder-test
```

`--capture` percorre 42 estados, salva `output/NN_estado.png` em 640×360 e
`output/NN_estado_window.png` na janela, e encerra sozinho. `--hit-test` abre
uma janela de 1400×900 e prova a conversão de clique para a base 640×360.
`--ladder-test` verifica saída lateral, travessia, encaixe, bloqueio de
reentrada enquanto a direção vertical está pressionada e rearme posterior;
também salva `output/ladder_middle_exit.png`.

Limitações observadas:

- A rota manual solicitada pelo ticket seria verificada com
  `Test-Path 'C:\Program Files\Processing\runtime\bin\java.exe'`. O resultado
  nesta instalação é `False`; portanto não há comando manual executável de
  compilação usando esse runtime. O launcher suportado é o CLI do Processing.
- A captura não usa bibliotecas externas do sketch: usa somente o core carregado
  pelo CLI e `data/m5x7.ttf`. Não há biblioteca adicional ausente bloqueando o
  harness.
- O CLI emite os avisos `display count needs to be implemented for non-AWT` e
  `AWT disabled`, mas compila, executa, salva as imagens e encerra com sucesso.
  A execução headless não foi validada nesta sessão.

## Estado da revisão

- **Código atual:** menus, mapa, salas jogáveis, movimento, escadas, colisão,
  interação, tarefas declarativas, HUD atualizado e captura automática.
- As tarefas novas (suporte de vida, sistema de energia e comunicações) e os
  eventos de falha correspondentes entraram no sketch no #17: oito tarefas, sete
  eventos e os três estados novos no painel `SISTEMA`. As variantes de energia
  são sorteadas na conversa com a Sílvia, sem repetição e só entre as pagáveis.
- **Decisões aplicadas nos documentos em 12/09:** roster (4 sobreviventes + técnico),
  quinta causa de derrota, tarefas em cadeia, layout de três conveses, números de
  movimento, nomes dos sobreviventes, vocabulário dos cômodos, ícones do HUD,
  tipografia e controles. Ver `interface/ROOMS.md` e `SESSION_START.md`.
- **Textos:** o contrato final de vinheta, transmissões, modais, alertas e
  derrotas está registrado no `issue://11` e nas fontes de interface. O sketch
  ainda contém a implementação provisória desses textos. Os cartões e as linhas
  de painel das três falhas novas são finais desde a D-047
  (`events/SYSTEM_FAULTS.md` e `interface/HUD.md`).
