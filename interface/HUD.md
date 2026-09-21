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
| Objetivo atual | linha textual | próxima ação e ponto de interação da ordem, socorro ou retorno ao beliche |
| Alerta atual | linha textual compacta | aviso fatal, risco individual ou condição relevante dos problemas ativos |

## Barras de recursos

Cada recurso de barra tem valor entre 0 e 100.

- **Verde:** recurso seguro, entre 60 e 100.
- **Amarelo:** recurso em atenção, entre 30 e 59.
- **Vermelho:** recurso crítico, entre 1 e 29.
- **Vazio:** recurso em zero e com risco de derrota.

As peças são uma contagem numérica, sem barra.

## Ícones

Os seis recursos renderizam **ícones de 16×16 unidades lógicas** — energia, oxigênio,
água, comida, peças e moral. Cada cartão mostra **ícone + número + rótulo de
texto** — `ENERGIA`, `OXIGÊNIO`, `ÁGUA`, `COMIDA`, `PEÇAS`, `MORAL` — e, nos
recursos de barra, a barra de preenchimento. Os PNGs de 64×64 em `data/icons/`
são preparados uma vez e reutilizados.

## Onde cada elemento fica

| Zona | Conteúdo |
| --- | --- |
| Topo | dia, quantos estão a bordo e os seis indicadores de recurso |
| Centro | sala 2D jogável usando toda a largura |
| Faixa de objetivo | próxima ação e ponto da etapa atual, quando houver |
| Faixa de alerta | aviso fatal ou risco atual |
| Rodapé | botões `MAPA`, `ORDENS` e `?`; `SOCORRO` quando há pessoa em risco; `!` pulsante quando há oferta ou retomada |
| Sobreposição | ordens, mapa, diálogos, incidentes e resumo ao dormir |

O mapa abre pelo botão `MAPA`, marca `VOCÊ ESTÁ AQUI`, o objetivo atual e a
contagem de problemas por sala. Fechá-lo retorna à mesma sala e posição.

## Controles de alto nível

### Mapa

O botão `MAPA` abre uma sobreposição com a imagem da nave e quatro cartões de
sala. Cada cartão mostra o nome e pode marcar a sala atual, o objetivo e a
contagem de problemas (`!N`).

### Diálogos e ordens

O botão `ORDENS` reabre as duas ofertas antes do aceite ou a ficha completa da
quest ativa. Nos dias sem incidente, `OFERTAS / PRÓXIMA RETOMADA` percorre as
soluções pendentes com seus prazos atuais. Nenhum desses botões move o técnico.

O botão `ORDENS` mostra `!` pulsando suavemente em tamanho e cor, com ciclo de
1,4 s, enquanto houver oferta ou retomada disponível e nenhuma seleção ou quest
em curso. Consultar e fechar sem escolher mantém o aviso; selecionar uma ordem
o remove. Os incidentes abrem seu cartão ao iniciar o dia.
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
- A linha de objetivo mostra a ação e o ponto da etapa atual; a entrega só
  aplica o resultado depois da confirmação. `COLETAR`/`ENTREGAR` e os detalhes
  completos ficam nos painéis da quest.
- O objeto só existe como parte de uma ordem aceita e pode ser carregado um por
  vez. Recursos comuns são pagos ou recebidos no destino.

Os botões exibem os atalhos disponíveis: `FECHAR (ESC)`, `AGORA NÃO (ESC)`,
`ACEITAR (ENTER)`, `DORMIR (ENTER)` e o controle de pausa `CONTINUAR (ESC)`.
Nos painéis de quest, o rótulo da ação acompanha a etapa.

### Ajuda

O botão `?` do rodapé abre um modal `AJUDA — CONTROLES` com a lista de teclas e
botões, fechado por `FECHAR (ESC)`, clique ou `ESC`. O rodapé reúne `MAPA`,
`ORDENS` e `?`; com pessoa em risco, também aparece `SOCORRO`.

### Faixa de objetivo e alerta

A faixa inferior desenha duas linhas: `currentObjectiveLine()` e
`currentAlertLine()`. A primeira identifica a ação e o ponto atual de interação
quando há uma ordem, uma pessoa em risco ou uma quest concluída. Sem alvo e sem
ofertas, a faixa indica consultar o mapa. A segunda prioriza aviso fatal, risco
individual e problemas ativos. Detalhes completos de ofertas e quests ficam no
painel `ORDENS`.

### Transmissões

Uma transmissão da Terra ocupa o centro da tela com título, texto e
`CONTINUAR (ENTER)`. Ela bloqueia a exploração e não consome dia, tarefa,
recurso ou ação. Quando coincide com o incidente do dia, a transmissão aparece
primeiro; fechá-la revela o cartão do incidente.

### Encerrar o dia

O técnico encerra o dia ao interagir com o próprio beliche no Dormitório. Antes
de dormir, o resumo modal mostra:

1. consumo previsto dos recursos;
2. recompensa ou perda da ordem preventiva, se houver;
3. estado e resultado do trabalho do dia;
4. problemas ativos, prazos e crises iminentes;
5. confirmação para dormir e opção de voltar.

Dormir com uma preventiva aceita e incompleta mostra a perda, devolve o objeto à
origem e encerra a ordem. Dormir com uma solução urgente incompleta mantém o
problema ativo com suas perdas, prazos e crise; a mesma solução reaparece como retomada nos
dias seguintes. Em dia com incidente novo, o cartão novo tem prioridade e a
retomada volta a aparecer no próximo dia sem incidente. Os valores e a ordem do
processamento estão em [[ACTIONS]].

## Estados da interface

O fluxo completo de telas está em [[FLOW]] e os pontos de interação de cada sala
em [[ROOMS]].

- **Salas de interior:** o Comando é o hub e tem portais para Dormitório,
  Depósito e Máquinas.
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
- **Mapa:** preserva sala e posição e marca sala atual, objetivo e contagem de problemas.
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
nenhuma pista. Os cartões indicam criticidade por cor, ícone e borda pulsante.

Alertas críticos usam os cartões de recurso: cor, ícone de aviso e borda
piscando. A linha de alerta também pode mostrar uma condição fatal, o risco
individual mais urgente ou um problema ativo. Quando há pessoa em risco, o
rodapé inclui o botão `SOCORRO`.

Se dois problemas tiverem o mesmo prazo, permanece em destaque o que foi
ativado primeiro. A ordem não muda quando o jogador troca de sala.

O mapa apresenta contagem de problemas por cômodo. Detalhes e valores numéricos
estão em [[ACTIONS]] e nos painéis de ordens.

Os textos editoriais de Vera, Bento, Neusa e Sílvia são derivados do contexto e
dos resultados reais. A validação exige 22 entradas ligadas por `quest_id`,
fallback factual e até 160 caracteres por campo.

## Referências

- [#8 Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8)
- [#16 HUD: ícones, alerta e rótulos](https://github.com/shelldonryan/gtd_example/issues/16)
- [#27 Corrigir desfechos, transmissões e parametrizar portas, escadas, NPCs e HUD](https://github.com/shelldonryan/gtd_example/issues/27)
