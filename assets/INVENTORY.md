# Inventário de assets

Inventário dos arquivos de arte e áudio usados pelo sketch em
`last_horizon/data/`.

## Diretrizes de Renderização e Escala

- **Escala 1:1**: 1 pixel da arte equivale a 1 pixel no render final em 1280×720.
- **Espaço lógico**: A grade lógica é de 640×360 e a renderização aplica escala 2× (`RENDER_SCALE = 2`).
- **Dimensões**: O canvas do asset representa o tamanho exato ocupado na tela lógica multiplicada por 2. Por exemplo, o frame do técnico possui 64×64 pixels reais e é posicionado em uma caixa lógica de 32×32.
- **Carregamento**: Definido em `last_horizon/assets.pde`. Os assets em `last_horizon/data/` são carregados dinamicamente na inicialização do sketch.
- **Formato**:
  - Assets estáticos: imagens PNG; arquivos-fonte são catalogados junto aos assets correspondentes.
  - Assets animados: spritesheet PNG acompanhada de arquivo JSON de metadados (`frames`).
  - Áudio: arquivos WAV PCM 16 bits, 44,1 kHz, mono, executados nativamente via `javax.sound.sampled`.
- **Licenciamento**: as pastas de assets presentes incluem `LICENSE.txt` com as
  atribuições correspondentes.

---

## Posições e Conveses nas Salas

As posições de escadas e estações são definidas em código (`ship.pde`) e estruturadas em três conveses:
- **Conveses (y)**: superior (`y = 128`), médio (`y = 202`), inferior (`y = 278`).
- **Limites úteis da sala**: horizontal `x` de 8 a 632; vertical `y` de 56 a 284.

| Sala | Escadas (x) | Estações por convés |
| :--- | :--- | :--- |
| **Comando** | 127 e 532 | Superior: Vera (x=575)<br>Médio: Console da rota (x=260)<br>Inferior: Antena (x=598) |
| **Máquinas** | 468 e 136 | Superior: Painel de suporte (x=454)<br>Médio: Sílvia (x=570), Distribuição (x=215)<br>Inferior: Bancada do motor (x=271) |
| **Depósito** | 520 e 130 | Superior: Prateleira de reserva (x=530)<br>Médio: Bento (x=310)<br>Inferior: Estoque de comida (x=85) |
| **Dormitório** | 542 e 243 | Superior: Beliche do técnico (x=185), Mesa comum (x=525)<br>Médio: Neusa (x=330), Mesa do grupo (x=440)<br>Inferior: Beliche de socorro (x=85) |

---

## Catálogo de Assets Integrados

### 1. Jogador (Técnico)
- **Localização**: `data/player/`
  - `player_sheet.png`: Spritesheet com frames de 64×64 px.
  - `player_sheet.json`: Definição dos quadros e animações.
- **Uso**: Controlado pelo jogador. Possui ciclos de animação para repouso (idle), caminhada (walk), corrida (run) e escadas (climb).

### 2. Personagens (NPCs)
- **Localização**: `data/npc/`
  - **Spritesheets**: `vera.png`, `bento.png`, `neusa.png`, `silvia.png`.
    - Quadros de 64×64 px (32×32 lógicos), com detecção de direção em relação ao técnico (perfil esquerdo, perfil direito e frontal) e ciclo de respiração idle de 2 quadros a 500 ms.
  - **Retratos**: `vera_portrait.png`, `bento_portrait.png`, `neusa_portrait.png`, `silvia_portrait.png`.
    - Imagens estáticas de 224×276 px (112×138 lógicos), exibidas nos modais de diálogo e confirmação presencial de ordens.
  - **Efeito visual**: Contorno/halo cyan ou laranja gerado proceduralmente em tempo de execução via mapa de transparência (`buildNpcGlow` / `buildColoredGlow`).

### 3. Portas
- **Localização**: `data/doors/`
  - `door_sheet.png`: Spritesheet de 210×97 px com dois estados: `fechada` e `aberta` (105×97 px cada, desenhado em 52.5×48.5 lógicos).
  - `door_sheet.json`: Metadados das animações.
- **Uso**: Utilizado em todas as conexões entre as salas. Ao aproximar-se, o jogo desenha o contorno cyan dinâmico e o rótulo da sala destino; a travessia executa a animação de abertura e fechamento.

### 4. Estações de Trabalho e Interação
- **Localização**: `data/stations/`
  - 11 imagens PNG ancoradas pela base no convés (`point_y`) e centralizadas no `x` do ponto interativo:
    - `antena.png` (Comando, convés inferior)
    - `console_rota.png` (Comando, convés médio)
    - `painel_suporte.png` (Máquinas, convés superior)
    - `painel_distribuicao.png` (Máquinas, convés médio)
    - `bancada_motor.png` (Máquinas, convés inferior)
    - `prateleira_reserva.png` (Depósito, convés superior)
    - `estoque_comida.png` (Depósito, convés inferior)
    - `mesa_comum.png` (Dormitório, convés superior)
    - `beliche_tecnico.png` (Dormitório, convés superior)
    - `mesa_grupo.png` (Dormitório, convés médio)
    - `beliche_socorro.png` (Dormitório, convés inferior)

### 5. Decorações de Sala
- **Localização**: `data/decorations/`
  - 21 PNGs utilizados para compor a ambientação visual dos conveses e paredes em cada sala, carregados via `roomDetail()` em `ship.pde`:
    - `Baril 1.png`, `Baril 2.png`, `Board 1.png`, `Computer 1.png`, `Electric wall.png`, `Lamp 1.png`, `Lockers 1.png`, `Neon.png`, `Pipe2.png`, `post it.png`, `Screen info 1.png`, `Screen info 2.png`, `Small Machine 1.png`, `Wall 3.png`, `Wall 4 Light.png`, `Wall cover 2.png`, `Wall cover 3.png`, `Wall electric pannel 1.png`, `Wall pipes.png`, `Wallbox 1.png`, `Window 2.png`.

### 6. Elementos de Cenário e Ambiente
- **Localização**: `data/environment/`
  - `floor_1.png`: Módulo de piso texturizado utilizado para renderizar as faixas dos conveses (`art_deck_strip`).
  - `dorm_bunk.png`: Arte complementar de beliche no dormitório.
  - `window_space.png`: Fundo estelar exibido através da janela de observação.

### 7. Ícones do HUD
- **Localização**: `data/icons/`
  - 6 imagens PNG de 64×64 px (renderizadas em 16×16 unidades lógicas) e seus arquivos `.aseprite` de origem:
    - `energia.png`, `oxigenio.png`, `agua.png`, `comida.png`, `pecas.png`, `moral.png`.
  - Nota: O ícone de alerta crítico permanece desenhado proceduralmente em código.

### 8. Mapa da Nave
- **Localização**: `data/map/`
  - `ship.png` e `ship.aseprite`: Vista estrutural da nave utilizada como fundo do modal de mapa.
  - Miniaturas dos cômodos: `1.png`, `2.png`, `3.png`, `4.png`, mapeadas no loader nos cartões de Comando (`4.png`), Máquinas (`2.png`), Depósito (`1.png`) e Dormitório (`3.png`).

### 9. Efeitos Sonoros (Áudio)
- **Localização**: `data/audio/` (arquivos WAV PCM 16 bits, 44,1 kHz, mono):
  - `audio/door/`: `door.wav` (tocado no início da travessia de porta).
  - `audio/walk/`: `step_01.wav` a `step_04.wav` (passos durante caminhada).
  - `audio/run/`: `step_01.wav` a `step_04.wav` (passos de ritmo acelerado na corrida).
  - `audio/ladder/`: `ladder.wav` (impacto na escada) e `step_01.wav` a `step_04.wav` (passos metálicos durante subida/descida).


---

## Componentes desenhados pelo sketch

O sketch também desenha os componentes de interface:
- Painéis, molduras e caixas de diálogo modais.
- Cartões de recursos (barras de progresso, molduras e indicador de pulso).
- Linhas informativas da faixa inferior (objetivo e alertas).
- Botões interativos, selo de notificação `!` pulsante e modal de ajuda (`?`).
- Tipografia Segoe UI renderizada vetorialmente.
- Indicador visual e marcação de sala atual / objetivo no modal de mapa.
