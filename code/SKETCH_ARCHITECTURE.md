# Arquitetura do sketch

Este documento descreve o esqueleto inicial do ticket [#9](https://github.com/shelldonryan/gtd_example/issues/9).
Ele continua válido para o viewport, o HUD e o estado global. O mapa macro agora
abre salas 2D jogáveis, e o técnico é controlável dentro delas.


A especificação vigente das salas e intervenções está em `interface/ROOMS.md`.
O sketch permanece plano, mas ainda implementa o ciclo anterior às decisões
D-073 a D-096.

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

## Pipeline de assets

- A origem Aseprite, quando disponível, pode permanecer em `last_horizon/data/`
  junto das exportações. O runtime não depende do arquivo `.aseprite`.
- Para qualquer animação do jogo, a exportação oficial usa uma spritesheet única
  em PNG com JSON de metadados; não há PNG separado por quadro.
- O sketch carrega os assets de produção com `loadImage()` e
  `loadJSONObject()` em `loadPlayerAssets()` durante `setup()`. A pasta `data/`
  é o diretório de assets do Processing.
- `player_sheet.png` mede 640×64 e contém 10 quadros de 64×64.
- `player_sheet.json` registra `idle` nos quadros 0–1 e `walk` nos quadros 2–9,
  com 500 ms por quadro parado e 100 ms por quadro em movimento.
- `playerCurrentFrame()` soma as durações da faixa selecionada e usa módulo
  pelo total para repetir `idle` e `walk` continuamente.
- A física mantém o personagem em 16×24 na grade lógica. O quadro visual é
  desenhado em 32×32 lógicos e centralizado sobre a caixa de colisão.
- A direção usa `player_facing`: `1` para a direita e `-1` para a esquerda.
  O valor acompanha A/D e setas, é espelhado na camada sem interpolação e é
  redefinido conforme a entrada pela porta ou o reinício da sala.
- Se o carregamento falhar, `drawPlayerFallback()` preserva a execução e a
  caixa física, sem alterar o contrato de movimento.
- O modo de prova `--asset-pipeline-test` continua separado dos assets do jogo.
- `pipeline_probe.aseprite` e `pipeline_probe_frame_1.png` são o fixture do
  ticket #10, não assets finais nem convenção de produção. O probe tem 16×16
  pixels e é exibido duas vezes na grade lógica, no render físico 1280×720.
- O modo de prova prepara uma camada `PGraphics` sem interpolação antes de
  `beginDraw()`. A camada é composta no buffer principal, preservando a
  suavização do texto.
- A prova do pipeline é:
  `"C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --asset-pipeline-test`
  Ela salva `last_horizon/output/pipeline_probe.png` e
  `pipeline_probe_window.png`.


## Contrato de gameplay ainda não implementado

O próximo ciclo remove o briefing e o `active_task` como porta de entrada do
trabalho. Incidentes alternados criam problemas locais persistentes; cada um
possui perda diária, prazo e crise. Uma intervenção principal por dia pode
corrigir, recuperar ou acelerar, enquanto diagnóstico, componente especial e
políticas permanecem livres.

A Sala de comando vira o hub com uma porta por convés: Dormitório no superior,
Depósito no médio e Sala de máquinas no inferior. O HUD mostra o problema mais
urgente e o mapa reúne todos por sala. Recursos comuns são pagos na intervenção;
somente componentes especiais são carregados.
D-097 já foi aplicada isoladamente ao protótipo anterior: quando meteoros rompem
o casco, o sketch sorteia um dos quatro cômodos e um ponto livre alcançável em
um dos três conveses, evitando estações fixas. O destino de `Reparar casco`
acompanha o ponto sorteado, e o evento não volta ao pool enquanto o vazamento
estiver ativo.

Perdas, prazos, crises, custos e benefícios dos sobreviventes ainda dependem do
protótipo de balanceamento. O restante de D-073 a D-096 não foi migrado.

## Implementação atual anterior ao redesign

- **Mapa macro:** sobreposição consultável aberta pelo botão `MAPA`; mostra a
  posição real, fichas dos cômodos e somente o destino final da tarefa ativa,
  sem alterar `screen`, posição ou tarefa.
- **Salas conectadas:** portas laterais trocam para a sala adjacente e posicionam
  o técnico na entrada correspondente. Os quatro cômodos mantêm três conveses,
  duas escadas e ausência de câmera.
- **Interação:** NPCs abrem diálogo modal com retrato e caixa inferior; `ENTER`
  avança diálogos e confirma o briefing; sistemas abrem painel técnico sem
  retrato; coletas e ações finais emitem avisos breves.
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

Números do movimento (grade lógica 640×360; render 1280×720 / 720p): personagem 16×24, andar 1,5 px/quadro, pulo
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

`mechanics/ACTIONS.md` continua sendo a fonte de regras, mas agora contém o
contrato futuro e marca os números que exigem novo balanceamento. As constantes
atuais do sketch ainda correspondem ao protótipo anterior; não devem ser
tratadas como implementação das decisões D-073 a D-096.

## Viewport e input

- O buffer de render é 1280×720 (720p). A grade lógica 640×360 é usada apenas
  para posicionamento e é transformada por 2×; a janela mantém ampliação inteira
  e letterbox centralizado.
- `view_scale = max(1, int(min(width / 1280, height / 720)))`; a conversão da
  janela para a grade lógica divide também pelo fator 2.
- O mouse aciona apenas controles da interface, como `MAPA` e opções modais. O
  mapa preserva a sala e a posição; a movimentação entre cômodos usa portas e
  interação por `E`.
- **Teclas modais:** `ENTER` avança diálogos e confirma a tarefa selecionada no
  briefing; `E` interage com pontos da sala e não confirma o briefing.
- Os botões repetem no próprio rótulo os atalhos disponíveis: `INICIAR (ENTER)`,
  `CONTINUAR (ENTER)`, `CONTINUAR (ESC)`, `CONFIRMAR (ENTER)`,
  `ENCERRAR DIA (ENTER)`, `VOLTAR (ESC)` e `FECHAR (ESC)`.
- **Camadas de input**: menu, sala jogável, mapa, diálogo, painel técnico, evento
  e pausa. Todas as camadas modais bloqueiam movimento e interação da sala.
- **ESC** é consumido pelo sketch (`key = 0`) antes de alternar a pausa; não
  encerra mais a janela.
- Enquanto há evento pendente, o modal técnico mostra as duas consequências e
  bloqueia exploração, mapa e objetivos.
- **Cursor**: `HAND` sobre controles ativos, `WAIT` sobre controles desabilitados
  e `ARROW` no restante.

## Legibilidade

O playtest inicial mostrou que 8–10 px na base eram microtexto na janela 2×. A
tipografia visível é **Segoe UI**, instalada no Windows, criada com suavização e
renderizada no buffer 1280×720 (720p); a grade lógica 640×360 continua
organizando as posições.
Assets pixel art, quando entrarem, devem usar amostragem sem interpolação. A
regra de suavização do texto não se aplica a esses assets.
Os helpers tipográficos usam **16 px** para leitura, com **entrelinha de 18 px**.
Os botões tentam 16 px e reduzem somente quando a frase não cabe na largura
disponível; o limite é 10 px. `COL_MUTED` e `COL_DIM` também foram clareados
para manter contraste com o fundo.

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

`--capture` percorre 23 estados, salva `output/NN_estado.png` em 1280×720 (720p) e
`output/NN_estado_window.png` na janela, verifica navegação, mapa, briefing,
diálogo, tarefa diária, beliche, previsão de consumo, evento, regras de falha e
o sorteio alcançável do dano no casco, e encerra sozinho. `--hit-test` abre
1400×900 e prova as quatro fichas do mapa e o letterbox. `--ladder-test` mantém
os cinco casos de saída e reentrada.

Limitações observadas:

- A rota manual solicitada pelo ticket seria verificada com
  `Test-Path 'C:\Program Files\Processing\runtime\bin\java.exe'`. O resultado
  nesta instalação é `False`; portanto não há comando manual executável de
  compilação usando esse runtime. O launcher suportado é o CLI do Processing.
- A captura não usa bibliotecas externas do sketch: usa somente o core carregado
  pelo CLI e a família Segoe UI instalada no Windows. Não há biblioteca adicional
  ausente bloqueando o harness.
- O CLI emite os avisos `display count needs to be implemented for non-AWT` e
  `AWT disabled`, mas compila, executa, salva as imagens e encerra com sucesso.
  A execução headless não foi validada nesta sessão.

## Estado da revisão

- **Código atual:** D-048 a D-072 e D-097 estão implementadas. O dano no casco
  sorteia um ponto livre alcançável nos quatro cômodos e atualiza o destino da
  correção; enquanto ativo, fica fora do pool. As salas ainda formam a sequência
  linear Comando → Energia → Depósito → Dormitório; o console do Comando ainda
  escolhe `active_task`; NPCs e coletas ainda compõem cadeias universais; eventos
  continuam diários e algumas respostas resolvem a falha no cartão.
- **Contrato confirmado, ainda ausente do código:** D-073 a D-096 definem
  problemas persistentes, incidentes alternados, intervenção principal,
  topologia em hub, recursos pagos no ponto, recuperação e socorro separados,
  aceleração real e prioridades no HUD/mapa.
- O beliche já encerra o dia após o resumo, mas ainda não processa perdas, prazos
  e crises do novo modelo.
- Os números atuais, `active_task`, `held_item`, `action_used`, a tabela de
  tarefas e as verificações de captura precisam ser redesenhados somente depois
  do balanceamento.
- **Textos:** vinheta, transmissões e telas de vitória/derrota continuam com as
  pendências de conteúdo registradas no #11.
