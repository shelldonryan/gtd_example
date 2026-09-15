# Ações e custos

Este arquivo registra o contrato mecânico vigente. Os estoques, consumos e o
modelo numérico da issue #20 foram confirmados pelo usuário após a execução das
simulações.

## Regras base

| Regra | Valor |
| --- | --- |
| Recursos em barra | energia, oxigênio, água, comida, moral — de 0 a 100 |
| Peças | contagem inteira |
| Sobreviventes | 4 a bordo; o técnico não entra na conta |
| Duração | 10 dias |
| Estoques iniciais | 100 em energia, oxigênio, água e moral; 70 de comida; 6 peças |
| Intervenções principais por dia | 1 correção, recuperação ou aceleração |
| Incidentes | em dias alternados; problema ativo não é sorteado novamente |

Decisões fixadas neste arquivo:

- **Energia é um estoque único**, consumido para manter o motor e o suporte de
  vida. Não existe combustível separado: a barra de energia é esse estoque.
- **Modo economia e racionamento são políticas persistentes locais.** Podem ser
  ligados ou desligados em Máquinas e no Depósito sem gastar a intervenção
  principal. Reduzem consumo e cobram moral ao ativar e em cada dia mantidos.
- **Encerrar o dia** continua exigindo dormir no beliche do técnico no
  Dormitório, conferir o resumo do consumo e confirmar. Não existe botão
  `Passar dia`.

## Consumo ao encerrar o dia

| Recurso | Consumo | Observação |
| --- | --- | --- |
| Energia | 6 | motor e suporte de vida; 3 com modo economia |
| Oxigênio | 5 | 10 se a energia estiver abaixo de 30 |
| Água | 8 | 4 com racionamento |
| Comida | 7 | 3 com racionamento |
| Moral | 2 | mais 1 por recurso em vermelho (de 1 a 29) |

O primeiro dia começa no Comando e os seguintes, no Dormitório. Incidentes
surgem em dias alternados. A resposta escolhe quanto risco aceitar naquele
momento, mas não resolve a causa: o problema nasce ativo no cômodo afetado.

O técnico pode explorar, diagnosticar, coletar componentes especiais — itens
únicos exigidos por correções específicas — e ajustar políticas sem gastar a
intervenção principal. Uma correção, recuperação ou aceleração pode ser
concluída por dia. Dormir processa consumo, perdas diárias,
prazos, crises, vitória ou derrota. Dormir sem intervir é permitido, mas todos
os problemas ativos continuam cobrando perdas e avançando para suas crises.

## Intervenções e problemas ativos

Não existe aceite diário de tarefa nem briefing obrigatório. O evento já cria
um problema ativo; HUD e mapa indicam onde agir, e os pontos relacionados passam
a responder imediatamente.

Cada problema mostra três informações antes do encerramento do dia:

1. perda aplicada por dia;
2. prazo restante;
3. consequência específica quando o prazo chega a zero.

O cartão do incidente segue o padrão **risco agora, correção depois**: suas duas
contenções trocam custo imediato por segurança, mas nenhuma encerra o problema.
A causa só desaparece com uma intervenção física no cômodo correspondente.

| Tipo de intervenção principal | Função |
| --- | --- |
| Correção | remove um problema persistente e seu prazo |
| Recuperação | restaura uma margem crítica ou estabiliza um sobrevivente |
| Aceleração | reduz a exposição aos próximos dias da viagem |

`Aumentar potência` elimina um dia futuro completo: consumo e eventual incidente
daquele dia deixam de ocorrer. No Dormitório, dormir apenas encerra o turno;
`Cuidar do grupo` recupera moral e `Socorrer [nome]` estabiliza uma pessoa em
risco. As duas últimas são intervenções principais distintas.

As sequências variam conforme o problema. Um passo só existe para descobrir
informação, obter algo realmente necessário ou aplicar a correção. NPC e troca
de cômodo não são requisitos universais. Recursos já contabilizados no HUD são
pagos diretamente no ponto final; somente componentes especiais precisam ser
buscados e carregados fisicamente.

Problemas e responsabilidades permanecem distribuídos assim:

| Origem | Local de correção |
| --- | --- |
| Motor, energia e suporte de vida | Sala de máquinas |
| Comunicações e rota | Sala de comando |
| Falta de comida, estoque e componentes | Depósito |
| Conflito, saúde e moral | Dormitório |
| Dano no casco por meteoros | local aleatório alcançável em qualquer um dos quatro cômodos |

## Modelo numérico confirmado na issue #20

### Calendário e ordem do turno

Os incidentes ocorrem no início dos dias **1, 3, 5, 7 e 9**. No começo da
partida, os sete problemas são embaralhados uniformemente e os cinco primeiros
formam a viagem. Assim, nenhum problema se repete na mesma partida e um problema
ativo nunca volta ao sorteio.

Ao dormir, o estado é processado nesta ordem:

1. custos diários das políticas;
2. consumo base de energia, oxigênio, água e comida;
3. perdas diárias dos problemas ativos;
4. moral base e penalidade por recursos em vermelho;
5. prazos de pessoas em risco e eventuais mortes;
6. prazos dos problemas e crises que chegaram a zero;
7. derrota, chegada e avanço do calendário.

O prazo exibido inclui a noite atual: um problema que nasce com prazo 2 pode ser
corrigido no dia do incidente ou no dia seguinte antes da crise. Crises não
fatais mantêm o problema ativo e reiniciam seu prazo.

### Sete problemas

| Problema | Perda diária | Contenção segura | Contenção arriscada | Crise |
| --- | --- | --- | --- | --- |
| Falha no motor | energia −4 | energia −5; prazo 3 | moral −2; prazo 2 | motor destruído; derrota |
| Dano no casco | oxigênio −5 | energia −5; prazo 3 | oxigênio −4; prazo 2 | oxigênio −15; reinicia em 2 |
| Falha no suporte de vida | oxigênio −4 | energia −4; prazo 4 | oxigênio −3; prazo 2 | oxigênio −12 e uma pessoa em risco; reinicia em 3 |
| Falha no sistema de energia | energia −3 | energia −4; prazo 4 | moral −4; prazo 2 | energia −12, desliga economia; reinicia em 3 |
| Falha nas comunicações | moral −2 | energia −3; prazo 4 | moral −3; prazo 2 | moral −10; reinicia em 3 |
| Falta de comida | comida −3 | comida −4; prazo 4 | moral −4; prazo 2 | comida −8 e uma pessoa em risco; reinicia em 3 |
| Conflito no dormitório | moral −4 | água −4; prazo 4 | moral −3; prazo 2 | moral −8 e uma pessoa em risco; reinicia em 3 |

### Intervenções e benefícios

| Intervenção | Com especialista vivo | Sem especialista |
| --- | --- | --- |
| Reparar motor — Sílvia | 2 peças | 3 peças |
| Reparar casco — Sílvia | kit de vedação + 1 peça | kit de vedação + 2 peças |
| Reparar suporte — Sílvia | 1 peça | 2 peças |
| Reparar energia — Sílvia | fusível de potência + 1 peça | fusível + 2 peças |
| Reparar comunicações — Vera | 1 peça | 2 peças |
| Reorganizar comida — Bento | sem recurso comum | comida −3 |
| Mediar conflito — Neusa | sem recurso comum | água −3 |
| Aumentar potência — Vera | energia −10 | energia −15 |
| Cuidar do grupo — Neusa | água −3, comida −2; moral +20 | mesmo custo; moral +12 |
| Socorrer pessoa — Neusa | água −6, comida −2 | água −9, comida −3 |

Kit de vedação e fusível de potência são componentes especiais: precisam ser
coletados, mas a coleta é livre. Os custos comuns são pagos no ponto final.
Uma pessoa em risco recebe prazo 2. Socorrer remove o risco; prazo zero causa
morte e remove o benefício da especialidade.

### Políticas

| Política | Efeito | Bento vivo | Bento morto |
| --- | --- | --- | --- |
| Modo economia | consumo de energia cai de 6 para 3 | moral −2 ao ativar e −1/dia | moral −4 ao ativar e −2/dia |
| Racionamento | água cai de 8 para 4; comida de 7 para 3 | moral −2 ao ativar e −1/dia | moral −4 ao ativar e −2/dia |

Desligar uma política não custa moral. Cada política cobra seu custo diário
separadamente.

### Protótipo executável

`node prototype/balance-model.mjs --simulate` executa quatro estratégias sobre
dez dias e as **2.520 ordens possíveis** de cinco problemas distintos para a
correção prioritária. Esse modelo confirmado é a entrada numérica da issue #21.

## Agravamento

Todo problema cobra sua perda ao encerrar o dia e reduz o prazo visível. Quando
o prazo chega a zero, aplica uma crise coerente com seu domínio, não uma derrota
universal. O motor pode ser destruído; crises de estoque, conflito, casco ou
comunicações produzem perdas próprias e podem continuar ativas.

Uma crise pode colocar um sobrevivente nomeado em risco. Essa pessoa recebe um
prazo visível; `Socorrer [nome]` a estabiliza, enquanto deixar o prazo chegar a
zero causa sua morte. A perda reduz `A BORDO` e remove o benefício da
especialidade daquela pessoa, mas nunca bloqueia uma intervenção necessária:
a mesma ação continua possível com custo ou risco maior.

## Sobreviventes e fim de jogo

| Situação | Efeito |
| --- | --- |
| Sobrevivente em risco chega ao prazo zero | a pessoa morre e `A BORDO` diminui |
| Sem sobreviventes vivos | derrota imediata — quinta causa, com mensagem própria |
| Oxigênio em zero | derrota imediata |
| Energia em zero | derrota imediata |
| Moral em zero | derrota imediata |
| Motor destruído | derrota imediata |
| Dia final com motor operante e 1 ou mais sobreviventes vivos | vitória |

## Estado do balanceamento

- Calendário, processamento, sete problemas, contenções, correções, recuperação,
  aceleração, políticas e benefícios foram confirmados pelo usuário.
- A issue #21 pode migrar esse contrato integralmente para o sketch.
