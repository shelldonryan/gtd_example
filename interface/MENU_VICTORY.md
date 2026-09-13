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
| Mensagem de Marte | Texto da base confirmando o recebimento da nave; usa o nome do técnico |
| Botão "Nova partida" | Volta para o `MENU_INIT` |
A tela de vitória é o desfecho modal e incorpora a mensagem de Marte; não há
um cartão adicional antes ou depois dela.

## Variações

- **Todos vivos:** `MARTE: [NOME], RECEBEMOS OS QUATRO SOBREVIVENTES. A BASE ESTÁ PRONTA.`
- **Com perdas:** `MARTE: [NOME], RECEBEMOS OS SOBREVIVENTES QUE RESTARAM. A BASE ESTÁ PRONTA.`
- **Reparo no limite:** `MARTE: [NOME], RECEBEMOS A NAVE. O MOTOR CHEGOU NO LIMITE, MAS VOCÊS CONSEGUIRAM.`

`[NOME]` é o nome digitado para o técnico. Se houver perdas e a chegada
acontecer logo após um reparo, prevalece a variação de reparo no limite; o
resumo continua listando os sobreviventes.

## Pendências

- Se a tela permite continuar jogando depois da chegada.
