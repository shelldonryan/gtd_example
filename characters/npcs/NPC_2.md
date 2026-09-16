# Bento

| Campo | Descrição |
| --- | --- |
| Nome | Bento |
| Papel | Intendente |
| Onde fica | Depósito, em ponto fixo junto aos estoques |
| Temperamento | Ranzinza; guarda o estoque a sete chaves |
| Função nas ordens | Oferece e confirma B-01, B-02, FOOD-A e FOOD-B |

## Papel no jogo

Bento oferece e confirma as ordens de estoque e logística:

- `B-01`: reforçar a reserva com caixa de provisões;
- `B-02`: separar peças de emergência com chave de torque;
- `FOOD-A` e `FOOD-B`: soluções físicas da falta de comida.

Ele pode ser a origem ou o destino de uma ordem. O objeto só aparece quando
pertence à ordem aceita; não entrega recursos comuns fora da etapa de entrega.
Se morrer, deixa de oferecer ordens; o pool validado usa os sobreviventes vivos.

## Vínculos

- Técnico: só solta o estoque depois que ele decide o que priorizar.
- Sobreviventes: responde pelo que Vera, Neusa e Sílvia consomem na viagem.
- Terra: o estoque que ele guarda foi carregado no planeta que ficou para trás.
- Marte: guarda o suficiente para a nave chegar à base.

## Limitações

- Não anda sozinho: fica no ponto fixo do Depósito.
- Não combate e não sai da nave.
- Depende das decisões do técnico para abrir ou segurar o estoque.
