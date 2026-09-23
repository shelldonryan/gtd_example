# Sugestões de enriquecimento da SPEC

## US-01 — Eliminar trabalho repetido de renderização estática

- **E1** [APLICADO] [US-01] A SPEC define invalidação por fonte, escala, largura e geração, mas não define como a geração é incrementada nem se uma `PImage` pode ser alterada no mesmo objeto. O cache de ícones usa fonte e escala, enquanto o cache de piso também usa geração; o desenvolvedor teria de escolher a semântica para alterações em memória.
  Opções: a) exigir identidade de objeto mais uma geração explícita para todo asset; b) calcular hash do conteúdo para detectar alterações; c) tratar `PImage` como imutável e invalidar apenas quando a referência for substituída por uma operação de carregamento.
  Sugestão: opção c - evita custo de varredura por quadro e segue o padrão atual de substituição de referências; a geração explícita pode continuar apenas onde já representa recarga de piso.
  Decisão: opção c.

- **E2** [APLICADO] [US-01] “Arte ausente ou parcial” não define o que ocorre com PNG inválido, spritesheet sem quadros esperados, JSON malformado ou somente um dos seis ícones ausente. É necessário saber se o fallback é por item, se a execução continua e como o erro é registrado.
  Opções: a) cada item inválido usa fallback geométrico, a execução continua e o diagnóstico é registrado; b) qualquer asset inválido interrompe o carregamento e a captura; c) ausência usa fallback, mas formato inválido torna a medição inconclusiva e falha a regressão.
  Sugestão: opção c - diferencia ausência tolerada de corrupção de entrada e impede que uma medição de performance esconda um problema de carregamento.
  Decisão: opção a.

## US-02 — Comparar baseline e versão revisada em condições equivalentes

- **E3** [APLICADO] [US-02] A SPEC exige condições equivalentes, mas não identifica a origem do baseline, o cenário exato de sala/estado, o conjunto de assets, os valores de `environment` e `machine` nem se Processing diferente de 4.5.6 deve ser rejeitado. Hoje `--metrics` grava uma amostra sem esses metadados.
  Opções: a) exigir um arquivo de configuração/manifesto fornecido em cada execução e rejeitar a captura sem ele; b) fixar o cenário dentro do modo `--metrics` e gerar os metadados automaticamente; c) aceitar metadados informados pelo operador sem validar o cenário inicial.
  Sugestão: opção b - torna a comparação reproduzível e evita que dois operadores preencham descrições diferentes para o mesmo estado.
  Decisão: opção b.

- **E4** [APLICADO] [US-02] Há incompatibilidade entre o contrato documental e os artefatos atuais: a SPEC/PRD exigem manifesto sidecar com `nominal_window_s` e CSV com nomes como `duration_real_s` e `frame_time_p95_ms`, enquanto `capture.pde` escreve `duration_s`, `frame_median_ms` e `frame_p95_ms` no próprio CSV, e `compare-metrics.mjs` procura esses campos antigos sem ler sidecar.
  Opções: a) adotar o contrato canônico da SPEC, gerar sidecar e atualizar produtor/comparador; b) manter os artefatos atuais e alterar SPEC e PRD; c) aceitar os dois formatos por normalização, desde que o manifesto obrigatório nunca seja substituído por valor padrão.
  Sugestão: opção a - alinha a implementação ao contrato já aprovado no PRD e separa metadados de métricas numéricas.
  Decisão: opção a.

- **E5** [APLICADO] [US-02] A janela nominal de 30 segundos está separada da duração real na SPEC, mas o comparador atual exige `duration_s === 30`; como a coleta encerra no primeiro quadro após o limite, a duração real pode ser maior. Também não há timeout para uma captura ou regressão que fique travada.
  Opções: a) registrar a duração real, aceitar uma tolerância explícita para a janela nominal e definir timeout por operação; b) normalizar a duração gravada para 30 e manter timeout externo; c) aceitar qualquer duração acima de 30 sem timeout específico.
  Sugestão: opção a - preserva a medição real e evita tanto falso erro por um quadro excedente quanto processo indefinidamente pendente.
  Decisão: opção a.

- **E6** [APLICADO] [US-02] A SPEC exige redução em pelo menos um custo e status inconclusivo sem redução, mas o comparador atual só calcula tempo de quadro, imprime `PASS` quando não há regressão e não decide sobre carregamento, memória, construções ou invalidações. Também não está definido se o limite de 10% é absoluto, se vale por amostra ou só pela mediana dos três p95, nem qual status prevalece quando há ganho e regressão simultâneos.
  Opções: a) o comparador produzir `PASS`, `INCONCLUSIVO` ou `FAIL`, avaliar todos os custos definidos e usar a mediana dos três p95 com variação absoluta; b) o comparador avaliar somente tempo de quadro e o registro final decidir o ganho; c) qualquer ganho de contador permitir `PASS` mesmo com regressão de tempo.
  Sugestão: opção a - concentra a regra de conclusão em um contrato executável e impede que ausência de regressão seja confundida com otimização comprovada.
  Decisão: opção a.

## US-03 — Remover somente código comprovadamente não utilizado

- **E7** [APLICADO] [US-03] A SPEC exige busca de referências e validação após cada remoção, mas não define qual evidência deve permanecer para cada símbolo removido nem como documentar referências implícitas de Processing, teclado, mouse e execução por script.
  Opções: a) registrar cada remoção, buscas, entrypoints examinados e validação em `code/VERIFICATION.md`; b) exigir apenas o diff e os comandos executados; c) manter um relatório separado por remoção em `docs/`.
  Sugestão: opção a - usa o registro já exigido pela feature e mantém a prova junto da decisão de prontidão.
  Decisão: opção a.

## US-04 — Consolidar lógica duplicada em helpers explícitos

- **E8** [APLICADO] [US-04] A SPEC lista categorias de duplicação, mas não diz quais funções concretas são obrigatórias nem se toda ocorrência semelhante deve ser consolidada. Isso deixa o limite da mudança sujeito ao julgamento do implementador.
  Opções: a) consolidar toda função das categorias listadas; b) consolidar apenas duplicações identificadas em um inventário antes da edição; c) consolidar somente duplicações que também reduzam custo de execução.
  Sugestão: opção b - permite justificar cada helper e evita abstrações artificiais em rotinas apenas parecidas.
  Decisão: opção b.

## US-05 — Remover comentários dos arquivos executáveis

- **E9** [APLICADO] [US-05] A árvore da SPEC omite `last_horizon/editorial.pde`, `tools/cleanup-verification-artifacts.mjs`, `tools/build.sh`, `tools/processing-cli.sh`, `tools/run-headless.sh` e `tools/run-processing.sh`, embora US-05/RF-11 abranjam `.pde`, `.mjs` e `.sh` executáveis. Também não está definido se arquivos rastreados fora de `last_horizon/` entram na auditoria e quais saídas geradas ficam excluídas.
  Opções: a) auditar todos os arquivos rastreados com extensões `.pde`, `.mjs` e `.sh`, excluindo apenas saídas geradas e diretórios transitórios; b) auditar somente os arquivos listados na árvore da SPEC; c) auditar somente arquivos com bit executável.
  Sugestão: opção a - corresponde ao escopo textual de US-05 e evita que um script operacional seja omitido por não aparecer na árvore resumida.
  Decisão: opção a.

- **E10** [APLICADO] [US-05] “Sem comentários” não define a regra para comentários de linha, blocos, JSDoc, comentários após código, shebang, `set -euo pipefail`, diretivas do shell e comentários dentro de strings. Também não define o formato e o local do resultado da auditoria.
  Opções: a) remover todos os comentários lexicais, preservar somente shebangs/diretivas exigidas e registrar arquivo, exceção e contagem em `code/VERIFICATION.md`; b) remover apenas comentários de implementação e preservar JSDoc; c) registrar somente o código de saída de uma ferramenta de auditoria.
  Sugestão: opção a - dá uma regra verificável para todas as extensões e preserva apenas conteúdo necessário ao funcionamento.
  Decisão: opção a.

## US-06 — Separar blocos coesos em abas procedurais menores

- **E11** [APLICADO] [US-06] O discovery permite novas abas `.pde`, enquanto a SPEC e o PRD descrevem manter os arquivos atuais e proíbem novas abas de UI. A SPEC também não inclui `editorial.pde` na árvore, embora ele seja um módulo real e seja usado por quests, noite e testes.
  Opções: a) permitir novas abas somente para domínios não visuais e incluir `editorial.pde` na lista autoritativa; b) proibir qualquer nova aba e manter todos os módulos atuais; c) permitir novas abas de qualquer responsabilidade se a compilação passar.
  Sugestão: opção a - resolve a contradição sem abrir espaço para uma nova arquitetura de interface e torna o inventário do sketch completo.
  Decisão: opção b.

## US-07 — Preparar a transição entre salas uma única vez

- **E12** [APLICADO] [US-07] A SPEC cobre ida, volta, coordenadas arbitrárias e ausência de arte, mas não define o comportamento para interação repetida durante abertura/fechamento, porta inválida, sala destino inexistente, porta de retorno ausente ou falha do áudio.
  Opções: a) ignorar nova entrada, limpar estado preparado inválido e manter o jogador na sala atual com fallback visual/sonoro; b) cancelar a transição e mostrar erro operacional; c) falhar a validação e interromper a execução.
  Sugestão: opção a - mantém a experiência local operável e trata configuração inválida sem permitir vazamento de estado para outra porta.
  Decisão: opção a.

## US-08 — Preservar quests e ciclo diário

- **E13** [APLICADO] [US-08] A SPEC afirma que todos os custos, recompensas, perdas, prazos, falhas, riscos, crises e desfechos devem permanecer iguais, mas não define a matriz mínima de fixtures nem quais campos formam a comparação. O código atual possui 22 quests, 34 estados de captura, campanhas e memória editorial, mas esses contratos não estão enumerados na SPEC.
  Opções: a) declarar `--capture` atual, suas fixtures e a contagem de estados como oráculo obrigatório; b) criar snapshots estruturados de estado antes/depois para cada fluxo; c) listar todos os valores e fluxos diretamente na SPEC.
  Sugestão: opção a - reaproveita a cobertura existente e exige apenas que sua superfície de prova seja documentada e versionada.
  Decisão: opção a.

- **E14** [APLICADO] [US-08] Quando vários efeitos fatais ocorrem na mesma noite, a SPEC não explicita a precedência entre energia, oxigênio, moral, motor e sobreviventes, nem a regra entre derrota e vitória no último dia. O código atual escolhe uma ordem específica, que precisa ser declarada como contrato preservado.
  Opções: a) registrar na SPEC a ordem já implementada e tratá-la como comportamento de referência; b) criar uma tabela de prioridade independente do código; c) comparar somente o estado final, sem exigir a causa escolhida.
  Sugestão: opção a - preserva o comportamento existente sem criar uma nova regra de balanceamento.
  Decisão: opção a.

## US-09 — Unificar previsão e aplicação noturna

- **E15** [APLICADO] [US-09] “Usar a mesma transição” não define se a confirmação deve aplicar exatamente o objeto `NightProjection` mostrado na prévia ou recalcular a partir do estado atual, nem quais campos devem ser iguais: recursos, arrays, prazos, riscos, mensagens, editoriais, tela e desfecho. O código atual recalcula em `processNight()`.
  Opções: a) guardar a projeção exibida e aplicar o mesmo objeto uma única vez; b) recalcular na confirmação, comparar com a prévia e rejeitar divergência; c) bloquear alterações de estado enquanto a prévia estiver aberta.
  Sugestão: opção b - preserva o seam puro atual e torna divergências observáveis sem aplicar uma previsão obsoleta.
  Decisão: opção a, com invalidação da projeção quando o estado de origem mudar.

## US-10 — Usar uma única decisão sobre o modal ativo

- **E16** [APLICADO] [US-10] A SPEC lista as camadas, mas não registra a ordem de prioridade nem a matriz completa de limpeza para combinações simultâneas. O código atual prioriza pausa, transmissão, incidente, ordens, mapa, diálogo, painel técnico, sono e ajuda, e cada fechamento limpa flags diferentes.
  Opções: a) incluir uma tabela de prioridade e uma tabela de transição/limpeza para cada camada e ação; b) usar apenas os cenários visuais existentes como contrato; c) converter as camadas em uma enumeração com prioridade numérica e derivar desenho e entrada dela.
  Sugestão: opção a - documenta o comportamento preservado sem exigir mudança estrutural além da resolução já existente.
  Decisão: opção a.

- **E17** [APLICADO] [US-10] A SPEC fixa grade lógica, saída e letterbox, mas não define os limites de viewport nem o comportamento de textos/botões quando a janela fica menor que 1280x720, tem proporção extrema ou excede o limite atual de 24 botões registrados.
  Opções: a) manter mínimo lógico 640x360, reduzir apenas por letterbox/escala inteira e rejeitar silenciosamente controles além do limite com diagnóstico; b) permitir escala fracionária e reflow responsivo; c) ampliar dinamicamente a capacidade de botões e refluír textos.
  Sugestão: opção a - mantém o modelo atual de pixel art e evita introduzir uma política de responsividade nova nesta revisão.
  Decisão: opção a.

## US-11 — Manter estrutura de testes e modo manual desacoplados

- **E18** [APLICADO] [US-11] A SPEC exige compilação com e sem módulos opcionais, mas não define a matriz exata nem os comandos que produzem cada combinação. Também não está claro se `capture.pde` e `test_mode.pde` podem ser ausentes de forma independente.
  Opções: a) validar quatro combinações: nenhum módulo, somente captura, somente modo manual e ambos; b) validar somente base e conjunto completo; c) validar base e cada ausência individual, sem exigir a combinação dos dois módulos.
  Sugestão: opção a - cobre todas as combinações booleanas e torna explícita a independência declarada.
  Decisão: opção a.

- **E19** [APLICADO] [US-11] O contrato do snapshot aparece como regra de segurança, mas não define a fonte da lista de exclusões, o conjunto mínimo de arquivos de runtime que deve sobreviver nem o artefato que comprova ausência de controles de desenvolvimento na cópia final.
  Opções: a) herdar exatamente `tools/snapshot-entrega.mjs`, gerar um manifesto de exclusões e verificar compilação da cópia; b) transformar a lista de exclusões em uma seção normativa da SPEC; c) retirar o snapshot do escopo desta feature e apenas preservar o script existente.
  Sugestão: opção a - mantém a política já usada e cria evidência verificável sem duplicar a lista em dois lugares.
  Decisão: opção a.

## US-12 — Produzir registro único de equivalência, custo e limitações

- **E20** [APLICADO] [US-12] A SPEC nomeia informações que devem estar em `code/VERIFICATION.md`, mas não define template, status permitidos, identificação do baseline/final, hashes ou versões, formato de métricas, motivo/impacto de limitações nem regra para comandos indisponíveis. O desenvolvedor teria de inventar o contrato do registro.
  Opções: a) definir uma estrutura fixa com identificação das referências, comandos, ambiente, cenários, métricas, status `PASS`/`FAIL`/`INCONCLUSIVO`, limitações e impacto; b) manter relatório narrativo livre; c) gerar somente a saída dos comandos sem documento adicional.
  Sugestão: opção a - permite auditoria consistente e impede que uma limitação seja confundida com evidência.
  Decisão: opção a.

- **E21** [APLICADO] [US-12] Os scripts `tools/e6-audit.mjs` e `tools/e6-evidence.mjs` fazem parte dos comandos do projeto, mas atualmente falham por caminhos e artefatos ausentes ou de outra execução; a SPEC não diz se devem ser corrigidos, substituídos ou retirados do registro final.
  Opções: a) atualizar os scripts para a SPEC e artefatos desta execução; b) retirar esses scripts do escopo e manter somente typecheck, regressão, simulação, métricas e snapshot; c) manter os scripts como estão e registrar sua indisponibilidade.
  Sugestão: opção b - evita depender de artefatos históricos não definidos nesta entrega e mantém o registro focado nos contratos atuais.
  Decisão: opção b.

- **E22** [APLICADO] [US-12] Os comandos documentados variam por ambiente (`npm.cmd` no Windows, `npm` no Linux, Processing local e script Bash), mas a SPEC não define o comando canônico, a mensagem/exit code para dependência ausente ou a diferença entre “não executado” e “falhou”.
  Opções: a) definir uma matriz Windows/Linux com comandos, pré-requisitos, timeout e status esperado para cada ambiente; b) padronizar tudo em scripts Bash; c) considerar indisponibilidade de ambiente como aprovação com limitação.
  Sugestão: opção a - preserva os caminhos existentes e mantém indisponibilidade explicitamente distinta de aprovação.
  Decisão: opção a.

- **E23** [APLICADO] [US-02/US-12] O teste real em Core i3 com vídeo integrado exige um gate de otimização robusta, com baseline e final no notebook do usuário e em um perfil de referência, manifesto de hardware/GPU/OS/Processing, profiling dos hotspots e critérios de prontidão mais fortes.
  Decisão: aplicar workstream obrigatório; p95 agregado de quadro <= 33,3 ms, sem regressão superior a 10% nos demais custos E6, sem crescimento persistente de alocações por quadro e sem falhas de carregamento. Medição indisponível gera INCONCLUSIVO; meta não atingida gera FAIL; nenhum dos dois permite declarar a entrega pronta.
