# Ações e custos

Este arquivo registra o contrato mecânico vigente do ciclo de quests. Os valores
foram definidos e simulados na issue [Simplificar mecânicas legadas e balancear
o ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26).

## Regras base

| Regra | Valor |
| --- | --- |
| Recursos em barra | energia, oxigênio, água, comida e moral |
| Peças | contagem inteira, sem consumo diário |
| Estoque inicial | energia 80; oxigênio 85; água 80; comida 70; moral 80; peças 4 |
| Consumo diário | energia -7; oxigênio -4; água -6; comida -6; moral -2 |
| Sobreviventes | 4 a bordo; o técnico não entra na conta |
| Duração | 10 dias |
| Incidentes | dias 2, 4, 6, 8 e 10 |
| Incidentes por partida | 5 de 7 tipos, sem reposição |
| Famílias de incidente | falhas técnicas, suprimentos e tripulação |
| Trabalho diário | uma quest concluída por dia |

O consumo é aplicado uma vez ao dormir. Nenhuma ordem preventiva cancela o
consumo normal. Ao dormir, o jogo aplica, nesta ordem: consequência da ordem
preventiva incompleta ou negligência, consumo diário, perdas dos problemas
ativos, contagem do risco individual, prazos e crises, limite dos recursos e
condições de término.

Economia e racionamento foram removidos. Também não existem bônus numéricos
ocultos por sobrevivente nem um contador separado de intervenção. Os
sobreviventes oferecem ordens, contextualizam os objetos e podem entrar em
risco,
mas não alteram silenciosamente os custos.

Encerrar o dia continua exigindo dormir no beliche do técnico no Dormitório. O
jogador pode dormir sem cumprir a ordem, mas assume a consequência prevista para
aquele dia.

## Consumo ao encerrar o dia

| Recurso | Consumo por noite | Razão mecânica |
| --- | ---: | --- |
| Energia | -7 | mantém motor e sistemas |
| Oxigênio | -4 | sustenta os sobreviventes |
| Água | -6 | consumo humano diário |
| Comida | -6 | consumo humano diário |
| Moral | -2 | desgaste básico da viagem |
| Peças | 0 | reserva para soluções técnicas |

Energia, oxigênio e moral em zero encerram a partida. Água e comida podem
chegar a zero, mas produzem pressão por escassez e não uma derrota instantânea;
seus incidentes e crises continuam aplicando consequências.

## Ordens e problemas ativos

O jogo não possui uma lista extensa de tarefas. O trabalho do dia é uma ordem
física curta, com objeto, origem, destino, recompensa ou resultado e consequência
visíveis antes do compromisso.

Nos dias sem incidente, os sobreviventes oferecem duas ordens preventivas. O
jogador compara as duas, confirma uma presencialmente e pode concluir somente
uma. A ordem aceita não pode ser cancelada. A ordem não escolhida expira ao
dormir.

Uma ordem preventiva concluída aumenta um recurso específico. Se a ordem aceita
não for concluída, perde-se uma pequena quantidade do mesmo recurso. Se nenhuma
ordem for aceita, cada recurso protegido pelas duas ofertas perde uma quantidade
maior. Assim, concluir é melhor que falhar depois de aceitar, e aceitar e falhar
é melhor que ignorar as duas ofertas.

Nos dias com incidente, o cartão apresenta duas soluções em formato de quest.
Cada solução informa seu objeto, origem, destino, custo e resultado. A escolha é
única e a solução precisa ser executada fisicamente.

Se a solução de um incidente não for concluída antes de dormir, o problema
permanece ativo. Sua perda diária, prazo e crise seguem normalmente; não há uma
multa extra pela quest não concluída.

## Ordens preventivas

O pool usa quatro pares de referência em ciclo: dia 1 usa `V-01 + B-01`, dia 3
usa `V-02 + N-01`, dia 5 usa `B-02 + S-02`, dia 7 usa `N-02 + S-01` e dia 9
reinicia o ciclo. Cada par protege recursos diferentes.

| ID | Responsável | Ordem | Objeto | Origem | Destino | Recompensa | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- |
| V-01 | Vera | Calibrar a antena | bobina de transmissão | reserva (Depósito) | antena (Comando) | `+8 moral` | `-3 moral` |
| V-02 | Vera | Atualizar a rota | cartão de rota | Vera (Comando) | console da rota (Comando) | `+8 energia` | `-3 energia` |
| B-01 | Bento | Reforçar a reserva | caixa de provisões | prateleira de reserva (Depósito) | estoque de comida (Depósito) | `+8 comida` | `-3 comida` |
| B-02 | Bento | Separar peças de emergência | chave de torque | prateleira de reserva (Depósito) | Bento (Depósito) | `+2 peças` | `-1 peça` |
| N-01 | Neusa | Preparar água do grupo | filtro de água | console da rota (Comando) | mesa comum (Dormitório) | `+8 água` | `-3 água` |
| N-02 | Neusa | Abrir espaço para a conversa | cartões de mediação | Neusa (Dormitório) | mesa do grupo (Dormitório) | `+8 moral` | `-3 moral` |
| S-01 | Sílvia | Regular a distribuição | módulo de relé | console da rota (Comando) | painel de distribuição (Máquinas) | `+8 energia` | `-3 energia` |
| S-02 | Sílvia | Testar o suporte de vida | cartucho de oxigênio | console da rota (Comando) | painel de suporte de vida (Máquinas) | `+8 oxigênio` | `-3 oxigênio` |

Se nenhuma preventiva for aceita, a perda é `-4` do recurso de cada oferta;
para peças, a perda é `-2`. As recompensas ficam abaixo do estoque máximo e do
consumo acumulado da campanha, portanto não anulam a pressão diária.

Se o responsável de uma oferta morrer, a oferta é removida. O modelo preenche a
vaga com a primeira oferta de sobrevivente vivo que proteja recurso diferente.
Se restar somente uma pessoa viva, suas duas ofertas são usadas. Sem
sobreviventes vivos, a partida já terminou.

## Matriz das soluções de incidente

Cada incidente tem duas soluções físicas. O custo é pago na entrega. A perda
diária começa quando a solução escolhida não é concluída antes de dormir. O
prazo diminui uma unidade por noite; ao chegar a zero, a crise é aplicada e o
prazo é reiniciado quando indicado.

| Incidente | ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Motor | ENG-A | Sílvia | chave de torque | `-2 peças` | console da rota (Comando) | bancada do motor (Máquinas) | alinhar o eixo do motor | `-4 energia/dia; prazo 3; crise: motor destruído` |
| Motor | ENG-B | Sílvia | atuador do motor | `-8 energia` | console da rota (Comando) | bancada do motor (Máquinas) | estabilizar a rotação | `-4 energia/dia; prazo 3; crise: motor destruído` |
| Casco | HUL-A | Sílvia | kit de vedação | `-1 peça` | console da rota (Comando) | ponto de casco sorteado | fechar a ruptura | `-4 oxigênio/dia; prazo 3; crise: -12 oxigênio; prazo 2` |
| Casco | HUL-B | Sílvia | placa de blindagem | `-6 energia` | console da rota (Comando) | ponto de casco sorteado | sustentar a placa | `-4 oxigênio/dia; prazo 3; crise: -12 oxigênio; prazo 2` |
| Suporte de vida | LIFE-A | Sílvia | cartucho de oxigênio | `-1 peça` | console da rota (Comando) | painel de suporte de vida (Máquinas) | repor o cartucho | `-3 oxigênio/dia; prazo 3; crise: -10 oxigênio e uma pessoa em risco; prazo 2` |
| Suporte de vida | LIFE-B | Sílvia | filtro de CO2 | `-6 energia` | console da rota (Comando) | painel de suporte de vida (Máquinas) | recircular o ar | `-3 oxigênio/dia; prazo 3; crise: -10 oxigênio e uma pessoa em risco; prazo 2` |
| Energia | PWR-A | Sílvia | fusível de potência | `-1 peça` | console da rota (Comando) | painel de distribuição (Máquinas) | isolar o circuito | `-3 energia/dia; prazo 3; crise: -10 energia; prazo 2` |
| Energia | PWR-B | Sílvia | módulo de relé | `-5 moral` | console da rota (Comando) | painel de distribuição (Máquinas) | redistribuir a carga | `-3 energia/dia; prazo 3; crise: -10 energia; prazo 2` |
| Comunicações | COM-A | Vera | bobina de transmissão | `-1 peça` | console da rota (Comando) | antena (Comando) | restabelecer o contato | `-2 moral/dia; prazo 4; crise: -8 moral; prazo 2` |
| Comunicações | COM-B | Vera | célula de sinal | `-5 energia` | console da rota (Comando) | antena (Comando) | manter a escuta | `-2 moral/dia; prazo 4; crise: -8 moral; prazo 2` |
| Comida | FOOD-A | Bento | caixa de provisões | `-1 peça` | console da rota (Comando) | estoque de comida (Depósito) | recompor o estoque | `-3 comida/dia; prazo 3; crise: -8 comida e uma pessoa em risco; prazo 2` |
| Comida | FOOD-B | Bento | selante de estoque | `-4 moral` | console da rota (Comando) | estoque de comida (Depósito) | proteger a reserva | `-3 comida/dia; prazo 3; crise: -8 comida e uma pessoa em risco; prazo 2` |
| Conflito | CON-A | Neusa | cartões de mediação | `-5 moral` | console da rota (Comando) | mesa do grupo (Dormitório) | mediar a conversa | `-3 moral/dia; prazo 3; crise: -8 moral e uma pessoa em risco; prazo 2` |
| Conflito | CON-B | Neusa | refeição quente | `-4 comida` | console da rota (Comando) | mesa do grupo (Dormitório) | reunir o grupo | `-3 moral/dia; prazo 3; crise: -8 moral e uma pessoa em risco; prazo 2` |

As soluções usam custos de recursos semanticamente relacionados às suas
famílias. A reserva inicial de quatro peças, mais `+2 peças` de `B-02`, cobre
uma campanha que priorize as soluções técnicas; energia, moral, comida e peças
oferecem alternativas para outras estratégias.

O ponto de casco é sorteado uma vez quando o problema nasce. Como as soluções
partem do console da rota, a rota até qualquer cômodo tem no máximo dois
cômodos distintos. Os objetos compartilhados podem reaparecer em ordens
diferentes, mas nunca ficam disponíveis para coleta livre.

## Socorro e risco individual

Uma crise de comida, suporte de vida ou conflito pode iniciar um risco. Há no
máximo uma pessoa em risco por vez. O prazo inicial é de 2 noites. Socorrer é
uma quest simples com custo `-8 água` e `-2 comida`. Se o prazo chega a zero, a
pessoa morre e `A BORDO` diminui; a morte não altera custos nem cria bônus.

## Estados da quest

Antes do compromisso, o cartão mostra responsável, objeto, origem, destino,
recompensa ou resultado e consequência da falha. Uma ordem preventiva escolhida
fica pendente até a confirmação presencial com seu responsável. Depois da
confirmação, a etapa é `COLETAR`; após guardar o objeto, a etapa é `ENTREGAR`; a
entrega confirmada conclui a única quest do dia.

Dormir com uma ordem preventiva aceita e incompleta aplica a falha daquela
ordem, devolve o objeto ao ponto de origem e limpa o item carregado. Dormir sem
aceitar preventiva aplica a negligência das duas ofertas. Dormir com uma solução
urgente incompleta não aplica multa extra: o problema segue ativo com sua perda,
prazo e crise normais.
A mesma solução escolhida reaparece como retomada nos dias seguintes enquanto o
problema permanecer ativo. Retomá-la continua consumindo a única conclusão diária
e não altera o custo ou a consequência já exibidos.
Em dia com incidente novo, o cartão do incidente tem prioridade; a retomada fica
disponível no próximo dia sem incidente, enquanto o problema permanece ativo.

## Vocabulário da interface da quest

Os cartões e painéis usam frases curtas e os mesmos nomes da matriz:

| Momento | Texto obrigatório |
| --- | --- |
| Oferta preventiva | `ORDEM PREVENTIVA — [ordem]` |
| Campos da oferta | responsável; objeto; coleta; entrega |
| Recompensa | `RECOMPENSA: +[n] [recurso]` |
| Falha prevista | `SE FALHAR: -[n] [recurso]` |
| Confirmação presencial | `[nome]: CONFIRME A ORDEM. ELA NÃO PODE SER CANCELADA.` |
| Coleta | `COLETAR [objeto]? SERVE PARA [resultado]. DESTINO: [destino].` |
| Entrega | `ENTREGAR [objeto]? RESULTADO: [resultado]. CUSTO: [custo].` |
| Preventiva concluída | `ORDEM CONCLUÍDA: +[n] [recurso].` |
| Preventiva incompleta | `ORDEM NÃO CONCLUÍDA: -[n] [recurso]. O OBJETO VOLTA À ORIGEM.` |
| Nenhuma preventiva | `NENHUMA ORDEM ACEITA: -[n] [recurso 1] E -[n] [recurso 2].` |
| Solução urgente incompleta | `SOLUÇÃO NÃO CONCLUÍDA. [PROBLEMA] PERMANECE ATIVO.` |

Formato linear dos campos: `RESPONSÁVEL: [nome] | OBJETO: [objeto] | COLETA:
[origem] | ENTREGA: [destino]`. O texto não pode esconder o recurso afetado,
a origem, o destino, o custo ou o estado da ordem.

## Calendário e processamento

Os incidentes ocorrem no início dos dias **2, 4, 6, 8 e 10**. No início da
partida, os sete tipos são embaralhados e cinco formam a viagem sem reposição.
Os tipos pertencem às famílias de falhas técnicas, suprimentos e tripulação.

Nos dias sem incidente, duas ordens preventivas são oferecidas. O jogador deve
aceitar e concluir uma para evitar a perda maior de negligência. Nos dias com
incidente, o cartão oferece duas soluções físicas; a escolhida deve ser
concluída para remover o problema.

Ao dormir, o jogo aplica consequência da preventiva, consumo, perdas dos
problemas ativos, risco individual, prazos, crises e condições de término. Uma
solução urgente não concluída deixa o problema ativo e não cria penalidade extra.

## Agravamento

Todo problema ativo cobra sua perda ao encerrar o dia e reduz o prazo visível.
Quando o prazo chega a zero, aplica uma crise coerente com sua família, não uma
derrota universal. O motor pode ser destruído; crises de suprimentos,
tripulação, casco ou comunicações produzem consequências próprias e podem
continuar ativas após o reinício do prazo.

## Sobreviventes e fim de jogo

| Situação | Efeito |
| --- | --- |
| Sobrevivente em risco chega ao prazo zero | a pessoa morre e `A BORDO` diminui |
| Sem sobreviventes vivos | derrota imediata |
| Oxigênio em zero | derrota imediata |
| Energia em zero | derrota imediata |
| Moral em zero | derrota imediata |
| Motor destruído | derrota imediata |
| Dia final com motor operante e 1 ou mais sobreviventes vivos | vitória |

## Estado do contrato

- A forma das ordens, incidentes e mecânicas simplificadas está confirmada.
- O calendário vigente é 2, 4, 6, 8 e 10, com cinco incidentes de sete tipos.
- O estoque, o consumo, os custos, as recompensas, as perdas, os prazos, as
  crises, o socorro e a seleção do pool estão implementados no
  `prototype/balance-model.mjs`.
- O código do sketch ainda implementa o ciclo anterior; a migração visual e a
  verificação do fluxo físico pertencem ao trabalho posterior ao balanceamento.
- A simulação da issue #26 é a evidência numérica do contrato; não substitui a
  futura captura do sketch migrado.
