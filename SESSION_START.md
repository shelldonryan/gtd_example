# Last Horizon — Session Start

> Documento obrigatório de abertura e encerramento de toda sessão. Leia antes de
> analisar, editar ou implementar qualquer coisa.

Atualizado em: 2026-09-15 (D-098 confirmada; #20 concluída)
Destino Wayfinder: [issue #1](issue://1)

## Como usar este arquivo

1. Leia este documento antes de qualquer avanço.
2. Recalcule a fronteira Wayfinder nas issues; o snapshot abaixo pode ficar velho.
3. Leia as fontes específicas da tarefa e compare intenção, documentação e código.
4. Antes de editar, reporte: entendimento, conflitos, lacunas e ticket escolhido.
5. Não invente uma decisão que altere o gameplay, a arquitetura, os controles, os
   objetivos ou os personagens. Pergunte ao usuário quando a decisão for material.
6. Atualize este arquivo imediatamente quando o usuário confirmar uma decisão e
   novamente antes de encerrar a sessão.

Este arquivo é um resumo operacional. Os detalhes continuam nas fontes específicas;
não copie documentos inteiros para cá.

## Legenda de estado

- **CONFIRMADA** — decisão explicitamente confirmada pelo usuário.
- **IMPLEMENTADA** — comportamento comprovado no código e na verificação.
- **ABERTA** — ainda exige decisão ou trabalho.
- **PROVISÓRIA** — usada para avançar, mas pode mudar.
- **SUPERSEDED** — decisão antiga substituída; não usar como regra atual.
- **INFERÊNCIA** — hipótese; nunca tratar como requisito.

## Hierarquia de autoridade

Em caso de conflito, siga esta ordem:

1. Última decisão confirmada pelo usuário.
2. Decisões CONFIRMADAS neste arquivo.
3. Documento específico do domínio correspondente.
4. Issue do Wayfinder e histórico de decisões.
5. Código atual, que descreve a implementação existente, não necessariamente a
   intenção final.

Se duas fontes de autoridade equivalente divergirem, pare e reporte o conflito.
Não escolha silenciosamente. Depois da decisão do usuário, atualize este arquivo
e as fontes afetadas.

## Contradições conhecidas

- `issue://1` é o mapa de coordenação. A fronteira atual possui
  `Balancear problemas persistentes e intervenções` e `Documento de entrega e
  como o jogo roda na apresentação` disponíveis; `Inventário de assets` e
  `Implementar problemas persistentes e hub central` estão bloqueados pelo novo
  balanceamento.
- `issue://19` registra o contrato D-073 a D-096 e supera as regras antigas de
  briefing diário, tarefa aceita, rota universal por NPC, evento diário e mapa
  com apenas um destino de tarefa.
- O sketch atual continua sendo a implementação comprovada de D-048 a D-072,
  agora com D-097 aplicada isoladamente. Ele ainda usa salas lineares,
  `active_task`, itens comuns carregados e eventos diários; portanto continua
  sendo evidência do protótipo anterior, não do novo ciclo completo.
- A linha de base D-030 a D-047 permanece histórica. O modelo numérico da issue
  #20 foi confirmado pelo usuário e passa a ser a entrada obrigatória da
  implementação #21.
- D-097 já sorteia o dano no casco entre pontos alcançáveis dos quatro cômodos;
  o restante de D-073 a D-096 continua ausente do sketch.
- A resolução canônica continua 1280×720; 640×360 é somente a grade lógica.
  Texto usa Segoe UI suavizada, e assets pixel art usam amostragem sem
  interpolação.
- Todo asset animado usa uma spritesheet PNG única com JSON; nomes permanecem
  ASCII e o `.aseprite` acompanha a exportação quando disponível.
- A nave não tem nome. As concept arts orientam linguagem visual e composição,
  nunca nomes ou números.

## Direção atual do produto

Last Horizon é um protótipo de gerenciamento de recursos com exploração 2D em
plataforma dentro de uma nave espacial. A nave **não tem nome**.

- `assets/concept_arts/HUD_CONCEPT_ART.png` é referência de linguagem visual do
  mapa macro e do HUD; os números do mock (520/600, Dia 084, 42 tripulantes)
  são ilustrativos — a fonte é `mechanics/ACTIONS.md`.
- `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png` é a linguagem visual das
  salas: cena lateral 2D em três conveses ligados por escadas, com terminais.
- A Sala de comando é o único hub: uma porta por convés leva ao Dormitório
  (superior), ao Depósito (médio) e à Sala de máquinas (inferior). As salas
  periféricas não se conectam entre si.
- `COMMAND_ROOM_CONCEPT_ART.png` orienta a composição espacial, sem importar
  nomes ou números ilustrativos.
- Incidentes surgem em dias alternados. O cartão escolhe uma contenção, mas
  sempre deixa um problema local persistente.
- Cada problema possui perda diária, prazo visível e crise específica.
- Dano no casco surge em um local aleatório alcançável da nave, em qualquer um
  dos quatro cômodos; não pertence a um ponto fixo do Depósito.
- Não existe aceite de tarefa nem briefing diário. HUD destaca o menor prazo; o
  mapa mostra todos os problemas por sala sem transportar o técnico.
- Uma intervenção principal por dia pode corrigir, recuperar ou acelerar.
  Diagnósticos, conversas, componentes especiais e políticas são livres.
- Recursos comuns são pagos no ponto final. Apenas componentes especiais são
  carregados fisicamente.
- Dormir no beliche do técnico encerra o turno. Dormir sem intervir é permitido,
  mas aplica perdas e reduz todos os prazos.
- `Aumentar potência` elimina um dia futuro completo de consumo e incidente.
- `Cuidar do grupo` recupera moral; `Socorrer [nome]` estabiliza uma pessoa em
  risco. Morte remove um benefício da especialidade, nunca uma ação necessária.
- Economia e racionamento são políticas persistentes de Máquinas e Depósito,
  com custo inicial e diário de moral.

### Loop de jogo confirmado

1. A partida dura dez dias.
2. O primeiro dia começa no Comando; os seguintes, no Dormitório.
3. Em dias alternados, o jogador escolhe uma contenção para o incidente; o
   problema nasce ativo na sala responsável.
4. HUD e mapa mostram urgências, perdas, prazos e crises.
5. O jogador explora e prepara qualquer problema sem aceitar uma tarefa.
6. Uma correção, recuperação ou aceleração principal pode ser concluída.
7. O técnico retorna ao próprio beliche, confere o resumo e dorme.
8. Consumos, perdas, prazos, crises e condições de término são processados.

`mechanics/ACTIONS.md` registra o contrato e as pendências numéricas.
`interface/ROOMS.md` registra topologia, responsabilidades e intervenções.

## Restrições técnicas confirmadas

- Processing 4.5.6, modo Java, sketch `.pde`.
- Resolução canônica do render em **1280×720 (720p)**, proporção 16:9, janela
  escalável com ampliação inteira; a grade lógica de layout permanece em 640×360
  apenas para posicionamento.
- A tipografia visível usa Segoe UI instalada no Windows, com suavização. Assets
  pixel art usam amostragem sem interpolação; uma regra não altera a outra.
- Código em inglês, sketch plano, sem hierarquia de classes desnecessária,
  funções curtas e separação `update`/`draw`.
- O novo modelo deve substituir `active_task` por problemas locais persistentes
  depois do balanceamento; a arquitetura concreta ainda não foi implementada.
- Sala jogável: três conveses, duas escadas, sem câmera.
- Movimento: personagem 16×24, andar 1,5 px/quadro, pulo de 48 px, gravidade 0,5,
  escada 1,0, alcance de interação 12 px, plataformas atravessáveis por baixo.
- Controles: setas e WASD, espaço e E para interação em sala; ENTER avança
  diálogos e confirma modais; ESC pausa; o botão `MAPA` usa o mouse. Dormir
  exige interação com o beliche do técnico.
- Tipografia: Segoe UI instalada no Windows, título 32 px, leitura 16 px,
  entrelinha 18 px, botão reduz até 10 px só quando a frase não cabe. HUD com
  ícones de 16×16 e sem rótulo nos cartões de recurso.
- Para qualquer animação do jogo, a convenção atual é uma spritesheet única em
  PNG com JSON de metadados, mantendo as durações e as tags exportadas pelo
  Aseprite. Não exportar PNG separado por quadro. O `.aseprite` de origem pode
  acompanhar a spritesheet quando estiver disponível.
- Áudio offline sem biblioteca externa: `javax.sound.sampled`, WAV PCM 16 bits em
  `data/`.

O sketch em `last_horizon/` continua executável e verificado para o ciclo
anterior: menus, salas lineares, movimento, tarefas aceitas, eventos diários e
encerramento no beliche. D-097 foi aplicada isoladamente nesse protótipo.

`code/SKETCH_ARCHITECTURE.md` separa explicitamente implementação atual e
contrato futuro. As capturas existentes comprovam D-048 a D-072 e a regressão
automatizada do local aleatório e alcançável de D-097.
Os tickets [#15](issue://15) e [#16](issue://16) estão CLOSED após a validação
da evidência na aceitação nativa de cada issue.

Os arquivos `characters/npcs/NPC_1.md` a `NPC_4.md` estão preenchidos com Vera,
Bento, Neusa e Sílvia. Não inventar nomes, personalidades ou histórias novas
sem decisão do usuário.


## Fontes obrigatórias

### Mapa e coordenação Wayfinder

- `issue://1` — destino, fronteira e decisões gerais do projeto.
- `issue://?state=all` — inventário atual de issues.
- `issue://14` — decisões D-006 a D-023 (histórico).
- `issue://11` — decisões D-024 a D-029 (roteiro e textos).
- `issue://12` — decisões D-030 a D-046 (balanceamento anterior).
- `issue://17` — implementação anterior das falhas novas e D-047.
- `issue://19` — decisões D-073 a D-096 do novo ciclo.
- `issue://20` — balanceamento confirmado e concluído.
- `issue://21` — implementação liberada pelo balanceamento.
- Issues específicas do ticket escolhido, incluindo seus bloqueadores nativos.

### Domínio e produto

- `README.md` — escopo resumido.
- `history/CONTEXT.md` — narrativa e vocabulário do domínio.
- `mechanics/ACTIONS.md` — números, custos, ciclo diário e condições de término.
- `interface/ROOMS.md` — pontos de interação, tarefas e geometria dos cômodos.
- `interface/FLOW.md` — mapa macro, salas, eventos, controles e navegação.
- `interface/HUD.md` — informações persistentes e controles de alto nível.
- `interface/MENU_INIT.md`
- `interface/MENU_GAME_OVER.md`
- `interface/MENU_VICTORY.md`
- `events/CREW_ISSUES.md`
- `events/HAZARDS.md`
- `events/SYSTEM_FAULTS.md`
- `characters/PLAYER.md`
- `characters/npcs/*.md`

### Visual e implementação

- `assets/concept_arts/HUD_CONCEPT_ART.png` — mapa macro e HUD.
- `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png` — sala lateral jogável.
- `code/SKETCH_ARCHITECTURE.md` — arquitetura registrada e lacunas conhecidas.
- Todos os `.pde` de `last_horizon/` quando a tarefa tocar o código.

`interface/MENU_CONFIGURATION.md` está fora do escopo. Os arquivos de pesquisa
(`research/*.md`) vivem nas branches `research/*`, não na árvore de trabalho da
`prototype/sketch-architecture`; não presumir arquivo ausente.

## Integração com o Wayfinder

### Papéis das labels

- `wayfinder:map` — destino, contexto e fronteira do projeto.
- `wayfinder:grilling` — decisão de design que exige conversa.
- `wayfinder:prototype` — provar uma ideia, estado ou balanceamento.
- `wayfinder:task` — executar uma alteração técnica concreta.
- `wayfinder:research` — investigar um fato externo ou uma convenção.

Para as sessões indicadas no mapa #1:

- decisão de design: combine `/grilling` e `/domain-modeling`;
- aparência ou estado: use `/prototype`;
- fato externo: use `/research`;
- execução técnica: use a issue `wayfinder:task` correspondente.

Use a skill correspondente à label do ticket. Uma issue pode exigir leitura de
mais de uma fonte, mas não se deve pular a etapa de entendimento do mapa.

### Regra de disponibilidade

Uma issue está disponível quando está **OPEN** e não possui nenhum bloqueador
nativo **OPEN**. Bloqueadores CLOSED não impedem o trabalho. Recalcule esta
regra nas issues no início de cada sessão; não confie apenas na tabela abaixo.

Sincronizado com o grafo nativo de dependências em 2026-09-15:

| Issue | Estado | Bloqueadores abertos | Relação relevante |
|---|---|---|---|
| Documento de entrega e como o jogo roda na apresentação | disponível | — | independente |
| Balancear problemas persistentes e intervenções | CLOSED | — | D-098 confirmada |
| Inventário de assets | disponível | — | liberada pelo balanceamento |
| Implementar problemas persistentes e hub central | disponível | — | próximo caminho crítico |
| Redesenhar o ciclo diário e a origem das tarefas | CLOSED | — | D-073 a D-096 confirmadas |

As issues de base até `Reestruturar navegação, tarefas e feedback` permanecem
CLOSED como histórico e evidência do protótipo anterior. O mapa continua OPEN.

O grafo Wayfinder é a fonte da disponibilidade. Não declarar implementação
concluída apenas porque o contrato foi documentado.

### Cadeias de trabalho relevantes

- `Redesenhar o ciclo diário e a origem das tarefas` (fechada) →
  `Balancear problemas persistentes e intervenções` (fechada) →
  `Implementar problemas persistentes e hub central` (disponível).
- `Inventário de assets` também está disponível após o balanceamento.
- `Documento de entrega e como o jogo roda na apresentação` permanece
  independente.

## Decisões confirmadas

As decisões D-001 a D-072 registram a formação e a implementação do protótipo
anterior. D-073 a D-096 foram confirmadas no grilling de
[Redesenhar o ciclo diário e a origem das tarefas](issue://19); D-097 e D-098
foram confirmadas no balanceamento [#20](issue://20). Quando houver conflito,
D-073 a D-098 superam decisões anteriores sobre briefing, tarefas, eventos,
rotas, coleta, mapa, prioridades, localização do dano no casco e números.

| ID | Decisão | Estado |
|---|---|---|
| D-001 | Interpretação anterior: o mapa macro abre as salas jogáveis | SUPERSEDED |
| D-002 | O técnico é controlável dentro das salas | CONFIRMADA |
| D-003 | A sala usa plataforma básica: andar, pular, escadas, colisão e interação | CONFIRMADA |
| D-004 | Interpretação anterior: uma tarefa aceita por dia e sua conclusão consome a ação | SUPERSEDED |
| D-005 | Sobreviventes ficam parados e interativos, sem rotinas autônomas | CONFIRMADA |
| D-006 | O técnico não entra na conta dos quatro sobreviventes | CONFIRMADA |
| D-007 | Sem sobreviventes vivos é derrota imediata (quinta causa) | CONFIRMADA |
| D-008 | Interpretação anterior: tarefa aceita em cadeia; só a conclusão gasta o dia | SUPERSEDED |
| D-009 | Interpretação anterior: todas as estações ativas e briefing apenas sugestivo | SUPERSEDED |
| D-010 | Interpretação anterior: todas as tarefas passam por NPC e troca de cômodo | SUPERSEDED |
| D-011 | Interpretação anterior: tarefa singular em `tasks.pde` governa o ciclo | SUPERSEDED |
| D-012 | Três conveses e duas escadas em todos os cômodos | CONFIRMADA |
| D-013 | Números de movimento (16×24, 1,5 / 48 / 0,5 / 1,0 / 12, sem câmera) | CONFIRMADA |
| D-014 | Vera, Bento, Neusa e Sílvia, um por cômodo | CONFIRMADA |
| D-015 | A nave não tem nome | CONFIRMADA |
| D-016 | Interpretação anterior: vocabulário com `Sala de energia`; os demais termos permanecem vigentes | SUPERSEDED |
| D-017 | Seis ícones de 16×16 no HUD | CONFIRMADA |
| D-018 | Tipografia 16 px / entrelinha 18 / título 32 / botão até 10 | CONFIRMADA |
| D-019 | Alerta com borda piscando e ícone de aviso | CONFIRMADA |
| D-020 | Interpretação anterior: setas + WASD, espaço, E, ESC e controles de navegação no rodapé | SUPERSEDED |
| D-021 | Interpretação anterior: o dia 1 ensina pelo briefing | SUPERSEDED |
| D-022 | Playtest com checklist de seis perguntas | CONFIRMADA |
| D-023 | Interpretação anterior: qualquer item de tarefa persiste com o técnico | SUPERSEDED |
| D-024 | Voz híbrida por canal: sistema seco; Terra e Marte brevemente humanos | CONFIRMADA |
| D-025 | Vinheta em três telas, com objetivo explícito e sem tutorial de controles | CONFIRMADA |
| D-026 | Terra reage uma vez a cada primeiro incidente grave; Marte fala só na vitória | CONFIRMADA |
| D-027 | Eventos, transmissões e desfechos são modais; consequência externa vem antes do evento seguinte | CONFIRMADA |
| D-028 | Interpretação anterior: nove estados aparecem como linhas no painel lateral | SUPERSEDED |
| D-029 | Cinco derrotas usam causa e consequência em texto seco | CONFIRMADA |
| D-030 | Comida inicial em 70; as demais barras começam em 100 e as peças em 6 | CONFIRMADA |
| D-031 | Eventos uniformes, sem repetição imediata, durante a viagem | CONFIRMADA |
| D-032 | Interpretação anterior: `Socorrer sobrevivente` troca 5 de água por 10 de moral | SUPERSEDED |
| D-033 | Falha de suporte: 2 peças ou emergência com 10 de energia e +3 O₂/dia | CONFIRMADA |
| D-034 | Nova tarefa declarativa de reparo, concluível no mesmo dia do evento | CONFIRMADA |
| D-035 | Falha de suporte entra no pool uniforme de cinco eventos, sem repetição imediata | CONFIRMADA |
| D-036 | Interpretação anterior: falha de energia libera três tarefas alternativas | SUPERSEDED |
| D-037 | Uma tarefa de energia; Sílvia entrega automaticamente uma de três soluções com itens distintos e sem repetição | CONFIRMADA |
| D-038 | Sílvia sorteia a solução entre as três variantes ainda não usadas, sem reposição | CONFIRMADA |
| D-039 | Variantes: fusível (Depósito, 1 peça, painel de distribuição), cabo (Sala de comando, 10 energia, reator) e cartucho (Dormitório, 5 água, bancada do motor) | CONFIRMADA |
| D-040 | Sorteio apenas entre variantes pagáveis; depois das três usadas, a falha sai do pool | CONFIRMADA |
| D-041 | Evento de energia: energia −10 ou moral −10; falha ativa com +3 de energia por dia até o reparo | CONFIRMADA |
| D-042 | Reparo pendente persiste com item e variante; a falha ativa não é resortada e cobra +3 de energia por dia até a instalação | CONFIRMADA |
| D-043 | `Falha no sistema de energia` entra no pool uniforme, que passa a seis eventos; no máximo três ocorrências por partida | CONFIRMADA |
| D-044 | Comunicações: reparar com 1 peça; o silêncio custa moral −1/dia e suspende as transmissões da Terra até `Reparar comunicações` | CONFIRMADA |
| D-045 | Os itens novos vêm do NPC da sala: Bento entrega o fusível e as peças; Vera, o cabo; Neusa, o cartucho | CONFIRMADA |
| D-046 | Falha ativa não é resortada: motor danificado, suporte em emergência, energia ativa e comunicações em silêncio | CONFIRMADA |
| D-047 | Textos das falhas de suporte, energia e comunicações (cartões, alternativas e linhas do painel) aprovados no formato do #11 | CONFIRMADA |
| D-048 | O técnico atravessa a nave fisicamente por portas entre cômodos; o mapa continua existindo, mas clicar nele não teletransporta o personagem | CONFIRMADA |
| D-049 | Interpretação anterior: a tarefa do dia exige escolha e confirmação | SUPERSEDED |
| D-050 | Interações usam hierarquia por consequência: NPCs em diálogo modal com retrato e caixa inferior; sistemas em painel técnico sem retrato; coleta e conclusão em avisos breves; portas e escadas em indicações contextuais | CONFIRMADA |
| D-051 | Depois da vinheta, o técnico começa fisicamente na Sala de comando | CONFIRMADA |
| D-052 | Clicar num cômodo do mapa abre sua ficha; o mapa marca onde o técnico está, mas não define rota nem desloca o personagem | CONFIRMADA |
| D-053 | Interpretação anterior: a faixa mostra a próxima ação de uma tarefa singular | SUPERSEDED |
| D-054 | Interpretação anterior: o console de briefing é a origem da tarefa diária | SUPERSEDED |
| D-055 | O painel lateral `SISTEMA / TAREFA` sai; mapa e salas usam a largura liberada, a orientação vira uma faixa textual compacta e alertas ficam nos recursos ou em avisos temporários | CONFIRMADA |
| D-056 | Um botão `MAPA` abre o mapa como sobreposição consultável e retorna o jogador à mesma posição ao fechar | CONFIRMADA |
| D-057 | Depois do primeiro dia iniciado na Sala de comando, cada novo dia começa fisicamente no Dormitório | CONFIRMADA |
| D-058 | O botão `Passar dia` sai; o técnico encerra o dia interagindo com um beliche próprio no Dormitório | CONFIRMADA |
| D-059 | Antes de encerrar o dia, o beliche abre um resumo modal com consumo previsto, falhas ativas e estado da tarefa, seguido da confirmação | CONFIRMADA |
| D-060 | Interpretação anterior: um evento abre em todo dia a partir do segundo | SUPERSEDED |
| D-061 | Interpretação anterior: `ENTER` também confirma o briefing | SUPERSEDED |
| D-062 | Interpretação anterior: o mapa mostra apenas o destino da tarefa ativa | SUPERSEDED |
| D-063 | A interface usa Segoe UI instalada no Windows, com suavização; o m5x7 deixa de ser a fonte visível do sketch | CONFIRMADA |
| D-064 | O sketch renderiza nativamente em 1280×720; a grade lógica 640×360 permanece apenas para posicionamento e o pixel art fica restrito aos assets | CONFIRMADA |
| D-065 | A resolução canônica do projeto é 1280×720 (720p); 640×360 é apenas a grade lógica de posicionamento | CONFIRMADA |
| D-066 | O texto visível usa Segoe UI instalada no Windows, com suavização; m5x7 e m6x11 não são fontes visíveis do jogo | CONFIRMADA |
| D-067 | A suavização pertence ao texto; assets pixel art usam amostragem sem interpolação, sem criar resolução alternativa | CONFIRMADA |
| D-068 | Botões exibem no próprio rótulo o atalho de teclado já disponível; dicas redundantes de `ENTER` são removidas quando o botão já o informa | CONFIRMADA |
| D-069 | O jogador usa uma spritesheet única em PNG + JSON para `idle` e `walk`; não há PNG separado por quadro | CONFIRMADA |
| D-070 | A spritesheet do jogador tem 10 quadros de 64×64; `idle` usa 0–1, `walk` usa 2–9 e o loop preserva as durações do JSON | CONFIRMADA |
| D-071 | O visual do jogador é 32×32 sobre colisão 16×24; `player_facing` espelha esquerda/direita sem duplicar a arte | CONFIRMADA |
| D-072 | Todos os assets animados do projeto usam uma spritesheet única em PNG + JSON; não há PNG separado por quadro | CONFIRMADA |
| D-073 | Eventos geram problemas locais: cada incidente cria uma necessidade concreta no sistema ou cômodo afetado, sem exigir briefing diário na Sala de comando; a função e a necessidade das manutenções permanecem ABERTAS | CONFIRMADA |
| D-074 | Todo incidente deixa um problema local persistente; a resposta define a contenção imediata, a tarefa corrige a causa e ignorar o problema mantém perdas, permite agravamento e pode levar à derrota | CONFIRMADA |
| D-075 | Problemas locais já nascem ativos após o evento; não existe etapa de aceitar tarefa. O mapa/HUD indica onde agir e os pontos relacionados respondem imediatamente; a correção final consome o trabalho do dia | CONFIRMADA |
| D-076 | O técnico pode concluir uma intervenção principal por dia; inspeções, conversas, coletas e contenções são livres, e problemas não corrigidos continuam ativos para os dias seguintes | CONFIRMADA |
| D-077 | Encerrar o dia continua exigindo dormir no beliche do técnico no Dormitório; para reduzir a travessia repetitiva, a nave deixa de ser uma sequência linear e passa a ter a Sala de comando como ponto central, com a topologia exata ainda ABERTA | CONFIRMADA |
| D-078 | A nave mantém quatro salas jogáveis: Sala de comando no centro, com acesso direto à Sala de máquinas, ao Depósito e ao Dormitório; a organização espacial se baseia na composição de `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png`, sem adotar nomes ou números ilustrativos da arte | CONFIRMADA |
| D-079 | A Sala de comando é o único hub: Dormitório, Depósito e Sala de máquinas possuem ligação direta apenas com ela, sem portas entre as três salas periféricas | CONFIRMADA |
| D-080 | A Sala de comando possui uma porta por convés: Dormitório no superior, Depósito no médio e Sala de máquinas no inferior; as escadas do hub fazem parte das rotas entre funções | CONFIRMADA |
| D-081 | As intervenções principais se dividem em correção, recuperação e aceleração; economia e racionamento são contenções livres; `Socorrer sobrevivente` estabiliza uma pessoa em risco pelos custos confirmados na D-098 | CONFIRMADA |
| D-082 | Cada problema ativo exibe custo por dia, prazo restante e consequência do agravamento; a perda é aplicada ao encerrar o dia e o prazo visível permite comparar prioridades antes de escolher a intervenção | CONFIRMADA |
| D-083 | Quando o prazo chega a zero, o problema aplica uma crise específica e coerente com seu domínio, não uma derrota universal; motor pode ser fatal, enquanto estoque, conflito, casco e comunicações causam perdas próprias e podem continuar ativos | CONFIRMADA |
| D-084 | O padrão geral dos eventos é `risco agora, correção depois`: o cartão escolhe entre contenções com custos e riscos diferentes, mas o problema permanece até uma intervenção física no cômodo correspondente | CONFIRMADA |
| D-085 | Sequências de correção variam conforme o problema e contêm apenas passos com função concreta: descobrir informação, obter algo realmente necessário ou aplicar a correção; NPC e troca de cômodo não são requisitos universais | CONFIRMADA |
| D-086 | Recursos comuns já contabilizados no HUD, como peças, água e energia, são pagos diretamente no ponto da intervenção; não exigem retirada com NPC. Apenas componentes especiais justificam uma etapa física de busca | CONFIRMADA |
| D-087 | O Depósito é a sala de logística: guarda componentes especiais usados por correções específicas e concentra controle de estoques e racionamento; não é passagem obrigatória para consumir recursos comuns | CONFIRMADA |
| D-088 | A Sala de comando concentra navegação e comunicações: rota, previsão de chegada, aumento de potência, antena e transmissões; Vera interpreta a situação geral, mas não exige conversa diária | CONFIRMADA |
| D-089 | Responsabilidades das salas: Comando cuida de navegação e comunicações; Máquinas, de motor, energia e suporte de vida; Depósito, de estoques, racionamento e componentes especiais; Dormitório, de descanso, saúde, moral e encerramento do dia | CONFIRMADA |
| D-090 | O HUD destaca o problema ativo com menor prazo e informa quantos outros existem; o mapa marca todas as salas afetadas, e cada ficha detalha perda diária, prazo e consequência da crise | CONFIRMADA |
| D-091 | Uma crise pode colocar um sobrevivente nomeado em risco com prazo visível; `Socorrer sobrevivente` é uma intervenção principal no Dormitório que consome recursos e estabiliza essa pessoa, enquanto prazo zerado causa sua morte e reduz `A BORDO` | CONFIRMADA |
| D-092 | A morte de um sobrevivente remove o benefício mecânico ligado à sua especialidade, mas nunca bloqueia uma ação necessária; a mesma ação continua possível com custo ou risco maior | CONFIRMADA |
| D-093 | Novos incidentes surgem em dias alternados, com dias sem evento entre eles; problemas anteriores continuam ativos, e os dias livres abrem espaço para correção, recuperação ou aceleração | CONFIRMADA |
| D-094 | `Aumentar potência` elimina um dia completo de exposição: reduz a duração da viagem e evita o consumo diário e o incidente que ocorreriam nesse dia futuro | CONFIRMADA |
| D-095 | No Dormitório, dormir apenas encerra o turno; `Cuidar do grupo` é uma intervenção principal que recupera moral; `Socorrer [nome]` é outra intervenção principal que estabiliza um sobrevivente em risco | CONFIRMADA |
| D-096 | Economia de energia e racionamento são políticas persistentes ativadas localmente em Máquinas e Depósito; não consomem a intervenção principal, reduzem consumo e cobram moral ao ativar e a cada dia mantidas | CONFIRMADA |
| D-097 | O dano no casco causado por meteoros não pertence a um ponto fixo: cada ocorrência escolhe um local aleatório alcançável pelo jogador em qualquer um dos quatro cômodos | IMPLEMENTADA |
| D-098 | Modelo numérico da viagem: incidentes nos dias 1, 3, 5, 7 e 9; cinco dos sete problemas sem reposição; ordem de turno, perdas, prazos, crises, contenções, intervenções, políticas e benefícios conforme `mechanics/ACTIONS.md` | CONFIRMADA |


## Decisões que exigem consulta

- se a tela de vitória permite continuar jogando depois da chegada;
- o silêncio das comunicações deve suspender transmissões da Terra, mas o modal
  de transmissão da D-026 continua fora do código;
- a aplicação dos textos do #11 segue sem ticket: alertas operacionais já usam
  avisos breves, mas ainda faltam transmissões e os textos finais de vinheta,
  vitória e derrota;
- qualquer nome, retrato ou história de personagem além do registrado em
  `characters/npcs/`.

## Checklist de início de sessão

- [ ] Ler `SESSION_START.md`.
- [ ] Ler `issue://1` e atualizar o grafo de dependências.
- [ ] Identificar o ticket disponível e a skill indicada pela label.
- [ ] Ler as fontes específicas e os assets visuais relevantes.
- [ ] Distinguir claramente intenção confirmada de implementação existente.
- [ ] Relatar conflitos e decisões abertas antes de editar.
- [ ] Definir o menor recorte que atende ao ticket; não remover gameplay para
      simplificar sem autorização.

## Checklist de encerramento

Antes de encerrar uma sessão, atualizar:

- decisões confirmadas e suas fontes;
- decisões abertas e perguntas feitas ao usuário;
- estado real do código e dos assets;
- issues iniciadas, concluídas ou ainda bloqueadas;
- arquivos alterados;
- comando, cenário ou teste de verificação executado;
- nova fronteira Wayfinder e próximo trabalho recomendado.

A última linha da sessão deve deixar claro se o repositório está apenas com uma
decisão documentada, com um protótipo executável ou com a funcionalidade pronta.

## Estado desta sessão

- **Issue concluída:** [Balancear problemas persistentes e intervenções](issue://20)
  teve o modelo numérico validado pelo usuário.
- **Decisão confirmada:** D-097 remove o ponto fixo do casco no Depósito. Cada
  dano por meteoros surge em um local aleatório alcançável pelo jogador em
  qualquer um dos quatro cômodos.
- **Fontes atualizadas:** `README.md`, `history/CONTEXT.md`,
  `mechanics/ACTIONS.md`, `interface/FLOW.md`, `interface/ROOMS.md`,
  `interface/HUD.md`, `events/HAZARDS.md`, `characters/npcs/NPC_2.md`,
  `code/SKETCH_ARCHITECTURE.md` e `SESSION_START.md`.
- **Código:** D-097 foi implementada em `game.pde` e `ship.pde`. O dano sorteia
  um ponto livre e alcançável entre os três conveses dos quatro cômodos, atualiza
  o destino da correção e fica fora do sorteio enquanto o vazamento estiver
  ativo. O restante do sketch continua implementando o ciclo anterior.
- **Wayfinder:** #20 está CLOSED; [Inventário de assets](issue://8) e
  [Implementar problemas persistentes e hub central](issue://21) estão
  disponíveis; [Documento de entrega](issue://7) permanece independente.
- **Verificação desta sessão:** `--capture` passou com cinco verificações de
  D-097: ponto oculto antes do dano, localização alcançável, variação entre
  cômodos, exclusão do evento enquanto ativo e remoção após o reparo.
  `--hit-test` e `--ladder-test` também passaram sem regressões.
- **Protótipo da #20:** `node prototype/balance-model.mjs --simulate` confirmou
  calendário, processamento, sete problemas, contenções, intervenções, políticas
  e benefícios; correção, recuperação e aceleração vencem, omissão perde, e
  correção prioritária vence as 2.520 ordens possíveis.

O repositório está com **o balanceamento da #20 confirmado e pronto para a migração integral da #21; o novo ciclo ainda não está no sketch**.
