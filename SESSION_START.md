# Last Horizon — Session Start

> Resumo operacional obrigatório. Leia antes de analisar, editar ou implementar
> e sincronize-o com o Wayfinder antes de encerrar a sessão.

Atualizado após a conclusão da
[issue #34](https://github.com/shelldonryan/gtd_example/issues/34), que recalibrou
a velocidade da caminhada (1,5 → 1,0 px/quadro) para casar com o ciclo da
animação de `walk`, com a corrida da [issue #33](https://github.com/shelldonryan/gtd_example/issues/33)
intacta (D-153, D-154).
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
- #28 foi concluída em D-158:
  [Escolher e integrar os efeitos sonoros](https://github.com/shelldonryan/gtd_example/issues/28);
  porta, caminhada, corrida e escada estão em bancos independentes sob
  `data/audio/<evento>/`, com licenças, sincronização e carregamento resiliente.
  Encerramento autorizado pelo usuário; commit `713473e`.
- As posições de escada e estação estão **fechadas** para a pintura dos fundos:
  escadas em 127/532 (Comando), 114/526 (Máquinas), 120/489 (Depósito) e 127/482
  (Dormitório), com as estações realocadas e folga mínima de 40 px do eixo de
  uma escada. As portas continuam sendo sprites e mudam sem repintura.
- A entrega vai pelo GitHub: o repositório é privado e o professor tem acesso;
  a branch `entrega` é **gerada** — `node tools/snapshot-entrega.mjs` remonta o
  snapshot a partir da branch de trabalho (D-134) —, e o push é ação do usuário.
  Uma cópia equivalente está em `../entrega_last_horizon/`. A apresentação roda
  na máquina dele abrindo `last_horizon/last_horizon.pde` no Processing.
- #7 foi concluída:
  [Documento de entrega e como o jogo roda na apresentação](https://github.com/shelldonryan/gtd_example/issues/7);
  o plano B é uma gravação curta de partida, a ser feita pelo usuário até 23/09.
- #31 foi concluída: suporte híbrido aos formatos Aseprite e Universal LPC, novo
  player LPC integrado com animações extras de climb na escada e jump no ar, e
  NPCs com olhar dinâmico por convés e alcance de interação ajustado para 22 px
  (D-140 a D-144).
- #32 foi concluída: entrega direta na confirmação presencial de preventivas com o
  responsável (V-02 e N-02, D-145), diálogo de orientação pós-entrega (D-146),
  HUD com `NA MÃO:` (D-147), mapa sem coleta concluída (D-148), cadência dos
  passos na escada a 27 px lógicos (~450 ms) com primeiro passo instantâneo em
  1 px e atenuação do som de saída (D-149, D-150).
- Os 4 retratos de NPCs foram integrados em `data/portraits/` com fundo sólido do
  card em `ui.pde` (D-151), a animação de pulo LPC foi corrigida para a linha 29
  com sequência canônica `0-1-2-3-4-1` em 450 ms (D-152) e o mixer de áudio
  recebeu pré-aquecimento no `setup()` com `primeSound()`.
- #33 foi concluída: corrida com `Shift` no convés a 2,4 px/quadro, com a faixa
  `run` do LPC (linha 41, 8 quadros de 75 ms) e fallback para a caminhada quando a
  spritesheet não traz a faixa (D-153).
- #34 foi concluída: o andar caiu de 1,5 para **1,0 px/quadro** para casar com o
  ciclo de 800 ms da animação de caminhada, com a corrida intacta (D-154).
- O destaque de proximidade dos NPCs foi refinado em D-155: as molduras
  geométricas foram removidas; o sprite recebe contorno/halo cyan gerado em
  runtime quando o técnico entra nos 22 px do gatilho, mantendo o `E`.
- D-156 reposiciona o `E` dos NPCs para a diagonal superior direita, próximo
  da cabeça (`x + 6`, `y - 24`), sem alterar o gatilho, o raio de interação
  ou os demais marcadores da sala.
- D-157 integrou os seis ícones de recursos em `data/icons/` como PNGs
  estáticos de 32×32 (`energia`, `oxigenio`, `agua`, `comida`, `pecas` e
  `moral`); o alerta crítico continua desenhado exclusivamente pelo código.
- D-158 concluiu os passos do técnico com três bancos separados: caminhada usa
  botas sem impacto em `audio/walk/`, sincronizadas aos contatos de 0 e 400 ms
  do ciclo visual de 800 ms; corrida usa a combinação `var_02` — botas
  `footsteps/boots/1,3,5,7` com `impactMetal_000.ogg` de Kenney e atraso de
  30 ms em `audio/run/`; a escada mantém os quatro takes metálicos originais em
  `audio/ladder/`. A issue #28 foi encerrada após autorização explícita.
- D-159 integrou os assets de piso de `assets/PNG/Floor*.png` aos conveses
  das salas: os 6 arquivos foram copiados para `data/environment/floor_1.png` a
  `floor_6.png`, integrados via `art_floor` e pré-renderizados em `art_deck_strip`
  em `assets.pde`, substituindo os traços geométricos em `drawDecks(g)` em
  `ship.pde`. Todos os conveses (superior, médio e inferior) usam `floor_1.png`
  (passadiço metálico reforçado com sinalizadores cyan), preservando a física
  dos pés e o fallback geométrico se a arte não for encontrada.
- D-160 dividiu o vão das escadas por sala mantendo os eixos x inalterados
  (127/532, 114/526, 120/489, 127/482): a escada esquerda liga o convés
  inferior ao médio (deck 2 ao 1, y = 278 a 202) e a escada direita liga o convés
  médio ao superior (deck 1 ao 0, y = 202 a 128). O acoplamento físico em
  `nearestLadder()`, a restrição de altura em `updatePlayerOnLadder()` e o
  desenho em `drawLadders(g)` foram parametrizados por `ladder_top_deck` e
  `ladder_bottom_deck`.
- D-161 reposicionou as portas da Sala de Comando recuadas das paredes físicas,
  preservando proporções arquiteturais e colunas laterais.
- D-162 integrou a camada de paredes de fundo modulares para os 3 conveses da
  nave em `data/environment/wall_deck_0.png` a `wall_deck_2.png`, montadas com
  base em `Wall 3.png`, `Wall 5.png`, `Separation*` e `Semi-wall*`, renderizadas
  por `drawWalls(g)` em `ship.pde` sob o piso metálico `Floor 1.png`.
- D-163 removeu os pontos de interação inativos `POINT_STATUS` ("SITUAÇÃO") e
  `POINT_REACTOR` ("REATOR") do código e da documentação (`INVENTORY.md` e
  `ROOMS.md`), reduzindo `POINT_COUNT` de 18 para 16 e o catálogo de estações a
  produzir de 13 para 11, sem afetar nenhuma quest ou incidente.
- D-164 integrou os assets de portas com animação de 2 quadros, efeito glow cyan
  de proximidade em runtime e reposicionamento adaptativo dos rótulos de interação.
- D-165 alinhou as portas da Sala de Comando com as paredes modulares dos conveses
  (Deck 0: x=40; Deck 1: x=598; Deck 2: x=88) e recalibrou as chegadas padrão
  (Deck 0: x=68; Deck 1: x=570; Deck 2: x=110) conforme gabarito visual.


- Os seis ícones de recursos já foram preparados pelo usuário e entram no HUD
  pelo carregador existente em `last_horizon/assets.pde`.
- O próximo caminho crítico na arte é a seleção dos assets restantes pelo
  usuário na ordem de `assets/INVENTORY.md`.

### Fronteira Wayfinder

Sincronizada com o grafo nativo após o encerramento das issues #28 e #36:

| Issue | Estado | Bloqueadores abertos | Relação |
|---|---|---|---|
| #34 Calibrar a velocidade da caminhada | CLOSED | — | andar a 1,0 px/quadro casado com o ciclo de 800 ms; corrida intacta |
| #33 Adicionar corrida com Shift | CLOSED | — | corrida a 2,4 px/quadro com a faixa `run` do LPC e fallback; verificada no harness |
| #32 Refinamento do fluxo de quests | CLOSED | — | entrega direta na confirmação (V-02, N-02), fala de orientação de NPCs, HUD e mapa refinados |
| #31 Suportar spritesheets Aseprite e LPC | CLOSED | — | suporte híbrido transparente, climb e jump para LPC e novo player integrado |
| #7 Documento de entrega | CLOSED | — | entrega pelo GitHub (repo privado, acesso do professor) e plano B por gravação curta |
| #29 Camada de assets | CLOSED | — | camada de arte com fallback, travessia de porta e drop-in documentado |
| #30 Desacoplar o harness | CLOSED | — | cópia entregue sem `capture.pde`, testada fora do repositório |
| #8 Inventário de assets | CLOSED | — | lista, canvas e ordem de produção em `assets/INVENTORY.md`; escadas e estações congeladas |
| #35 Reestilizar e integrar ícones de recursos do HUD | CLOSED | — | seis PNGs 32×32 integrados; alerta crítico permanece via código; D-157 concluída |
| #36 Refinamento e correções visuais pós-D-157 | CLOSED | — | glow e prompt preservados; orientação dos NPCs corrigida durante o pulo; HUD e gameplay intactos |
| #28 Escolher e integrar os efeitos sonoros | CLOSED | — | porta, caminhada, corrida e escada concluídas em bancos independentes; D-158 |
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
- Jogador: colisão 16×24; andar 1,0 px/quadro; correr 2,4 px/quadro com `Shift`
  no convés; pulo 48 px; gravidade 0,5; escada 1,0; interação 12 px; plataformas
  atravessáveis por baixo.
- Controles: setas/WASD, `Shift` para correr, espaço, E, ENTER em diálogos/modais,
  ESC para pausa e mouse nos botões `MAPA` e `ORDENS`.
- HUD: seis ícones 16×16; cartões de recurso com ícone, número, rótulo e barra.
- Áudio offline: `javax.sound.sampled`, WAV PCM 16 bits em
  `data/audio/<evento>/`; porta, escada e passos do técnico (caminhada, corrida,
  decolagem e aterrissagem) estão integrados; alerta e clique seguem sem som.
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
- **D-134 (workflow da entrega):** a branch `entrega` é artefato **gerado** a
  partir da branch de trabalho (`node tools/snapshot-entrega.mjs`); código e
  documentação evoluem só na branch de trabalho e o snapshot é remontado antes
  de publicar — não existe atualização em dois lugares.
- **D-135 (sessão #28, som):** o conjunto de sons foi definido evento por evento
  e ficou em **travessia de porta e escada**; clique de UI, alerta de recurso
  crítico e os demais eventos não têm som — o alerta continua apenas visual. A
  cadência "uma vez na transição para o vermelho" chegou a ser confirmada e foi
  revertida na mesma sessão, ficando **SUPERSEDED**; o par "clique + alerta" era
  recorte de escopo da #3, nunca confirmado pelo usuário.
- **D-136 (sessão #28, som):** o som da escada é a mistura de `footsteps/metal/4`
  (congusbongus, CC-BY 3.0, crédito obrigatório de Eelke) com `impactMetal_004`
  (Kenney, CC0), 60 ms entre as peças; os arquivos vivem em
  `last_horizon/data/audio/ladder/`, com receita e créditos em
  `LICENSE.txt`, e toca **apenas na saída** da escada — o engate não tem som,
  porque a subida é coberta pelos passos (D-137). Nesta etapa, a porta ainda
  estava pendente (**SUPERSEDED por D-138**), com a direção "pneumático metálico".
- **D-137 (sessão #28, som):** a escada ganhou **passos** enquanto o técnico sobe
  ou desce — a cadência inicialmente registrada de 18 px lógicos por passo está
  **SUPERSEDED** pelo ajuste final posterior: `LADDER_STEP_SPACING = 27` px
  lógicos (~450 ms), conforme o código atual e a licença do asset.
  O gatilho do `ladder.wav` é único, na saída (`leaveLadderAtDeck`), o que também
  elimina o disparo duplo que existia nas pontas da escada, quando engate e saída
  caíam no mesmo quadro. A medição inicial registrava `ladder.wav` a −10 dBFS;
  esse nível está **SUPERSEDED por D-150**, que o atenuou para −18,6 dBFS de pico
  e −34,1 dBFS de RMS, mantendo os passos a −20 dBFS com passa-baixas em 5 kHz.
- **D-138 (sessão #28, som):** a porta usa `door.wav` — chiado de ar contínuo
  (rubberduck, CC0) com batente metálico (Kenney, CC0) 480 ms depois, escolhido
  pelo usuário entre seis candidatos; toca uma vez no início da travessia
  (`enterRoomThroughDoor`), nos dois caminhos, com ou sem a arte da porta. Os
  sons ficaram separados em `data/audio/<evento>/`, cada pasta com o seu
  `LICENSE.txt`. A porta foi suavizada por medição: pico em −10 dBFS e RMS em
  −25,8 dBFS; a escada foi atenuada posteriormente em D-150 para −18,6 dBFS de
  pico e −34,1 dBFS de RMS, portanto os níveis finais não são iguais.
- **D-139 (sessão #28, som; estado histórico SUPERSEDED pela autorização de encerramento de 2026-09-18):** o escopo do #28 — porta e escada — foi entregue, integrado e aprovado na escuta. A hipótese de acrescentar outros sons se sobrasse tempo era **PROVISÓRIA**, nunca requisito, e não integra a fronteira atual; o ticket #28 está **CLOSED**.
  A fronteira vigente não amplia o recorte sem nova decisão explícita.
- **D-140 (sessão #31, spritesheet do jogador):** o sketch suporta
  transparentemente os formatos Aseprite e Universal LPC; no LPC, o player ativa
  `climb` (6 quadros, linha 21) na escada e `jump` (13 quadros, linha 49) no ar,
  com fallback gracioso para idle/walk quando o sprite for Aseprite.
- **D-141 (sessão #31, spritesheet de NPCs):** na camada de arte (`assets.pde`),
  os NPCs suportam transparentemente o formato Universal LPC com orientação
  frontal (Sul / linha 24, 2 quadros de respiração), além do formato Aseprite com
  array `"frames"`.
- **D-142 (sessão #31, organização de assets do jogador):** substituição direta
  com backup — `player_sheet.png` e `player_sheet.json` passam a ser o novo sprite
  LPC (832×3456), com o original mantido como `player_sheet_aseprite.*`, backup
  explícito em `player_sheet_lpc.*` e créditos/licença em `LICENSE.txt`.
- **D-143 (sessão #31, integração de NPCs e olhar por deck):** os 4 NPCs
  (`vera.png`, `bento.png`, `neusa.png` e `silvia.png`) foram integrados em `data/npc/`
  no padrão Universal LPC com `LICENSE.txt`. Em `ship.pde`, `drawNpc` verifica se o
  jogador está no mesmo convés (`same_deck`): se estiver no mesmo deck, o sobrevivente
  vira dinamicamente para o técnico (linha 23 para a esquerda, linha 25 para a direita);
  se estiver em deck diferente ou em escada, mantém a pose neutra/frontal (linha 24),
  preservando o fallback geométrico caso o asset não exista.
- **D-144 (sessão #31, raio de interação dos NPCs):** o alcance lateral de
  interação com NPCs foi ajustado para 22 px (`NPC_INTERACTION_RANGE = 22`), após
  redução de ~30% em relação aos 32 px iniciais, proporcionando um encaixe justo
  e natural ao lado do sobrevivente. Estações e portas mantêm o raio padrão de 12 px.
- **D-145 (sessão #32, entrega direta em preventivas):** quando a origem de uma
  ordem preventiva coincide com o próprio responsável (`V-02` com Vera e `N-02` com
  Neusa), a confirmação presencial entrega o objeto diretamente na mão do técnico
  (`held_item = active_quest + 1`) e avança a etapa imediatamente para `QUEST_DELIVER`,
  eliminando a segunda interação redundante no mesmo ponto físico.
- **D-146 (sessão #32, fala de orientação pós-entrega):** ao interagir novamente
  com o responsável da quest com o objeto já em mãos, o diálogo orienta a rota de
  entrega no destino ("SIGA A ORDEM: JÁ ENTREGUEI [OBJETO]. LEVE ATÉ [DESTINO]."),
  reforçando a clareza da etapa atual.
- **D-147 (sessão #32, linha de rota no HUD com item na mão):** em `hud.pde`,
  quando o técnico carrega um item (`held_item != ITEM_NONE`), a segunda linha da
  faixa de ordem exibe `NA MÃO: [OBJETO] | ENTREGA: [DESTINO]`, alinhada à terminologia
  canônica de `INVENTORY.md`.
- **D-148 (sessão #32, mapa consultável na etapa de entrega):** em `ship.pde`,
  a ficha da sala no mapa oculta a linha de `COLETA` quando a etapa já avançou para
  `QUEST_DELIVER`, exibindo apenas `ENTREGA` na sala de destino.
- **D-149 (sessão #32, sincronização de som e animação da escada):** o ritmo dos
  passos na escada foi recalibrado para uma cadência mais cadenciada e natural:
  animação com quadros de 140 ms (420 ms por passada no LPC de 6 quadros) e
  `LADDER_STEP_SPACING = 25` px lógicos (~417 ms a 60 FPS), eliminando a sensação
  acelerada do valor anterior. O primeiro passo dispara em `LADDER_FIRST_STEP = 1` px lógico
  (~16 ms / 1 quadro), o temporizador `player_animation_started_at` passa a ser
  reiniciado ao iniciar o movimento na escada, e o subsistema de áudio passa por
  pré-aquecimento no `setup()` com `primeSound()`.
- **D-150 (sessão #32, atenuação do som de saída da escada):** atendendo ao pedido
  de menos destaque ao final do curso da escada, `ladder.wav` foi atenuado em −8,5 dB
  (pico de −10,0 dBFS para −18,6 dBFS; RMS de −25,6 dBFS para −34,1 dBFS) e filtrado com
  passa-baixas em 5 kHz, eliminando o estalo metálico agudo e nivelando a presença sonora
  diretamente à faixa dos passos da subida.
- **D-151 (sessão complementar, retratos dos NPCs no diálogo):** os 4 retratos em pixel art
  foram integrados em `data/portraits/` (`vera.png`, `bento.png`, `neusa.png`, `silvia.png`),
  com fallback automático para `data/npc/*_portrait.png` em `assets.pde`. Em `ui.pde`,
  `drawPortrait` agora desenha o fundo sólido do card (`COL_PANEL` e `COL_BORDER`) antes da arte com transparência, eliminando vazamento visual do cenário atrás do busto.
- **D-152 (sessão complementar, sequência canônica de pulo LPC 0-1-2-3-4-1 na linha 29):** a animação de pulo
  do técnico no padrão Universal LPC foi corrigida para a linha correta de pulo (linha 29, Leste / perfil direito,
  pertencente ao bloco de 4 direções das linhas 26–29 com 5 quadros cada), usando a sequência canônica
  `0-1-2-3-4-1` (6 quadros a 75 ms), totalizando 450 ms, sincronizada perfeitamente
  com o tempo de voo físico de 462 ms (28 frames a 60 FPS). Em quedas prolongadas, o frame é
  fixado na pose final de aterrissagem via `min(raw_elapsed, total_duration - 1)`, sem repetir o agachamento no ar.
- **D-153 (sessão #33, corrida com Shift):** `Shift` com uma direção horizontal
  acelera o técnico de 1,5 para 2,4 px/quadro no convés e ativa a faixa `run` da
  spritesheet (linha 41 do LPC, 8 quadros de 75 ms, espelhada para Oeste), com
  regresso imediato a caminhada ou repouso ao soltar a tecla. Correr é decisão de
  convés: escada e ar mantêm velocidade e animação próprias, `Shift` parado não
  anima nada, e um sprite sem a faixa de `run` acelera o passo mantendo a
  caminhada. Velocidade e animação saem do mesmo predicado, então nunca
  discordam. O modal `AJUDA — CONTROLES` ganhou a linha `CORRER: SHIFT` e passou
  a dimensionar a altura pelo número de linhas.
- **D-154 (sessão #34, caminhada):** o playtest reprovou o andar a 1,5 px/quadro
  por deslizar em relação à animação de 8 quadros a 100 ms. `PLAYER_SPEED` caiu
  para **1,0 px/quadro**: 48 px lógicos por ciclo, perto de duas alturas do
  técnico, mantendo a navegação da nave em ~10 s de ponta a ponta. A corrida
  (2,4 px/quadro) foi aprovada no playtest e ficou intacta.
- **D-155 (sessão complementar, destaque visual dos NPCs):** as molduras
  geométricas do ponto de NPC foram removidas. A camada de assets pré-calcula
  máscaras cyan a partir da transparência de cada frame LPC/Aseprite e
  desenha o contorno/halo somente quando o NPC está dentro do alcance de 22 px.
  O `E` permanece como prompt de interação; colisão, interação e sprites
  originais não mudam.
- **D-156 (sessão complementar, posição do prompt de NPC):** quando o técnico
  está no alcance, o `E` aparece na diagonal superior direita, próximo da
  cabeça (`x + 6`, `y - 24`). Estações, portas, quests e o raio de interação
  permanecem iguais.
- **D-157 (sessão complementar, ícones de recursos do HUD):** os seis recursos
  usam PNGs estáticos de 32×32 em `data/icons/`; o alerta crítico continua
  desenhado exclusivamente em código, sem `aviso.png`.
- **D-158 (sessão #28, bancos de passos e sincronização):** caminhada, corrida
  e escada usam bancos independentes. A caminhada toca nos contatos de 0 e
  400 ms do ciclo visual de 800 ms; a corrida preserva a combinação `var_02` e
  a cadência aprovada; a escada mantém seus takes e gatilhos. O carregador
  reporta 14 de 14 clipes e degrada para mudo sem quebrar o jogo. As issues #28
  e #36 foram encerradas após autorização explícita; commit `713473e`.
- **D-159 (sessão conveses modulares):** conveses utilizam `floor_1.png` a `floor_6.png`
  em `last_horizon/data/environment/`, com todos os conveses usando `floor_1.png`
  pré-renderizado em `art_deck_strip` em `assets.pde`, substituindo os traços
  geométricos em `drawDecks(g)`.
- **D-160 (sessão escadas por convés):** escadas divididas por vão vertical mantendo
  eixos horizontais inalterados (esquerda deck 2 a 1, direita deck 1 a 0), com
  transição física e visual sem atravessar decks inexistentes.
- **D-161 (sessão layout das portas no Comando):** portas da Sala de Comando recuadas
  das paredes laterais (`door_x = 50, 590, 50`), reproduzindo as proporções dos
  concept arts e mantendo passadiços seguros.
- **D-162 (sessão paredes modulares dos conveses):** tiras pré-renderizadas de paredes
  modulares para os 3 conveses da nave em `data/environment/wall_deck_0.png` a
  `wall_deck_2.png` montadas sem distorção com base em `Wall 3`, `Wall 5`, `Separation*`
  e `Semi-wall*`, desenhadas por `drawWalls(g)` em `ship.pde` sob o piso metálico e
  preservando o fallback geométrico.
- **D-163 (sessão saneamento de estações inativas):** remoção de `POINT_STATUS` ("SITUAÇÃO")
  e `POINT_REACTOR` ("REATOR") do código e da documentação (`assets/INVENTORY.md` e
  `interface/ROOMS.md`), reduzindo `POINT_COUNT` de 18 para 16 e o catálogo de estações a
  produzir de 13 para 11, sem impacto em quests ou incidentes.
- **D-164 (sessão integração dos assets de portas):** spritesheet de 2 quadros em
  `last_horizon/data/doors/door_sheet.png` (210×97 px), animação de travessia, contorno
  glow cyan em runtime na aproximação do técnico e rótulos `E - [SALA]` adaptativos.
- **D-165 (sessão alinhamento das portas no Comando):** portas da Sala de Comando
  alinhadas visual e arquiteturalmente com as paredes modulares dos conveses (D-162):
  Deck 0 em `x = 40` no vão de `Wall 3`; Deck 1 em `x = 598` na baía direita sob a luminária;
  Deck 2 em `x = 88` na baía liberada por `POINT_STATUS`. Chegadas padrão recalibradas
  para `x = 68` (Deck 0), `x = 570` (Deck 1) e `x = 110` (Deck 2).


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

### Sessão atual — sincronização dos quatro conflitos de áudio
Sessão de alinhamento documental com o código atual, sem alteração de gameplay
ou do sketch.

- **Cadência final:** `LADDER_STEP_SPACING = 27` px lógicos (~450 ms), com
  primeiro passo em 1 px. Os registros anteriores de 18 e 25 px foram marcados
  como **SUPERSEDED** no histórico local.
- **Níveis finais:** `ladder.wav` em −18,6 dBFS de pico e −34,1 dBFS de RMS,
  com passa-baixas em 5 kHz; passos em −20 dBFS com passa-baixas em 5 kHz;
  `door.wav` em −10 dBFS de pico e −25,8 dBFS de RMS.
- **Escopo vigente:** somente travessia de porta e escada. Clique de UI e alerta
  de recurso crítico permanecem sem som.
- **Evidência vigente:** o código e `code/VERIFICATION.md` registram
  `--capture` com 159 `OK`, `--ladder-test` com 6 `OK`, `--hit-test` com 5
  `OK` e `--asset-pipeline-test` com `OK`. Contagens 145/146 permanecem como
  baseline histórico das sessões anteriores.
- **Wayfinder:** corpos das issues #1, #8 e #28 atualizados; comentários de
  sincronização registrados em #1, #8 e #28. A fronteira não mudou: #1 e #28
  continuam OPEN; #28 permanece aberta por D-139, sem ampliação aprovada; #8 e
  todas as demais tarefas continuam CLOSED.
- **Arquivos locais atualizados:** este resumo e
  `last_horizon/data/audio/{door,ladder}/LICENSE.txt`. Nenhum arquivo `.pde`
  foi alterado. A conferência final foi documental, sem nova execução do harness.

**Resultado:** conflitos resolvidos contra o contrato implementado; a produção
da arte continua como próximo caminho crítico, iniciando pelos ícones do HUD.

### Sessão anterior — #34 calibração da caminhada
Sessão da [issue #34](https://github.com/shelldonryan/gtd_example/issues/34) —
reajuste do andar para casar com a animação de caminhada.

- **Relato do playtest:** o técnico deslizava andando; a corrida com `Shift` está
  aprovada e **não foi tocada**.
- **Decisão (D-154):** `PLAYER_SPEED` foi de 1,5 para **1,0 px/quadro**. A
  animação de caminhada tem 8 quadros de 100 ms (ciclo de 800 ms) e um passo
  curto: a 1,5 px/quadro o técnico cobria 72 px lógicos por ciclo (três alturas)
  e os pés patinavam. Com 1,0 px/quadro o ciclo cobre 48 px lógicos (duas
  alturas) e o deslize por quadro de animação cai cerca de um terço (medido nas
  solas: de 15–24 para 9–18 px de arte por quadro). O passo lateral ao sair da
  escada (`leaveLadderAtDeck`) usa a mesma constante e encolhe junto.
- **Código alterado:** `last_horizon/last_horizon.pde` (`PLAYER_SPEED` com o
  comentário de calibração).
- **Evidência:** `--capture` → **159 asserções `OK`**, zero `FALHOU`,
  `QUEST CHECK: PASS`; `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`;
  `--asset-pipeline-test` → `OK`. A aferição do deslize é medida, mas o veredito
  continua sendo o playtest.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `730d57b`
  (sketch) e `8ac6494` (documentos), mais este registro.
- **Resultado:** funcionalidade ajustada no jogo Processing — andar casado com a
  animação; nenhuma outra tecla, faixa ou velocidade mudou.

### Sessão anterior — #33 corrida com Shift
Sessão da [issue #33](https://github.com/shelldonryan/gtd_example/issues/33) —
corrida acionada por `Shift`, com a faixa `run` da spritesheet.

- **Decisão confirmada (D-153):** `Shift` com uma direção horizontal corre no
  convés a 2,4 px/quadro (caminhada, 1,5 na época; recalculada na #34) e anima a
  linha 41 do LPC (8 quadros de 75 ms, espelhada para Oeste); soltar a tecla volta
  imediatamente a caminhada ou repouso. Correr é decisão de convés: escada e ar
  mantêm velocidade e animação próprias, `Shift` parado não anima nada e um sprite
  sem a faixa de `run` acelera o passo mantendo a caminhada. Velocidade e animação
  compartilham o mesmo predicado (`playerIsRunning()`), então sprite e passo nunca
  discordam.
- **Código alterado:** `last_horizon/last_horizon.pde` (`PLAYER_RUN_SPEED`,
  `run_held`, faixa de `run`, `SHIFT` no mapa de teclas), `last_horizon/ship.pde`
  (carga da linha 41, tag `run` do Aseprite, estados `PLAYER_ANIM_*`,
  `playerIsRunning()` e passo do convés), `last_horizon/ui.pde` (linha
  `CORRER: SHIFT COM ← → OU A/D` e painel de ajuda que dimensiona pelo número de
  linhas) e `last_horizon/capture.pde` (`checkPlayerRun()`).
- **Evidência:** `--capture` → **159 asserções `OK`**, zero `FALHOU`,
  `QUEST CHECK: PASS`, `som: 6 de 6 carregados`, `arte: 8 de 57 imagens carregadas`;
  `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`; `--asset-pipeline-test` → `OK`.
  A linha de base medida no commit `fd62b7a` fecha em 148 asserções, então o
  delta é de +11, sem remoções. Revisão de código independente antes do commit:
  oito achados, todos tratados (guardas do teste sem faixa de `run`, asserções
  por mutação — linha 39 no lugar da 41, passo antes da gravidade e perda do
  passo acelerado reprovam —, tecla vazada no harness, termo inerte em
  `player_animation_moving`, ordem do passo no quadro da decolagem e
  enumerações da arquitetura). Inspeção visual do modal de ajuda confirma a nova
  linha e o botão com folga.
- **Wayfinder:** #33 fechada com o relatório da sessão; a fronteira fica #28
  (áudio, aberta por decisão do usuário) e a arte na ordem de
  `assets/INVENTORY.md`.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `3962d52`
  (sketch) e `2b91c24` (documentos), mais este registro.
- **Resultado:** funcionalidade pronta no jogo Processing — corrida no convés com
  animação própria e fallback.

### Sessão anterior — áudio da escada, retratos de NPC e animação do pulo
Sessão de correção do áudio da escada, integração dos 4 retratos de diálogo e alinhamento da animação de pulo LPC.

- **Áudio da escada (D-149, D-150):** `primeSound()` agora aquece os clips em frame 0
  por 50 ms em silêncio durante `setup()`, eliminando a latência do mixer; cadência
  dos passos calibrada em 27 px lógicos (~450 ms) com o primeiro passo instantâneo em 1 px.
- **Retratos dos NPCs (D-151):** 4 portraits integrados em `data/portraits/` (`vera.png`,
  `bento.png`, `neusa.png`, `silvia.png`) com fallback para `data/npc/*_portrait.png`;
- **Animação do pulo (D-152):** o pulo LPC foi corrigido para a linha real de pulo
  (linha 29, Leste / perfil direito do bloco 26–29 de 5 quadros), usando a sequência canônica
  do Universal LPC Generator `0-1-2-3-4-1` (6 quadros a 75 ms), totalizando 450 ms,
  casando perfeitamente com os 462 ms de tempo no ar da física do pulo (28 frames a 60 FPS).
  Em quedas longas, o frame congela no quadro final de descida/aterrissagem sem repetir agachamento no ar.
- **Evidência:** `--ladder-test` → 6 `OK`, `som: 6 de 6 carregados`, `arte: 8 de 57 imagens carregadas`;
  `--hit-test` → 5 `OK`; `--capture` → `QUEST CHECK: PASS`, 148 asserções `OK`
  (recontadas no commit `fd62b7a`; o número 146 registrado na sessão estava defasado).
- **Commit na branch `prototype/sketch-architecture` (sem push):**
  `7cde3f9` — `feat(sketch): integrar retratos dos NPCs, corrigir pulo LPC e ajustar audio`
- **Wayfinder:** #28 reivindicada e mantida OPEN para validação acústica no ambiente de apresentação;
  #32 atualizada com o relatório da sessão e mantida OPEN.
### Sessão anterior — #32
Sessão da [issue #32](https://github.com/shelldonryan/gtd_example/issues/32) —
refinamento do fluxo de quests, eliminação de redundâncias e polimento do HUD/mapa.

- **Decisões confirmadas (D-145 a D-150):** entrega direta na confirmação de preventivas
  (V-02 e N-02) avançando direto para `QUEST_DELIVER`; diálogo de orientação atualizado;
  linha de rota no HUD exibindo `NA MÃO:` quando item carregado; mapa consultável exibindo
  apenas entrega na etapa de entrega; sincronização da cadência sonora da escada
  com a animação de climb (o valor intermediário de 25 px foi **SUPERSEDED** pelo
  ajuste final posterior para 27 px / ~450 ms, com partida instantânea em 1 px);
  e atenuação do som de saída da escada (`ladder.wav` a −18,6 dBFS de pico,
  −34,1 dBFS de RMS, com passa-baixas em 5 kHz).
- **Código alterado:** `tasks.pde` (`acceptPreventive`, `interactNpc`), `hud.pde` (`orderRouteLine`),
  `ship.pde` (`drawRoomCard`), `capture.pde` (`captureCompleteQuest`, asserção de entrega direta)
  e `prototype/balance-model.mjs` (`acceptPreventive`).
- **Evidência:** `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` → **146 asserções `OK`**,
  zero `FALHOU`, `QUEST CHECK: PASS`, `som: 6 de 6 carregados`, `arte: 4 de 57 imagens carregadas`.
  `node prototype/balance-model.mjs --simulate` → `BALANCE CHECK: PASS` (2520/2520 sequências).
- **Wayfinder:** #32 aberta e mantida OPEN por decisão expressa do usuário, ligada como sub-issue da #1.
- **Fontes sincronizadas:** `mechanics/ACTIONS.md`, `interface/FLOW.md`, `interface/HUD.md`,
  `code/SKETCH_ARCHITECTURE.md`, `code/VERIFICATION.md` e este arquivo.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `a8aeed6` (sketch), `0e632ba` (áudio) e este registro de documentação.
- Resultado: funcionalidade refinada e verificada no Processing — fluxo de preventivas sem cliques redundantes.

### Sessão anterior — #31

Sessão da [issue #31](https://github.com/shelldonryan/gtd_example/issues/31) —
suporte híbrido aos padrões Aseprite e Universal LPC, novas animações do player e integração.

- **Decisões do usuário (D-140 a D-142):** suporte híbrido transparente a Aseprite e LPC;
  ativação de `climb` (6 quadros, linha 21) na escada e `jump` (13 quadros, linha 49) no ar
  para sprites LPC, com fallback gracioso para Aseprite; orientação frontal (Sul / linha 24)
  para NPCs no formato LPC; substituição direta com backup (`player_sheet_aseprite.*` e `LICENSE.txt`).
- **Código:** `assets.pde` detecta automaticamente JSON Aseprite (`"frames"`) vs LPC;
  carrega perfis esquerdo (linha 23) e direito (linha 25) para os NPCs virarem
  dinamicamente na direção do técnico (D-143); `ship.pde` gerencia máquina de
  estados com idle, walk, climb e jump.
- **Assets integrados:** os 4 NPCs foram colocados em `data/npc/` (`vera.png`,
  `bento.png`, `neusa.png`, `silvia.png`) com `LICENSE.txt`.
- **Evidência:** `--hit-test` → 5 `OK`; `--ladder-test` → 6 `OK`; `--capture` → **145 asserções `OK`**,
  zero `FALHOU`, `QUEST CHECK: PASS`, `arte: 4 de 57 imagens carregadas`.
  Inspeção visual confirma Vera, Bento, Neusa e Sílvia desenhados no convés e olhando
  para o jogador.
- **Wayfinder:** #31 criada, rotulada `wayfinder:task`, vinculada como sub-issue da #1 e concluída com evidência.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `ec99d12` (sketch),
  `84cfe48` (assets), `5c46a74` (documentos), `a509fe0` (vault) e este registro.
- Resultado: funcionalidade pronta no jogo Processing — player e 4 NPCs integrados em LPC, com animações e olhar dinâmico.
### Sessão anterior — #28


Sessão da [issue #28](https://github.com/shelldonryan/gtd_example/issues/28) —
som da escada e da porta escolhidos com o usuário, integrados e verificados.

- Fronteira recalculada no grafo nativo antes desta sessão: apenas #1 e #28
  abertas; #28 sem bloqueadores.
- **Correção de escopo:** o ticket afirmava "dois efeitos (clique e alerta)",
  herdados do recorte da #3, sem confirmação do usuário. A definição passou a ser
  **evento por evento**, a partir dos eventos reais do código — 18 candidatos
  levantados com âncora em `ship.pde`, `game.pde`, `hud.pde` e `tasks.pde` —, e a
  procedência ficou registrada no ticket.
- **Decisões do usuário:** clique de UI e alerta de recurso crítico **sem som**
  (a cadência "uma vez na transição para o vermelho" foi confirmada e revertida
  na mesma sessão — **SUPERSEDED**); a escada toca na **saída** e ganha **passos**
  na subida e na descida, com o primeiro passo em 1 px e os seguintes a cada
  27 px lógicos (~450 ms); a porta toca **uma vez na travessia** (D-135 a D-138).
- **Escolha por escuta, em quatro rodadas:** a Kenney foi reprovada pelo usuário;
  entraram qubodup (portas reais), yd (porta deslizante), BMacZero (mecânica),
  rubberduck (ar) e congusbongus (escada de alumínio). A porta final — "tsssss
  contínuo + metal" — trocou a camada de ar, que era gravação de porta de
  madeira, por chiado real: ZCR 4.070 → ~13.400.
- **Defeito corrigido:** engate e saída da escada no mesmo quadro disparavam o
  som em rajada — 5 disparos no mesmo quadro no teste do harness → 1 depois. Com
  o gatilho único na saída, o caso deixou de existir por construção.
- **Níveis finais medidos, não estimados:** `ladder.wav` a −18,6 dBFS de pico e
  −34,1 dBFS de RMS, com passa-baixas em 5 kHz; passos a −20 dBFS com passa-baixas
  em 5 kHz; porta a −10 dBFS de pico e −25,8 dBFS de RMS.
- **Estrutura:** os sons ficaram em `data/audio/<evento>/`, cada pasta com o seu
  `LICENSE.txt`.
- **Evidência da integração:** `--ladder-test` → 6 `OK`; `--capture` →
  **145 asserções `OK`** no baseline daquela sessão, zero `FALHOU`,
  `QUEST CHECK: PASS`, `som: 6 de 6 carregados`; com a pasta de som ausente,
  `5 de 6 carregados`, jogo mudo e sem exceção. O estado atual consolidado do
  sketch fecha em **159 asserções `OK`**, conforme `code/VERIFICATION.md`.
- **Wayfinder:** #28 permanece OPEN por decisão do usuário (D-139), com o corpo
  reescrito no estado entregue; a #1 registra a entrega e a hipótese.
- **Commits** na branch `prototype/sketch-architecture`, sem push: `f11ca5b`
  (sketch), `274aa4a` (sons), `ce7098a` (documentos), `34dda16` (vault) e o
  próprio registro de commits. A
  árvore fica limpa, exceto `last_horizon/data/player/player_sheet_new.*`, que
  não é desta sessão. A branch `entrega` precisa ser remontada
  (`node tools/snapshot-entrega.mjs`) antes de publicar.
- Resultado: funcionalidade pronta no jogo Processing — som de porta e de escada,
  com licenças e níveis documentados.

### Sessão anterior — #7

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
- Commits da sessão na branch de trabalho, sem push: `acca499` (sketch),
  `9124fbf` (documentos), `6d52247` (resumo), `8ff4f26` (Obsidian) e `00bc5fa`
  (script do snapshot e regra D-134).
- A branch `entrega` foi gerada por `tools/snapshot-entrega.mjs` — 42 arquivos,
  sem material de verificação — e o script não cria commit quando a árvore não
  mudou.
- Pendências: som (#28) e a seleção da arte seguem abertos, e a gravação do
  plano B é ação do usuário até 23/09.
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

### Sessão anterior — destaque visual dos NPCs

Refinamento complementar do fluxo de interação, solicitado após a inspeção
visual das molduras duplas nos personagens.

- **Decisão D-155:** remover os dois retângulos geométricos que envolviam NPCs.
  O feedback de proximidade passa a ser um contorno/halo cyan pixelado,
  calculado em runtime a partir da transparência do frame atual do sprite.
- O efeito é pré-calculado no carregamento para os frames frontal, esquerdo e
  direito de cada NPC; os PNGs não foram alterados. Isso preserva o idle LPC e
  o fallback geométrico.
- O raio lateral continua em 22 px; o `E` aparece na diagonal superior direita,
  próximo da cabeça, somente quando o ponto está disponível e o técnico está
  na mesma altura.
- **Arquivos alterados:** `last_horizon/assets.pde`,
  `last_horizon/ship.pde`, `interface/ROOMS.md`,
  `code/SKETCH_ARCHITECTURE.md`, `assets/INVENTORY.md` e
  `code/VERIFICATION.md`.
- **Evidência:** `--capture` → 159 asserções `OK`, `QUEST CHECK: PASS`;
  `--hit-test` → 5 `OK`; `--asset-pipeline-test` → `pipeline: OK`.
  A inspeção visual confirmou as molduras removidas e o contorno pixelado
  preservando a leitura do NPC.

**Resultado:** funcionalidade pronta no jogo Processing; documentação local
sincronizada. A seleção de arte CC0/CC-BY continua sendo o próximo caminho
crítico.

### Sessão atual — ícones de recursos do HUD

Os seis ícones fornecidos pelo usuário foram exportados para o contrato do HUD
e integrados pelo carregador de assets existente.

- **Decisão D-157:** usar `energia.png`, `oxigenio.png`, `agua.png`,
  `comida.png`, `pecas.png` e `moral.png` em `last_horizon/data/icons/`.
- Os PNGs finais têm canvas 32×32, são estáticos e são desenhados no cartão em
  16×16 unidades lógicas.
- O alerta crítico permanece geométrico e desenhado exclusivamente em código;
  `aviso.png` não faz parte do conjunto.
- O layout dos cartões, valores, barras, limiares críticos e gameplay não
  foram alterados.
- **Estado Wayfinder:** `Reestilizar e integrar ícones de recursos do HUD`
  foi encerrada após autorização explícita; commit `21f105d`.
- **Evidência D-157:** `--asset-pipeline-test` carregou os seis PNGs
  (`arte: 14 de 56 imagens carregadas`, `pipeline: OK`); `--hit-test`
  retornou 5 `OK`; `--capture` concluiu com `QUEST CHECK: PASS`. A inspeção
  visual do HUD confirmou os seis ícones nos cartões sem alteração do layout.

### Encerramento — issues #28 e #36

- [#28](https://github.com/shelldonryan/gtd_example/issues/28) foi encerrada com
  os quatro bancos de áudio documentados e verificados em D-158.
- [#36](https://github.com/shelldonryan/gtd_example/issues/36) foi encerrada com
  glow, prompt e ícones preservados e a orientação do NPC corrigida durante o
  pulo.
- **Evidência final:** `--capture` → 169 `OK`, `QUEST CHECK: PASS`;
  `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`;
  `--asset-pipeline-test` → `pipeline: OK`.
- **Commit técnico:** `713473e`. A issue-mapa #1 permanece aberta; as duas
  sub-issues aparecem como `CLOSED` no grafo nativo.

### Sessão atual — conveses com assets modulares Floor*.png (D-159)

- **Decisão D-159:** usar `floor_1.png` a `floor_6.png` em `last_horizon/data/environment/` para a composição visual dos conveses. Por decisão do usuário, todos os conveses (superior, médio e inferior) usam `floor_1.png`.
- As tiras de piso são pré-renderizadas em `art_deck_strip` durante o carregamento de arte, eliminando alocações no loop de 60 FPS e garantindo pixel-art 1:1 exato com recorte nas bordas da sala (`ROOM_LEFT + 4` a `ROOM_RIGHT - 4`).
- O fallback geométrico permanece totalmente funcional se a arte estiver ausente.
- **Evidência D-159:** `--asset-pipeline-test` carregou 20 de 62 imagens (`pipeline: OK`); `--ladder-test` retornou 6 `OK`; `--hit-test` retornou 5 `OK`; `--capture` concluiu com 169 asserções `OK`, zero `FALHOU` e `QUEST CHECK: PASS`.

### Sessão atual — escadas divididas por convés (D-160)

- **Decisão D-160:** dividir o vão das escadas por sala mantendo os eixos horizontais inalterados. A escada esquerda liga o convés inferior ao médio (`top_deck = 1`, `bottom_deck = 2`) e a escada direita liga o convés médio ao superior (`top_deck = 0`, `bottom_deck = 1`), eliminando a continuidade vertical que atravessava todos os 3 conveses.
- A física de subida/descida em `ship.pde` foi atualizada com `current_ladder`, `ladder_top_deck` e `ladder_bottom_deck`: o jogador só agarra a escada na direção do vão correspondente, transita sem atravessar decks inexistentes e salta com saída lateral limpa.
- **Evidência D-160:** `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`; `--capture` → 169 `OK`, zero `FALHOU`, `QUEST CHECK: PASS`.

### Sessão atual — layout das portas na Sala de Comando (D-161)

- **Decisão D-161:** reposicionar as portas da Sala de Comando (`SCREEN_COMMAND`) recuadas das paredes físicas, reproduzindo a proporção da arte do conceito:
  - **Convés Superior (Deck 0):** porta no lado esquerdo com recuo (`door_x[0] = 50`), preservando a coluna/guarda-corpo à esquerda. Retorno do Dormitório ao Comando configurado em `x = 78` com orientação para a direita (`facing = 1`).
  - **Convés Médio (Deck 1):** porta no lado direito com recuo (`door_x[1] = 590`), preservando a coluna de parede à direita e 58 px de vão até a escada direita (`x = 532`). Retorno do Depósito ao Comando configurado em `x = 562` com orientação para a esquerda (`facing = -1`).
  - **Convés Inferior (Deck 2):** porta movida do centro (`x = 320`) para o lado esquerdo com recuo (`door_x[2] = 50`), alinhada verticalmente com o convés superior e com espaçamento seguro de 35 px até a estação de Situação (`x = 85`). Retorno da Sala de Máquinas ao Comando configurado em `x = 72` com orientação para a direita (`facing = 1`).
- `placePlayerAtDoor()` no harness (`capture.pde`) passa a aplicar `constrain(..., ROOM_LEFT + 4, ROOM_RIGHT - 4 - PLAYER_W)` para respeitar a física dos limites da sala, espelhando `enterRoomAtPosition()` e `updatePlayerWalk()`.
- **Evidência D-161:** `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`; `--asset-pipeline-test` → `pipeline: OK`; `--capture` → 169 asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS` e 2.520/2.520 campanhas vencidas.

### Sessão atual — paredes modulares dos conveses (D-162)

- **Decisão D-162:** compor tiras contínuas de parede modular para os 3 conveses de `last_horizon` a partir dos assets nativos de `assets/PNG/` (`Wall 3`, `Wall 5`, `Separation*`, `Semi-wall*`):
  - **Deck 0 (Comando Superior, 1232×144 px):** `Wall 3` (x=0) + `Semi-wall 2` (x=160) + `Separation 3` (x=240) + `Wall 3` (x=272) + `Separation 2` (x=432) + `Wall 3` (x=464) + `Semi-wall 2 copie` (x=624) + `Separation 3` (x=704) + `Wall 3` (x=736) + `Semi-wall 1` (x=896) + `Separation 2` (x=976) + `Wall 3` (x=1008) + `Wall pipes` (x=1168).
  - **Deck 1 (Operações Médio, 1232×148 px):** baias operacionais com `Seperation wall 2`, `Semi-wall 1/2`, `Wall 3` e `Separation 3`.
  - **Deck 2 (Engenharia Inferior, 1232×152 px):** visual industrial pesado com pilares de sustentação hidráulicos `Separation 1`, colunas de alerta âmbar `Wall 5`, faixas hazard `Wall 7` / `Wall 6`, `Seperation wall 2` e `Wall 3`.
- As tiras são salvas em `last_horizon/data/environment/wall_deck_0.png` a `wall_deck_2.png` e carregadas em `art_wall_strip` em `assets.pde`.
- Em `ship.pde`, `drawWalls(g)` desenha a tira de cada deck antes de `drawDecks(g)`, posicionando o rodapé da parede perfeitamente alinhado com o topo do piso metálico.
- **Evidência D-162:** `--asset-pipeline-test` carregou 23 de 63 imagens (`pipeline: OK`); `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`; `--capture` → 169 asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS`.

### Sessão atual — saneamento das estações inativas SITUAÇÃO e REATOR (D-163)

- **Decisão D-163:** remover os pontos inativos `POINT_STATUS` (Comando inferior, x=85) e `POINT_REACTOR` (Máquinas superior, x=485) do código e documentação. Ambos eram estações inertes de leitura técnica (`point_kind = POINT_STATION_STATUS`), sem vínculo a quests, incidentes ou reparos e com `pointIsAvailable()` retornando `false`.
- **Código alterado:** `last_horizon/ship.pde` (`POINT_COUNT = 16`, reindexação de `POINT_ANTENNA = 2` até `POINT_HULL = 15`, remoção das entradas nos arrays `point_room`, `point_x`, `point_y`, `point_label`, `point_kind`); `last_horizon/assets.pde` (`art_station_file` ajustado de 18 para 16 posições).
- **Documentação sincronizada:** `assets/INVENTORY.md` (tabela de estações reduzida de 13 para 11 imagens + 1 sheet; tabela de posições e lista canônica atualizadas) e `interface/ROOMS.md` (removidas as linhas de leitura técnica nas tabelas de Comando e Máquinas).
- **Evidência D-163:** `--asset-pipeline-test` → 23 de 63 imagens carregadas (`pipeline: OK`); `--ladder-test` → 6 `OK`; `--hit-test` → 5 `OK`; `--capture` → 169 asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS` e 2.520/2.520 campanhas vencidas no harness.

### Sessão atual — assets de portas com animação, contorno/glow e textos de interação (D-164)

- **Decisão D-164:** integrar os assets `Doors 1.png` (porta fechada) e `Doors 2.png` (porta aberta) ao sistema de portas de `last_horizon`, com spritesheet de 2 quadros em `last_horizon/data/doors/door_sheet.png` (210×97 px) e `door_sheet.json`.
- A renderização usa `ART_DOOR_W = 52.5` e `ART_DOOR_H = 48.5`, resultando em exatamente 105×97 pixels reais no render 720p (escala 1:1 pixel-perfect sem distorção).
- Na aproximação do jogador ao raio de interação (`doorInRange`), o contorno/halo cyan gerado em runtime a partir da transparência do frame com `prepareDoorGlow()` e `doorGlowFrame()` (mesmo algoritmo `buildNpcGlow` dos NPCs em D-155) é desenhado ao redor da porta, substituindo o antigo retângulo geométrico.
- Os textos de interação `E - [SALA]` foram reposicionados acima do topo da porta (`y - ART_DOOR_H - 6`) com restrições horizontais (`ROOM_LEFT + 6` e afastamento de segurança das escadas) e ajuste automático de largura (`fitTextSize`). Isso elimina a sobreposição de "E - SALA DE MÁQUINAS" com a escada esquerda no Convés 2 e o afastamento arbitrário de 210 px de "E - DEPÓSITO" no Convés 1.
- **Evidência D-164:** `--asset-pipeline-test` carregou 24 de 63 imagens (`pipeline: OK`); `--ladder-test` retornou 6 `OK`; `--hit-test` retornou 5 `OK`; `--capture` concluiu com 169 asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS` e 2.520/2.520 campanhas vencidas no harness.

### Sessão atual — alinhamento das portas da Sala de Comando com paredes modulares (D-165)

- **Decisão D-165:** alinhar visual e arquiteturalmente as três portas da Sala de Comando (`SCREEN_COMMAND`) com as paredes modulares dos conveses (D-162), eliminando sobreposições com colunas estruturais e ocupando as baías naturais do cenário conforme gabarito visual fornecido pelo usuário:
  - **Convés Superior (Deck 0):** `door_x[0]` ajustado de `50` para `40`, centralizado perfeitamente no painel rebaixado de `Wall 3` entre a parede esquerda e a coluna estrutural com luzes (`strip_x = 112` / `game_x = 68`), com folga simétrica de 1,75 px de cada lado. Chegada do Dormitório ao Comando (`door_arrival_x[3]`) recalibrada de `78` para `68` com `facing = 1`.
  - **Convés Médio (Deck 1):** `door_x[1]` ajustado de `590` para `598`, alinhando a porta na baía direita sob o cone da luminária de teto (`strip_x = 1169` / `game_x = 596.5`), entre a coluna (`strip_x = 1119` / `game_x = 571.5`) e a borda direita, eliminando a sobreposição de 8 px sobre a coluna esquerda. Chegada do Depósito ao Comando (`door_arrival_x[4]`) recalibrada de `562` para `570` com `facing = -1`.
  - **Convés Inferior (Deck 2):** `door_x[2]` reposicionado de `50` para `88`, deslocando a porta de cima do pilar hidráulico/hazard para a baía modular de `Wall 3` que ficou livre com a remoção de `POINT_STATUS` (D-163), preservando folga segura de 13 px até a escada (`x = 127`). Chegada da Sala de Máquinas ao Comando (`door_arrival_x[5]`) recalibrada de `72` para `110` com `facing = 1`.
- **Código alterado:** `last_horizon/ship.pde` (`door_x` atualizado para `{40, 598, 88, ...}`; `door_arrival_x` atualizado para `{..., 68, 570, 110}`).
- **Evidência D-165:** `--asset-pipeline-test` carregou 24 de 63 imagens (`pipeline: OK`); `--ladder-test` retornou 6 `OK`; `--hit-test` retornou 5 `OK`; `--capture` concluiu com 169 asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS` e 2.520/2.520 campanhas simuladas vencidas no harness.

### Sessão atual — alinhamento de portas e escadas nas salas operacionais (D-166)

- **Decisão D-166:** ajustar e alinhar a posição de portas e escadas nas demais salas da nave (Sala de Máquinas, Dormitório e Depósito) e adicionar fundo preto no vão da porta aberta:
  - **Fundo opaco da porta aberta:** preenchimento do vão interno de `Doors 2.png` e `door_sheet.png` (frame 1) com preto sólido (`#000000`), evitando que a textura da parede apareça através do vão aberto.
  - **Sala de Máquinas (`SCREEN_MACHINES`):** porta deslocada para a baía modular esquerda do Deck 2 (`door_x[5] = 88`) com chegada `door_arrival_x[2] = 110`. Escada inferior (Deck 2→1) reposicionada para `ladder_x[2] = 468` (marcação verde) e escada superior (Deck 1→0) para `ladder_x[3] = 136` (marcação azul).
  - **Dormitório (`SCREEN_DORMITORY`):** porta alinhada à baía esquerda do Deck 0 (`door_x[3] = 40`) com chegada `door_arrival_x[0] = 68`. Escada central (Deck 1→0) reposicionada para a junção modular `ladder_x[7] = 243` (marcação azul) e escada inferior (Deck 2→1) para `ladder_x[6] = 542` (marcação verde), liberando a estação `SOCORRO` no convés inferior.
  - **Depósito (`SCREEN_DEPOT`):** porta do Deck 1 centralizada com folgas simétricas no vão da parede (`door_x[4] = 45`), desencostando a borda esquerda da faixa de perigo da parede, com chegada calibrada para `door_arrival_x[1] = 73`.
- **Código alterado:** `last_horizon/ship.pde` (`door_x`, `door_arrival_x`, `ladder_x`), `assets/PNG/Doors 2.png`, `last_horizon/data/doors/door_sheet.png`.
- **Documentação sincronizada:** `assets/INVENTORY.md` (coordenadas de escadas atualizadas para Máquinas e Dormitório).

### Sessão atual — integração do BioComputer no console da rota com efeito de trigger (D-167)

- **Decisão D-167:** integrar o asset `assets/PNG/BioComputer.png` ao console da rota (`POINT_ROUTE` em `SCREEN_COMMAND`, Deck 1) e ao pipeline de estações (`last_horizon/data/stations/console_rota.png`):
  - **Dimensões, respiro de contorno e escala 1:1:** o asset nativo possui 181×117 px físicos e foi gerado em `last_horizon/data/stations/console_rota.png` com margem transparente de 4 px em todas as bordas (189×125 px), eliminando o corte do contorno cyan no bloco inferior esquerdo e no topo. No render 720p (`RENDER_SCALE = 2`), é desenhado em 94,5×62,5 unidades lógicas (conteúdo em 90,5×58,5) com pixel art 1:1 sem distorção. A ancoragem repousa a base sobre o piso (`y = 202`) e o centro em `x = 260`.
  - **Efeito de trigger (halo/contorno azul):** geração em tempo de carregamento de `art_station_glow` através de `prepareStationGlow()` e do algoritmo canônico `buildNpcGlow()` (idêntico ao contorno azul presente nas portas e nos NPCs).
  - **Largura dinâmica do trigger:** `pointInteractionRange(POINT_ROUTE)` recalibrado para cobrir a largura total do console ($(\text{largura}/2) + 4 \approx 51$ unidades lógicas em vez dos 12 px fixos) e `nearestInteractablePoint()` desvinculado do antigo teto fixo de 23 px (`Float.MAX_VALUE`), permitindo acionar o comando `E` tanto no reator à esquerda quanto na mesa do terminal à direita.
  - **Ativação estrita durante a quest:** seguindo o comportamento atual do jogo, o console da rota só se torna disponível quando selecionado como próximo objetivo de quest (`pointIsAvailable(POINT_ROUTE)`). O contorno azul e o prompt `E` só são desenhados quando o jogador está no raio de interação durante a etapa ativa da quest (`nearby == true`), permanecendo desligado em repouso.
  - **Saneamento visual:** quando a estação possui sprite próprio (`has_art`), a caixa retangular geométrica de fallback (`g.rect(x - 16, y - 26, 32, 26, 2)`) é omitida.
- **Código alterado:** `last_horizon/data/stations/console_rota.png`, `last_horizon/assets.pde` (`art_station_glow`, `prepareStationGlow()`), `last_horizon/ship.pde` (`drawPointArt`, `drawRoomPoint`, `pointInteractionRange`, `nearestInteractablePoint`).
- **Documentação sincronizada:** `assets/INVENTORY.md` (registro da integração do `console_rota.png` com dimensões e margem de contorno).
- **Evidência D-167:** `--asset-pipeline-test` carregou 25 de 63 imagens (`pipeline: OK`); `--ladder-test` retornou 6 `OK`; `--hit-test` retornou 5 `OK`; `--capture` concluiu com 169 asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS` e 2.520/2.520 campanhas simuladas vencidas no harness.

### Sessão atual — test-mode, pulso de quest, prompt refinado e estações da Sala de Máquinas e Comando (D-168)

- **Decisão D-168:** aprimorar a experiência de interação e compor as estações de trabalho de Comando e Máquinas com assets nativos modulares:
  - **Test-Mode (`test_mode.pde`):** módulo de depuração e inspeção acionado via `Ctrl + K`. Permite teleporte direto para o centro de cada sala (`1: Comando`, `2: Dormitório`, `3: Máquinas`, `4: Depósito`) e chaveamento do estado visual de quests/glow (`5: VISUAL: ON/OFF`), com ganchos em `last_horizon.pde` e `tasks.pde`.
  - **Feedback e Tipografia de Interação:** rótulo de interação ajustado para `"Pressione E"` em tamanho 11 com sombra projetada (`textPromptShadow`), preservando intocado o `MIN_TEXT_SIZE = 16` global da UI. Nomes de estações passam a ser exibidos apenas quando ativas/disponíveis (`available`), com sombra preta (`textCenteredShadow`).
  - **Glow de Quest Ativa (Pulso Âmbar/Laranja):** introdução de halo âmbar pulsante (`COL_ORANGE`, pulso senoidal suave) no alvo ativo de quest à distância, que transiciona para o halo ciano (`COL_CYAN`) quando o jogador entra no raio de interação (`nearby`). Aplicado a NPCs e estações via `art_station_glow_orange` (`buildColoredGlow`).
  - **Estações Integradas:**
    - **Antena (`POINT_ANTENNA`):** substituída pelo asset `assets/PNG/Pillars.png` e centralizada com a parede em `x = 407` (`y = 128`, Comando superior).
    - **Distribuição (`POINT_DISTRIBUTION`):** composta por `CryoBox.png` + `Electric wall.png` + `CryoBox.png` (165×111 px) em `data/stations/painel_distribuicao.png`, ancorada em `x = 215` (`y = 202`, Máquinas médio).
    - **Bancada do Motor (`POINT_ENGINE_BENCH`):** reposicionada para `x = 271` (`y = 278`, Máquinas inferior, baía modular entre as faixas de perigo) e composta por `Desk 1.png` + `Screen device.png` + `Small Machine 1.png` (121×75 px) em `data/stations/bancada_motor.png`.
    - **Suporte (`POINT_LIFE_SUPPORT`):** reposicionado para `x = 454` (`y = 128`, Máquinas superior, centralizado no vão do painel duplo) e composto por `Board 1.png` + `Health Pack 1.png` + `Props 4.png` (93×74 px) em `data/stations/painel_suporte.png`.
- **Código alterado:** `last_horizon/test_mode.pde`, `last_horizon/last_horizon.pde`, `last_horizon/ship.pde`, `last_horizon/tasks.pde`, `last_horizon/ui.pde`, `last_horizon/assets.pde`, `last_horizon/data/stations/antena.png`, `last_horizon/data/stations/painel_distribuicao.png`, `last_horizon/data/stations/bancada_motor.png`, `last_horizon/data/stations/painel_suporte.png`.
- **Documentação sincronizada:** `assets/INVENTORY.md` (coordenadas definitivas de antena, suporte e bancada do motor; registros dos novos assets integrados).
- **Evidência D-168:** `--hit-test` retornou 5 `OK`; `--capture` concluiu com 169 asserções `OK`, zero `FALHOU`, `QUEST CHECK: PASS` e 2.520/2.520 campanhas simuladas vencidas no harness.

