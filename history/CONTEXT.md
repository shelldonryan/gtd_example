# Contexto narrativo

## Premissa

A Terra está passando por uma crise ambiental e populacional. O aumento das
temperaturas, a falta de água potável e o esgotamento dos recursos tornaram
diversas regiões inabitáveis. Sem uma solução imediata, a humanidade corre o
risco de entrar em extinção.

Antes do colapso completo, uma base foi construída em Marte para receber uma
pequena população e iniciar uma nova civilização. Uma espaçonave foi preparada
com o que restava de recursos, levando sobreviventes, equipamentos e estoques
essenciais para a viagem.

## Situação inicial

O jogador assume o controle da espacionave logo após a partida. A nave possui
quatro áreas principais:

- Sala de comando.
- Sala de energia, onde fica o motor.
- Depósito.
- Dormitório.
A visão geral da nave é o mapa macro da viagem. Ao selecionar um cômodo nesse
mapa, o jogador entra numa cena 2D lateral própria, com três conveses ligados por
duas escadas.

Dentro do cômodo, o técnico é controlável: pode andar, pular, usar escadas,
atravessar plataformas e interagir com os pontos do cômodo.

Quatro sobreviventes viajam a bordo, além do técnico: **Vera**, a piloto, no
comando; **Bento**, o intendente, no depósito; **Neusa**, a enfermeira, no
dormitório; e **Sílvia**, a mecânica, na sala de energia. Eles ficam parados em
pontos dos cômodos e respondem quando o técnico interage com eles. Não possuem
rotinas autônomas nesta versão.

Os sistemas estão funcionando, mas não foram preparados para uma viagem sem
problemas. A nave precisa economizar energia, controlar os estoques e lidar com
falhas que podem surgir durante o percurso.

## Desenvolvimento da viagem

A viagem é representada por dez dias de jogo. Em cada dia, o técnico explora os
cômodos com movimentação livre e conclui uma tarefa. Cada tarefa é uma cadeia de
poucos passos — falar com um sobrevivente, pegar o item, instalar — e atravessa
mais de um cômodo. Andar, pular, usar escada e cumprir os passos intermediários
não consomem a ação; só a interação que conclui a tarefa usa a única ação do dia.
Depois, o jogador decide quando avançar o tempo. Ao final do dia, a nave consome
água, comida, oxigênio e energia. Eventos como falhas no motor, chuva de
meteoros, falta de comida, conflitos entre os sobreviventes e as falhas de
suporte de vida, de energia e de comunicações podem alterar o estado da missão.

As decisões não possuem uma solução perfeita. Reparar o motor pode gastar as
últimas peças, manter o consumo normal pode deixar os estoques vazios e aplicar
o racionamento pode reduzir a moral. O jogador precisa escolher qual perda é
aceitável para manter a viagem em andamento.

## Objetivo

O objetivo é chegar a Marte com o motor funcionando e pelo menos um sobrevivente
vivo. Para isso, o jogador deve manter energia, oxigênio, água, comida, peças e
moral em níveis suficientes durante os dez dias.

## Narrativa

O jogo apresenta uma situação de sobrevivência e responsabilidade coletiva.
As mensagens e os eventos devem transmitir urgência sem transformar o projeto
em uma história muito extensa. A narrativa será contada principalmente por
avisos do sistema, mensagens da Terra ou de Marte e pelas consequências das
decisões do jogador.

## Escopo

O foco será a viagem, a administração da nave e a exploração controlável dos
cômodos. A visão macro organiza a navegação; as cenas laterais transformam cada
cômodo em um espaço jogável para cumprir os objetivos da viagem.
