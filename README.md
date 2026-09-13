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

A partida representa uma viagem de dez dias. Em cada dia, o jogador entra em um
cômodo, controla o técnico numa cena 2D lateral e conclui uma tarefa. Cada tarefa
é uma cadeia de poucos passos — ir até o lugar, falar com um sobrevivente, pegar
o item, instalar — e passa por mais de um cômodo. Andar, pular, usar escada e
cumprir os passos intermediários não consomem a ação; só a interação que conclui
a tarefa usa a única ação do dia. Depois, o jogador avança o tempo pelo botão
"Passar dia". Ao final do dia, os recursos são consumidos.

O jogador deve equilibrar os seguintes recursos:

- **Energia:** mantêm o motor e os sistemas da nave funcionando.
- **Oxigênio:** garante a sobrevivência das pessoas a bordo.
- **Água:** Consumida pelos sobreviventes.
- **Comida:** Consumida diariamente pelos sobreviventes.
- **Peças:** Utilizadas para reparar o motor e outros sistemas.
- **Moral:** Representa o estado emocional dos sobreviventes e pode afetar a
  capacidade de lidar com problemas.

## Comodos da nave

### Sala de comando

É a sala de leitura da viagem. O técnico acompanha a rota, os recursos e o
briefing do dia no console, e é onde Vera, a piloto, recalcula a rota quando o
jogador decide aumentar a potência. Nenhuma tarefa termina aqui: o dia avança
pelo rodapé.

### Sala de energia

Contém o motor e os controles de energia. Sílvia, a mecânica, dá o diagnóstico
do motor; o técnico instala o reparo na bancada, alinha o reator para aumentar a
potência e liga o modo de economia no painel de distribuição.

### Depósito

Armazena comida, água e peças. Bento, o intendente, entrega as peças do reparo e
a água do socorro, e libera o racionamento. O depósito também guarda o kit de
vedação e o ponto do casco, onde o vazamento é estancado. O racionamento preserva
os estoques, mas reduz a moral dos sobreviventes.

### Dormitório

É onde os sobreviventes descansam. Neusa, a enfermeira, aponta quem está mal e
onde o casco vaza; o técnico organiza o descanso na mesa comum ou leva água ao
sobrevivente que precisa. Descanso e organização recuperam moral, mas custam
energia e fazem o jogador abrir mão das outras tarefas do dia.

## Eventos

- **Falha no motor:** exige peças para o reparo ou aumenta a duração da viagem.
- **Chuva de meteoros:** pode danificar a nave ou consumir energia para ativar
  os escudos.
- **Falta de comida:** permite manter as porções normais ou iniciar o
  racionamento.
- **Conflito no dormitório:** pode ser ignorado ou resolvido com uma ação que
  recupera a moral.

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
