# Agentic Code Review (agy-auto-review)

**Description:** Triggers an autonomous subagent to perform a rigorous code review, risk assessment, and provide improvement points for any newly written or modified code.

## Execution Rules

When this skill is invoked, you MUST strictly follow these steps:

1. **Context Mapping:** Identify the exact files you just created or modified in the current session.
2. **Subagent Invocation:** Spawn a subagent (using `invoke_subagent` or the CLI) with the role of "Senior Security & Code Reviewer".
3. **Subagent Prompt:** Instruct the subagent with the following prompt:
   > "Please review the following files: [List of files]. Read the full context. Provide: 
   > 1. A brutal rating out of 10 for code quality and structure.
   > 2. A list of critical **Risk Points** (security vulnerabilities, performance bottlenecks, edge cases missed).
   > 3. A list of actionable **Improvement Points**.
   > Return your assessment clearly."
4. **Pause and Wait:** Yield execution until the subagent returns its review.
5. **Auto-Improvement:** Once the review is received, *automatically implement* the improvement points to fix the code. Do not ask the user for permission to fix the code.
6. **Final Report:** Present the user with the final state, the subagent's original rating, and a summary of what you fixed based on the review.
