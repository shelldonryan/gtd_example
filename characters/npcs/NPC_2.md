# Bento

| Campo | Descrição |
| --- | --- |
| Nome | Bento |
| Papel | Intendente |
| Onde fica | Depósito, em ponto fixo junto aos estoques |
| Temperamento | Ranzinza; guarda o estoque a sete chaves |
| Função nas ordens | Oferece/confirma as preventivas B-01 e B-02; é responsável por FOOD-A e FOOD-B, escolhidas no cartão de incidente |

## Papel no jogo

Bento oferece e confirma as ordens de estoque e logística:

- `B-01`: reforçar a reserva com caixa de provisões;
- `B-02`: separar peças de emergência com chave de torque;
- `FOOD-A` e `FOOD-B`: soluções físicas da falta de comida; são escolhidas e
  confirmadas no cartão de incidente, sem exigir a presença de Bento.

O ponto de Bento é o destino de `B-02`; as demais origens e destinos seguem a
matriz de [[ACTIONS]]. As soluções urgentes atribuídas a ele não exigem sua
presença. O objeto só aparece quando pertence à ordem aceita; ele não entrega
recursos comuns fora da etapa de entrega. Se morrer, deixa de oferecer ordens
preventivas; o pool usa sobreviventes vivos.

Sua voz editorial varia por fase da viagem e contexto do estoque; reconhecimento
de resultado aparece uma vez e expira no dia seguinte.

## Vínculos

- Técnico: só solta o estoque depois que ele decide o que priorizar ([[PLAYER]]).
- Sobreviventes: responde pelo que [[NPC_1]], [[NPC_3]] e [[NPC_4]] consomem na viagem.
- Terra: o estoque que ele guarda foi carregado no planeta que ficou para trás.
- Marte: guarda o suficiente para a nave chegar à base.

## Limitações

- Não anda sozinho: fica no ponto fixo do Depósito.
- Não combate e não sai da nave.
- Depende das decisões do técnico para abrir ou segurar o estoque.

## Referências

- [#14 Decisões pendentes: roster, derrota, objetivos das salas e vocabulário](https://github.com/shelldonryan/gtd_example/issues/14)
- [#25 Redesenhar incidentes e ordens como quests físicas](https://github.com/shelldonryan/gtd_example/issues/25)
