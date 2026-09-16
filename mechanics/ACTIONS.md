# Ações e custos

Este arquivo registra o contrato mecânico vigente. A forma das quests está
definida; o modelo numérico anterior da issue #20 foi **SUPERSEDED**. Estoques,
consumos, custos, recompensas, perdas, prazos e crises serão fechados no #26.

## Regras base

| Regra | Valor |
| --- | --- |
| Recursos em barra | energia, oxigênio, água, comida e moral |
| Peças | contagem inteira |
| Sobreviventes | 4 a bordo; o técnico não entra na conta |
| Duração | 10 dias |
| Incidentes | dias 2, 4, 6, 8 e 10 |
| Incidentes por partida | 5 de 7 tipos, sem reposição |
| Famílias de incidente | falhas técnicas, suprimentos e tripulação |
| Trabalho diário | uma quest concluída por dia |

Os valores de estoque inicial, consumo, custos e recompensas serão consolidados
em [Simplificar mecânicas legadas e balancear o ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26)
após a pesquisa do código e a simulação. Esta fonte registra a forma vigente do
sistema, não números provisórios.

Economia e racionamento foram removidos. Também não existem bônus numéricos
ocultos por sobrevivente nem um contador separado de intervenção. Os
sobreviventes oferecem ordens, contextualizam os objetos e podem entrar em
risco, mas não alteram silenciosamente os custos.

Encerrar o dia continua exigindo dormir no beliche do técnico no Dormitório.
Dormir processa consumo, perdas, riscos, prazos, crises e condições de término.
O jogador pode dormir sem cumprir a ordem, mas assume a consequência de
negligência prevista para aquele dia.

## Consumo ao encerrar o dia

O consumo diário continua sendo a pressão de base dos seis recursos. O cálculo
final e a ordem exata do processamento serão definidos no ticket de
balanceamento. Nenhuma ordem preventiva cancela o consumo normal do dia.


## Ordens e problemas ativos

O jogo não possui uma lista extensa de tarefas. O trabalho do dia é uma ordem
física curta, com objeto, origem, destino, recompensa e consequência visíveis
antes do compromisso.

Nos dias sem incidente, os sobreviventes oferecem duas ordens preventivas. O
jogador compara as duas, confirma uma presencialmente e pode concluir somente
uma. A ordem aceita não pode ser cancelada. A ordem não escolhida expira ao
dormir.

Uma ordem preventiva concluída aumenta um recurso específico. Se a ordem aceita
não for concluída, perde-se uma pequena quantidade do mesmo recurso. Se nenhuma
ordem for aceita, perdem-se pequenas quantidades dos dois recursos associados às
ofertas. Os valores exatos serão definidos no ticket de balanceamento.

Nos dias com incidente, o cartão apresenta duas soluções em formato de quest.
Cada solução informa seu objeto, origem, destino, custo e resultado. A escolha
é única e a solução precisa ser executada fisicamente.

Se a solução de um incidente não for concluída antes de dormir, o problema
permanece ativo. Sua perda diária, prazo e crise seguem normalmente; não há uma
multa extra pela quest não concluída.

## Regras da ordem

| Regra | Aplicação |
| --- | --- |
| Etapas | coleta do objeto e entrega no destino |
| Limite | uma quest concluída por dia |
| Componentes | objetos de quest, carregados um por vez |
| Recursos comuns | pagos ou recebidos no destino |
| NPC | origem ou destino, sem bônus numérico |
| Rota | curta e sem três cômodos distintos |
| Diagnóstico | opcional e curto |

Uma ordem pode usar um fusível, kit, caixa, ferramenta ou outro objeto produzido
para a atividade. O objeto deve ter função mecânica e pode ser reutilizado em
ordens diferentes.
## Catálogo de ordens preventivas

O pool de dias sem incidente possui oito ofertas. Cada oferta protege um único
recurso; o valor numérico da recompensa e da perda pertence ao ticket de
balanceamento. Os pares abaixo são combinações válidas para comparação:

| ID | Responsável | Ordem | Objeto | Origem | Destino | Recompensa | Falha |
| --- | --- | --- | --- | --- | --- | --- | --- |
| V-01 | Vera | Calibrar a antena | bobina de transmissão | reserva (Depósito) | antena (Comando) | moral + | moral - |
| V-02 | Vera | Atualizar a rota | cartão de rota | Vera (Comando) | console da rota (Comando) | energia + | energia - |
| B-01 | Bento | Reforçar a reserva | caixa de provisões | prateleira de reserva (Depósito) | estoque de comida (Depósito) | comida + | comida - |
| B-02 | Bento | Separar peças de emergência | chave de torque | prateleira de reserva (Depósito) | Bento (Depósito) | peças + | peças - |
| N-01 | Neusa | Preparar água do grupo | filtro de água | console da rota (Comando) | mesa comum (Dormitório) | água + | água - |
| N-02 | Neusa | Abrir espaço para a conversa | cartões de mediação | Neusa (Dormitório) | mesa do grupo (Dormitório) | moral + | moral - |
| S-01 | Sílvia | Regular a distribuição | módulo de relé | console da rota (Comando) | painel de distribuição (Máquinas) | energia + | energia - |
| S-02 | Sílvia | Testar o suporte de vida | cartucho de oxigênio | console da rota (Comando) | painel de suporte de vida (Máquinas) | oxigênio + | oxigênio - |

Os pares de referência são `V-01 + B-01`, `V-02 + N-01`, `B-02 + S-02` e
`N-02 + S-01`. Eles protegem recursos diferentes, usam rotas distintas e não
criam uma opção universal. O ticket de balanceamento escolhe um par válido,
remove as ordens de sobreviventes mortos e preserva esses invariantes. Se um par
de referência deixar de existir, escolhe duas ofertas de sobreviventes vivos com
recursos protegidos diferentes; se restar apenas uma pessoa, usa as duas ofertas
dela. Sem sobreviventes, a partida já terminou.

## Matriz das soluções de incidente

Cada incidente tem duas soluções físicas. O custo abaixo identifica o recurso
que será calibrado no ticket de balanceamento; o resultado é a consequência
positiva da entrega. A perda, o prazo e a crise de deixar o problema ativo
continuam pertencendo à definição numérica do problema.

O catálogo contém quatorze soluções: duas para cada um dos sete incidentes.
Em cada solução de incidente, o campo `SE FALHAR` aparece como `PROBLEMA
ATIVO: [perda/dia] | PRAZO [n] | CRISE [texto]`. Os valores de perda, prazo e
crise são os da família do incidente e serão preenchidos no #26 antes da
implementação.

| Incidente | ID | Responsável | Objeto | Custo | Origem | Destino | Resultado | Se falhar |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Motor | ENG-A | Sílvia | chave de torque | peças | console da rota (Comando) | bancada do motor (Máquinas) | alinhar o eixo do motor | problema ativo; perda, prazo e crise do motor |
| Motor | ENG-B | Sílvia | atuador do motor | energia | console da rota (Comando) | bancada do motor (Máquinas) | estabilizar a rotação | problema ativo; perda, prazo e crise do motor |
| Casco | HUL-A | Sílvia | kit de vedação | peças | console da rota (Comando) | ponto de casco sorteado | fechar a ruptura | problema ativo; perda, prazo e crise do casco |
| Casco | HUL-B | Sílvia | placa de blindagem | energia | console da rota (Comando) | ponto de casco sorteado | sustentar a placa | problema ativo; perda, prazo e crise do casco |
| Suporte de vida | LIFE-A | Sílvia | cartucho de oxigênio | peças | console da rota (Comando) | painel de suporte de vida (Máquinas) | repor o cartucho | problema ativo; perda, prazo e crise do suporte |
| Suporte de vida | LIFE-B | Sílvia | filtro de CO2 | energia | console da rota (Comando) | painel de suporte de vida (Máquinas) | recircular o ar | problema ativo; perda, prazo e crise do suporte |
| Energia | PWR-A | Sílvia | fusível de potência | peças | console da rota (Comando) | painel de distribuição (Máquinas) | isolar o circuito | problema ativo; perda, prazo e crise da energia |
| Energia | PWR-B | Sílvia | módulo de relé | moral | console da rota (Comando) | painel de distribuição (Máquinas) | redistribuir a carga | problema ativo; perda, prazo e crise da energia |
| Comunicações | COM-A | Vera | bobina de transmissão | peças | console da rota (Comando) | antena (Comando) | restabelecer o contato | problema ativo; perda, prazo e crise das comunicações |
| Comunicações | COM-B | Vera | célula de sinal | energia | console da rota (Comando) | antena (Comando) | manter a escuta | problema ativo; perda, prazo e crise das comunicações |
| Comida | FOOD-A | Bento | caixa de provisões | peças | console da rota (Comando) | estoque de comida (Depósito) | recompor o estoque | problema ativo; perda, prazo e crise da comida |
| Comida | FOOD-B | Bento | selante de estoque | moral | console da rota (Comando) | estoque de comida (Depósito) | proteger a reserva | problema ativo; perda, prazo e crise da comida |
| Conflito | CON-A | Neusa | cartões de mediação | moral | console da rota (Comando) | mesa do grupo (Dormitório) | mediar a conversa | problema ativo; perda, prazo e crise do conflito |
| Conflito | CON-B | Neusa | refeição quente | comida | console da rota (Comando) | mesa do grupo (Dormitório) | reunir o grupo | problema ativo; perda, prazo e crise do conflito |

O ponto de casco é sorteado uma vez quando o problema nasce. Como as soluções
partem do console da rota, a rota até qualquer cômodo tem no máximo dois
cômodos distintos: Comando e o cômodo do dano. Os objetos compartilhados, como
bobina, caixa, chave, filtro, cartões e relé, podem reaparecer em ordens
diferentes, mas nunca ficam disponíveis para coleta livre.

## Estados da quest

Antes do compromisso, o cartão mostra responsável, objeto, origem, destino,
recompensa ou resultado e consequência da falha. Uma ordem preventiva escolhida
fica pendente até a confirmação presencial com seu responsável. Depois da
confirmação, a etapa é `COLETAR`; após guardar o objeto, a etapa é `ENTREGAR`; a
entrega confirmada conclui a única quest do dia.

Dormir com uma ordem preventiva aceita e incompleta aplica a falha daquela
ordem, devolve o objeto ao ponto de origem e limpa o item carregado. Dormir com
uma solução de incidente incompleta não aplica multa extra: o problema segue
ativo com sua perda, prazo e crise normais. A ordem não escolhida expira, e uma
ordem aceita nunca pode ser cancelada.
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


Formato linear dos campos: `RESPONSÁVEL: [nome] | OBJETO: [objeto] | COLETA: [origem] | ENTREGA: [destino]`.
`[n]` e `[custo]` são preenchidos pelo balanceamento. O texto não pode esconder
o recurso afetado, a origem, o destino ou o estado da ordem.

## Calendário e processamento

Os incidentes ocorrem no início dos dias **2, 4, 6, 8 e 10**. No início da
partida, os sete tipos são embaralhados e cinco formam a viagem sem reposição.
Os tipos pertencem às famílias de falhas técnicas, suprimentos e tripulação.

Nos dias sem incidente, duas ordens preventivas são oferecidas. O jogador deve
aceitar e concluir uma para evitar a perda maior de negligência. As duas ofertas
informam os recursos envolvidos antes da escolha e vêm de um pool validado.

Nos dias com incidente, o cartão oferece duas soluções em formato de quest. Cada
solução possui objeto, origem, destino, custo e resultado. A solução escolhida
deve ser concluída fisicamente para remover o problema.

Ao dormir, o jogo processa o consumo diário, as perdas dos problemas ativos, o
risco individual vigente, as crises que chegarem ao prazo e as condições de
término. A ordem exata e os valores serão consolidados após a pesquisa e a
simulação de [Simplificar mecânicas legadas e balancear o ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26).

Uma ordem preventiva concluída aumenta um recurso específico. Se for aceita e
não for concluída, perde-se uma pequena quantidade desse mesmo recurso. Se
nenhuma ordem for aceita, perdem-se pequenas quantidades dos dois recursos
associados às ofertas. Nenhuma ordem aceita pode ser cancelada.

### Sete incidentes

| Família | Tipos | Estrutura |
| --- | --- | --- |
| Falhas técnicas | motor, casco, suporte de vida, energia e comunicações | duas soluções físicas para reparar ou estabilizar o sistema |
| Suprimentos | falta de comida | duas soluções físicas para recuperar ou proteger o estoque |
| Tripulação | conflito no dormitório | duas soluções físicas para recuperar a convivência ou proteger o grupo |

Os incidentes continuam criando problemas persistentes. A solução urgente não
concluída deixa o problema ativo, com perda diária, prazo e crise. Não existe
mais uma contenção separada da quest de solução.

### Objetos e recursos

Componentes especiais, como fusível e kit de vedação, são objetos de quest. A
coleta não é livre: o item aparece como parte da ordem aceita, pode ser carregado
um por vez e é consumido ou entregue no destino. Recursos comuns são pagos ou
recebidos na estação correspondente.

As ordens preventivas usam recompensas de um único recurso. Os valores de
recompensa, falha e negligência devem ser pequenos em relação ao consumo diário,
mas relevantes para a decisão. O ticket de balanceamento define os números e
verifica que nenhuma oferta é inútil ou universalmente dominante.

### Sobreviventes

Vera, Bento, Neusa e Sílvia continuam nomeados e oferecem ordens relacionadas às
suas áreas. Eles não alteram custos ou recompensas por bônus numérico.

Uma crise pode colocar no máximo uma pessoa em risco. Socorrer é uma quest
visível e simples. Se o prazo chegar a zero, a pessoa morre e `A BORDO` diminui;
a morte não recalcula custos nem cria uma exceção de regra.

### Mecânicas removidas

- modo economia;
- racionamento;
- bônus de especialista;
- contador separado de intervenção;
- coleta livre de componentes;
- seleção determinística complexa de riscos;
- múltiplos riscos simultâneos;
- contenção separada da solução física.

### Estado do balanceamento

Os números do modelo anterior da issue #20 estão **SUPERSEDED** pela estrutura
de quests. O calendário, o consumo, os custos, as recompensas, as perdas, os
prazos e as crises serão recalculados no ticket de balanceamento antes da
implementação. O resultado deve manter uma campanha ganhável por mais de uma
estratégia e perdível por negligência.

## Agravamento

Todo problema ativo cobra sua perda ao encerrar o dia e reduz o prazo visível.
Quando o prazo chega a zero, aplica uma crise coerente com sua família, não uma
derrota universal. O motor pode ser destruído; crises de suprimentos, tripulação,
casco ou comunicações produzem consequências próprias e podem continuar ativas.

Uma crise pode colocar um sobrevivente nomeado em risco. Há no máximo uma pessoa
em risco por vez. Essa pessoa recebe um prazo visível e uma quest simples de
socorro. Se o prazo chegar a zero, a pessoa morre e `A BORDO` diminui.

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
- Os valores antigos do modelo da issue #20 estão **SUPERSEDED** pela estrutura
  nova e não devem ser reutilizados sem a recalibração de
  [Simplificar mecânicas legadas e balancear o ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26).
- O código atual ainda implementa o ciclo anterior; a migração e a verificação
  pertencem ao trabalho posterior à validação numérica da #26.
