# Multi-Agent Brainstorm Swarm (agy-brainstorm)

**Description:** Coordinates a multi-agent debate and critique swarm to solve complex architectural challenges, design systems, or deep debugging issues before any code is modified.

## 1. Activation Trigger
Invoke this skill when:
- Designing a new module, API interface, or system architecture.
- Refactoring complex, state-heavy, or concurrent components.
- Fixing transient, multi-component, or highly complex bugs (e.g., race conditions, memory leaks, synchronization bottlenecks).
- Explicitly requested by the user or outlined as a precursor step in an execution plan.

---

## 2. The 4-Phase Swarm Debate Protocol
You MUST execute the brainstorm swarm using the following structured phases:

### Phase 1: Swarm Assembly & Target Scoping
1. **Dynamic Persona Selection:** Spawn 2 to 4 subagents concurrently using the `invoke_subagent` tool. Assign each a distinct, specialized persona customized to the problem. Define their roles using the following schema:
   - **Title**: A professional title (e.g., *Principal Architect*, *CSO / Security Auditor*, *Devil's Advocate / QA Lead*, *Performance Engineer*).
   - **Objective**: The primary goal this subagent must achieve.
   - **Cognitive Bias**: The specific lens or skeptical attitude they must adopt.
   - **Scope of Inspection**: Specific files or directories they are responsible for.
   - **Anti-Goals**: What they must explicitly ignore to prevent duplication of effort.
2. **Context Isolation:** Identify target files and directories. Do NOT send the entire codebase context to every subagent. Scopes must be role-pruned (e.g., feed the Security Auditor security-sensitive boundaries, feed the Performance Engineer profiling configs or loops).

### Phase 2: Core Proposal Draft
1. Prompt the primary technical lead role (usually *Principal Architect*) to draft a core proposal based on the requirements.
2. Concurrently, prompt the other specialist roles to identify domain-specific constraints, edge cases, and standards that the solution must adhere to.
3. Pause and wait for all Phase 2 responses to compile.

### Phase 3: The Cross-Critique Debate Loop
1. Distribute the *Principal Architect's* draft solution to the other subagents.
2. Instruct the *Devil's Advocate* to find at least 3 concrete failure scenarios, race conditions, or edge cases in the draft.
3. Instruct the other domain specialists to audit the draft solution against their specialties (e.g., security vulnerabilities, memory leak vectors, scaling bottlenecks).
4. Pause and wait for all critiques.

### Phase 4: Resolution & Synthesis (Master Plan Compilation)
1. Feed all critiques back to the *Principal Architect*.
2. Instruct the *Principal Architect* to revise the design to mitigate the identified risks and compile the final **Master Plan**.
3. Reconcile conflicts (e.g., Performance optimizations vs. Security boundaries) using a structured trade-off matrix.

---

## 3. Subagent Prompt & Output Constraints
For each subagent, construct a highly structured prompt. You MUST inject the following prompt template and constraints into their instruction:

```markdown
You are acting as the **[Role Title]** subagent in a brainstorming swarm.
Your objective: [Role Objective]
Your cognitive bias: [Role Cognitive Bias]

### Codebase Context
- **Files under inspection**: [Inject specific absolute file paths and line ranges]
- **Target environment**: [Language, frameworks, package managers]
- **Dependencies**: [List relevant dependencies from package files]

### Task
[Inject clear description of the feature to add, the bug to fix, or the design decision to make]

### Output Constraints
You MUST structure your response using the following XML tags exactly. Do not omit any sections:

<thinking>
Write your step-by-step Chain of Thought analysis. Identify assumptions, trace code execution paths, and brainstorm edge cases.
</thinking>

<references>
List all files, line numbers, and API symbols you read or verified in the codebase to construct your response.
</references>

<critique>
State the flaws, limitations, or risks of the proposed change or the existing implementation from your persona's perspective.
</critique>

<proposal>
Provide your concrete recommendations. Any proposed code must be complete, syntactically correct, and density-focused (referencing specific files and lines). Avoid placeholders like "// TODO" or "// logic here".
</proposal>

<verification_checklist>
Attest to the existence of all methods, imports, and variables proposed. Write:
- [ ] Checked: [Method name/dependency] exists in [file/docs]
Only check off items that you have explicitly verified.
</verification_checklist>
```

---

## 4. Synthesis Validation & UX Reporting Template
Read and validate all subagent responses. Reject or re-run any subagent providing low-density or generic feedback. Format the final output to the user using this template:

````markdown
# 🧠 Brainstorm Swarm Report: [Feature/Problem Name]
*A synthesis of specialized agent perspectives to establish a bulletproof execution plan.*

> [!NOTE]
> **Executive Summary:** A brief 2-3 sentence overview of the chosen architectural direction and why it was selected over alternatives.

---

## ⚔️ The Swarm Debate
Below is a matrix summarizing the core tensions, tradeoffs, and consensus reached by the assembled subagents.

| Specialist Role | Core Perspective / Stance | Key Recommendation / Constraint |
| :--- | :--- | :--- |
| **Architect** | *e.g., Standardize on modular interfaces* | *e.g., Avoid tight coupling in module X* |
| **Security** | *e.g., Input validation boundaries* | *e.g., Sanitize inputs at API layer* |
| **Devil's Advocate** | *e.g., Stressed scaling bottlenecks* | *e.g., Use redis/caching for high-load* |
| **Performance** | *e.g., Memory allocations in hot path* | *e.g., Avoid clone/copy in loops* |

<details>
<summary>🔍 View Detailed Perspectives (Raw Arguments)</summary>

### 📐 Principal Architect
*Detailed architectural notes...*

### 🛡️ Security Auditor
*Detailed security concerns...*

### 😈 Devil's Advocate
*Detailed edge cases and failure modes...*

### ⚡ Performance Engineer
*Detailed profiling and resource recommendations...*
</details>

---

## 🗺️ The Master Plan (Incremental & Verifiable)
To minimize risk and ensure stability, we will execute the plan in small, testable phases.

- [ ] **Phase 1: Foundation & Interface Definition**
  - **Scope:** Define traits, interfaces, and minimal type stubs.
  - **Verification:** Run `cargo test` / `npm run test` / `pytest` to verify compilability.
- [ ] **Phase 2: Core Logic & Edge Cases**
  - **Scope:** Implement primary business logic, integrating security sanitization.
  - **Verification:** Run unit tests for boundary conditions.
- [ ] **Phase 3: Integration & Optimization**
  - **Scope:** Wire up modules, apply performance optimizations.
  - **Verification:** Run end-to-end suite and performance benchmarks.

> [!WARNING]
> **Key Risk / Compromise:** [Describe the most significant trade-off, e.g., "Performance was prioritized over absolute configuration flexibility in module Y. Changes here will require custom rebuilds."]

---

## 🚦 Next Steps & Interaction Options
Please review the proposed plan. You can:
1. **Approve & Proceed:** Type "Proceed" to begin execution of Phase 1.
2. **Refine / Deep-Dive:** Ask specific questions about any phase or specialist's recommendation.
3. **Interactive Alignment:** Run the `/grill-me` command to co-design the system details interactively.
````

---

## 5. Downstream Skill Linkages
- **Spec Generation:** Pass the Master Plan to `gstack-spec.md` to finalize the API surface.
- **Task Planning:** Use `gstack-plan-eng-review.md` to break the Master Plan down into atomic tasks.
- **Verification:** When running code reviews via `agy-auto-review.md`, supply the review agent with the Master Plan and explicitly check if all critiques raised in Phase 3 are successfully addressed in the final code.
