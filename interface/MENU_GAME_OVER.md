# MENU GAME OVER

## Objetivo

Encerrar a partida informando **qual** falha acabou com a viagem.

## Condições

Oxigênio em zero, energia em zero, moral em zero, motor destruído ou nenhum sobrevivente vivo.

## Elementos

| Elemento | Função |
| --- | --- |
| Motivo | o nome da falha que encerrou a viagem |
| Mensagem | uma linha fechando aquela falha |
| Resumo | dia alcançado, sobreviventes vivos e distância até Marte |
| Botão "Nova partida" | volta ao MENU INIT |

## Regras

- A tela de derrota é um desfecho modal e informa a causa sem mensagem adicional de Marte.
- A mensagem muda conforme a causa:

| Causa | Título | Mensagem |
| --- | --- | --- |
| Oxigênio em zero | OXIGÊNIO ZERO | `O OXIGÊNIO ACABOU ANTES DA CHEGADA.` |
| Energia em zero | ENERGIA ZERO | `SEM ENERGIA, A NAVE NÃO PÔDE SEGUIR.` |
| Moral em zero | MORAL ZERO | `A MORAL CAIU A ZERO. O GRUPO NÃO RESISTIU À VIAGEM.` |
| Motor destruído | MOTOR DESTRUÍDO | `O MOTOR FOI DESTRUÍDO ANTES DE MARTE.` |
| Nenhum sobrevivente vivo | SOBREVIVENTES PERDIDOS | `NENHUM SOBREVIVENTE RESTOU A BORDO.` |

## Pendências

- Se a derrota mostra os sobreviventes ou apenas a contagem.
