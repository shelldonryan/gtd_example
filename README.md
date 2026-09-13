# Last Horizon

## Visao geral

Last Horizon é um jogo 2D de gerenciamento de recursos e exploração em plataformas.

O jogador assume o papel de um técnico responsével por uma espaconave que transporta os últimos sobreviventes da Terra para uma base em Marte.

A Terra está passando por uma crise ambiental e populacional, com os recursos
do planeta se esgotando, a viagem até Marte é necessária para a sobrevivência da humanidade. 

Durante o percurso, o jogador precisa manter a nave funcionando, administrar os estoques e tomar decisões diante de problemas.

## Genero e perspectiva

- Gerenciamento de recursos
- Sobrevivência
- Exploração 2D em plataforma
- Visão macro da espaçonave como mapa
- Cômodos laterais exploráveis
- Interface com indicadores de recursos

## Mecanica principal

A partida representa uma viagem de dez dias por quatro cômodos conectados. O
técnico atravessa portas, consulta o mapa sem ser transportado e escolhe
explicitamente uma tarefa no console da Sala de comando. O painel mostra custo,
efeito e rota antes da confirmação.

Cada tarefa tem etapas concretas — conversar, coletar e executar a ação final.
Somente a ação final usa a tarefa do dia. Para encerrar o dia, o técnico retorna
ao próprio beliche no Dormitório, confere o consumo previsto e confirma.

O jogador deve equilibrar os seguintes recursos:

- **Energia:** mantém o motor e os sistemas da nave funcionando.
- **Oxigênio:** garante a sobrevivência das pessoas a bordo.
- **Água:** Consumida pelos sobreviventes.
- **Comida:** Consumida diariamente pelos sobreviventes.
- **Peças:** Utilizadas para reparar o motor e outros sistemas.
- **Moral:** Representa o estado emocional dos sobreviventes e pode afetar a
  capacidade de lidar com problemas.

## Comodos da nave

### Sala de comando

É a sala de leitura da viagem. O técnico acompanha a rota, os recursos e o
briefing do dia no console. Vera, a piloto, recalcula a rota em "aumentar
potência", dá o diagnóstico das comunicações e entrega o cabo de derivação de
uma das variantes de energia. A antena, no convés de cima, é onde o reparo das
comunicações é concluído.

### Sala de energia

Contém o motor, o reator, o painel de distribuição e o painel de suporte de vida.
Sílvia, a mecânica, dá o diagnóstico do motor, do suporte de vida e do sistema de
energia; o técnico instala o reparo na bancada, alinha o reator para aumentar a
potência, liga o modo de economia e troca o fusível no painel de distribuição.

### Depósito

Armazena comida, água e peças. Bento, o intendente, entrega as peças do reparo do
motor e do suporte de vida, a peça das comunicações, o fusível reserva e a água
do socorro, e libera o racionamento. O depósito também guarda o kit de vedação e
o ponto do casco, onde o vazamento é estancado. O racionamento preserva os
estoques, mas reduz a moral dos sobreviventes.

### Dormitório

É onde os sobreviventes e o técnico descansam. Neusa, a enfermeira, aponta quem
está mal e onde o casco vaza, e entrega o cartucho refrigerante de uma das
variantes de energia. A mesa comum conclui `Descanso e organização`; o beliche
do sobrevivente recebe a água de socorro; o beliche do técnico mostra o consumo
previsto e encerra o dia após confirmação.

## Eventos

- **Falha no motor:** exige peças para o reparo ou aumenta a duração da viagem.
- **Chuva de meteoros:** pode danificar a nave ou consumir energia para ativar
  os escudos.
- **Falta de comida:** permite manter as porções normais ou iniciar o
  racionamento.
- **Conflito no dormitório:** pode ser ignorado ou resolvido com uma ação que
  recupera a moral.
- **Falha no suporte de vida:** reparar com peças ou operar em emergência, que
  gasta energia na hora e consome mais oxigênio por dia até o reparo.
- **Falha no sistema de energia:** forçar a rede ou desligar setores; as duas
  mantêm a falha ativa, que drena energia por dia até o reparo com uma das três
  variantes.
- **Falha nas comunicações:** reparar com uma peça ou seguir em silêncio, que
  custa moral por dia até o conserto.

Os eventos são sorteados de um pool uniforme, sem repetir o anterior, e uma
falha que já está ativa não volta ao sorteio.

Cada evento deve apresentar pelo menos duas alternativas com consequências
diferentes. Dessa forma, o jogador nao apenas reage aos problemas, mas decide
 qual recurso esta disposto a sacrificar.

## Condições de término

### Vitória

O jogador vence ao chegar ao décimo dia com o motor funcionando e pelo menos
um sobrevivente vivo.

### Derrota

O jogador perde caso o oxigênio chegue a zero, o motor seja destruído, a moral
chegue a zero, a nave fique sem energia para continuar a viagem ou não reste
nenhum sobrevivente vivo a bordo.

## Escopo da primeira versão

O protótipo sera desenvolvido com quatro cômodos, quatro sobreviventes a bordo
(além do técnico controlado pelo jogador), seis recursos e uma viagem de dez dias.

O objetivo é garantir uma versão em duas semanas, com foco na navegação entre o
mapa macro e os cômodos, no controle direto do técnico, no controle dos
recursos e nas consequências das decisões.

## Referências

- Fallout Shelter
- Jogos 2D de gerenciamento e sobrevivencia
