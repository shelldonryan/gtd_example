# Last Horizon — Session Start

> Resumo operacional obrigatório. Leia antes de analisar, editar ou implementar
> e sincronize-o com o Wayfinder antes de encerrar a sessão.

Atualizado em: 2026-09-15 (D-099 a D-107 registradas; #21 implementada, revisada e fechada)
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

- #19, #20 e #21 estão CLOSED; D-073 a D-107 estão confirmadas e implementadas
  no protótipo.
- #8 está disponível para o inventário de assets.
- #7 está disponível e independente.
- O sketch implementa o ciclo novo: incidentes nos dias 1, 3, 5, 7 e 9, cinco
  problemas sem reposição, contenções que não corrigem a causa, uma intervenção
  principal por dia, hub por convés, riscos individuais e crises.
- Nenhum trabalho de código ou documentação está pendente nesta etapa; a
  implementação está no commit do ticket.

### Fronteira Wayfinder

Sincronizada com o grafo nativo em 2026-09-15:

| Issue | Estado | Bloqueadores abertos | Relação |
|---|---|---|---|
| #7 Documento de entrega | OPEN | — | independente |
| #8 Inventário de assets | OPEN | — | disponível |
| #19 Redesenhar o ciclo | CLOSED | — | D-073 a D-096 |
| #20 Balancear o novo ciclo | CLOSED | — | D-097 e D-098 |
| #21 Implementar novo ciclo e hub | CLOSED | — | D-099 a D-103, aplicadas |

## Contrato vigente do produto

- Jogo de gerenciamento de recursos e exploração 2D em plataforma, em uma nave
  **sem nome**.
- Viagem de dez dias; primeiro dia no Comando, seguintes no Dormitório.
- Incidentes nos dias 1, 3, 5, 7 e 9; cinco dos sete problemas, embaralhados sem
  reposição.
- Toda contenção deixa um problema persistente com perda diária, prazo e crise.
- Não há briefing nem aceite de tarefa. HUD destaca o menor prazo entre
  problemas e pessoas em risco; mapa mostra todos os problemas por sala e nunca
  transporta o técnico.
- Uma intervenção principal por dia: correção, recuperação ou aceleração.
  Diagnósticos, conversas, componentes especiais e políticas são livres.
- Recursos comuns são pagos na intervenção. Só kit de vedação e fusível de
  potência exigem coleta e transporte.
- O Comando é o único hub: porta superior para Dormitório, média para Depósito e
  inferior para Sala de máquinas. Salas periféricas não se conectam.
- Dano no casco surge em ponto aleatório, livre e alcançável de qualquer cômodo.
- Dormir no beliche do técnico processa políticas, consumo, perdas, moral,
  riscos individuais, prazos, crises e término.
- `Aumentar potência` elimina um dia futuro completo, inclusive consumo e
  eventual incidente.
- `Cuidar do grupo` recupera moral; `Socorrer [nome]` estabiliza uma pessoa em
  risco. Morte remove o benefício da especialidade, nunca uma ação necessária.
- Economia e racionamento são políticas persistentes com custo inicial e diário
  de moral.
- Vitória: chegar após o décimo dia com motor operante e ao menos um
  sobrevivente. Derrota: energia, oxigênio ou moral em zero, motor destruído ou
  nenhum sobrevivente vivo.

Números, custos, ordem do turno e crises: `mechanics/ACTIONS.md`.
Topologia e intervenções: `interface/ROOMS.md`.

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

Concept arts definem linguagem visual e composição, nunca nomes ou números:

- `assets/concept_arts/HUD_CONCEPT_ART.png`;
- `assets/concept_arts/COMMAND_ROOM_CONCEPT_ART.png`.

## Índice de decisões

Não replique aqui o histórico completo:

- D-001 a D-047: protótipo anterior; fontes em #14, #11, #12 e #17.
- D-048 a D-072: navegação, interação, viewport, tipografia e animação já
  implementadas; fonte principal em #18.
- D-073 a D-096: novo ciclo e hub, confirmados em #19; superam regras antigas de
  briefing, tarefa singular, evento diário, rota universal por NPC, itens comuns
  carregados e mapa com um único destino.
- D-097: dano no casco aleatório e alcançável, implementado; fonte em #20.
- D-098: calendário, problemas, contenções, intervenções, políticas, benefícios e
  ordem do turno, confirmados em #20 e `mechanics/ACTIONS.md`.
- D-099 a D-102: distribuição como reparo de energia, beliche temporário com
  seleção determinística, urgência pelo problema mais antigo em empate e crise
  imediata sem contenção pagável; confirmadas e implementadas na #21.
- D-103: o beliche temporário prioriza a pessoa em risco com menor prazo e usa
  ordem de criação no empate; confirmada e implementada na #21.
- D-104 a D-107 (leituras de implementação, não decisões de gameplay): risco
  selecionado pela ordem do modelo aprovado, painel de distribuição com reparo e
  economia juntos, prazo da pessoa em risco visível no HUD e no beliche, e
  derrota com precedência energia, oxigênio e moral; registradas em
  `code/SKETCH_ARCHITECTURE.md`.

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

## Lacunas que exigem consulta

- se a vitória permite continuar jogando;
- se a derrota mostra nomes ou apenas a contagem dos sobreviventes;
- comportamento do nome vazio no menu: botão bloqueado versus fallback
  `Técnico`;
- transmissões da Terra e textos finais de vinheta, vitória e derrota ainda não
  implementados;
- qualquer nome, retrato ou história além de Vera, Bento, Neusa e Sílvia.

## Checklist de abertura

- [ ] Ler este arquivo antes de qualquer avanço.
- [ ] Recalcular issues, bloqueadores e fronteira.
- [ ] Identificar ticket e skill correspondente à label.
- [ ] Ler fontes específicas, comentários e assets relevantes.
- [ ] Comparar intenção, documentação e código.
- [ ] Reportar entendimento, conflitos, lacunas e recorte antes de editar.

## Checklist de encerramento

- [ ] Registrar decisões e evidências na issue trabalhada.
- [ ] Atualizar estado e dependências nativas da issue.
- [ ] Atualizar o corpo da #1 com a fronteira e o próximo ticket.
- [ ] Atualizar fontes locais afetadas e este arquivo.
- [ ] Confirmar que #1, issues específicas e documentos locais concordam.
- [ ] Registrar arquivos alterados e verificação executada.
- [ ] Declarar se o resultado é documentação, protótipo executável ou
      funcionalidade pronta.

## Última sessão registrada

- #21 implementada: o sketch abandonou `active_task`, briefing, itens comuns
  carregados, eventos diários e salas lineares.
- D-099 a D-103 confirmadas com o usuário e registradas em `SESSION_START.md`,
  `mechanics/ACTIONS.md` e `interface/ROOMS.md`.
- Código alterado: `last_horizon.pde`, `game.pde`, `tasks.pde`, `ship.pde`,
  `hud.pde`, `screens.pde`, `ui.pde`, `capture.pde`.
- Documentos sincronizados: `SESSION_START.md`, `code/SKETCH_ARCHITECTURE.md`,
  `mechanics/ACTIONS.md`, `interface/ROOMS.md`, `interface/HUD.md`,
  `interface/FLOW.md`.
- Verificação: `--capture` com 57 verificações e nenhuma falha, `--hit-test` e
  `--ladder-test` com 5 cada, `BALANCE CHECK: PASS` no modelo numérico e
  `git diff --check` limpo.
- Revisão: eixos Standards e Spec executados sobre o diff; os achados de risco
  determinístico, ponto do reparo de energia, prazo da pessoa em risco, resumo
  do sono, ficha do mapa, console da rota, precedência de derrota e código morto
  foram corrigidos.
- Encerramento no Wayfinder: decisões, arquivos e evidência registrados na #21,
  issue fechada como concluída e corpo da #1 atualizado com a nova fronteira.
- Resultado: protótipo executável com o novo ciclo; textos finais e transmissões
  seguem pendentes do #11.

A fronteira vigente é **#7 e #8 abertos, ambos disponíveis e sem bloqueadores**.
O próximo caminho crítico é **#8 (inventário de assets)**, com **#7 (documento de
entrega)** em paralelo.
