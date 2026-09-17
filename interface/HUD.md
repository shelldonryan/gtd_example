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
água, comida, peças e moral. Cada cartão mostra **ícone + número + rótulo de
texto** — `ENERGIA`, `OXIGÊNIO`, `ÁGUA`, `COMIDA`, `PEÇAS`, `MORAL` — e, nos
recursos de barra, a barra de preenchimento. O rótulo é texto provisório: o
inventário [#8](https://github.com/shelldonryan/gtd_example/issues/8) troca os
ícones geométricos por assets do Aseprite, sem mudar o restante do cartão.

## Onde cada elemento fica

| Zona | Conteúdo |
| --- | --- |
| Topo | dia, quantos estão a bordo e os seis indicadores de recurso |
| Centro | sala 2D jogável usando toda a largura |
| Faixa de ordem | estágio, responsável, objeto, origem, destino, recompensa ou resultado e perda da ordem ativa |
| Faixa de urgência | problema com menor prazo e quantidade dos demais |
| Rodapé | botões `MAPA`, `ORDENS` e `?`; `!` pulsante quando há oferta ou retomada |
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

O botão `ORDENS` reabre as duas ofertas antes do aceite ou a ficha completa da
quest ativa. Nos dias sem incidente, `OFERTAS / PRÓXIMA RETOMADA` percorre as
soluções pendentes com seus prazos atuais. Nenhum desses botões move o técnico.

O início do jogo e os dias sem incidente não abrem o modal automaticamente.
O botão mostra `!` pulsando suavemente em tamanho e cor, com ciclo de 1,4 s,
enquanto houver oferta/retomada disponível e nenhuma seleção ou quest em curso.
Consultar e fechar sem escolher mantém o aviso; selecionar uma ordem o remove.
Cartões obrigatórios de incidentes continuam abrindo normalmente.
O círculo e a exclamação formam um selo único: os dois crescem e mudam de cor
juntos, na mesma proporção; o glifo nunca fica parado enquanto o círculo pulsa.
A exclamação é desenhada como geometria — barra e ponto — e fica centrada no
círculo por construção, sem depender da métrica da fonte.

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

### Ajuda

O botão `?` do rodapé abre um modal `AJUDA — CONTROLES` com a lista de teclas e
botões, fechado por `FECHAR (ESC)`, clique ou `ESC`. A dica de teclas fixa que
antes ocupava o rodapé saiu: o rodapé tem apenas `MAPA`, `ORDENS` e `?`.

### Faixa de ordem e urgência

A faixa inferior tem quatro linhas fixas, para o jogador não precisar reler a
tela a cada quadro:

1. `[ESTÁGIO]: [objeto] | RESPONSÁVEL: [nome]` — ou `CONFIRMAR COM [nome] EM [ponto] | OBJETO: [objeto]` antes do aceite;
2. `COLETA: [ponto (sala)] | ENTREGA: [ponto (sala)]`;
3. `[RECOMPENSA: +n] ou [CUSTO: -n] | SE FALHAR: [perda; prazo; crise]`;
4. problema mais urgente, prazo, sala, quantidade dos demais e pessoa em risco — ou a mensagem de sistema em vigor.

Sem ordem ativa, as duas primeiras linhas exibem o estado da quest do dia
(`NENHUMA ORDEM ATIVA — COMPARE AS DUAS OFERTAS EM ORDENS`, `UMA QUEST POR DIA.
ACEITA: NÃO PODE SER CANCELADA.`).

### Transmissões

Uma transmissão da Terra ocupa o centro da tela com título, texto e
`CONTINUAR (ENTER)`. Ela bloqueia a exploração e não consome dia, tarefa,
recurso ou ação. Quando coincide com o incidente do dia, a transmissão aparece
primeiro; fechá-la revela o cartão do incidente.

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
dias seguintes. Em dia com incidente novo, o cartão novo tem prioridade e a
retomada volta a aparecer no próximo dia sem incidente. Os valores e a ordem do processamento estão em `mechanics/ACTIONS.md`.

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
- **Transmissão da Terra:** modal central aberto na primeira falha do motor, na
  primeira chuva de meteoros e na primeira perda; fecha com clique, `ENTER` ou
  `ESC` e não consome dia, tarefa, recurso ou ação.
- **Ajuda:** modal `AJUDA — CONTROLES` aberto pelo botão `?` do rodapé.
- **Transmissão e desfecho:** permanecem modais.

## Avisos

Um recurso em vermelho (de 1 a 29) avisa por três canais ao mesmo tempo: a cor,
um **ícone de aviso** ao lado do número e a **borda do cartão piscando** (meio
segundo aceso, meio apagado). A cor sozinha deixa quem não a distingue sem
nenhuma pista.

Alertas críticos usam os cartões de recurso: cor, ícone de aviso e borda
piscando. Alerta não gera linha de texto: o problema ativo aparece na quarta
linha da faixa e o recurso crítico se identifica pelo próprio cartão. As nove
linhas do painel `SISTEMA` do [#11](https://github.com/shelldonryan/gtd_example/issues/11)
ficam **superseded** — economia e racionamento saíram pela ADR-0002 e os estados
restantes já são cobertos pelo cartão e pela faixa. A faixa de urgência mostra:

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
