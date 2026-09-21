# MENU VICTORY

## Objetivo

Encerrar a partida informando que a nave chegou a Marte. A tela só existe
quando a condição de vitória é atingida: dia final alcançado, motor operante,
pelo menos um sobrevivente vivo e energia, oxigênio e moral acima de zero.
Qualquer derrota de recurso ou condição de término anterior impede a vitória;
em qualquer outro caso a partida termina em [[MENU_GAME_OVER]], com o motivo da
derrota.

## Elementos

| Elemento | Função |
| --- | --- |
| Título | Confirma a chegada à base marciana |
| Resumo da viagem | Dias transcorridos e condição de chegada |
| Sobreviventes | Quantos chegaram vivos, de quantos partiram — Vera, Bento, Neusa e Sílvia, por nome na variação com perdas |
| Recursos finais | Valores textuais restantes de energia, oxigênio, água, comida, peças e moral |
| Mensagem de Marte | Texto da base confirmando o recebimento da nave; usa o nome do técnico |
| Botão "Nova partida" | Volta para o [[MENU_INIT]] |
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

Nenhuma. A tela encerra a partida: não existe continuar jogando depois da
chegada. O botão `NOVA PARTIDA` volta ao `MENU_INIT`.

## Implementação

`drawVictoryScreen` monta a lista de sobreviventes por nome quando houve perdas
(`SOBREVIVENTES: 3 DE 4 — BENTO, NEUSA, SÍLVIA`) e usa `SOBREVIVENTES: 4 DE 4`
quando todos chegaram. A mensagem de Marte ocupa uma linha e usa o nome do
técnico.

- Todos vivos: `MARTE: [NOME], RECEBEMOS OS QUATRO SOBREVIVENTES. A BASE ESTÁ PRONTA.`
- Com perdas: `MARTE: [NOME], RECEBEMOS OS SOBREVIVENTES QUE RESTARAM. A BASE ESTÁ PRONTA.`
- Reparo no limite: `MARTE: [NOME], RECEBEMOS A NAVE. O MOTOR CHEGOU NO LIMITE, MAS VOCÊS CONSEGUIRAM.`

**Reparo no limite** é a solução do motor entregue com o prazo do problema em 1,
ou seja, a uma noite da crise ([[ACTIONS]]). A variação só prevalece quando
houver perdas.

## Referências

- [#11 Roteiro da vinheta, mensagens e textos do jogo](https://github.com/shelldonryan/gtd_example/issues/11)
- [#27 Corrigir desfechos, transmissões e parametrizar portas, escadas, NPCs e HUD](https://github.com/shelldonryan/gtd_example/issues/27)
