# HUD

## Objetivo

O HUD apresenta recursos, a ordem ativa e a urgência que o jogador precisa
acompanhar enquanto atravessa a nave. A partida tem um objetivo global — chegar
a Marte — e uma decisão concreta por dia.

Nos dias sem incidente, o HUD apoia a comparação de duas ordens preventivas. Nos
dias com incidente, mostra a solução física escolhida e o problema que permanece
caso ela não seja concluída.

## Informações exibidas

| Elemento | Como aparece | Função |
| --- | --- | --- |
| Dia da viagem | cartão de texto | mostra o dia atual e o total de dias da viagem |
| A bordo | cartão de texto | quantos sobreviventes vivos; o técnico não entra na conta |
| Energia | ícone, número e barra | estoque que mantém o motor e os sistemas |
| Oxigênio | ícone, número e barra | margem de sobrevivência da tripulação |
| Água | ícone, número e barra | quantidade de água |
| Comida | ícone, número e barra | quantidade de comida armazenada |
| Peças | ícone e número | quantas peças podem ser usadas em ordens técnicas |
| Moral | ícone, número e barra | estado emocional dos sobreviventes |
| Ordem ativa | faixa textual e marcador | estágio, responsável, objeto, origem, destino, recompensa ou resultado e perda |
| Problema urgente | faixa textual compacta | menor prazo, sala responsável e quantidade de outros problemas |

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
| Centro | sala 2D jogável usando toda a largura |
| Faixa de ordem | estágio, responsável, objeto, origem, destino, recompensa ou resultado e perda da ordem ativa |
| Faixa de urgência | problema com menor prazo e quantidade dos demais |
| Rodapé | botão `MAPA` e orientação de controles |
| Sobreposição | ordens, mapa, diálogos, incidentes e resumo ao dormir |

O mapa abre pelo botão `MAPA`, mostra `VOCÊ ESTÁ AQUI`, a ordem ativa e todas as
salas afetadas. Fechá-lo retorna à mesma sala e posição.

## Controles de alto nível

### Mapa

O botão `MAPA` abre uma sobreposição consultável. Clicar num cômodo mostra
ocupante, sistemas e todos os problemas locais. Cada problema informa perda
diária, prazo restante e consequência da crise. O clique nunca transporta o
técnico.

### Diálogos e ordens

- Diálogos de NPC avançam com `ENTER` ou clique em `CONTINUAR (ENTER)`.
- Nos dias sem incidente, o cartão compara duas ofertas do pool com
  responsável, objeto, origem, destino, recompensa e perda.
- A ordem escolhida é confirmada presencialmente com o sobrevivente responsável.
  Depois da confirmação, ela não pode ser cancelada.
- Nos dias com incidente, o cartão mostra duas soluções físicas com responsável,
  custo, objeto, origem, destino, resultado e `SE FALHAR`: problema ativo, perda,
  prazo e crise. A solução escolhida deve ser executada.
- A faixa da ordem ativa mostra `COLETAR` ou `ENTREGAR`; a entrega só aplica o
  resultado depois da confirmação.
- O objeto só existe como parte de uma ordem aceita e pode ser carregado um por
  vez. Recursos comuns são pagos ou recebidos no destino.

Os botões dos modais repetem o atalho no rótulo: `FECHAR (ESC)`, `VOLTAR (ESC)`,
`CONFIRMAR (ENTER)`, `ACEITAR ORDEM (ENTER)`, `ENTREGAR (ENTER)` e o botão de
dormir. O botão de pausa é `CONTINUAR (ESC)`.

### Encerrar o dia
Não existe botão persistente `Passar dia`. O técnico precisa chegar ao próprio
beliche no Dormitório e interagir. Antes de dormir, o resumo modal mostra:

1. consumo previsto dos recursos;
2. recompensa ou perda da ordem preventiva, se houver;
3. etapa e resultado da ordem ativa, ou ausência de ordem;
4. problemas ativos, prazos e crises iminentes;
5. confirmação para dormir e opção de voltar.

Dormir com uma preventiva aceita e incompleta mostra a perda, devolve o objeto à
origem e encerra a ordem. Dormir com uma solução urgente incompleta mantém o
problema sem penalidade adicional; a mesma solução reaparece como retomada nos
dias seguintes. Os valores e a ordem do processamento estão em `mechanics/ACTIONS.md`.

## Estados da interface

- **Salas de interior:** o Comando é o hub; Dormitório, Depósito e Máquinas
  ligam-se somente a ele.
- **Ofertas de ordem:** duas ordens preventivas comparáveis nos dias sem
  incidente; apenas uma pode ser aceita presencialmente.
- **Diálogo de confirmação:** retrato e caixa inferior; confirma a ordem ao
  encontrar o sobrevivente responsável.
- **Painel técnico:** caixa inferior sem retrato para custos, resultados, coleta,
  entrega, risco e resumo do fim do dia.
- **Coleta:** mostra o objeto, sua finalidade e o destino; confirmar guarda o
  item.
- **Entrega:** mostra recompensa, custo, resultado ou problema resolvido antes
  de aplicar.
- **Mapa:** preserva sala e posição e marca origem, destino e problemas.
- **Incidente:** modal técnico com duas soluções físicas; bloqueia exploração
  até a escolha e confirmação.
- **Falha de preventiva:** exibe a perda do recurso protegido e devolve o objeto
  à origem ao dormir.
- **Transmissão e desfecho:** permanecem modais.

## Avisos

Um recurso em vermelho (de 1 a 29) avisa por três canais ao mesmo tempo: a cor,
um **ícone de aviso** ao lado do número e a **borda do cartão piscando** (meio
segundo aceso, meio apagado). A cor sozinha deixa quem não a distingue sem
nenhuma pista.

Alertas críticos usam os cartões de recurso: cor, ícone de aviso e borda
piscando. A faixa de urgência mostra:

1. problema ativo com menor prazo;
2. prazo restante;
3. sala onde a intervenção deve ocorrer;
4. quantidade de outros problemas ativos.

Exemplo: `MOTOR DANIFICADO — 2 DIAS — MÁQUINAS | +2 PROBLEMAS`.

Se dois problemas tiverem o mesmo prazo, permanece em destaque o que foi
ativado primeiro. A ordem não muda quando o jogador troca de sala.

O mapa contém a comparação completa. A ficha da sala mostra, para cada problema,
a perda diária, o prazo e a consequência quando ele chegar a zero. Para dano no
casco, a ficha pertence ao cômodo que contém o local alcançável sorteado naquela
ocorrência. A estrutura e os valores numéricos estão em `mechanics/ACTIONS.md`.
