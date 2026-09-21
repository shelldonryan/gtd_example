# Vera

| Campo | Descrição |
| --- | --- |
| Nome | Vera |
| Papel | Piloto |
| Onde fica | Sala de comando, em ponto fixo junto ao painel de rota |
| Temperamento | Pragmática |
| Função nas ordens | Oferece/confirma as preventivas V-01 e V-02; é responsável por COM-A e COM-B, escolhidas no cartão de incidente |

## Papel no jogo

Vera oferece e confirma as ordens de rota e comunicações:

- `V-01`: calibrar a antena com bobina de transmissão;
- `V-02`: atualizar a rota com cartão de rota;
- `COM-A` e `COM-B`: soluções físicas da falha nas comunicações; são escolhidas
  e confirmadas no cartão de incidente, sem exigir a presença de Vera.

O ponto de Vera é a origem de `V-02`; as demais origens e destinos seguem a
matriz de [[ACTIONS]]. As soluções urgentes atribuídas a ela não exigem sua
presença. Suas ordens não recebem bônus numérico. Se morrer, deixa de oferecer
ordens preventivas; o pool usa sobreviventes vivos.

Sua voz editorial varia por fase da viagem e contexto da ordem; reconhecimento
de resultado aparece uma vez e expira no dia seguinte.

## Vínculos

- Técnico: recebe dele a decisão de mexer ou não na rota ([[PLAYER]]).
- Sobreviventes: viaja com [[NPC_2]], [[NPC_3]] e [[NPC_4]] e responde pela rota de todos.
- Terra: a viagem começa no planeta colapsado que ela deixou para trás.
- Marte: é o destino que ela persegue com números e horas.

## Limitações

- Não anda sozinha: fica no ponto fixo da Sala de comando.
- Não combate e não sai da nave.
- Depende das decisões do técnico para mudar a rota.

## Referências

- [#14 Decisões pendentes: roster, derrota, objetivos das salas e vocabulário](https://github.com/shelldonryan/gtd_example/issues/14)
- [#25 Redesenhar incidentes e ordens como quests físicas](https://github.com/shelldonryan/gtd_example/issues/25)
