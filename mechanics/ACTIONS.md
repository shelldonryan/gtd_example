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
| Estoques iniciais | 100 em energia, oxigênio, água e moral; 70 de comida; 6 peças |
| Tarefas por dia | 1 em cadeia, escolhida explicitamente no console do comando |
| Eventos | 1 por dia, a partir do dia 2; pool uniforme sem repetição imediata; falha ativa não é resortada |

Decisões fixadas neste arquivo:

- **Energia é um estoque único**, consumido para manter o motor e o suporte de
  vida. Não existe combustível separado: a barra de energia é esse estoque.
- **Modo economia e racionamento são estados**, ligados e desligados durante a
  visita ao cômodo. Não gastam a tarefa do dia; movimento e etapas de preparação
  também não. Somente a **ação final** da cadeia usa a tarefa.
- **Encerrar o dia** exige interagir com o beliche do técnico no Dormitório,
  conferir o resumo do consumo e confirmar. Não existe botão `Passar dia`.

## Consumo ao encerrar o dia

| Recurso | Consumo | Observação |
| --- | --- | --- |
| Energia | 6 | motor e suporte de vida; 3 com modo economia |
| Oxigênio | 5 | 10 se a energia estiver abaixo de 30 |
| Água | 8 | 4 com racionamento |
| Comida | 7 | 3 com racionamento |
| Moral | 2 | mais 1 por recurso em vermelho (de 1 a 29) |

O primeiro dia começa na Sala de comando; os seguintes começam no Dormitório
com o evento correspondente. Depois de responder ao evento, o técnico vai ao
console do comando, escolhe uma tarefa e atravessa as salas pelas portas.
Movimento e etapas de preparação não gastam a tarefa; somente a ação final
gasta. Confirmar o resumo no beliche consome recursos, atualiza a moral, avança
o dia e verifica vitória ou derrota.

A resposta do evento **não** gasta a ação do dia.

## Tarefas por dia

Uma tarefa por dia, em **cadeia**: o jogador escolhe explicitamente uma das
tarefas disponíveis no console de briefing da Sala de comando. Antes de
confirmar, o painel mostra custo, efeito e rota. Cada tarefa passa por um
sobrevivente e por pelo menos uma troca de cômodo.

O item que o técnico carrega não se perde quando o dia vira: continua na mão até
ser entregue ou trocado. Tarefa não concluída não custa nada. O mapa dos pontos
de interação de cada cômodo está em `interface/ROOMS.md`.

| Tarefa | Etapas de preparação | Ação final | Custo | Efeito |
| --- | --- | --- | --- | --- |
| Reparar motor | Sílvia dá o diagnóstico (energia) → Bento entrega 2 peças (depósito) | bancada do motor (energia) | 2 peças | motor volta a operante |
| Aumentar potência | Vera recalcula a rota (comando) | reator (energia) | 20 de energia | viagem encurta 1 dia; no máximo 2 vezes |
| Reparar casco | Neusa aponta o vazamento (dormitório) → kit de vedação (depósito) | ponto do casco (depósito) | 1 peça | estanca o vazamento de oxigênio |
| Descanso e organização | Neusa indica quem está mal (dormitório) | mesa comum (dormitório) | 8 de energia | moral +15, até o limite de 100 |
| Socorrer sobrevivente | Bento entrega a água (depósito) | beliche do sobrevivente (dormitório) | 5 de água | moral +10 |
| Reparar suporte de vida | Sílvia diagnostica (energia) → Bento entrega 2 peças (depósito) | painel de suporte de vida (energia) | 2 peças | encerra o modo de emergência |
| Reparar sistema de energia | Sílvia sorteia a variante (energia) → NPC da variante entrega o item | estação da variante (energia) | conforme a variante | encerra a falha de energia |
| Reparar comunicações | Vera diagnostica (comando) → Bento entrega 1 peça (depósito) | antena (Sala de comando) | 1 peça | restaura as transmissões e encerra o silêncio |

Variantes de `Reparar sistema de energia` — Sílvia sorteia uma, sem repetição:

| Variante | Item | Etapa de preparação | Ação final | Custo |
| --- | --- | --- | --- | --- |
| Trocar fusível | Fusível reserva | Bento entrega (depósito) | painel de distribuição (energia) | 1 peça |
| Reforçar circuito | Cabo de derivação | Vera entrega (comando) | reator (energia) | 10 energia |
| Resfriar regulador | Cartucho refrigerante | Neusa entrega (dormitório) | bancada do motor (energia) | 5 água |

O sorteio considera apenas variantes ainda não usadas e pagáveis; depois das
três, a falha sai do pool de eventos.

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
| Reparar suporte de vida | suporte de vida em emergência |
| Reparar sistema de energia | falha no sistema de energia ativa |
| Reparar comunicações | comunicação em silêncio |

O briefing não inicia uma tarefa automaticamente. O jogador compara as opções no
console e confirma uma delas; conversar com um sobrevivente sem tarefa ativa não
cria uma cadeia por acaso.

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
## Estado do suporte de vida

| Estado | Efeito | Como sai |
| --- | --- | --- |
| Estável | consumo normal de oxigênio | a falha leva à emergência |
| Emergência | energia −10 na escolha ou +3 de oxigênio por dia até reparar | reparar com 2 peças |


## Consequências dos eventos

| Evento | Alternativa A | Alternativa B |
| --- | --- | --- |
| Falha no motor | reparar: 2 peças | seguir: viagem +1 dia, motor danificado |
| Chuva de meteoros | escudos: 15 de energia | impacto: oxigênio −15 e vazamento de 3 por dia até reparar o casco |
| Falta de comida | porções normais: consumo normal | racionamento: moral −8 |
| Conflito no dormitório | ignorar: moral −10 | intervir: moral +10, energia −10 |
| Falha no suporte de vida | reparar: 2 peças | modo de emergência: energia −10 e oxigênio +3 por dia até reparar |
| Falha no sistema de energia | forçar a rede: energia −10 | desligar setores: moral −10; a falha fica ativa com +3 de energia por dia até reparar |
| Falha nas comunicações | reparar: 1 peça | silêncio: moral −1 por dia e as transmissões da Terra suspensas até reparar |

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

- Nenhuma falha de sistema pendente nesta versão.
