# Cômodos jogáveis

Este documento fecha o que `mechanics/ACTIONS.md` deixava em aberto: o objetivo,
os passos e os pontos de interação de cada cômodo. O layout é **um só esqueleto
para os quatro**: três conveses ligados por duas escadas, dentro da área de
470 × 280 px da base 640×360 (o HUD do topo, o painel da direita e o rodapé
continuam visíveis). A sala inteira cabe na tela — **não existe câmera**.

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

| Tipo | Gasta o dia | O que faz |
| --- | --- | --- |
| Leitura | não | mostra estado (rota, recursos, motor, diagnóstico) |
| Coleta | não | põe um item na mão do técnico |
| Conversa | não | o sobrevivente entrega o item ou aponta o alvo da tarefa |
| Interruptor | não | liga ou desliga um estado (economia, racionamento) |
| Conclusão | **sim** | fecha a tarefa do dia e cobra o custo |

Regras que valem em todos os cômodos:

- Alcance de interação de 12 px, na mesma altura, e o ponto se destaca quando o
  técnico entra no alcance.
- O técnico carrega **um item por vez**. O item não se perde ao virar o dia:
  continua na mão até ser entregue ou trocado por outro.
- Tarefa não concluída não custa nada; o dia vira normalmente.
- Todo ponto de conclusão cobra o custo da tarefa e usa a única ação do dia.

## Sala de comando

Nenhuma tarefa termina aqui: o cômodo é leitura e briefing.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| superior | console do briefing — urgência do dia e onde está cada sobrevivente | leitura |
| superior | Vera — assina o briefing e recalcula a rota | conversa (passo de "aumentar potência") |
| médio | console da rota — dia, jornada percorrida, dias restantes | leitura |
| inferior | painel de status — recursos, motor e vazamento | leitura |

No **dia 1** o briefing faz o papel de tutorial: duas frases sobre o loop, a
tarefa sugerida destacada e as teclas no rodapé até a primeira interação.

## Sala de energia

| Convés | Ponto | Tipo | Tarefa |
| --- | --- | --- | --- |
| inferior | bancada do motor | conclusão | reparar motor — 2 peças |
| médio | Sílvia — diagnóstico do motor e comentário da potência | conversa | passo de "reparar motor" |
| médio | painel de distribuição | interruptor | modo economia |
| superior | reator | conclusão | aumentar potência — 20 energia |

## Depósito

| Convés | Ponto | Tipo | Tarefa |
| --- | --- | --- | --- |
| inferior | prateleira do kit de vedação | coleta | passo de "reparar casco" |
| inferior | ponto do casco | conclusão | reparar casco — 1 peça |
| médio | Bento — entrega as peças ou a água da tarefa em andamento | conversa | passos de "reparar motor" e "socorrer sobrevivente" |
| médio | alavanca de racionamento | interruptor | racionamento |
| superior | prateleira de reserva | leitura | — |

## Dormitório

| Convés | Ponto | Tipo | Tarefa |
| --- | --- | --- | --- |
| inferior | beliche do sobrevivente | conclusão | socorrer sobrevivente — 5 água |
| médio | Neusa — quem está mal e onde o casco vaza | conversa | passos de "descanso e organização" e "reparar casco" |
| superior | mesa comum | conclusão | descanso e organização — 8 energia |

## As cinco tarefas

Todas passam por um sobrevivente e por pelo menos uma troca de cômodo. Só o
passo marcado como conclusão gasta o dia.

| Tarefa | Passos livres | Conclusão | Custo |
| --- | --- | --- | --- |
| Reparar motor | Sílvia dá o diagnóstico (energia) → Bento entrega 2 peças (depósito) | bancada do motor | 2 peças |
| Aumentar potência | Vera recalcula a rota (comando) | reator | 20 energia |
| Reparar casco | Neusa aponta o vazamento (dormitório) → kit de vedação (depósito) | ponto do casco | 1 peça |
| Descanso e organização | Neusa indica quem está mal (dormitório) | mesa comum | 8 energia |
| Socorrer sobrevivente | Bento entrega a água (depósito) | beliche do sobrevivente | 5 água |

De onde cada tarefa vem:

| Tarefa | Só aparece quando |
| --- | --- |
| Reparar motor | motor danificado |
| Aumentar potência | até duas vezes na viagem |
| Reparar casco | vazamento ativo |
| Descanso e organização | sempre |
| Socorrer sobrevivente | oxigênio ou moral em vermelho |

Interruptores (**modo economia** e **racionamento**) não gastam o dia: ligam e
desligam na visita ao cômodo, e a moral cobra o preço por dia enquanto estiverem
ativos.

## Leitura do jogador

O briefing do comando aponta a urgência e sugere uma tarefa, mas **nenhuma
estação fica travada**: o jogador escolhe qual cadeia cumprir hoje e paga o preço
dela. É essa escolha que `history/CONTEXT.md` chama de decidir qual perda é
aceitável.

## Implementação

A tabela de tarefas vive em `tasks.pde`, como dado: rótulo, estado que a abre
(gate), cômodo da conclusão, custo, passo intermediário e efeito. Somar uma
tarefa nova é somar uma linha na tabela e uma estação em um dos cômodos acima.
Detalhes de estilo em `code/SKETCH_ARCHITECTURE.md`.
