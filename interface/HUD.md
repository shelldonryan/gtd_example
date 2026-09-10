# HUD

## Objetivo

O HUD apresenta as informações necessárias para o jogador
acompanhar o estado da espaçonave. Ele deve ser simples e legível.

## Informacoes exibidas

| Elemento            | Funcao                                                   |
| ------------------- | -------------------------------------------------------- |
| Dia da viagem       | Mostra o dia atual e o total de dias da viagem           |
| Sobreviventes       | Mostra a quantidade de pessoas vivas na nave             |
| Energia             | Indica a quantidade de combustível para funcionar a nave |
| Oxigênio            | Indica o tempo de sobrevivência possivel no espaço       |
| água                | Mostra a quantidade de água                              |
| Comida              | Mostra a quantidade de comida armazenada                 |
| Peças               | Mostra quantas peças podem ser usadas em reparos         |
| Moral               | Indica o estado emocional dos sobreviventes              |
| Mensagem do sistema | Exibe eventos, avisos e o resultado das ações            |

## Barras de recursos

Cada recurso deve ser representado por uma barra com valor entre 0 e 100.

- **Verde:** recurso seguro, entre 60 e 100.
- **Amarelo:** recurso em atenção, entre 30 e 59.
- **Vermelho:** recurso crítico, entre 1 e 29.
- **Vazio:** recurso em zero e com risco de derrota.

As peças será uma contagem numérica

## Botões

### Passar dia

Avanca a viagem em um dia. O botão deve ficar na inferior da tela. Ao ser acionado:

1. Os recursos são consumidos.
2. A moral é atualizada.
3. Um evento pode ser sorteado.
4. O numero do dia é atualizado.
5. O jogo verifica as condições de vitoria e derrota.

### Voltar para a nave

Retorna da visualização de um comodo para a tela geral da espaconave.

### Abrir comodo

Cada comodo é uma área clicável na nave. Ao clicar nele, o
jogador visualiza a sala correspondente e suas ações disponíveis.

## Estados da interface

- **Visao da nave:** mostra os quatro comodos e permite escolher uma sala.
- **Sala de comando:** mostra o mapa da viagem e o botão para passar o dia.
- **Sala de energia:** mostra o motor e as ações de reparo ou economia.
- **Depósito:** mostra os estoques e as opções de racionamento.
- **Dormitório:** mostra os sobreviventes e as ações relacionadas a moral.
- **Evento:** mostra uma mensagem e as alternativas disponíveis.
- **Vitória:** informa que a nave chegou a Marte.
- **Derrota:** informa qual recurso ou sistema causou o fim da viagem.

## Avisos

Quando um recurso estiver baixo, o HUD deve destacar o indicador usando uma
cor de alerta. Quando um sistema estiver em estado crítico, a mensagem do
sistema pode exibir instruções diretas, como:

- `Oxigênio crítico: verifique a sala de controle.`
- `Motor danificado: utilize peças para realizar o reparo.`
- `Moral baixa: visite o dormitório para recuperar os sobreviventes.`