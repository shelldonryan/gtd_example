# Verificação final

Os contratos históricos estão em
[Docs20260919_145427/verification.md](Docs20260919_145427/verification.md) e
[code/VERIFICATION.md](../code/VERIFICATION.md). A consolidação E6 é
reproduzível por:

```text
npm run typecheck
npm run e6:audit
npm run e6:evidence
npm run e6:compare -- docs/metrics-baseline.csv docs/metrics-final.csv
node prototype/balance-model.mjs --simulate
./tools/regression-final.sh
git diff --check
```

O harness Processing usa as fixtures determinísticas de
`last_horizon/capture.pde` e cobre captura, portas, escadas, pipeline, NPCs,
quests, noite, preview, input, caches e restauração. O registro consolidado
está em [E6_REPORT.md](E6_REPORT.md) e em
[`docs/evidence/e6-results.json`](evidence/e6-results.json).

## Matriz funcional executada

| Área | Cobertura |
| --- | --- |
| Mundo | quatro salas, quatro sobreviventes, seis recursos, dez dias |
| Calendário | dias 2/4/6/8/10, sete tipos, cinco incidentes sem reposição |
| Quests | 22 IDs, uma conclusão diária, um objeto carregado |
| Casos especiais | V-02, N-02, retomada, casco aleatório, socorro, NPC morto, alvo ausente, rota ausente, porta arbitrária, asset ausente |
| Interface e input | transmissão sobre incidente, pausa, mapa, ajuda, teclado, mouse, cursor e clique fora |

Todos os casos acima retornaram `pass` no registro E6. As fixtures restauram
tabelas, arte, RNG, posição, flags e memória antes do próximo caso.

A campanha final remove `last_horizon/output/` ao começar e ao terminar por
meio de `tools/cleanup-verification-artifacts.mjs`; capturas, logs e medições
transitórias não são retidos.
