# Last Horizon — Session Start

> Resumo operacional obrigatório. Leia antes de analisar, editar ou implementar
> e sincronize-o com o Wayfinder antes de encerrar a sessão.

Atualizado em: 2026-09-16 (issue #25 concluída; fronteira atualizada)
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
- #25 foi concluída: o catálogo das oito ordens preventivas e das quatorze
  soluções físicas está definido em `mechanics/ACTIONS.md` e `events/`.
- O contrato de quests foi fechado, mas os valores numéricos e a migração do
  sketch ainda não foram concluídos.
- #26 está OPEN e disponível: [Simplificar mecânicas legadas e balancear o
  ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26).
- #8 está OPEN e bloqueada nativamente por #26:
  [Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8).
- #7 está OPEN, disponível e independente:
  [Documento de entrega e como o jogo roda na apresentação](https://github.com/shelldonryan/gtd_example/issues/7).
- O próximo caminho crítico é #26; #8 será liberada quando o balanceamento
  estiver fechado.

### Fronteira Wayfinder

Sincronizada com o grafo nativo após o fechamento do catálogo de quests:

| Issue | Estado | Bloqueadores abertos | Relação |
|---|---|---|---|
| #7 Documento de entrega | OPEN | — | independente e disponível |
| #8 Inventário de assets | OPEN | #26 | depende do balanceamento |
| #25 Redesenhar incidentes e ordens como quests físicas | CLOSED | — | catálogo e fluxo definidos |
| #26 Simplificar mecânicas legadas e balancear o ciclo de quests | OPEN | — | próximo caminho crítico |
| #19 Redesenhar o ciclo | CLOSED | — | contrato anterior superseded |
| #20 Balancear o novo ciclo | CLOSED | — | números anteriores superseded |
| #21 Implementar novo ciclo e hub | CLOSED | — | implementação anterior superseded em parte |
| #22 Calendário em dias pares | CLOSED | — | calendário preservado |
| #23 Confirmação nas intervenções | CLOSED | — | confirmação preservada para ações importantes |
| #24 Painel na coleta de componentes | CLOSED | — | componentes reaproveitados como quests |


## Contrato vigente do produto

O contrato abaixo é a direção confirmada para a próxima migração. O sketch ainda
implementa parte do contrato anterior; não tratar a implementação atual como
prova da intenção nova.

- Jogo de gerenciamento de recursos e exploração 2D em plataforma, em uma nave
  **sem nome**.
- Viagem de dez dias; primeiro dia no Comando, seguintes no Dormitório.
- Incidentes nos dias 2, 4, 6, 8 e 10; cinco dos sete tipos, embaralhados sem
  reposição. Os tipos pertencem às famílias de falhas técnicas, suprimentos e
  tripulação.
- Nos dias sem incidente, os sobreviventes oferecem duas ordens preventivas. O
  jogador escolhe e confirma uma presencialmente; deve concluí-la para evitar o
  prejuízo maior de negligência.
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
  prazo e crise normais, sem multa extra.
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

O catálogo concreto, seus IDs, objetos, origens, destinos, resultados e textos
estão em `mechanics/ACTIONS.md` e `events/`. As oito preventivas usam pares de
recursos distintos; as quatorze soluções cobrem os sete incidentes. O ticket
#26 ainda define os valores numéricos e a seleção final do pool.

Números, custos, recompensas, perdas, prazos e ordem final do processamento:
`mechanics/ACTIONS.md` e [Simplificar mecânicas legadas e balancear o ciclo de
quests](https://github.com/shelldonryan/gtd_example/issues/26). Topologia e
ordens: `interface/ROOMS.md`.

## Contrato técnico

- Processing 4.5.6, modo Java, sketch plano em inglês, funções curtas e
  `update` separado de `draw`.
- Render 1280×720; grade lógica 640×360 apenas para posicionamento; janela 16:9
  escalável com ampliação inteira.
- Segoe UI suavizada: título 32 px, leitura 16 px, entrelinha 18 px; botão pode
  reduzir até 10 px somente para caber.
- Pixel art sem interpolação. Asset animado: uma spritesheet PNG + JSON; nomes
  ASCII; `.aseprite` acompanha a exportação quando disponível.
- Sala: três conveses, duas escadas, sem câmera.
- Jogador: colisão 16×24; andar 1,5 px/quadro; pulo 48 px; gravidade 0,5;
  escada 1,0; interação 12 px; plataformas atravessáveis por baixo.
- Controles: setas/WASD, espaço, E, ENTER em diálogos/modais, ESC para pausa e
  mouse no botão `MAPA`.
- HUD: seis ícones 16×16; cartões de recurso sem rótulo.
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
  foi **SUPERSEDED** pela ADR-0002 e aguarda recalibração no ticket #26. O
  calendário e os sete tipos continuam como base do novo contrato.
- D-099 a D-103: decisões de implementação do ciclo anterior, incluindo
  distribuição, beliche temporário, empate de urgência e crise imediata;
  **SUPERSEDED** onde conflitarem com ordens e riscos simplificados.
- D-104 a D-107: leituras de implementação do ciclo anterior; não são requisitos
  do novo sketch até a conclusão da #26.
- D-108: os incidentes ocorrem nos dias 2, 4, 6, 8 e 10 e o dia 1 fica sem
  incidente; decisão preservada no novo contrato.
- D-109: confirmação de ações importantes; o princípio permanece, mas os painéis
  e ações concretas serão adaptados ao fluxo de ordens do novo ciclo.
- D-110: coleta com confirmação; o princípio de objeto explicado permanece, mas
  coleta livre e uso exclusivo de fusível ou kit ficam **SUPERSEDED** pelo
  modelo de objetos de quest.
- **Novo ciclo de quests (ADR-0001):** dias sem incidente oferecem duas ordens
  preventivas e permitem concluir uma; dias com incidente oferecem duas
  soluções físicas. Objetos têm origem, destino e consequência legíveis.
- **Simplificação do ciclo (ADR-0002):** seis recursos e consumo permanecem;
  políticas, bônus numéricos, coleta livre e contador separado de intervenção
  saem. Problemas persistentes permanecem; há no máximo uma pessoa em risco.
- **Tickets novos:** a #25, agora CLOSED, define a matriz, os textos e as
  rotas; a #26 pesquisa o código e define os números. O inventário de assets
  (#8) depende agora somente da #26.

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

- a seleção final do pool e os cálculos de consumo, custos, recompensas,
  perdas, prazos e crises, no ticket [Simplificar mecânicas legadas e balancear
  o ciclo de quests](https://github.com/shelldonryan/gtd_example/issues/26);
- o inventário final de assets, dimensões, reutilização e ordem de produção,
  no ticket [Inventário de assets](https://github.com/shelldonryan/gtd_example/issues/8),
  bloqueado pelo #26;
- se a vitória permite continuar jogando depois da chegada;
- se a derrota mostra os nomes dos sobreviventes ou apenas a contagem;
- comportamento do nome vazio no menu: botão bloqueado versus fallback
  `Técnico`;
- vinheta implementada com texto provisório diferente do roteiro confirmado no
  #11;
- as nove linhas de alerta do painel `SISTEMA` ainda não foram classificadas
  como superseded;
- transmissões da Terra e a mensagem de Marte na vitória ainda não
  implementadas;
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

- Issue #25 implementada e fechada após a definição do contrato de conteúdo das
  quests físicas.
- `mechanics/ACTIONS.md` agora contém oito ordens preventivas (`V-01` a `S-02`),
  quatro pares de comparação, quatorze soluções de incidente e os textos
  canônicos de oferta, confirmação, coleta, entrega e falha.
- `README.md` e `events/` registram as soluções técnicas, de casco, suprimentos
  e tripulação. `interface/`, `characters/` e `code/SKETCH_ARCHITECTURE.md`
  foram alinhados ao mesmo catálogo, às rotas de no máximo dois cômodos e às
  etapas `COLETAR` → `ENTREGAR`.
- A confirmação presencial, a impossibilidade de cancelamento, a devolução de
  objeto em falha preventiva e a permanência do problema em falha urgente estão
  documentadas.
- O corpo da #1 foi atualizado: #25 CLOSED, #26 OPEN e disponível, #8 OPEN
  bloqueada apenas por #26 e #7 OPEN independente.
- A #26 e a #8 receberam comentários de dependência atualizada no Wayfinder.
- Probe documental passou: oito preventivas, quatorze soluções, duas por
  incidente, campos obrigatórios e 22 rotas sem violação do limite.
- `node prototype/balance-model.mjs --simulate`, `--capture`, `--hit-test` e
  `--ladder-test` passaram. Esses comandos comprovam o artefato anterior; o
  sketch ainda não executa o novo ciclo.
- Revisão Standards/Spec contra a issue #25 terminou sem achados remanescentes;
  a duplicação entre fontes foi considerada intencional para o domínio.
- `git diff --check` passou, com avisos apenas de conversão LF/CRLF.
- Os quatro PNGs não rastreados em `assets/concept_arts/` foram preservados.
- Resultado: documentação de domínio pronta para a #26; não é ainda protótipo
  executável nem funcionalidade pronta do novo ciclo.
