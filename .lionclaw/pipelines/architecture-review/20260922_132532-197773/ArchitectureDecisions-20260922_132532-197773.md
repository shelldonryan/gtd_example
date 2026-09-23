# Architecture Decisions: gtd_example/20260922_132532-197773

## Context
- **Selected candidate:** C6
- **Source files:**
  - /home/ubuntu/pessoal/01-projetos/gtd_example/.lionclaw/pipelines/architecture-review/20260922_132532-197773/ArchitectureMap-20260922_132532-197773.md
  - /home/ubuntu/pessoal/01-projetos/gtd_example/.lionclaw/pipelines/architecture-review/20260922_132532-197773/ArchitectureCandidates-20260922_132532-197773.md
  - /home/ubuntu/pessoal/01-projetos/gtd_example/.lionclaw/pipelines/architecture-review/20260922_132532-197773/ArchitectureDiagnosis-20260922_132532-197773.md

---

## D1 - Relógio de simulação com passo fixo
- **Pergunta:** O movimento deve avançar por um relógio de simulação com passo fixo, acumulador limitado e eventos de áudio derivados do avanço simulado?
- **Opcoes consideradas:** Passo fixo com acumulador limitado; delta variável por callback; manter movimento dependente de callbacks e aprofundar apenas apresentação e áudio.
- **Decisao:** Adotar passo fixo com acumulador limitado.
- **Razao:** O objetivo é performance e estabilidade temporal: movimento, animação e eventos de áudio devem avançar pelo tempo simulado, independentemente da taxa de renderização. O acumulador deve ser limitado para evitar recuperação excessiva depois de frames longos, sem rajadas de áudio acumuladas. As velocidades e a cadência observadas em 60 FPS devem ser preservadas e o comportamento deve ser validado em 15, 30 e 60 FPS.
- **Implica:** O Module de frame passa a possuir uma política explícita de avanço temporal e recuperação limitada. A próxima decisão deve definir o orçamento de recuperação após frames longos e como eventos de áudio excedentes serão descartados ou consolidados, mantendo o escopo restrito ao Module de frame.
- **Timestamp:** 14:14

## D2 - Descarte do excedente temporal
- **Pergunta:** Quando o tempo acumulado ultrapassar o limite após um frame longo, qual política o Module de frame deve aplicar?
- **Opcoes consideradas:** Descartar imediatamente o excedente; reter a divida e drena-la gradualmente; comprimir o excedente em um passo maior.
- **Decisao:** Descartar imediatamente o excedente.
- **Razao:** O Module deve executar no maximo os passos permitidos por frame, limitar o acumulador ao orcamento definido e iniciar o proximo frame sem carregar divida temporal. Eventos de audio so podem ser emitidos pelos passos realmente executados, sem rajadas. A politica deve ser medida nos cenarios de 15, 30 e 60 FPS e registrada como decisao de performance.
- **Implica:** Frames longos nao geram recuperacao prolongada nem replay de eventos de audio; o proximo frame parte de um acumulador limitado. A proxima decisao deve fixar o orcamento numerico de passos para que 15, 30 e 60 FPS sejam cobertos dentro do limite.
- **Timestamp:** 14:15

## D3 - Contrato numerico de recuperacao por frame
- **Pergunta:** Qual orcamento numerico deve limitar os passos fixos por callback de renderizacao?
- **Opcoes consideradas:** Passo de 1/60 s com no maximo 4 passos por callback; no maximo 2 passos; 8 ou mais passos.
- **Decisao:** Usar passo fixo de 1/60 s com no maximo 4 passos por callback.
- **Razao:** Esse limite cobre 60 FPS com um passo, 30 FPS com dois e 15 FPS com quatro. Acima de aproximadamente 66,7 ms, o excedente sera descartado. O limite deve ser tratado como contrato de performance e validado para que o custo maximo de recuperacao permaneça previsivel.
- **Implica:** O acumulador tera teto equivalente a quatro passos de 1/60 s, e nenhum callback podera concentrar mais que quatro atualizacoes fixas. A proxima decisao deve definir como a apresentacao visual usa o estado entre passos sem alterar o contrato temporal da simulacao, da animacao ou do audio.
- **Timestamp:** 14:16

## D4 - Apresentacao do ultimo estado confirmado
- **Pergunta:** Entre os passos fixos, como a renderizacao deve apresentar o estado do jogador?
- **Opcoes consideradas:** Renderizar o ultimo estado simulado confirmado sem interpolacao; interpolar transformacoes visuais entre estados; extrapolar o proximo estado.
- **Decisao:** Renderizar o ultimo estado simulado confirmado, sem interpolacao.
- **Razao:** A prioridade e manter colisoes, animacoes e audio alinhados ao mesmo estado, sem criar historico visual ou outro caminho de calculo. A validacao deve comparar comportamento e custo em 15, 30 e 60 FPS.
- **Implica:** A apresentacao consumira o estado simulado confirmado; nao havera interpolacao ou extrapolacao visual no escopo de C6. O contrato temporal permanece concentrado no Module de frame, e a validacao deve verificar alinhamento funcional e custo previsivel nas tres taxas.
- **Timestamp:** 14:16

## D5 - Escopo da SPEC de performance
- **Pergunta:** Quais superficies do Architecture Map devem ser medidas e validadas para aplicar D1-D4 sem ampliar o trabalho para refatoracao funcional?
- **Opcoes consideradas:** Escopo restrito ao Module de frame; escopo de performance nas superficies do loop, movimento, animacao, HUD/UI, assets/caches, audio e harness; refatoracao funcional ampla.
- **Decisao:** Incluir na SPEC de performance: application shell e loop de frame em `last_horizon.pde` (`draw()`, `updateRoom()`, `drawBase()`, `drawWindow()`, viewport/letterbox, composicao do `PGraphics`, `smooth`, escala e redraw); movimento em `movement.pde` com D1-D3 para caminhada, corrida, gravidade e escadas; animacao em `animation.pde` preservando a reutilizacao de `player_frame_layer` e invalidando somente quando frame ou direcao mudarem; HUD e UI em `hud.pde`, `ui.pde` e `screens.pde`; assets e caches em `assets.pde` e `ship.pde`, incluindo C5; audio em `audio.pde` com eventos derivados do avanco simulado e investigacao de `stopStepSounds()`; e toolchain/harness em `capture.pde` e `tools/`.
- **Razao:** Medir o custo e a estabilidade temporal nas superficies indicadas pelo Map permite verificar performance de ponta a ponta sem alterar a experiencia sonora nem introduzir refatoracao funcional. A evidencia deve cobrir perfis reais de 15, 30 e 60 FPS, frame p95, distancia percorrida, eventos e intervalos de audio, alocacoes, caches, carregamento e memoria.
- **Implica:** A SPEC deve exigir validacao em 15, 30 e 60 FPS, manter dados dinamicos por frame e evitar reconstruir representacoes estaticas, cobrir escalonamento, spritesheets, faixas de piso, icones, fallbacks, invalidacoes e memoria, evitar rajadas de audio apos frames longos e medir `stopStepSounds()` sem mudar a experiencia sonora. Ficam fora transicao noturna, quests, modais como refatoracao de dominio, remocao de codigo ou comentarios, reorganizacao ampla, snapshot e mudancas de comportamento que nao sejam necessarias para estabilizar o tempo e reduzir custo.
