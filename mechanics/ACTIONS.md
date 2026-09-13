# Ações e custos

Números do protótipo. Este arquivo é a fonte única: as telas e os eventos
descrevem as escolhas, mas não repetem valores.

## Regras base

| Regra | Valor |
| --- | --- |
| Recursos em barra | energia, oxigênio, água, comida, moral — de 0 a 100 |
| Peças | contagem inteira |
| Sobreviventes | 4 a bordo; o técnico não entra na conta |
| Duração | 10 dias |
| Estoque inicial | 100 em cada barra e 6 peças |
| Tarefas por dia | 1 em cadeia, além de "Passar dia" |
| Eventos | 1 por dia, a partir do dia 2 |

Decisões fixadas neste arquivo:

- **Energia é um estoque único**, consumido para manter o motor e o suporte de
  vida. Não existe combustível separado: a barra de energia é esse estoque.
- **Modo economia e racionamento são estados**, ligados e desligados durante a
  visita ao cômodo. Não gastam a ação do dia; a movimentação e os passos
  intermediários das tarefas também não. Só a **conclusão** da tarefa em cadeia
  gasta a única ação do dia.
- **"Passar dia" fica no rodapé**, visível em qualquer tela. A sala de comando
  é a tela de leitura da viagem.

## Consumo ao passar o dia

| Recurso | Consumo | Observação |
| --- | --- | --- |
| Energia | 6 | motor e suporte de vida; 3 com modo economia |
| Oxigênio | 5 | 10 se a energia estiver abaixo de 30 |
| Água | 8 | 4 com racionamento |
| Comida | 7 | 3 com racionamento |
| Moral | 2 | mais 1 por recurso em vermelho (de 1 a 29) |

O dia abre com o evento: o jogador responde e depois entra em um cômodo,
movimenta o técnico pela cadeia da tarefa e conclui a interação final. Andar,
pular, usar escada e cumprir os passos intermediários não gastam a ação; a
conclusão gasta a única ação do dia. Ao apertar "Passar dia", os recursos são
consumidos, a moral é atualizada, o dia avança e o jogo verifica vitória e
derrota.

A resposta do evento **não** gasta a ação do dia.

## Tarefas por dia

Uma tarefa por dia, em **cadeia**: cada uma passa por um sobrevivente e por pelo
menos uma troca de cômodo. O item que o técnico carrega não se perde quando o dia
vira — continua na mão até ser entregue ou trocado por outro. Tarefa não
concluída não custa nada. O mapa dos pontos de interação de cada cômodo está em
`interface/ROOMS.md`.

| Tarefa | Passos livres | Conclusão | Custo | Efeito |
| --- | --- | --- | --- | --- |
| Reparar motor | Sílvia dá o diagnóstico (energia) → Bento entrega 2 peças (depósito) | bancada do motor (energia) | 2 peças | motor volta a operante |
| Aumentar potência | Vera recalcula a rota (comando) | reator (energia) | 20 de energia | viagem encurta 1 dia; no máximo 2 vezes |
| Reparar casco | Neusa aponta o vazamento (dormitório) → kit de vedação (depósito) | ponto do casco (depósito) | 1 peça | estanca o vazamento de oxigênio |
| Descanso e organização | Neusa indica quem está mal (dormitório) | mesa comum (dormitório) | 8 de energia | moral +15, até o limite de 100 |
| Socorrer sobrevivente | Bento entrega a água (depósito) | beliche do sobrevivente (dormitório) | 5 de água | moral +10 (provisório, ver Pendências) |

Limites: nenhum recurso fica negativo e nenhuma barra passa de 100 — o efeito
que ultrapassa o limite é descartado.

### Quando cada tarefa aparece

| Tarefa | Só aparece quando |
| --- | --- |
| Reparar motor | motor danificado |
| Aumentar potência | até duas vezes na viagem |
| Reparar casco | vazamento ativo |
| Descanso e organização | sempre |
| Socorrer sobrevivente | oxigênio ou moral em vermelho |

O jogador escolhe qual cadeia cumprir no dia. O briefing do comando sugere uma
tarefa, mas não trava as outras estações.

### Estados ligados no cômodo

| Cômodo | Interruptor | Efeito |
| --- | --- | --- |
| Energia | Modo economia | consumo de energia cai para 3; moral −5 e −1 por dia enquanto ativo |
| Depósito | Racionamento | comida e água pela metade; moral −8 e −1 por dia enquanto ativo |

## Estado do motor

| Estado | Efeito | Como sai |
| --- | --- | --- |
| Operante | consumo normal | a falha no motor leva a danificado |
| Danificado | viagem +1 dia; 3 dias sem reparo destroem o motor | reparar com 2 peças |
| Destruído | derrota imediata | — |

A vitória exige o motor operante no dia final.

## Consequências dos eventos

| Evento | Alternativa A | Alternativa B |
| --- | --- | --- |
| Falha no motor | reparar: 2 peças | seguir: viagem +1 dia, motor danificado |
| Chuva de meteoros | escudos: 15 de energia | impacto: oxigênio −15 e vazamento de 3 por dia até reparar o casco |
| Falta de comida | porções normais: consumo normal | racionamento: moral −8 |
| Conflito no dormitório | ignorar: moral −10 | intervir: moral +10, energia −10 |

## Sobreviventes e fim de jogo

| Situação | Efeito |
| --- | --- |
| Comida em zero ao fim do dia | morre 1 sobrevivente e a moral cai 15 |
| Sem sobreviventes vivos | derrota imediata — quinta causa, com mensagem própria |
| Oxigênio em zero | derrota imediata |
| Energia em zero | derrota imediata |
| Moral em zero | derrota imediata |
| Motor destruído | derrota imediata |
| Dia final com motor operante e 1 ou mais sobreviventes vivos | vitória |

## Pendências

- Probabilidade de cada evento e repetição ao longo dos dez dias.
- O efeito de "socorrer sobrevivente" (+10 de moral) é provisório até o
  balanceamento.
- Custo de outras falhas de sistema além do motor.
