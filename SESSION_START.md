# Last Horizon — Session Start

> Resumo operacional obrigatório. Leia antes de analisar, editar ou implementar
> e sincronize-o com o Wayfinder antes de encerrar a sessão.

Atualizado após a sessão da
[issue #7](https://github.com/shelldonryan/gtd_example/issues/7), que separou a
documentação de design do material de verificação, montou o pacote de entrega e
preparou o sketch para receber a arte.

Destino Wayfinder: [issue #1](issue://1)

## Regras inegociáveis

1. Antes de qualquer avanço, leia este arquivo, `issue://1`, o inventário de
   issues e as fontes específicas do ticket.
2. Recalcule a disponibilidade pelo estado e pelos bloqueadores **nativos** das
   issues. Snapshots neste arquivo ou no corpo da #1 podem estar velhos.
3. Antes de editar, reporte entendimento, conflitos, lacunas e ticket escolhido.
4. Não invente decisões de gameplay, arquitetura, controles, objetivos,
   personagens ou apresentação. Decisão material exige consulta ao usuário.
5. Ao confirmar uma decisão, atualize imediatamente a fonte de domínio, este
   resumo e a issue correspondente.
6. Uma sessão **não está encerrada** enquanto documentos locais e Wayfinder
   divergirem sobre decisões, estados, bloqueios, evidências, fronteira ou
   próximo ticket.

## Sincronização obrigatória no encerramento

Execute sempre, nesta ordem:

1. Releia `issue://?state=all`, `issue://1`, a issue trabalhada, seus comentários
   e bloqueadores nativos.
2. Na issue trabalhada, registre decisões, arquivos alterados e evidência de
   verificação. Atualize estado e dependências; só feche quando a aceitação
   estiver comprovada.
3. Atualize o **corpo da issue #1** com a fronteira atual: disponíveis,
   bloqueadas, concluídas e próximo caminho crítico. Comentário histórico não
   substitui um corpo desatualizado.
4. Atualize as fontes locais afetadas e este arquivo com o mesmo estado.
5. Releia o corpo da #1 e este arquivo lado a lado. Corrija qualquer diferença
   antes da resposta final.

O grafo nativo define disponibilidade. O corpo da #1 e este arquivo devem
reproduzi-lo; nenhum dos dois pode manter um snapshot sabidamente obsoleto.

## Autoridade e estados

Ordem em caso de conflito:

1. última decisão explicitamente confirmada pelo usuário;
2. decisão confirmada na issue responsável e na fonte específica do domínio;
3. resumo operacional deste arquivo;
4. código atual, que prova implementação, não necessariamente intenção.

Fontes de mesma autoridade divergentes constituem erro de sincronização: pare,
reporte e não escolha silenciosamente.

- **CONFIRMADA** — decisão aprovada pelo usuário.
- **IMPLEMENTADA** — comportamento comprovado no código e na verificação.
- **ABERTA** — ainda exige decisão ou trabalho.
- **PROVISÓRIA** — hipótese temporária, nunca requisito.
- **SUPERSEDED** — regra histórica substituída; não reutilizar.

## Estado operacional atual

- #19, #20, #21, #22, #23 e #24 estão CLOSED; D-073 a D-110 continuam
  confirmadas e implementadas no protótipo anterior.
- #25 foi concluída: catálogo das oito preventivas e quatorze soluções,
  agora com confirmação, coleta e entrega físicas em `last_horizon/`.
- #26 foi concluída: números, pool, falhas, negligência, crises, risco e socorro
  estão implementados tanto no modelo Node quanto no sketch Processing.
- #27 foi concluída após validação manual do retorno pelas portas. Nesta sessão,
  os portais ganharam limiar `x/y` independente de deck e chegada configurável
  (`x/y/direção`) em qualquer ponto válido da sala; a porta das Máquinas no
  Comando está no centro do deck inferior (`x = 320`) e foi validada manualmente.
  O harness mantém a tela estável durante as campanhas internas e prioriza
  pontos de quest quando coincidem com um portal.

- A migração foi solicitada explicitamente antes do inventário #8. O jogo já
  executa o novo ciclo; a arte entra por arquivo, com fallback geométrico.
- #8 foi concluída: a lista de imagens, os canvas e a ordem de produção estão em
  `assets/INVENTORY.md`, e o layout de escadas e estações ficou congelado para a
  pintura dos fundos.
- #29 foi concluída nesta sessão: o sketch tem a camada de arte (`assets.pde`)
  com fallback geométrico, desenho 1:1 e travessia de porta em dois quadros.
- #30 foi concluída nesta sessão: a aba principal não cita mais o harness, então
  a cópia entregue sai sem `capture.pde` e compila fora do repositório.
- #28 está OPEN e disponível:
  [Escolher e integrar os dois efeitos sonoros](https://github.com/shelldonryan/gtd_example/issues/28);
  o jogo segue mudo até a escolha.
- As posições de escada e estação estão **fechadas** para a pintura dos fundos:
  escadas em 127/532 (Comando), 114/526 (Máquinas), 120/489 (Depósito) e 127/482
  (Dormitório), com as estações realocadas e folga mínima de 40 px do eixo de
  uma escada. As portas continuam sendo sprites e mudam sem repintura.
- A entrega vai pelo GitHub: o repositório é privado e o professor tem acesso;
  a branch local `entrega` é o snapshot curado (notas de design, concept arts e
  o sketch de 8 abas), e o push é ação do usuário. Uma cópia equivalente está em
  `../entrega_last_horizon/`. A apresentação roda na máquina dele abrindo
  `last_horizon/last_horizon.pde` no Processing.
- #7 foi concluída:
  [Documento de entrega e como o jogo roda na apresentação](https://github.com/shelldonryan/gtd_example/issues/7);
  o plano B é uma gravação curta de partida, a ser feita pelo usuário até 23/09.
- O próximo caminho crítico é a arte: o usuário seleciona os assets CC0/CC-BY e
  o sketch já os recebe por arquivo, na ordem de `assets/INVENTORY.md`.

### Fronteira Wayfinder

Sincronizada com o grafo nativo depois da sessão do #7:

| Issue | Estado | Bloqueadores abertos | Relação |
|---|---|---|---|
| #7 Documento de entrega | CLOSED | — | entrega pelo GitHub (repo privado, acesso do professor) e plano B por gravação curta |
| #29 Camada de assets | CLOSED | — | camada de arte com fallback, travessia de porta e drop-in documentado |
| #30 Desacoplar o harness | CLOSED | — | cópia entregue sem `capture.pde`, testada fora do repositório |
| #8 Inventário de assets | CLOSED | — | lista, canvas e ordem de produção em `assets/INVENTORY.md`; escadas e estações congeladas |
| #28 Escolher e integrar os dois efeitos sonoros | OPEN | — | dependente da #3; o jogo segue mudo |
| #27 Portais, desfechos, transmissões, NPCs e HUD | CLOSED | — | escopo ampliado; concluído e validado |
| #25 Redesenhar incidentes e ordens como quests físicas | CLOSED | — | catálogo e fluxo físico implementados no sketch |
| #26 Simplificar mecânicas legadas e balancear o ciclo de quests | CLOSED | — | números, pool e consequências implementados no sketch |
| #19 Redesenhar o ciclo | CLOSED | — | contrato anterior superseded |
| #20 Balancear o novo ciclo | CLOSED | — | números anteriores superseded |
| #21 Implementar novo ciclo e hub | CLOSED | — | implementação anterior superseded em parte |
| #22 Calendário em dias pares | CLOSED | — | calendário preservado |
| #23 Confirmação nas intervenções | CLOSED | — | confirmação preservada para ações importantes |
| #24 Painel na coleta de componentes | CLOSED | — | componentes reaproveitados como quests |


## Contrato vigente do produto

O contrato abaixo está implementado no sketch `last_horizon/` e no modelo
numérico `prototype/balance-model.mjs`. A migração não aguardou o inventário #8,
por solicitação explícita do usuário; arte final continua fora desta mudança.

- Jogo de gerenciamento de recursos e exploração 2D em plataforma, em uma nave
  **sem nome**.
- Viagem de dez dias; primeiro dia no Comando, seguintes no Dormitório.
- Incidentes nos dias 2, 4, 6, 8 e 10; cinco dos sete tipos, embaralhados sem
  reposição. Os tipos pertencem às famílias de falhas técnicas, suprimentos e
  tripulação.
- Nos dias sem incidente, os sobreviventes oferecem duas ordens preventivas. O
  jogador escolhe e confirma uma presencialmente; deve concluí-la para evitar o
  prejuízo maior de negligência.
- Ajuste de playtest: dias tranquilos começam sem modal; `ORDENS` mostra `!`
  pulsante enquanto houver escolha disponível, até selecionar uma ordem.
- O selo de `ORDENS` usa círculo e exclamação geométrica centralizados, com
  pulso conjunto de tamanho e cor em ciclo de 1,4 s.
- Só o ponto da etapa atual permite interação. Demais estações e NPCs ficam
  sem marcador de ação e sem resposta a `E`; NPCs vivos permanecem visíveis.
  Portas, beliche do técnico e socorro com risco/quest livre são preservados.
- Nos dias com incidente, o cartão apresenta duas soluções físicas. O jogador
  escolhe uma, coleta o objeto e entrega no destino.
- Toda ordem informa objeto, origem, destino, recompensa e consequência de falha.
  Uma ordem aceita não pode ser cancelada.
- Uma única quest pode ser concluída por dia. Coleta e entrega são as duas etapas
  leves; o técnico carrega um objeto por vez.
- Ordem preventiva concluída aumenta um recurso específico. Ordem aceita e não
  concluída perde uma pequena quantidade desse mesmo recurso. Nenhuma ordem
  preventiva aceita perde os dois recursos oferecidos.
- Se nenhuma ordem preventiva for aceita, os dois recursos das ofertas sofrem
  pequenas perdas. Os valores exatos pertencem ao balanceamento.
- Solução de incidente não concluída deixa o problema ativo, com perda diária,
  prazo e crise normais, sem multa extra; a mesma solução pode ser retomada nos
  dias seguintes. Em dia com incidente novo, o cartão novo tem prioridade; a
  retomada volta a aparecer no próximo dia sem incidente.
- O sobrevivente responsável pode ser origem ou destino. A rota é curta e não
  exige três cômodos distintos.
- Componentes especiais, como fusível e kit de vedação, existem como objetos de
  quest; não há coleta livre fora de uma ordem.
- Economia, racionamento e bônus numéricos dos sobreviventes não fazem parte do
  novo ciclo.
- Há no máximo uma pessoa em risco por vez. Socorro é uma quest simples; a morte
  reduz `A BORDO` sem recalcular custos.
- O Comando é o único hub. O mapa mostra origem, destino e problemas, mas nunca
  transporta o técnico.
- Dormir no beliche do técnico processa consumo, perdas, riscos, prazos, crises
  e término.
- Vitória: chegar após o décimo dia com motor operante e ao menos um
  sobrevivente. Derrota: energia, oxigênio ou moral em zero, motor destruído ou
  nenhum sobrevivente vivo.
- Todo NPC vivo responde a `E` a qualquer momento, com texto e tipo de painel
  conforme o estado do dia; estações fora da etapa atual continuam apagadas.
- Portais são dados: cada porta declara sala, destino, `x/y` do limiar, referência
  opcional de convés (`door_deck`) e `x/y/direção` de chegada. `door_deck = -1`
  permite abertura sem deck ou acima do piso; a proximidade usa os dois eixos.
- Transmissões da Terra (primeira falha do motor, primeira chuva de meteoros e
  primeira perda) abrem uma vez por partida, antes do cartão do incidente, e não
  consomem dia, tarefa, recurso ou ação.
- A vitória traz a mensagem de Marte em três variações e lista os sobreviventes
  por nome quando houver perdas. "Reparo no limite" é a solução do motor entregue
  com o prazo do problema em 1 e só prevalece quando houver perdas.
- A derrota mostra apenas a contagem de sobreviventes e encerra a partida: não
  existe continuar jogando depois da chegada.
- O nome do técnico é obrigatório: `INICIAR (ENTER)` e a tecla `ENTER` ficam
  bloqueados enquanto o campo estiver vazio.
- Alertas não têm linha de texto: cor, ícone de aviso e borda piscando no cartão
  do recurso, e o problema ativo na faixa de urgência.
- Os cartões de recurso mostram rótulo de texto (`ENERGIA`, `OXIGÊNIO`, `ÁGUA`,
  `COMIDA`, `PEÇAS`, `MORAL`); o inventário #8 troca apenas os ícones por assets.
- O rodapé tem `MAPA`, `ORDENS` e `?`; a dica de teclas virou o modal
  `AJUDA — CONTROLES`. Textos e estética de modais e cartões ficam deferidos.
- A arte final está especificada em `assets/INVENTORY.md`: fundo em imagem por
  sala, com o piso e as escadas **pintados** no fundo e a colisão mantida no
  código; estações, objetos, NPCs, portas, ícones, retratos, telas e miniaturas
  do mapa são sprites carregados por arquivo, com a geometria do protótipo como
  fallback enquanto o asset não existe; painéis, cartões, barras, faixas,
  botões, o selo `!` e todo o texto continuam em código.

O catálogo concreto, seus IDs, objetos, origens, destinos, resultados e textos
estão em `mechanics/ACTIONS.md` e `events/`. Os valores numéricos e a seleção
final do pool foram definidos e simulados no ticket #26, e são executados pelo
sketch `last_horizon/`.

Números, custos, recompensas, perdas, prazos e ordem final do processamento:
`mechanics/ACTIONS.md`, `prototype/balance-model.mjs` e `last_horizon/game.pde`.
Topologia e ordens: `interface/ROOMS.md`.

## Contrato técnico

- Processing 4.5.6, modo Java, sketch plano em inglês, funções curtas e
  `update` separado de `draw`.
- Render 1280×720; grade lógica 640×360 apenas para posicionamento; janela 16:9
  escalável com ampliação inteira.
- Segoe UI suavizada: título 32 px, leitura 16 px, entrelinha 18 px; botão pode
  reduzir até 10 px somente para caber.
- Pixel art sem interpolação. Asset animado: uma spritesheet PNG + JSON; nomes
  ASCII; `.aseprite` acompanha a exportação quando disponível.
- Asset estático: canvas = tamanho na tela, porque 1 pixel de arte = 1 pixel do
  render 1280×720. Base 64×64; porta 64×128; ícones 32×32; retratos 224×276;
  fundos de sala 1280×456; telas 1280×720; miniaturas do mapa 240×144. Lista
  completa por arquivo em `assets/INVENTORY.md`.
- Sala: três conveses, duas escadas por sala, sem câmera. Escadas finais:
  127/532, 114/526, 120/489 e 127/482; nenhuma estação a menos de 40 px de um
  eixo de escada.
- Portais e escadas vivem em tabelas. Portas usam `door_room`, `door_target`,
  `door_x`, `door_y`, `door_deck`, `door_arrival_x`, `door_arrival_y` e
  `door_arrival_facing`; escadas usam `ladder_room` e `ladder_x`. O limiar da
  porta não precisa coincidir com um deck e a chegada configurada vale na
  primeira travessia; no retorno imediato, o jogador reaparece no `x/y` de saída.
- Jogador: colisão 16×24; andar 1,5 px/quadro; pulo 48 px; gravidade 0,5;
  escada 1,0; interação 12 px; plataformas atravessáveis por baixo.
- Controles: setas/WASD, espaço, E, ENTER em diálogos/modais, ESC para pausa e
  mouse nos botões `MAPA` e `ORDENS`.
- HUD: seis ícones 16×16; cartões de recurso com ícone, número, rótulo e barra.
- Áudio offline: `javax.sound.sampled`, WAV PCM 16 bits em `data/`.
- A arte entra por arquivo em `data/` (`icons/`, `stations/`, `objects/`,
  `npc/`, `doors/`, `rooms/`, `portraits/`, `screens/`, `map/`), com fallback
  geométrico quando o arquivo não existe, desenho 1:1 no render 1280×720 e
  travessia de porta em dois quadros.
- A cópia entregue é o sketch sem a aba do harness (`capture.pde`): a aba
  principal declara pontos de extensão inertes e o harness se instala neles.

Concept arts definem linguagem visual e composição, nunca nomes, números,
dimensões ou layout final:

- `assets/concept_arts/HUD_CONCEPT_ART.png`;
- `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png`;
- `assets/concept_arts/COMMAND_ROOM_EDITED.png`, `MACHINE_ROOM.png`,
  `WAREHOUSE.png` e `BEDROOM.png`, agora incluídos no escopo do inventário
  ampliado da issue [Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8).

## Índice de decisões

Não replique aqui o histórico completo:

- D-001 a D-047: protótipo anterior; fontes em #14, #11, #12 e #17.
- D-048 a D-072: navegação, interação, viewport, tipografia e animação já
  implementadas; fonte principal em #18.
- D-073 a D-096: contrato histórico do ciclo anterior, com briefing, tarefa,
  contenção e correção separadas; **SUPERSEDED** pelo novo contrato de ordens e
  soluções físicas registrado na ADR-0001.
- D-097: dano no casco aleatório e alcançável; permanece confirmado e deverá ser
  usado como destino de uma solução física.
- D-098: números do ciclo anterior; a forma de problemas, políticas e benefícios
  foi **SUPERSEDED** pela ADR-0002. A recalibração do novo ciclo está
  implementada no ticket #26; o calendário e os sete tipos continuam como base.
- D-099 a D-103: decisões de implementação do ciclo anterior, incluindo
  distribuição, beliche temporário, empate de urgência e crise imediata;
  **SUPERSEDED** onde conflitarem com ordens e riscos simplificados.
- D-104 a D-107: leituras do ciclo anterior; superseded onde conflitam com as
  quests das issues #25 e #26, agora implementadas no sketch.
- D-108: os incidentes ocorrem nos dias 2, 4, 6, 8 e 10 e o dia 1 fica sem
  incidente; decisão preservada no novo contrato.
- D-109: confirmação de ações importantes; o princípio permanece e os painéis
  e ações concretas foram adaptados e implementados no fluxo de quests do sketch.
- D-110: coleta com confirmação; o princípio de objeto explicado permanece, mas
  coleta livre e uso exclusivo de fusível ou kit ficam **SUPERSEDED** pelo
  modelo de objetos de quest.
- **Novo ciclo de quests (ADR-0001):** dias sem incidente oferecem duas ordens
  preventivas e permitem concluir uma; dias com incidente oferecem duas
  soluções físicas. Objetos têm origem, destino e consequência legíveis.
- **Simplificação do ciclo (ADR-0002):** seis recursos e consumo permanecem;
  políticas, bônus numéricos, coleta livre e contador separado de intervenção
  saem. Problemas persistentes permanecem; há no máximo uma pessoa em risco.
- **Tickets concluídos:** a #25 define matriz, textos e rotas; a #26 define
  números, seleção do pool e simulação. Ambos foram migrados para o sketch.
  O inventário de assets (#8) continua disponível como próximo caminho.
- **D-111 a D-117 (sessão #27):** fala de NPC por estado (D-111); portas e
  escadas em tabela (D-112); HUD com rótulos nos cartões, faixa inferior em
  campos fixos e modal de ajuda `?` (D-113); nome vazio mantém `INICIAR`
  bloqueado (D-114); derrota sem nomes e inexistência de pós-vitória (D-115);
  transmissões da Terra antes do incidente e mensagens de Marte, com "reparo no
  limite" definido como entrega com prazo 1 (D-116); alertas do #11
  **superseded**, sem linha de texto (D-117).
- **Ampliação técnica da #27 nesta sessão:** o limiar do portal usa `x/y`
  independente de deck e a chegada usa `x/y/direção` configurável; no retorno
  imediato, o jogador reaparece na posição de saída da sala anterior. Isso
  permite aberturas sem deck e surgimento inicial em qualquer ponto válido.
- **D-118 a D-125 (sessão #8, inventário de assets):** o fundo de cada sala é
  uma imagem e o piso e a escada passam a ser **pintados** nela, com a colisão
  mantida no código (D-118); escadas definitivas por sala — 127/532, 114/526,
  120/489 e 127/482 — medidas na composição dos concept arts, com as estações
  realocadas e folga mínima de 40 px (D-119); 14 estações com desenho próprio em
  canvas 64×64, com o casco sorteado em qualquer ponto (D-120); NPCs, porta e
  casco animados em dois quadros e o restante estático (D-121); canvas = tamanho
  na tela, com base 64×64 e exceções por peça (D-122); menu e vinheta com a nave
  de fora e a Terra ao fundo, vitória com a base em Marte e derrota com o espaço
  vazio (D-123); o som fica pendente e o jogo segue mudo (D-124); a lista e a
  ordem de produção vivem em `assets/INVENTORY.md`, começando pelos ícones do
  HUD (D-125).
- **D-126 a D-131 (sessão #7, entrega e camada de arte):** a entrega é a
  documentação de design do vault mais o jogo em Processing, rodando na máquina
  do professor a partir da pasta do sketch (D-126); o material de verificação sai
  dos documentos entregues e passa a viver em `code/VERIFICATION.md`, só do
  repositório, com a cópia entregue sem a aba do harness (D-127); o `README.md`
  é o hub do grafo, as notas se linkam por wikilink e as issues ficam só em
  `Referências` no fim, com `assets/INVENTORY.md` e as concept arts na entrega
  (D-128); a camada de arte carrega por arquivo com fallback geométrico e 1:1 e
  a porta ganha travessia em dois quadros, com **arte de IA proibida** e
  CC0/CC-BY permitida, selecionada pelo usuário (D-129); prazo de entrega em
  23/09 (D-130); o harness fixa a sequência de incidentes para não repetir o
  motor no dia 4, corrigindo falha intermitente (D-131). A opção de "esperar a
  arte final toda" fica **superseded** por D-126/D-129.
- **D-132 e D-133 (fechamento da sessão #7):** a entrega vai pelo GitHub — o
  repositório é privado e o professor tem acesso —, com uma branch `entrega`
  curada como snapshot (D-132); o plano B da apresentação é uma gravação curta
  de partida feita pelo usuário (D-133).

## Fontes por tarefa

Sempre:

- `issue://1`, `issue://?state=all`, issue escolhida, comentários e bloqueadores;
- `README.md`, `history/CONTEXT.md` e este arquivo.

Gameplay e balanceamento:

- `mechanics/ACTIONS.md`;
- `interface/ROOMS.md`, `interface/FLOW.md`, `interface/HUD.md`;
- `events/CREW_ISSUES.md`, `events/HAZARDS.md`,
  `events/SYSTEM_FAULTS.md`;
- `characters/PLAYER.md`, `characters/npcs/*.md`;
- #19, #20 e `prototype/balance-model.mjs`.

Interface e desfechos:

- `interface/MENU_INIT.md`, `interface/MENU_GAME_OVER.md`,
  `interface/MENU_VICTORY.md`;
- #11 e assets visuais relevantes.

Arte e layout:

- `assets/INVENTORY.md`;
- `assets/concept_arts/*.png` (linguagem visual e composição, nunca nomes,
  números ou dimensões).

Código:

- `code/SKETCH_ARCHITECTURE.md`;
- todos os `.pde` de `last_horizon/`;
- `code/VERIFICATION.md` (só do repositório) para comandos, harness, costura e
  fixtures;
- comandos e evidências de captura da issue afetada.

`interface/MENU_CONFIGURATION.md` foi removido; o menu de configuração segue fora
do escopo. Arquivos `research/*.md` podem existir apenas nas branches
`research/*`.

## Lacunas que exigem consulta ou ticket

- a escolha do som: o inventário reserva `data/audio/click.wav` e
  `data/audio/alerta.wav` e o jogo segue mudo;
- a seleção da arte, na ordem de `assets/INVENTORY.md` — ícones, porta, casco,
  objetos, NPCs, estações, retratos, fundos, telas e miniaturas do mapa; quem
  seleciona é o usuário, e arte gerada por IA é proibida pelo professor;
- a gravação curta do plano B, a ser feita pelo usuário até 23/09;
- a definição visual das **portas**, que são sprite e mudam sem repintura; as
  escadas, que são pintadas, estão fechadas;
- o texto e a estética dos modais e cartões, deferidos por decisão da #27;
- qualquer nome, retrato ou história além de Vera, Bento, Neusa e Sílvia.

## Checklist de abertura

- [x] Ler este arquivo antes de qualquer avanço.
- [x] Recalcular issues, bloqueadores e fronteira.
- [x] Identificar ticket e skill correspondente à label.
- [x] Ler fontes específicas, comentários e assets relevantes.
- [x] Comparar intenção, documentação e código.
- [x] Reportar entendimento, conflitos, lacunas e recorte antes de editar.

## Checklist de encerramento

- [x] Registrar decisões e evidências na issue trabalhada.
- [x] Atualizar estado e dependências nativas da issue.
- [x] Atualizar o corpo da #1 com a fronteira e o próximo ticket.
- [x] Atualizar fontes locais afetadas e este arquivo.
- [x] Confirmar que #1, issues específicas e documentos locais concordam.
- [x] Registrar arquivos alterados e verificação executada.
- [x] Declarar se o resultado é documentação, protótipo executável ou
      funcionalidade pronta.

## Última sessão registrada

Sessão da [issue #7](https://github.com/shelldonryan/gtd_example/issues/7) —
entrega montada, documentação separada da verificação e sketch pronto para
receber arte.

- Fronteira recalculada no grafo nativo antes desta sessão: apenas #1, #7 e #28
  estavam OPEN; #8 CLOSED com todos os bloqueadores fechados.
- Grilling do #7 com decisões confirmadas uma a uma: entrega = documentação do
  vault (menos os operacionais) + o jogo; `assets/INVENTORY.md` e as concept
  arts entram; material de verificação sai dos docs entregues e vira
  `code/VERIFICATION.md`, só do repositório; `README.md` é o hub do grafo, com
  wikilinks entre as notas e issues apenas em `Referências`; o pacote roda na
  máquina do professor abrindo o `.pde` no Processing; prazo 23/09; arte de IA
  proibida, CC0/CC-BY permitidas e selecionadas pelo usuário.
- Tickets abertos e concluídos na sessão: #29 (camada de arte) e #30 (desacoplar
  o harness), ambos ligados como sub-issues da #1 e fechados com evidência.
- Código: `last_horizon/assets.pde` carrega a arte por arquivo com fallback
  geométrico e desenho 1:1; `ship.pde` ganhou a travessia de porta em dois
  quadros; `last_horizon.pde` declara os pontos de extensão do harness
  (`harness_setup`, `harness_update`, `harness_scene`); `capture.pde` se instala
  neles e passou a fixar a sequência de incidentes.
- Evidência: `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` →
  **145 asserções `OK`** e `QUEST CHECK: PASS` em três execuções seguidas; cópia
  com as 57 fixtures de arte em pasta temporária → 57/57 carregadas, 145 `OK`,
  `PASS`; híbrido sem os fundos de sala → 53/57, 145 `OK`, `PASS`; inspeção
  visual confirmou ícones nos cartões, estações com a base no convés, porta no
  limiar e retratos/telas desenhados.
- Defeito de verificação corrigido: o sorteio da sequência de incidentes podia
  repetir o motor no dia 4 e quebrar a asserção de prioridade — reproduzido no
  código original (três execuções: `PASS`, `FALHOU`, `PASS`) e corrigido com
  sequência determinística; três execuções seguintes passaram.
- Pacote montado fora do repositório: `../entrega_last_horizon/` com 23 notas,
  8 concept arts, o sketch de 8 abas e `data/player/`; zero wikilink quebrado e
  zero token de verificação nos documentos entregues; a pasta compila e roda
  fora do repositório.
- Fontes sincronizadas: `README.md`, `interface/`, `mechanics/ACTIONS.md`,
  `events/`, `characters/`, `docs/adr/`, `history/CONTEXT.md`,
  `assets/INVENTORY.md`, `code/SKETCH_ARCHITECTURE.md`, `code/VERIFICATION.md`
  (novo) e este arquivo.
- Wayfinder: #29 e #30 CLOSED com evidência; #7 desbloqueada no grafo (as duas
  dependências concluídas) e fechada no fim da sessão com entrega pelo GitHub e
  plano B por gravação curta.
- Pendências: som (#28) e a seleção da arte seguem abertos; nada foi commitado
  nesta sessão — o delta está no working tree.
- Resultado: protótipo executável pronto para receber arte e pacote de entrega
  montado e verificado.

### Sessão anterior — #8

Sessão da [issue #8](https://github.com/shelldonryan/gtd_example/issues/8) —
inventário de assets e congelamento do layout para a pintura.

- Fronteira recalculada no grafo nativo antes desta sessão: apenas #1, #7 e #8
  estão OPEN, e os bloqueadores nativos da #8 estão todos CLOSED.

- Decisões confirmadas pelo usuário, uma a uma: fundo em imagem por sala, com
  piso e escadas **pintados** no fundo e colisão mantida no código; escadas
  definitivas por sala, medidas na composição dos concept arts; 14 estações com
  desenho próprio; NPCs com idle, porta com abertura e casco com brilho
  animados; menu e vinheta com a nave de fora e a Terra ao fundo; vitória com a
  base em Marte; derrota com o espaço vazio; som deixado para depois.

- Layout aplicado em `last_horizon/ship.pde`: `ladder_x` por sala (127/532,
  114/526, 120/489, 127/482) e dez estações realocadas — mais Vera (540→575) e
  Sílvia (540→570), que ficariam sobre a escada. Folga mínima de 40 px do eixo
  de escada e 60 px entre estações; nenhuma coordenada estava cravada no harness.

- Documento novo: `assets/INVENTORY.md` — 57 PNGs e 6 JSONs, com canvas por
  peça, tela onde aparece, estática ou animada, o que continua em código e a
  ordem de produção (ícones → porta e casco → objetos → NPCs → estações →
  retratos → fundos → telas e mapa).

- Evidência: `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` → 142
  asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS`; inspeção visual das
  capturas novas confirmou as escadas em 0,20/0,83 (Comando), 0,18/0,82
  (Máquinas) e 0,20/0,75 (Dormitório), sem estação sob escada.

- Fontes sincronizadas: `assets/INVENTORY.md`, `interface/ROOMS.md`,
  `interface/HUD.md`, `code/SKETCH_ARCHITECTURE.md`, `README.md` e este arquivo.
- Commits na branch `prototype/sketch-architecture`, sem push: `d7010c5`
  (sketch), `006334c` (inventário), `edfae19` (fontes) e este registro.
- Wayfinder: #8 CLOSED com decisões, arquivos e evidência no ticket; #28 criada,
  rotulada `wayfinder:task` e ligada como sub-issue da #1; corpo e comentário da
  #1 atualizados com a fronteira.

- Pendência: o som foi para a #28; nenhuma decisão de áudio foi tomada nesta
  sessão.
- Grafo: a #27 foi ligada como sub-issue da #1, fechando a única lacuna — todas
  as issues marcadas "Part of #1" estão agora no grafo nativo. Continuam abertas
  #7 e #28; as demais estão CLOSED.
- Resultado: documentação de arte fechada e layout congelado no protótipo
  executável — não é a arte final, que segue a ordem de produção.

### Sessão anterior — #27

Sessão da [issue #27](https://github.com/shelldonryan/gtd_example/issues/27),
concluída após o trabalho ser desviado do inventário #8 e o retorno pelas portas
ser validado manualmente.

- Fronteira recalculada no grafo nativo antes desta sessão: #7 e #8 estão OPEN;
  #27 está CLOSED; #8 segue como próximo caminho crítico.

- Decisões confirmadas pelo usuário, uma a uma: NPCs voltam a ser interativos com
  texto por estado; portas viram portais com limiar e chegada configurável,
  retornando imediatamente à posição `x/y` de saída na sala anterior; escadas
  viram dados aceitando posições arbitrárias; HUD com rótulos de texto nos
  cartões, faixa inferior em campos fixos e rodapé com `?`; nome vazio mantém
  `INICIAR` bloqueado; derrota só com contagem; pós-vitória inexistente; alertas
  sem linha de texto; "reparo no limite" é a solução do motor entregue com prazo 1.

- Vinheta trocada pelo roteiro confirmado no #11; transmissões da Terra e a
  mensagem de Marte implementadas com o nome do técnico.
- Defeito corrigido: `enterRoom()` usava o destino da porta em vez da sala da
  própria porta — entrar no Depósito levava ao Comando.
- Harness endurecido: asserção falha reprova o resultado e `QUEST CHECK: PASS`
  não é mais impresso depois de uma falha.
- Evidência: `--capture` → 140 asserções `OK` e `QUEST CHECK: PASS`, incluindo
  abertura sem deck, limiar acima de deck, chegada independente em outro canto,
  retorno da porta à posição de entrada, prioridade de quest sobre portal
  coincidente e 2.520/2.520 campanhas sem travar a janela; `--hit-test` → 5
  `OK`; `--ladder-test` → 6 `OK` (inclui escada em x arbitrário); `node
  prototype/balance-model.mjs --simulate` → `BALANCE CHECK: PASS`.
- Capturas novas em `last_horizon/output/`: `32_help_panel.png`,
  `34_earth_transmission.png`, `29_victory.png` (mensagem de Marte),
  `28_defeat.png` (contagem, sem nomes) e `catalogue_*_hud.png` (cartões
  rotulados e faixa em campos fixos); a inspeção visual confirmou os textos.
- Fontes sincronizadas: `interface/` (MENU_INIT, MENU_VICTORY, MENU_GAME_OVER,
  HUD, FLOW, ROOMS), `code/SKETCH_ARCHITECTURE.md`, `README.md` e este arquivo.
- Wayfinder: #27 CLOSED após validação manual, com o corpo atualizado para os
  portais ampliados; corpo e comentário da #1 atualizados; comentário na #8
  registrando que os cartões passam a ter rótulo e que portas/escadas deixaram de
  ser posições fixas.
- GitNexus continua sem indexar as funções `.pde`; a verificação funcional é a do
  Processing.
- O delta desta sessão foi commitado depois do encerramento: `e1563e0` (sketch),
  `89328d9` (docs), `f992cfb` (concept arts) e `d870f67` (vault); nenhum push foi
  feito.
- Alinhamento posterior: `SESSION_START.md` (contrato técnico) e
  `interface/TEXT_FONTS.md` ainda diziam "cartões de recurso sem rótulo"; as duas
  linhas passaram a registrar ícone + número + rótulo + barra, conforme a decisão
  confirmada na #27 e o comentário da #8. Nenhuma decisão nova foi tomada.
- Wayfinder desta sincronização: corpo e comentário da #1 atualizados com a
  fronteira recalculada no grafo nativo, os commits acima e o alinhamento dos
  rótulos. A fronteira não mudou: #8 é o próximo caminho crítico e #7 segue em
  paralelo.
- Resultado: funcionalidade pronta no jogo Processing — vinheta, transmissões,
  desfechos, NPCs, HUD e portais com limiar e chegada configuráveis —, não apenas
  documentação.
