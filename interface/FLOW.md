# Fluxo de telas

## Telas e como se chega

| Tela | Como se chega | O que mostra |
| --- | --- | --- |
| MENU INIT | ao abrir o jogo | título, campo do nome do técnico e botão de início |
| Vinheta | depois do INIT | 3 telas de texto, avançadas com clique |
| Sala de comando | depois da vinheta ou pelas portas do hub | cena 2D jogável, rota, comunicações, ordens e acessos por convés |
| Sala de máquinas | pela porta inferior do Comando | cena 2D jogável, motor, energia, suporte e ordens técnicas |
| Depósito | pela porta média do Comando | cena 2D jogável, estoques, componentes e ordens logísticas |
| Dormitório | pela porta superior do Comando e no início de cada novo dia | cena 2D jogável, descanso, saúde, moral, Neusa e ordens da tripulação |
| Ordens | no início de dias sem incidente | duas ordens preventivas comparáveis, com objeto, rota, recompensa e perda |
| Mapa | botão `MAPA` | sobreposição com posição, ordens ativas e problemas por sala; nunca transporta |
| Diálogo | interação com sobrevivente | retrato e caixa inferior; oferece ou confirma uma ordem |
| Incidente | no início dos dias 2, 4, 6, 8 e 10 | cartão modal com duas soluções físicas |
| Pausa | ESC nas salas | continuar, reiniciar ou sair |
| Vitória | fim da viagem, com motor operante e sobrevivente vivo | ver `MENU_VICTORY.md` |
| Derrota | recurso crítico, motor destruído ou nenhum sobrevivente vivo | ver `MENU_GAME_OVER.md` |

## Grafo

```mermaid
graph LR
  INIT["MENU INIT"] --> VINHETA --> COMANDO["Sala de comando — hub"]
  COMANDO <-->|porta superior| DORMITORIO["Dormitório"]
  COMANDO <-->|porta média| DEPOSITO["Depósito"]
  COMANDO <-->|porta inferior| MAQUINAS["Sala de máquinas"]
  DORMITORIO -.->|dia sem incidente| ORDENS["duas ordens preventivas"]
  ORDENS -->|escolher uma| CONFIRMA["confirmar com sobrevivente"]
  CONFIRMA --> QUEST["coletar → entregar"]
  COMANDO -.->|dia com incidente| INCIDENTE["duas soluções físicas"]
  INCIDENTE -->|escolher uma| QUEST
  QUEST -->|recompensa ou correção| DORMITORIO
  DORMITORIO -->|beliche: dormir| DORMITORIO
  COMANDO -.->|MAPA| MAPA["mapa consultável"]
  MAQUINAS -.->|MAPA| MAPA
  DEPOSITO -.->|MAPA| MAPA
  DORMITORIO -.->|MAPA| MAPA
  MAPA -.->|fechar| SALA_ATUAL["mesma sala e posição"]
  COMANDO -.->|ESC| PAUSA["PAUSA"]
  MAQUINAS -.->|ESC| PAUSA
  DEPOSITO -.->|ESC| PAUSA
  DORMITORIO -.->|ESC| PAUSA
```
## O ciclo do dia

1. O primeiro dia começa na Sala de comando; os seguintes, no Dormitório.
2. Nos dias sem incidente, duas ordens preventivas aparecem remotamente. O
   jogador compara as ofertas, escolhe uma e confirma a escolha ao encontrar o
   sobrevivente responsável.
3. A ordem aceita informa objeto, origem, destino, recompensa e perda em caso de
   falha. Não pode ser cancelada e deve ser concluída antes de dormir.
4. Nos dias 2, 4, 6, 8 e 10, um incidente apresenta duas soluções físicas. O
   jogador escolhe uma e executa a quest correspondente.
5. A coleta e a entrega são as duas etapas leves da ordem. O mapa marca origem e
   destino, mas não transporta o técnico.
6. Uma única quest pode ser concluída por dia. Diagnóstico e conversa fora da
   ordem são opcionais e não criam uma cadeia obrigatória.
7. Se nenhuma ordem preventiva for aceita, os dois recursos oferecidos sofrem
   pequenas perdas. Se a ordem aceita falhar, perde-se uma pequena quantidade do
   recurso que ela protegeria.
8. Se a solução de incidente falhar, o problema permanece ativo e segue sua
   perda, prazo e crise normais.
9. O técnico retorna ao próprio beliche no Dormitório. Dormir processa consumo,
   perdas, riscos, crises e condições de término.

O objetivo global continua sendo chegar a Marte com o motor operante e pelo
menos um sobrevivente vivo. A pressão diária vem da escolha entre duas ordens,
do custo dos seis recursos e da consequência de deixar uma necessidade sem
manutenção.

## Controles

| Ação | Tecla ou controle |
| --- | --- |
| Andar | ← → ou A/D |
| Usar escada | ↑ ↓ ou W/S |
| Pular | espaço |
| Interagir e abrir portas | E |
| Continuar diálogos, confirmar modal e dormir | ENTER |
| Abrir o mapa | botão `MAPA`, com o mouse |
| Pausa, fechar/voltar modal e continuar na pausa | ESC |

O dia não avança por tecla ou botão persistente. Encerrá-lo exige chegar ao
beliche do técnico no Dormitório, conferir o resumo e dormir.

## Regras de navegação

- A Sala de comando é o único hub. Sua porta superior leva ao Dormitório, a
  média ao Depósito e a inferior à Sala de máquinas. As salas periféricas não
  possuem portas entre si.
- A composição espacial toma `COMMAND_ROOM_CONCEPT_ART.png` como referência,
  sem adotar nomes ou números ilustrativos da imagem.
- O mapa é uma sobreposição consultável. Marca `VOCÊ ESTÁ AQUI`, mostra a ordem
  ativa e os problemas por cômodo; clicar numa sala não move o técnico.
- Fechar o mapa retorna à mesma sala e à mesma posição.
- O HUD mostra a ordem ativa, seu objeto, origem, destino e recompensa. Problemas
  ativos continuam mostrando perda, prazo e crise.
- Nos dias sem incidente, duas ordens preventivas são apresentadas remotamente.
  A escolhida é confirmada ao encontrar o sobrevivente; a outra expira.
- Nos dias com incidente, o cartão apresenta duas soluções físicas. A solução
  escolhida substitui a contenção separada e deve ser executada no espaço jogável.
- O sobrevivente responsável pode ser origem ou destino da ordem. Uma rota não
  exige três cômodos distintos.
- Coleta e entrega são as duas etapas da quest. Componentes são carregados um por
  vez e só existem como parte de uma ordem aceita.
- Diagnóstico e conversa fora da ordem são opcionais. Não há cadeia universal de
  NPCs nem objetivo paralelo.
- Uma quest pode ser concluída por dia. A ordem aceita não pode ser cancelada.
- Uma ordem preventiva aceita e não concluída perde uma pequena quantidade do
  recurso que protegeria. A ordem não escolhida não gera perda.
- Se nenhuma ordem preventiva for aceita, os dois recursos das ofertas sofrem
  pequenas perdas. Se uma solução de incidente falhar, o problema permanece com
  suas perdas, prazo e crise normais.
- NPCs usam retrato e caixa inferior modal. Ordens e soluções mostram confirmação
  antes do compromisso; coleta, entrega e dormir exibem o custo ou resultado
  relevante antes de aplicar.
- A pausa não consome tempo nem recursos. Portas e escadas continuam sendo
  indicações contextuais.

Os botões exibem no próprio rótulo o atalho de teclado que controla a ação:
`INICIAR (ENTER)`, `CONTINUAR (ENTER)`, `CONTINUAR (ESC)`, `CONFIRMAR (ENTER)`,
`ACEITAR ORDEM (ENTER)`, `ENTREGAR (ENTER)`, `ENCERRAR DIA (ENTER)`,
`VOLTAR (ESC)` e `FECHAR (ESC)`. Botões sem atalho de teclado permanecem
acionados pelo mouse.
