# HUD

## Objetivo

O HUD apresenta as informações necessárias para o jogador
acompanhar o estado da espaçonave. Ele deve ser simples e legível, e continua
visível dentro dos cômodos, enquanto o técnico anda, pula, usa escadas e
interage.

## Informações exibidas

| Elemento | Como aparece | Função |
| --- | --- | --- |
| Dia da viagem | cartão de texto | mostra o dia atual e o total de dias da viagem |
| A bordo | cartão de texto | quantos sobreviventes vivos; o técnico não entra na conta |
| Energia | ícone, número e barra | estoque que mantém o motor e o suporte de vida |
| Oxigênio | ícone, número e barra | tempo de sobrevivência possível no espaço |
| Água | ícone, número e barra | quantidade de água |
| Comida | ícone, número e barra | quantidade de comida armazenada |
| Peças | ícone e número | quantas peças podem ser usadas em reparos |
| Moral | ícone, número e barra | estado emocional dos sobreviventes |
| Mensagem do sistema | texto no painel da direita | eventos, avisos e o resultado das ações |

## Barras de recursos

Cada recurso de barra tem valor entre 0 e 100.

- **Verde:** recurso seguro, entre 60 e 100.
- **Amarelo:** recurso em atenção, entre 30 e 59.
- **Vermelho:** recurso crítico, entre 1 e 29.
- **Vazio:** recurso em zero e com risco de derrota.

As peças são uma contagem numérica, sem barra.

## Ícones

Os seis recursos usam **ícones de 16×16** na paleta do HUD — energia, oxigênio,
água, comida, peças e moral. O cartão do recurso passa a ser ícone + número
(+ barra), **sem rótulo de texto**: só DIA e A BORDO têm rótulo. Os ícones entram
no inventário de assets.

## Onde cada elemento fica

| Zona | Conteúdo |
| --- | --- |
| Topo | dia, quantos estão a bordo e os seis indicadores de recurso |
| Coluna direita | painel de alertas e eventos |
| Centro | o mapa macro da nave, ou a cena 2D jogável do cômodo aberto |
| Rodapé | "Passar dia" e o botão de voltar |

O cartão de evento ocupa o painel da direita, e a tela de trás continua visível.

## Botões

### Passar dia

Avanca a viagem em um dia. O botão fica no rodapé, acionado com o mouse. Ao ser
acionado:

1. Os recursos são consumidos.
2. A moral é atualizada.
3. O numero do dia é atualizado.
4. O jogo verifica as condições de vitoria e derrota.
5. O dia seguinte abre com o evento sorteado, em cartão sobre a tela.

Não existe tecla para passar o dia: é uma ação que fecha o dia e não deve
acontecer por engano.

### Voltar para a nave

Retorna da visualização de um comodo para a tela geral da espaconave. Também é
botão de rodapé, com o mouse.

Cada cômodo é uma área clicável no mapa macro. Ao clicar nele, o jogador
entra na cena correspondente; a execução da tarefa acontece pela
movimentação e pela interação do técnico, não apenas por botões.
Os pontos de interação de cada cômodo estão em `interface/ROOMS.md`.

## Estados da interface

- **Visão da nave:** mostra o mapa macro e permite escolher um cômodo.
- **Salas de interior:** mostram uma cena 2D jogável, o técnico controlável,
  três conveses ligados por duas escadas, pontos de interação e o briefing do dia.
- **Evento:** mostra uma mensagem e as alternativas disponíveis; bloqueia a
  exploração até ser respondido.
- **Vitória:** informa que a nave chegou a Marte.
- **Derrota:** informa qual recurso ou sistema causou o fim da viagem.

## Avisos

Um recurso em vermelho (de 1 a 29) avisa por três canais ao mesmo tempo: a cor,
um **ícone de aviso** ao lado do número e a **borda do cartão piscando** (meio
segundo aceso, meio apagado). A cor sozinha deixa quem não a distingue sem
nenhuma pista.

Quando um sistema estiver em estado crítico, a mensagem do sistema pode exibir
instruções diretas, como:

- `Oxigênio crítico: verifique os sistemas.`
- `Motor danificado: use 2 peças no reparo.`
- `Moral baixa: visite o dormitório para recuperar os sobreviventes.`

Os textos definitivos são do ticket de roteiro e textos.
