# Last Horizon — Session Start

> Resumo operacional obrigatório. Leia antes de analisar, editar ou implementar
> e sincronize-o com o Wayfinder antes de encerrar a sessão.

Atualizado após o encerramento da
[issue #27](https://github.com/shelldonryan/gtd_example/issues/27), concluída
depois da validação manual do retorno pelas portas; o delta da sessão foi
commitado em seguida e as duas linhas residuais dos cartões de recurso foram
alinhadas ao contrato.

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
  executa o novo ciclo; estações e objetos ainda usam a arte geométrica.
- #8 está OPEN e disponível após o fechamento da #26:
  [Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8).
- #7 está OPEN, disponível e independente:
  [Documento de entrega e como o jogo roda na apresentação](https://github.com/shelldonryan/gtd_example/issues/7).
- O próximo caminho crítico é #8 para arte final; a expansão técnica dos portais
  não bloqueia o inventário.
- A escolha visual das posições finais de portas e escadas continua aberta; a
  infraestrutura aceita coordenadas arbitrárias sem nova alteração de lógica.

### Fronteira Wayfinder

Sincronizada com o grafo nativo após a conclusão da #27:

| Issue | Estado | Bloqueadores abertos | Relação |
|---|---|---|---|
| #7 Documento de entrega | OPEN | — | independente e disponível |
| #8 Inventário de assets | OPEN | — | disponível após #26; próximo caminho crítico |
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
- Sala: três conveses, duas escadas por sala, sem câmera.
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

Código:

- `code/SKETCH_ARCHITECTURE.md`;
- todos os `.pde` de `last_horizon/`;
- comandos e evidências de captura da issue afetada.

`interface/MENU_CONFIGURATION.md` está fora do escopo. Arquivos
`research/*.md` podem existir apenas nas branches `research/*`.

## Lacunas que exigem consulta ou ticket

- a arte final dos objetos e estações, que ainda usam representação geométrica;
- o inventário final de assets, dimensões, reutilização e ordem de produção,
  no ticket [Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8),
  agora disponível;
- As posições finais de portas e escadas continuam sendo uma decisão visual do
  usuário; a infraestrutura já aceita coordenadas arbitrárias e não depende de
  novas alterações de lógica.
- o texto e a estética dos modais e cartões, deferidos por decisão da #27;
- qualquer nome, retrato ou história além de Vera, Bento, Neusa e Sílvia;
- os quatro concept arts de interior em `assets/concept_arts/` ainda precisam ser
  rastreados no inventário final.

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
