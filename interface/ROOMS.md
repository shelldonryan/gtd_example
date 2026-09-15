# Cômodos jogáveis

Os quatro cômodos formam uma topologia em estrela inspirada na composição
lateral de `COMMAND_ROOM_CONCEPT_ART.png`. A Sala de comando é o hub central:
uma porta por convés leva ao Dormitório, ao Depósito e à Sala de máquinas. As
três salas periféricas não possuem portas entre si. O mapa é apenas consultável.

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
| Coleta | não | põe um componente especial na mão e mostra aviso breve |
| Conversa | sim | abre retrato e caixa inferior do sobrevivente |
| Interruptor | sim | explica a consequência e pede confirmação |
| Intervenção principal | não | cobra o custo, remove ou altera o estado e usa a intervenção do dia |
| Porta | não | troca entre o Comando e uma sala periférica |

Regras que valem em todos os cômodos:

- Alcance de interação de 12 px, na mesma altura, e o ponto se destaca quando o
  técnico entra no alcance.
- O técnico carrega **um componente especial por vez**. Recursos comuns do HUD
  são pagos diretamente no ponto da intervenção e não viram itens carregados.
- Diagnóstico, conversa, coleta de componente especial e mudança de política não
  gastam a intervenção principal.
- Uma correção, recuperação ou aceleração concluída usa a intervenção do dia.
- Problemas não corrigidos atravessam o dia, aplicam perdas e reduzem seus prazos.
- Cada dano no casco cria um ponto de correção temporário em um local aleatório
  alcançável pelo jogador, em qualquer um dos quatro cômodos.
- O mapa não altera sala, posição, problemas ou componente carregado.
- Indicações usam ações concretas, nunca termos internos.

## Sala de comando

O cômodo é o hub físico e concentra navegação e comunicações. Não existe console
de aceite diário nem conversa obrigatória com Vera.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| superior | porta do Dormitório | porta |
| superior | Vera — navegação, comunicações e benefício de piloto | conversa |
| superior | antena — correção das comunicações | intervenção principal |
| médio | porta do Depósito | porta |
| médio | console da rota — jornada, previsão e aumento de potência | leitura técnica e intervenção principal |
| inferior | porta da Sala de máquinas | porta |
| inferior | painel de situação — visão geral dos problemas | leitura técnica |

No primeiro dia, o técnico começa no Comando. Nos demais, chega ao hub pela
porta superior vinda do Dormitório. `Aumentar potência` elimina um dia futuro
completo, incluindo consumo e eventual incidente daquele dia.

## Sala de máquinas

O cômodo concentra motor, energia e suporte de vida.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | bancada do motor — correção do motor | intervenção principal |
| médio | Sílvia — diagnóstico e benefício de mecânica | conversa |
| médio | painel de distribuição — falha elétrica e modo economia | intervenção principal e política |
| superior | reator — potência do sistema | leitura técnica |
| superior | painel de suporte de vida | intervenção principal |
| acesso | porta única para o convés inferior do Comando | porta |

## Depósito

O cômodo concentra logística, estoques, componentes especiais e racionamento.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | componentes especiais, incluindo kit de vedação e fusível | coleta |
| médio | Bento — leitura dos estoques e benefício de intendente | conversa |
| médio | alavanca de racionamento | política |
| médio | estoque de comida — correção da falta de comida | intervenção principal |
| superior | prateleira de reserva — componentes disponíveis | leitura técnica |
| acesso | porta única para o convés médio do Comando | porta |

## Dormitório

O cômodo concentra descanso, saúde, moral e encerramento do turno.

| Convés | Ponto | Tipo |
| --- | --- | --- |
| inferior | beliche temporário `SOCORRER [NOME]` de sobrevivente em risco | intervenção principal de socorro |
| médio | Neusa — estado do grupo e benefício de enfermeira | conversa |
| médio | mesa do grupo — mediação do conflito | intervenção principal |
| superior | mesa comum — `Cuidar do grupo` | intervenção principal de recuperação |
| superior | beliche do técnico — resumo e dormir | leitura técnica e encerramento |
| acesso | porta única para o convés superior do Comando | porta |

## Intervenções

Problemas já nascem ativos após os incidentes; não são aceitos numa lista. HUD e
mapa indicam a sala afetada, e os pontos relacionados respondem imediatamente.

As sequências variam. Um passo existe somente para descobrir informação, obter
um componente especial ou aplicar a correção. Não há obrigação universal de
falar com NPC ou trocar de cômodo.

| Intervenção | Tipo | Onde conclui |
| --- | --- | --- |
| Reparar motor | correção | bancada do motor, Máquinas |
| Aumentar potência | aceleração | console da rota, Comando |
| Reparar casco | correção | local aleatório alcançável indicado pelo problema |
| Cuidar do grupo | recuperação | mesa comum, Dormitório |
| Socorrer sobrevivente | recuperação | beliche da pessoa em risco, Dormitório |
| Reparar suporte de vida | correção | painel de suporte, Máquinas |
| Reparar sistema de energia | correção | painel de distribuição, Máquinas |
| Reparar comunicações | correção | antena, Comando |
| Reorganizar comida | correção | estoque de comida, Depósito |
| Mediar conflito | correção | mesa do grupo, Dormitório |

O painel de distribuição atende as duas funções: quando a falha elétrica está
ativa, a interação abre as opções de reparo e de economia no mesmo painel; sem a
falha, alterna apenas a economia.

Economia e racionamento são políticas persistentes locais. Não usam a
intervenção principal, mas cobram moral ao ativar e em cada dia mantidas.

Uma crise pode colocar Vera, Bento, Neusa ou Sílvia em risco. Socorrer estabiliza
a pessoa; a morte remove o benefício da especialidade, mas não bloqueia nenhuma
ação necessária.

O beliche de socorro só aparece enquanto existe uma pessoa em risco e usa o nome
dela no rótulo. A pessoa segue a seleção determinística do modelo aprovado. Com
mais de um risco, mostra o menor prazo e, em empate, o mais antigo; depois do
socorro, passa ao próximo. O ponto não cria um quinto personagem nem fixa novos
beliches no layout.

## Leitura do jogador

O HUD mostra o problema com menor prazo e quantos outros existem. O mapa agrupa
todos por sala; cada ficha mostra perda diária, prazo e consequência da crise.
Quando o dano no casco estiver ativo, ele pertence ao cômodo sorteado para
aquela ocorrência, não ao Depósito por definição.
O jogador escolhe sua prioridade pelo deslocamento e pela intervenção, não por
um aceite abstrato.

O sketch implementa a topologia em hub, os pontos de intervenção e o dano no
casco aleatório e alcançável nos três conveses de qualquer um dos quatro
cômodos. `tasks.pde` mantém problemas persistentes, componentes especiais,
políticas, riscos individuais e intervenções sem briefing ou tarefa singular.
