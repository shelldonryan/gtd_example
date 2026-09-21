# Last Horizon — Contexto de sessão

> Revisado em 21/09/2026. Este arquivo resume o checkout local; não representa o estado atual do issue tracker ou do Wayfinder.

## Estado atual

- O código executável é o sketch Processing em `last_horizon/`; a leitura estática mais recente está em [`docs/CURRENT_IMPLEMENTATION.md`](docs/CURRENT_IMPLEMENTATION.md).
- A SPEC de enxugamento continua sendo uma proposta de produto. O código já implementa partes do contrato, mas há diferenças abertas; registre requisito e comportamento atual separadamente.
- No mapa, o código mostra quatro cartões estáticos com sala atual, objetivo e contagem de problemas. Não calcula rota nem mostra portas, escadas ou detalhes clicáveis. O HUD tem uma linha de objetivo e outra de alerta.
- A tela inicial tem uma alteração local em `last_horizon/screens.pde`: rótulo do nome atualizado, cursor intermitente e remoção do texto provisório. Preserve-a; não foi validada em runtime.
- Existem assets de estações, NPCs/retratos, porta, ícones, mapa e áudio. Objetos de quest, fundos de sala, casco animado e fundos das telas não foram encontrados; veja [`assets/INVENTORY.md`](assets/INVENTORY.md).
- Os resultados E6 em `docs/` descrevem uma campanha registrada em 20/09/2026. Não foram repetidos contra este checkout.
- A última revisão foi estática: não houve build, execução do jogo, harness nem playtest. `git diff --check` passou.
- O issue tracker e o Wayfinder não foram consultados nesta revisão. Status copiados em registros antigos não são status nativos atuais.
- O worktree tem alterações locais de código e documentação. Confira `git status` e preserve-as antes de editar, reverter ou preparar commits.

## Fontes do projeto

- **Comportamento observado:** `last_horizon/*.pde` e arquivos presentes em `last_horizon/data/`.
- **Mecânicas:** [`mechanics/ACTIONS.md`](mechanics/ACTIONS.md), [`events/`](events/) e ADRs em [`docs/adr/`](docs/adr/).
- **Interface e salas:** [`interface/FLOW.md`](interface/FLOW.md), [`interface/HUD.md`](interface/HUD.md), [`interface/ROOMS.md`](interface/ROOMS.md) e documentos de telas.
- **Implementação, arquitetura e assets:** [`docs/CURRENT_IMPLEMENTATION.md`](docs/CURRENT_IMPLEMENTATION.md), [`code/SKETCH_ARCHITECTURE.md`](code/SKETCH_ARCHITECTURE.md) e [`assets/INVENTORY.md`](assets/INVENTORY.md).
- **Evidência histórica:** [`docs/E6_REPORT.md`](docs/E6_REPORT.md), `docs/playtest.md`, `docs/verification.md` e `docs/visual-diff.md`.
- Em caso de divergência, não converta automaticamente código em decisão de produto: documente o requisito, o comportamento observado e o que falta decidir ou implementar.

## Contrato mecânico resumido

- Viagem de 10 dias, quatro cômodos, quatro sobreviventes e seis recursos; incidentes nos dias 2, 4, 6, 8 e 10, cinco tipos sorteados de um pool de sete, sem reposição.
- Em dia sem incidente há até duas preventivas; uma exige confirmação presencial com o responsável vivo. Incidentes oferecem soluções pelo cartão, sem exigir a presença do NPC responsável.
- Uma quest pode ser concluída por dia; coleta e entrega são físicas e o técnico carrega um objeto por vez. Problemas não resolvidos mantêm perdas, prazo e crise.
- Socorro custa 8 de água e 2 de comida, ocupa a conclusão diária e fica bloqueado em dia com incidente novo.
- Vitória exige concluir a viagem com motor operante, ao menos um sobrevivente e energia, oxigênio e moral acima de zero. Custos e demais regras ficam em `mechanics/ACTIONS.md`.

## Regras para continuar o trabalho

- Para trabalho ligado a uma issue, consulte primeiro a issue e seus bloqueadores nativos; snapshots locais não substituem esse estado. Não faça atualização remota sem pedido explícito.
- Antes de alterar código, identifique escopo, fonte de verdade e validação. Siga o `AGENTS.md`: faça análise de impacto GitNexus antes de editar símbolos e avise se o risco for alto ou crítico. Para Processing `.pde` não indexado, rastreie referências no código.
- Não instale dependências/ferramentas sem aprovação, não crie cópias concorrentes do repositório e não exponha segredos.
- Para capturas ou artefatos temporários, use `last_horizon/output/` e remova-os ao terminar.
- Em mudanças visuais, não declare resultado validado sem executar e inspecionar o jogo ou uma captura atual.
