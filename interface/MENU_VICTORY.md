# MENU VICTORY

## Objetivo

Encerrar a partida informando que a nave chegou a Marte. A tela só existe
quando a condição de vitória é atingida: dia final alcançado, motor operante e
pelo menos um sobrevivente vivo. Qualquer outra combinação cai no
`MENU_GAME_OVER`, com o motivo da derrota.

## Elementos

| Elemento | Função |
| --- | --- |
| Título | Confirma a chegada à base marciana |
| Resumo da viagem | Dias transcorridos e dias ganhos com "Aumentar potência" |
| Sobreviventes | Quantos chegaram vivos, de quantos partiram — Vera, Bento, Neusa e Sílvia, por nome na variação com perdas |
| Recursos finais | Barras restantes e peças |
| Mensagem de Marte | Texto da base confirmando o recebimento da nave |
| Botão "Nova partida" | Volta para o `MENU_INIT` |

## Variações

- **Todos vivos:** a mensagem fecha o arco da missão — os quatro sobreviventes
  reconstroem a humanidade em Marte.
- **Com perdas:** a mesma chegada, com a lista de quem não sobreviveu entre Vera,
  Bento, Neusa e Sílvia. A vitória não é escondida nem penalizada; o desfecho só
  reconhece o preço.
- **Motor reparado no limite:** quando a chegada acontece logo depois de um
  reparo, a mensagem de Marte menciona o estado da nave.

## Pendências

- Texto definitivo de cada variação.
- Se a tela permite continuar jogando depois da chegada.
