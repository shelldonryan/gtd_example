/* Reescreve a branch `entrega` a partir da branch de trabalho.

   A `entrega` e um artefato gerado, nao um lugar de edicao: a evolucao do
   prototipo e da documentacao acontece toda na branch de trabalho, e este
   comando monta o snapshot aplicando o corte da entrega.

   Uso, a partir da raiz do repositorio:

     node tools/snapshot-entrega.mjs
     git push origin entrega

   O snapshot e montado por indice temporario: o seu working tree (e o Obsidian
   aberto em cima dele) nao e tocado. Cada geracao entra como um commit novo em
   cima do snapshot anterior, entao o push e sempre normal, sem force. */

import { execFileSync } from "node:child_process";
import { rmSync } from "node:fs";
import { resolve } from "node:path";

const WORK_BRANCH = "prototype/sketch-architecture";
const DELIVERY_BRANCH = "entrega";
const MESSAGE = "chore(entrega): atualizar o snapshot para o professor";

/* Material de verificacao, de processo e de agente: nao vai para o professor. */
const EXCLUDED = [
  "SESSION_START.md",
  "code/VERIFICATION.md",
  "prototype",
  "tools",
  "skills-lock.json",
  ".obsidian",
  "last_horizon/capture.pde",
  "last_horizon/data/pipeline_probe.aseprite",
  "last_horizon/data/pipeline_probe_frame_1.png",
];

function git(...args) {
  return execFileSync("git", args, { encoding: "utf8" }).trim();
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

let root;
try {
  root = git("rev-parse", "--show-toplevel");
} catch {
  fail("Rode o comando a partir de um repositorio git.");
}

const index_file = resolve(root, ".git/snapshot-entrega.index");
rmSync(index_file, { force: true });

const index_env = { ...process.env, GIT_INDEX_FILE: index_file };

function gitIndex(...args) {
  return execFileSync("git", args, { encoding: "utf8", env: index_env, cwd: root }).trim();
}

try {
  gitIndex("read-tree", WORK_BRANCH);

  const removed = [];
  for (const path of EXCLUDED) {
    const listed = gitIndex("ls-files", "--", path);
    if (listed === "") continue;
    gitIndex("rm", "--cached", "--quiet", "-r", "--ignore-unmatch", "--", path);
    removed.push(path);
  }

  const tree = gitIndex("write-tree");
  const previous = git("rev-parse", "--verify", "--quiet", DELIVERY_BRANCH) || WORK_BRANCH;
  const previous_tree = git("rev-parse", "--verify", "--quiet", DELIVERY_BRANCH + "^{tree}");

  if (previous_tree === tree) {
    console.log("Snapshot " + DELIVERY_BRANCH + " ja esta igual a " + WORK_BRANCH + "; nada a fazer.");
    process.exit(0);
  }

  const commit = execFileSync("git", ["commit-tree", tree, "-p", previous, "-m", MESSAGE],
    { encoding: "utf8", env: index_env, cwd: root }).trim();

  git("update-ref", "refs/heads/" + DELIVERY_BRANCH, commit);

  const count = git("ls-tree", "-r", "--name-only", DELIVERY_BRANCH).split("\n").filter(Boolean).length;
  console.log("Snapshot " + DELIVERY_BRANCH + " atualizado a partir de " + WORK_BRANCH + " (" + commit.slice(0, 7) + ").");
  console.log("Fora do snapshot: " + removed.join(", "));
  console.log("Arquivos no snapshot: " + count);
  console.log("Publicar: git push origin " + DELIVERY_BRANCH);
} finally {
  rmSync(index_file, { force: true });
}
