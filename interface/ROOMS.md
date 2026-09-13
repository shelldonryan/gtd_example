# Cômodos jogáveis

Os quatro cômodos formam uma sequência contínua inspirada na composição lateral
de `COMMAND_ROOM_CONCEPT_ART.png`. Cada um conserva três conveses e duas escadas,
mas passa a usar a largura liberada pela remoção do painel lateral. Portas nas
extremidades conectam as salas; não existe câmera nem teletransporte pelo mapa.

```
  convés superior  y≈164   [ estação ]        [ estação ]
  convés médio     y≈232   [ estação ]   esc  [ estação ]
  convés inferior  y≈300   [ estação ]   esc  [ estação ]
                            x≈150                x≈330
```

As posições acima são indicativas; o ajuste fino é da implementação, desde que
cada estação fique alcançável andando ou subindo escada. O pulo de 48 px
**não** alcança o convés de cima: trocar de nível é papel da escada.

## Pontos de interação

| Tipo | Interrompe movimento | O que faz |
| --- | --- | --- |
| Leitura técnica | sim | abre painel inferior sem retrato |
| Coleta | não | põe um item na mão e mostra aviso breve |
| Conversa | sim | abre retrato e caixa inferior do sobrevivente |
| Interruptor | sim | explica a consequência e pede confirmação |
| Ação final | não | cobra o custo, fecha a tarefa e mostra o resultado |
| Porta | não | troca para a sala adjacente pela entrada correspondente |

Regras que valem em todos os cômodos:

- Alcance de interação de 12 px, na mesma altura, e o ponto se destaca quando o
  técnico entra no alcance.
- O técnico carrega **um item por vez**. O item não se perde ao virar o dia:
  continua na mão até ser entregue ou trocado por outro.
- Tarefa não concluída não custa nada; o item continua com o técnico.
- Toda ação final cobra o custo da tarefa e usa a única tarefa do dia.
- O mapa não altera `current_room`, posição, tarefa ou item carregado.
- Indicações para portas, escadas e pontos próximos usam ações concretas, nunca
  os termos `passos livres` ou `ponto final`.

## Sala de comando

O cômodo concentra planejamento e leitura da viagem. O console de briefing é a
única origem da escolha da tarefa do dia.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| superior | console do briefing — lista tarefas disponíveis com custo, efeito e rota; exige confirmação | leitura técnica |
| superior | Vera — conversas da piloto, cabo de derivação e diagnóstico das comunicações | conversa |
| superior | antena — reparo das comunicações | ação final |
| médio | console da rota — dia, jornada percorrida, dias restantes | leitura técnica |
| inferior | painel de status — recursos, motor e vazamento | leitura técnica |

No primeiro dia, o técnico começa na Sala de comando. O console apresenta a
escolha explícita e ensina que a nave é atravessada pelas portas.

## Sala de energia

| Convés | Ponto | Tipo | Tarefa |
| --- | --- | --- | --- |
| inferior | bancada do motor | ação final | reparar motor — 2 peças; variante "resfriar regulador" — 5 água |
| médio | Sílvia — diagnóstico do motor, do suporte de vida e do sistema de energia | conversa | etapas de "reparar motor", "reparar suporte de vida", "reparar sistema de energia" e "aumentar potência" |
| médio | painel de distribuição | interruptor e ação final | modo economia; variante "trocar fusível" — 1 peça |
| superior | reator | ação final | aumentar potência — 20 energia; variante "reforçar circuito" — 10 energia |
| superior | painel de suporte de vida | ação final | reparar suporte de vida — 2 peças |

## Depósito

| Convés | Ponto | Tipo | Tarefa |
| --- | --- | --- | --- |
| inferior | prateleira do kit de vedação | coleta | etapa de "reparar casco" |
| inferior | ponto do casco | ação final | reparar casco — 1 peça |
| médio | Bento — entrega peças, água e itens das tarefas em andamento | conversa | etapas de "reparar motor", "socorrer sobrevivente", "reparar suporte de vida", "reparar comunicações" e da variante "trocar fusível" |
| médio | alavanca de racionamento | interruptor | racionamento |
| superior | prateleira de reserva | leitura técnica | — |

## Dormitório

| Convés | Ponto | Tipo | Tarefa |
| --- | --- | --- | --- |
| inferior | beliche do sobrevivente | ação final | socorrer sobrevivente — 5 água |
| médio | Neusa — quem está mal, onde o casco vaza e o cartucho refrigerante | conversa | etapas de "descanso e organização", "reparar casco" e da variante "resfriar regulador" |
| superior | mesa comum | ação final | descanso e organização — 8 energia |
| superior | beliche do técnico | leitura técnica | resumo do consumo, falhas e tarefa; confirmação para encerrar o dia |

## As oito tarefas

Todas passam por um sobrevivente e por deslocamento entre cômodos. Somente a ação
final gasta a tarefa do dia.

| Tarefa | Etapas de preparação | Ação final | Custo |
| --- | --- | --- | --- |
| Reparar motor | Sílvia dá o diagnóstico (energia) → Bento entrega 2 peças (depósito) | bancada do motor | 2 peças |
| Aumentar potência | Vera recalcula a rota (comando) | reator | 20 energia |
| Reparar casco | Neusa aponta o vazamento (dormitório) → kit de vedação (depósito) | ponto do casco | 1 peça |
| Descanso e organização | Neusa indica quem está mal (dormitório) | mesa comum | 8 energia |
| Socorrer sobrevivente | Bento entrega a água (depósito) | beliche do sobrevivente | 5 água |
| Reparar suporte de vida | Sílvia dá o diagnóstico (energia) → Bento entrega 2 peças (depósito) | painel de suporte de vida | 2 peças |
| Reparar sistema de energia | Sílvia sorteia a variante (energia) → NPC da variante entrega o item | estação da variante (energia) | conforme a variante |
| Reparar comunicações | Vera dá o diagnóstico (comando) → Bento entrega 1 peça (depósito) | antena (comando) | 1 peça |

De onde cada tarefa vem:

| Tarefa | Só aparece quando |
| --- | --- |
| Reparar motor | motor danificado |
| Aumentar potência | até duas vezes na viagem |
| Reparar casco | vazamento ativo |
| Descanso e organização | sempre |
| Socorrer sobrevivente | oxigênio ou moral em vermelho |
| Reparar suporte de vida | suporte de vida em emergência |
| Reparar sistema de energia | falha no sistema de energia ativa |
| Reparar comunicações | comunicação em silêncio |

Interruptores (**modo economia** e **racionamento**) não gastam o dia: ligam e
desligam na visita ao cômodo, e a moral cobra o preço por dia enquanto estiverem
ativos. O painel de distribuição acumula as duas funções: a ação final da variante
do fusível vale quando o técnico chega com o fusível na mão; sem o item, o ponto
continua sendo o interruptor do modo economia.

## Leitura do jogador

O console do comando apresenta somente tarefas disponíveis e mostra custo,
efeito e rota antes da confirmação. Depois da escolha, a faixa de orientação
mostra uma única próxima ação concreta. Conversar com um sobrevivente sem tarefa
ativa nunca inicia uma cadeia.

## Implementação

A tabela de tarefas vive em `tasks.pde`, como dado: rótulo, estado que a abre
(gate), cômodo da ação final, custo, etapas e efeito. Somar uma tarefa nova é
somar uma linha na tabela e uma estação em um dos cômodos acima.
Detalhes de estilo em `code/SKETCH_ARCHITECTURE.md`.

No jogo, as estações usam rótulos curtos na tela: **SUPORTE** para o painel de
suporte de vida, **DISTRIBUIÇÃO** para o painel de distribuição e **ANTENA**
para a antena das comunicações.
