#!/usr/bin/env node
/**
 * PROTÓTIPO DESCARTÁVEL — balanceamento da issue #20.
 *
 * Pergunta: quais números tornam a viagem de dez dias legível, ganhável por
 * correção, recuperação ou aceleração, mas perdível quando o jogador omite as
 * intervenções?
 *
 * Simulação automática: node prototype/balance-model.mjs --simulate
 * Exploração interativa: node prototype/balance-model.mjs
 */

import readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";
import { pathToFileURL } from "node:url";

const MAX_RESOURCE = 100;
const INCIDENT_DAYS = new Set([1, 3, 5, 7, 9]);
const INCIDENT_SEQUENCE = ["hull", "conflict", "engine", "food", "power"];
const SURVIVORS = ["Vera", "Bento", "Neusa", "Sílvia"];

export const PROBLEMS = Object.freeze({
  engine: {
    name: "Falha no motor",
    room: "Sala de máquinas",
    loss: { energy: 4 },
    safe: { label: "Reduzir rotação", cost: { energy: 5 }, deadline: 3 },
    risky: { label: "Manter impulso", cost: { morale: 2 }, deadline: 2 },
    crisis: "Motor destruído — derrota imediata",
    crisisReset: 0,
    specialist: "Sílvia",
    repair: { withSpecialist: { parts: 2 }, withoutSpecialist: { parts: 3 } },
  },
  hull: {
    name: "Dano no casco",
    room: "Local aleatório alcançável",
    loss: { oxygen: 5 },
    safe: { label: "Selar anteparas", cost: { energy: 5 }, deadline: 3 },
    risky: { label: "Isolar apenas o setor", cost: { oxygen: 4 }, deadline: 2 },
    crisis: "Ruptura: −15 oxigênio; novo prazo de 2 dias",
    crisisReset: 2,
    specialist: "Sílvia",
    repair: {
      withSpecialist: { parts: 1 },
      withoutSpecialist: { parts: 2 },
      component: "kit de vedação",
    },
  },
  lifeSupport: {
    name: "Falha no suporte de vida",
    room: "Sala de máquinas",
    loss: { oxygen: 4 },
    safe: { label: "Usar redundância", cost: { energy: 4 }, deadline: 4 },
    risky: { label: "Recircular o ar", cost: { oxygen: 3 }, deadline: 2 },
    crisis: "Contaminação: −12 oxigênio e uma pessoa em risco",
    crisisReset: 3,
    specialist: "Sílvia",
    repair: { withSpecialist: { parts: 1 }, withoutSpecialist: { parts: 2 } },
  },
  power: {
    name: "Falha no sistema de energia",
    room: "Sala de máquinas",
    loss: { energy: 3 },
    safe: { label: "Desligar circuitos", cost: { energy: 4 }, deadline: 4 },
    risky: { label: "Distribuir a sobrecarga", cost: { morale: 4 }, deadline: 2 },
    crisis: "Apagão: −12 energia e modo economia desligado",
    crisisReset: 3,
    specialist: "Sílvia",
    repair: {
      withSpecialist: { parts: 1 },
      withoutSpecialist: { parts: 2 },
      component: "fusível de potência",
    },
  },
  communications: {
    name: "Falha nas comunicações",
    room: "Sala de comando",
    loss: { morale: 2 },
    safe: { label: "Manter escuta", cost: { energy: 3 }, deadline: 4 },
    risky: { label: "Desligar o transmissor", cost: { morale: 3 }, deadline: 2 },
    crisis: "Isolamento: −10 moral; novo prazo de 3 dias",
    crisisReset: 3,
    specialist: "Vera",
    repair: { withSpecialist: { parts: 1 }, withoutSpecialist: { parts: 2 } },
  },
  food: {
    name: "Falta de comida",
    room: "Depósito",
    loss: { food: 3 },
    safe: { label: "Abrir a reserva", cost: { food: 4 }, deadline: 4 },
    risky: { label: "Reduzir porções agora", cost: { morale: 4 }, deadline: 2 },
    crisis: "Fome: −8 comida e uma pessoa em risco",
    crisisReset: 3,
    specialist: "Bento",
    repair: { withSpecialist: {}, withoutSpecialist: { food: 3 } },
  },
  conflict: {
    name: "Conflito no dormitório",
    room: "Dormitório",
    loss: { morale: 4 },
    safe: { label: "Separar o grupo", cost: { water: 4 }, deadline: 4 },
    risky: { label: "Deixar a discussão esfriar", cost: { morale: 3 }, deadline: 2 },
    crisis: "Agressão: −8 moral e uma pessoa em risco",
    crisisReset: 3,
    specialist: "Neusa",
    repair: { withSpecialist: {}, withoutSpecialist: { water: 3 } },
  },
});


function shuffledProblems() {
  const problems = Object.keys(PROBLEMS);
  for (let index = problems.length - 1; index > 0; index--) {
    const swapIndex = Math.floor(Math.random() * (index + 1));
    [problems[index], problems[swapIndex]] = [problems[swapIndex], problems[index]];
  }
  return problems.slice(0, 5);
}

export function initialState(incidentSequence = shuffledProblems()) {
  return {
    day: 1,
    resources: { energy: 100, oxygen: 100, water: 100, food: 70, morale: 100, parts: 6 },
    alive: Object.fromEntries(SURVIVORS.map((name) => [name, true])),
    risks: [],
    activeProblems: [],
    pendingIncident: null,
    policies: { economy: false, rationing: false },
    interventionUsed: false,
    skipNextDay: false,
    motorOperational: true,
    outcome: "ongoing",
    reason: "",
    incidentsSeen: [],
    incidentSequence,
    skippedDays: [],
    interventions: [],
    crises: [],
    lastMessage: "Dia 1 iniciado.",
  };
}

function copyState(state) {
  return structuredClone(state);
}
function clampResources(state) {
  for (const key of ["energy", "oxygen", "water", "food", "morale"]) {
    state.resources[key] = Math.max(0, Math.min(MAX_RESOURCE, state.resources[key]));
  }
}

function canPay(state, cost) {
  return Object.entries(cost).every(([resource, amount]) => state.resources[resource] >= amount);
}

function pay(state, cost) {
  for (const [resource, amount] of Object.entries(cost)) {
    state.resources[resource] -= amount;
  }
}

function addResources(state, gain) {
  for (const [resource, amount] of Object.entries(gain)) {
    state.resources[resource] += amount;
  }
  clampResources(state);
}

function specialistAlive(state, name) {
  return state.alive[name];
}

function checkOutcome(state) {
  const depleted = ["energy", "oxygen", "morale"].find((key) => state.resources[key] <= 0);
  if (depleted) {
    state.outcome = "defeat";
    state.reason = `${depleted} chegou a zero`;
  } else if (!state.motorOperational) {
    state.outcome = "defeat";
    state.reason = "motor destruído";
  } else if (Object.values(state.alive).every((alive) => !alive)) {
    state.outcome = "defeat";
    state.reason = "nenhum sobrevivente vivo";
  }
}

function incidentForDay(day, sequence) {
  if (!INCIDENT_DAYS.has(day)) return null;
  return sequence[(day - 1) / 2];
}

function beginDay(state) {
  const next = copyState(state);
  if (next.outcome !== "ongoing") return next;
  next.interventionUsed = false;
  next.skipNextDay = false;
  const incidentId = incidentForDay(next.day, next.incidentSequence);
  if (incidentId && !next.activeProblems.some((problem) => problem.id === incidentId)) {
    next.pendingIncident = incidentId;
    next.incidentsSeen.push({ day: next.day, id: incidentId });
    next.lastMessage = `Incidente: ${PROBLEMS[incidentId].name}. Escolha uma contenção.`;
  } else {
    next.lastMessage = `Dia ${next.day}: sem incidente novo.`;
  }
  return next;
}

function containIncident(state, choice) {
  const next = copyState(state);
  if (!next.pendingIncident) {
    next.lastMessage = "Não há incidente aguardando contenção.";
    return next;
  }
  const definition = PROBLEMS[next.pendingIncident];
  const containment = definition[choice];
  if (!containment || !canPay(next, containment.cost)) {
    next.lastMessage = "Contenção inválida ou sem recursos para pagar.";
    return next;
  }
  pay(next, containment.cost);
  next.activeProblems.push({ id: next.pendingIncident, deadline: containment.deadline });
  next.lastMessage = `${containment.label}: ${definition.name} ativo por ${containment.deadline} dias.`;
  next.pendingIncident = null;
  checkOutcome(next);
  return next;
}

function togglePolicy(state, policy) {
  const next = copyState(state);
  if (!(policy in next.policies)) {
    next.lastMessage = "Política desconhecida.";
    return next;
  }
  const enabling = !next.policies[policy];
  if (enabling) {
    const activationCost = specialistAlive(next, "Bento") ? 2 : 4;
    if (next.resources.morale < activationCost) {
      next.lastMessage = "Moral insuficiente para ativar a política.";
      return next;
    }
    next.resources.morale -= activationCost;
  }
  next.policies[policy] = enabling;
  next.lastMessage = `${policy} ${enabling ? "ativado" : "desativado"}.`;
  checkOutcome(next);
  return next;
}

function urgentProblem(state) {
  return [...state.activeProblems].sort((a, b) => a.deadline - b.deadline)[0] ?? null;
}

function repairProblem(state, problemId) {
  const next = copyState(state);
  if (next.interventionUsed) {
    next.lastMessage = "A intervenção principal do dia já foi usada.";
    return next;
  }
  const activeIndex = next.activeProblems.findIndex((problem) => problem.id === problemId);
  if (activeIndex < 0) {
    next.lastMessage = "Esse problema não está ativo.";
    return next;
  }
  const definition = PROBLEMS[problemId];
  const cost = specialistAlive(next, definition.specialist)
    ? definition.repair.withSpecialist
    : definition.repair.withoutSpecialist;
  if (!canPay(next, cost)) {
    next.lastMessage = "Recursos insuficientes para a correção.";
    return next;
  }
  pay(next, cost);
  next.activeProblems.splice(activeIndex, 1);
  next.interventionUsed = true;
  next.interventions.push({ day: next.day, type: "repair", target: problemId });
  const component = definition.repair.component ? ` após coletar ${definition.repair.component}` : "";
  next.lastMessage = `${definition.name} corrigido${component}.`;
  return next;
}

function careForGroup(state) {
  const next = copyState(state);
  if (next.interventionUsed) {
    next.lastMessage = "A intervenção principal do dia já foi usada.";
    return next;
  }
  const cost = { water: 3, food: 2 };
  if (!canPay(next, cost)) {
    next.lastMessage = "Recursos insuficientes para cuidar do grupo.";
    return next;
  }
  pay(next, cost);
  const gain = specialistAlive(next, "Neusa") ? 20 : 12;
  addResources(next, { morale: gain });
  next.interventionUsed = true;
  next.interventions.push({ day: next.day, type: "care", target: "group" });
  next.lastMessage = `Grupo cuidado: +${gain} moral.`;
  return next;
}

function rescueSurvivor(state, name) {
  const next = copyState(state);
  if (next.interventionUsed) {
    next.lastMessage = "A intervenção principal do dia já foi usada.";
    return next;
  }
  const riskIndex = next.risks.findIndex((risk) => risk.name.toLowerCase() === name.toLowerCase());
  if (riskIndex < 0) {
    next.lastMessage = "Essa pessoa não está em risco.";
    return next;
  }
  const cost = specialistAlive(next, "Neusa") ? { water: 6, food: 2 } : { water: 9, food: 3 };
  if (!canPay(next, cost)) {
    next.lastMessage = "Recursos insuficientes para o socorro.";
    return next;
  }
  pay(next, cost);
  const rescued = next.risks.splice(riskIndex, 1)[0];
  next.interventionUsed = true;
  next.interventions.push({ day: next.day, type: "rescue", target: rescued.name });
  next.lastMessage = `${rescued.name} foi estabilizado.`;
  return next;
}

function boost(state) {
  const next = copyState(state);
  if (next.interventionUsed) {
    next.lastMessage = "A intervenção principal do dia já foi usada.";
    return next;
  }
  const cost = specialistAlive(next, "Vera") ? 10 : 15;
  if (next.resources.energy < cost) {
    next.lastMessage = "Energia insuficiente para aumentar potência.";
    return next;
  }
  next.resources.energy -= cost;
  next.interventionUsed = true;
  next.skipNextDay = true;
  next.interventions.push({ day: next.day, type: "boost", target: "route" });
  next.lastMessage = `Potência aumentada por ${cost} energia; o próximo dia será eliminado.`;
  checkOutcome(next);
  return next;
}

function putSurvivorAtRisk(state, source) {
  const candidates = SURVIVORS.filter((name) => state.alive[name] && !state.risks.some((risk) => risk.name === name));
  if (candidates.length === 0) return;
  const offset = Object.keys(PROBLEMS).indexOf(source);
  const name = candidates[(state.day + offset) % candidates.length];
  state.risks.push({ name, deadline: 2, source });
}

function applyCrisis(state, problem) {
  const definition = PROBLEMS[problem.id];
  state.crises.push({ day: state.day, id: problem.id });
  switch (problem.id) {
    case "engine":
      state.motorOperational = false;
      break;
    case "hull":
      state.resources.oxygen -= 15;
      break;
    case "lifeSupport":
      state.resources.oxygen -= 12;
      putSurvivorAtRisk(state, problem.id);
      break;
    case "power":
      state.resources.energy -= 12;
      state.policies.economy = false;
      break;
    case "communications":
      state.resources.morale -= 10;
      break;
    case "food":
      state.resources.food -= 8;
      putSurvivorAtRisk(state, problem.id);
      break;
    case "conflict":
      state.resources.morale -= 8;
      putSurvivorAtRisk(state, problem.id);
      break;
  }
  problem.deadline = definition.crisisReset;
}

function processRisks(state) {
  for (const risk of state.risks) risk.deadline--;
  const expired = state.risks.filter((risk) => risk.deadline <= 0);
  for (const risk of expired) state.alive[risk.name] = false;
  state.risks = state.risks.filter((risk) => risk.deadline > 0);
}

function sleep(state) {
  const next = copyState(state);
  if (next.pendingIncident) {
    next.lastMessage = "Escolha a contenção antes de dormir.";
    return next;
  }
  if (next.outcome !== "ongoing") return next;

  const dailyPolicyCost = specialistAlive(next, "Bento") ? 1 : 2;
  if (next.policies.economy) next.resources.morale -= dailyPolicyCost;
  if (next.policies.rationing) next.resources.morale -= dailyPolicyCost;

  next.resources.energy -= next.policies.economy ? 3 : 6;
  next.resources.oxygen -= next.resources.energy < 30 ? 10 : 5;
  next.resources.water -= next.policies.rationing ? 4 : 8;
  next.resources.food -= next.policies.rationing ? 3 : 7;

  for (const problem of next.activeProblems) pay(next, PROBLEMS[problem.id].loss);

  const redResources = ["energy", "oxygen", "water", "food"].filter(
    (key) => next.resources[key] > 0 && next.resources[key] < 30,
  ).length;
  next.resources.morale -= 2 + redResources;

  processRisks(next);
  for (const problem of next.activeProblems) {
    problem.deadline--;
    if (problem.deadline <= 0) applyCrisis(next, problem);
  }
  clampResources(next);

  checkOutcome(next);
  if (next.outcome !== "ongoing") {
    next.lastMessage = `Derrota no dia ${next.day}: ${next.reason}.`;
    return next;
  }

  const skippedDay = next.skipNextDay ? next.day + 1 : null;
  if (skippedDay && skippedDay <= 10) next.skippedDays.push(skippedDay);
  const nextDay = next.day + (next.skipNextDay ? 2 : 1);
  if (nextDay > 10) {
    next.outcome = "victory";
    next.reason = "chegada a Marte";
    next.lastMessage = `Vitória após processar o dia ${next.day}.`;
  } else {
    next.day = nextDay;
    next.lastMessage = `Dia ${next.day} iniciado.`;
  }
  return next;
}

export function reduce(state, action) {
  switch (action.type) {
    case "begin": return beginDay(state);
    case "contain": return containIncident(state, action.choice);
    case "policy": return togglePolicy(state, action.policy);
    case "repair": return repairProblem(state, action.problem);
    case "care": return careForGroup(state);
    case "rescue": return rescueSurvivor(state, action.name);
    case "boost": return boost(state);
    case "sleep": return sleep(state);
    default: {
      const next = copyState(state);
      next.lastMessage = "Ação desconhecida.";
      return next;
    }
  }
}

const STRATEGIES = {
  priority: {
    title: "Correção prioritária",
    containment: "safe",
    policies(state) {
      return state.day === 1 && !state.policies.rationing ? [{ type: "policy", policy: "rationing" }] : [];
    },
    action(state) {
      const problem = urgentProblem(state);
      return problem ? { type: "repair", problem: problem.id } : null;
    },
  },
  recovery: {
    title: "Recuperação",
    containment: "risky",
    policies(state) {
      return state.day === 1 && !state.policies.rationing ? [{ type: "policy", policy: "rationing" }] : [];
    },
    action(state) {
      const planned = {
        1: { type: "care" },
        2: { type: "repair", problem: "hull" },
        3: { type: "care" },
        4: { type: "care" },
        6: { type: "repair", problem: "engine" },
        7: { type: "repair", problem: "conflict" },
        8: { type: "repair", problem: "food" },
        9: { type: "care" },
        10: { type: "repair", problem: "power" },
      };
      if (state.day === 5 && state.risks.length > 0) return { type: "rescue", name: state.risks[0].name };
      return planned[state.day] ?? null;
    },
  },
  acceleration: {
    title: "Aceleração",
    containment: "safe",
    policies() { return []; },
    action(state) {
      if (state.day === 1) return { type: "repair", problem: "hull" };
      if ([2, 4, 6, 8].includes(state.day)) return { type: "boost" };
      return null;
    },
  },
  omission: {
    title: "Omissão",
    containment: "risky",
    policies() { return []; },
    action() { return null; },
  },
};

function runStrategy(strategy, incidentSequence = INCIDENT_SEQUENCE) {
  let state = initialState(incidentSequence);
  const messages = [];
  while (state.outcome === "ongoing") {
    state = reduce(state, { type: "begin" });
    messages.push(`D${state.day}: ${state.lastMessage}`);
    if (state.pendingIncident) {
      state = reduce(state, { type: "contain", choice: strategy.containment });
      messages.push(`D${state.day}: ${state.lastMessage}`);
    }
    for (const policy of strategy.policies(state)) {
      state = reduce(state, policy);
      messages.push(`D${state.day}: ${state.lastMessage}`);
    }
    const action = strategy.action(state);
    if (action) {
      state = reduce(state, action);
      messages.push(`D${state.day}: ${state.lastMessage}`);
    }
    state = reduce(state, { type: "sleep" });
    messages.push(state.lastMessage);
  }
  return { state, messages };
}

function compactResources(resources) {
  return `E${resources.energy} O${resources.oxygen} A${resources.water} C${resources.food} M${resources.morale} P${resources.parts}`;
}

function printProblemTable() {
  console.log("\nTABELA DOS SETE PROBLEMAS");
  for (const [id, problem] of Object.entries(PROBLEMS)) {
    const loss = Object.entries(problem.loss).map(([key, value]) => `${key} −${value}/dia`).join(", ");
    const safeCost = Object.entries(problem.safe.cost).map(([key, value]) => `${key} −${value}`).join(", ") || "sem custo";
    const riskyCost = Object.entries(problem.risky.cost).map(([key, value]) => `${key} −${value}`).join(", ") || "sem custo";
    console.log(`- ${id}: ${problem.name} | ${problem.room} | ${loss}`);
    console.log(`  segura: ${problem.safe.label} (${safeCost}, prazo ${problem.safe.deadline})`);
    console.log(`  arriscada: ${problem.risky.label} (${riskyCost}, prazo ${problem.risky.deadline})`);
    console.log(`  crise: ${problem.crisis}`);
  }
}


function orderedSelections(items, length, prefix = []) {
  if (prefix.length === length) return [prefix];
  const remaining = items.filter((item) => !prefix.includes(item));
  return remaining.flatMap((item) => orderedSelections(items, length, [...prefix, item]));
}

function simulateAll() {
  printProblemTable();
  const results = Object.entries(STRATEGIES).map(([id, strategy]) => [id, strategy, runStrategy(strategy)]);
  console.log("\nSIMULAÇÕES");
  for (const [, strategy, result] of results) {
    const state = result.state;
    const alive = Object.values(state.alive).filter(Boolean).length;
    console.log(`- ${strategy.title}: ${state.outcome.toUpperCase()} (${state.reason})`);
    console.log(`  recursos ${compactResources(state.resources)} | vivos ${alive} | intervenções ${state.interventions.length}`);
    console.log(`  incidentes ${state.incidentsSeen.map((entry) => entry.day).join(",") || "nenhum"} | dias eliminados ${state.skippedDays.join(",") || "nenhum"} | crises ${state.crises.length}`);
  }

  const byId = Object.fromEntries(results.map(([id, , result]) => [id, result.state]));
  const winners = Object.values(byId).filter((state) => state.outcome === "victory").length;
  const recoveryTypes = new Set(byId.recovery.interventions.map((entry) => entry.type));
  const problemIds = Object.keys(PROBLEMS);
  const prioritySchedules = orderedSelections(problemIds, 5).map(
    (schedule) => runStrategy(STRATEGIES.priority, schedule).state,
  );
  const checks = [
    ["mais de uma estratégia vence", winners >= 2],
    ["correção prioritária vence", byId.priority.outcome === "victory"],
    ["recuperação usa cuidado e socorro e vence", byId.recovery.outcome === "victory" && recoveryTypes.has("care") && recoveryTypes.has("rescue")],
    ["aceleração elimina dias e vence", byId.acceleration.outcome === "victory" && byId.acceleration.skippedDays.length > 0],
    ["omissão perde", byId.omission.outcome === "defeat"],
    ["correção prioritária vence nas 2.520 ordens", prioritySchedules.every((state) => state.outcome === "victory")],
  ];
  const robustWins = prioritySchedules.filter((state) => state.outcome === "victory").length;
  console.log(`\nROBUSTEZ: correção prioritária venceu ${robustWins}/${prioritySchedules.length} ordens possíveis.`);
  console.log("\nCRITÉRIOS");
  for (const [label, passed] of checks) console.log(`- ${label}: ${passed ? "OK" : "FALHOU"}`);
  const passed = checks.every(([, value]) => value);
  console.log(`\nBALANCE CHECK: ${passed ? "PASS" : "FAIL"}`);
  if (!passed) process.exitCode = 1;
}

function renderState(state) {
  if (output.isTTY) console.clear();
  console.log("\x1b[1mPROTÓTIPO DE BALANCEAMENTO — ISSUE #20\x1b[0m");
  console.log(`\x1b[1mDia\x1b[0m ${state.day}/10    \x1b[1mEstado\x1b[0m ${state.outcome}`);
  console.log(`\x1b[1mRecursos\x1b[0m ${compactResources(state.resources)}`);
  console.log(`\x1b[1mPolíticas\x1b[0m economia=${state.policies.economy} racionamento=${state.policies.rationing}`);
  console.log(`\x1b[1mSobreviventes\x1b[0m ${SURVIVORS.map((name) => `${name}:${state.alive[name] ? "vivo" : "morto"}`).join(" | ")}`);
  console.log(`\x1b[1mRiscos\x1b[0m ${state.risks.map((risk) => `${risk.name}:${risk.deadline}`).join(", ") || "nenhum"}`);
  console.log(`\x1b[1mProblemas\x1b[0m ${state.activeProblems.map((problem) => `${problem.id}:${problem.deadline}`).join(", ") || "nenhum"}`);
  console.log(`\x1b[1mIncidente pendente\x1b[0m ${state.pendingIncident ?? "nenhum"}`);
  console.log(`\n${state.lastMessage}`);
  console.log("\n\x1b[2m[segura] [arriscada] [reparar ID] [cuidar] [socorrer NOME] [potência]\x1b[0m");
  console.log("\x1b[2m[economia] [racionamento] [dormir] [tabela] [sair]\x1b[0m");
}

async function interactive() {
  const terminal = readline.createInterface({ input, output });
  let state = reduce(initialState(), { type: "begin" });
  while (state.outcome === "ongoing") {
    renderState(state);
    const line = (await terminal.question("> ")).trim();
    const [command, ...rest] = line.split(/\s+/);
    if (command === "sair") break;
    if (command === "segura") state = reduce(state, { type: "contain", choice: "safe" });
    else if (command === "arriscada") state = reduce(state, { type: "contain", choice: "risky" });
    else if (command === "reparar") state = reduce(state, { type: "repair", problem: rest.join(" ") });
    else if (command === "cuidar") state = reduce(state, { type: "care" });
    else if (command === "socorrer") state = reduce(state, { type: "rescue", name: rest.join(" ") });
    else if (command === "potência" || command === "potencia") state = reduce(state, { type: "boost" });
    else if (command === "economia") state = reduce(state, { type: "policy", policy: "economy" });
    else if (command === "racionamento") state = reduce(state, { type: "policy", policy: "rationing" });
    else if (command === "dormir") {
      state = reduce(state, { type: "sleep" });
      if (state.outcome === "ongoing") state = reduce(state, { type: "begin" });
    } else if (command === "tabela") printProblemTable();
    else state = reduce(state, { type: "unknown" });
  }
  renderState(state);
  terminal.close();
}

const isMain = process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;
if (isMain && process.argv.includes("--simulate")) simulateAll();
else if (isMain) await interactive();
