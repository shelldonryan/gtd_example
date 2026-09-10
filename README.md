# Last Horizon

## Visao geral

Last Horizon é um jogo 2D de gerenciamento de recursos. 

O jogador assume o papel de um técnico responsével por uma espaconave que transporta os últimos sobreviventes da Terra para uma base em Marte.

A Terra está passando por uma crise ambiental e populacional, com os recursos
do planeta se esgotando, a viagem até Marte é necessária para a sobrevivência da humanidade. 

Durante o percurso, o jogador precisa manter a nave funcionando, administrar os estoques e tomar decisões diante de problemas.

## Genero e perspectiva

- Gerenciamento de recursos
- Sobrevivencia
- Jogo 2D
- Visao lateral da espaconave
- Interface com indicadores de recursos
- Nave dividida em comodos interativos

## Mecanica principal

A partida representa uma viagem de dez dias. Em cada dia, o jogador pode
visitar os comodos da nave, realizar uma ação e avançar o tempo pelo botão
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

É a tela principal de gerenciamento. O jogador vê os recursos,
verifica o dia atual, acompanha a distância atá Marte e decide quando avançar
para o proximo dia.

### Sala de controle de energia

Contêm o motor e os principais controles de energia da espaconave. O jogador
pode reparar o motor usando peças, ativar um modo de economia ou aumentar a
potência para tentar reduzir o tempo da viagem.

### Depósito

Armazena comida, água e peças. O jogador pode escolher entre
manter o consumo normal ou aplicar racionamento. O racionamento preserva os
estoques, mas reduz a moral dos sobreviventes.

### Dormitório

Representa o espaço de descanso dos passageiros. Ações de descanso e
organização podem recuperar parte da moral, mas consomem energia e fazem o
jogador abrir mão de outras atividades naquele dia.

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
chegue a zero ou a nave fique sem energia para continuar a viagem.

## Escopo da primeira versão

O protótipo sera desenvolvido com quatro cômodos, quatro sobreviventes, seis
recursos e uma viagem de dez dias.

O objetivo é garantir uma versão em duas semanas, com
foco na navegação entre telas, no controle dos recursos e nas consequências
das decisões.

## Referências

- Fallout Shelter
- Jogos 2D de gerenciamento e sobrevivencia
