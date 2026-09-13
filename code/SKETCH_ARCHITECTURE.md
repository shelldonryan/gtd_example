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
| `ui.pde` | painéis, diálogos, retratos procedurais, texto, botões, hit-test e AABB |
| `hud.pde` | cartões do topo, faixa da próxima ação e rodapé |
| `screens.pde` | máquina de estados, camadas modais, menus, vinheta, pausa e desfechos |
| `ship.pde` | quatro salas conectadas, portas, mapa consultável, plataformas, escadas, NPCs e estações |
| `game.pde` | ciclo do dia, previsão e consumo, eventos e condições de término |
| `tasks.pde` | tabela, console de briefing, progressão, custos, variantes e efeitos |
| `capture.pde` | captura visual e verificações de fluxo, clique e escada |

## Camadas da revisão

- **Mapa macro:** sobreposição consultável aberta pelo botão `MAPA`; mostra a
  posição real e fichas dos cômodos, sem alterar `screen`, posição ou tarefa.
- **Salas conectadas:** portas laterais trocam para a sala adjacente e posicionam
  o técnico na entrada correspondente. Os quatro cômodos mantêm três conveses,
  duas escadas e ausência de câmera.
- **Interação:** NPCs abrem diálogo modal com retrato e caixa inferior; sistemas
  abrem painel técnico sem retrato; coletas e ações finais emitem avisos breves.
- **Tarefas como dado:** o console do comando filtra e apresenta as tarefas
  disponíveis com custo, efeito e rota. A confirmação define `active_task`; NPC
  nenhum inicia tarefa incidentalmente. A tabela continua declarando gate,
  etapas, custo, ação final e efeito.
- **Orientação:** uma faixa compacta deriva da tarefa ativa somente a próxima
  ação concreta e seu cômodo. Os termos `passos livres` e `ponto final` não
  pertencem à interface.
- **Ciclo:** o primeiro dia começa no comando; os demais, no Dormitório. O
  beliche do técnico abre o resumo e a confirmação que chamam o processamento
  diário. Não existe botão `Passar dia`.

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
- O mouse aciona apenas controles da interface, como `MAPA` e opções modais. O
  mapa preserva a sala e a posição; a movimentação entre cômodos usa portas e
  interação por `E`.
- **Camadas de input**: menu, sala jogável, mapa, diálogo, painel técnico, evento
  e pausa. Todas as camadas modais bloqueiam movimento e interação da sala.
- **ESC** é consumido pelo sketch (`key = 0`) antes de alternar a pausa; não
  encerra mais a janela.
- Enquanto há evento pendente, o modal técnico mostra as duas consequências e
  bloqueia exploração, mapa e objetivos.
- **Cursor**: `HAND` sobre controles ativos, `WAIT` sobre controles desabilitados
  e `ARROW` no restante.

## Legibilidade

O playtest inicial mostrou que 8–10 px na base eram microtexto na janela 2×. A fonte
`m5x7` e a base 640×360 continuam iguais, mas os helpers tipográficos agora usam
**16 px** para rótulos e textos quebrados, com **entrelinha de 18 px**. Os botões
tentam 16 px e reduzem somente quando a frase não cabe na largura disponível; o
limite é 10 px. `COL_MUTED` e `COL_DIM` também foram clareados para manter contraste
com o fundo.

Nenhum desenho de texto chama `g.textSize` direto: o HUD, as salas e os modais
passam por `text`, `textCentered` ou `drawTextWrapped`, que aplicam o piso de
16 px. Só `drawButton` reduz, pelo `fitTextSize`, e só quando a frase não cabe.

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

`--capture` percorre 23 estados, salva `output/NN_estado.png` em 640×360 e
`output/NN_estado_window.png` na janela, verifica navegação, mapa, briefing,
diálogo, tarefa diária, beliche, previsão de consumo, evento e regras de falha,
e encerra sozinho. `--hit-test` abre 1400×900 e prova as quatro fichas do mapa e
o letterbox. `--ladder-test` mantém os cinco casos de saída e reentrada.

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

- **Código atual:** D-048 a D-060 implementadas. As quatro salas são conectadas
  por portas; o mapa é uma sobreposição consultável; o console do comando escolhe
  a tarefa; NPCs, sistemas e eventos usam suas camadas próprias; o beliche do
  técnico encerra o dia após o resumo previsto.
- `action_used` agora bloqueia outra escolha no console depois da ação final.
- O HUD não possui painel lateral: usa cartões de recurso, faixa de próxima ação
  e botão `MAPA`.
- As oito tarefas e os sete eventos continuam com as regras de #12 e #17.
- **Textos:** os alertas operacionais migraram para avisos breves e para os
  cartões. Vinheta, transmissões e telas de vitória/derrota ainda têm as
  pendências de conteúdo registradas no #11.
