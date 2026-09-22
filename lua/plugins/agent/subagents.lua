if true then
  return {}
end

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      extensions = {
        subagents = {
          enabled = true,
          opts = {
            powers = {
              xhigh = {
                adapter = { name = "dks_ultra", model = "DeepSeek-V4.1-Flash" },
              },
              high = {
                adapter = { name = "dks_ultra", model = "GLM-5.3-Flash" },
              },
              medium = {
                adapter = { name = "local_landev", model = "local/Qwen/Qwen3.8-27B-FP8" },
              },
              low = {
                adapter = { name = "local_landev", model = "local/google/gemma-4-31B-it" },
              },
            },
            subagents = {
              generic = {
                description = "A general-purpose subagent that you can delegate a task to. It sees all your previous messages so you don't need to repeat the whole context.",
                tools = "inherit",
                mcp_servers = "inherit",
                context_mode = "inherit",
                result_spec = "A brief summary of what you have done, or errors/exceptions encountered that prevented you from completing the task.",
              },
              code_reviewer = {
                description = [[Senior Code Reviewer. Reviews a git range (BASE_SHA..HEAD_SHA) against its plan/requirements.
Use after each task, after a major feature, before merging to main, when stuck, or after a complex bugfix.
Read-only; never dispatches subagents. Follows the requesting-code-review template.]],
                system_prompt = [[You are a Senior Code Reviewer.

Your task carries the complete, filled-in code review template (from the requesting-code-review skill): it defines WHAT to check, HOW to calibrate severity, and the EXACT output format. Follow that template — do not restructure it or add your own sections.

Hard constraints (in addition to the template):
- Read-only checkout. Inspect history via shell: `git diff --stat BASE..HEAD`, `git diff BASE..HEAD`, `git show`, `git log`. Never mutate the working tree, index, HEAD, or branch state. If you need another revision, `git worktree add /tmp/review-<sha> <sha>` — never move HEAD.
- Read real code (file_read, grep_search, file_search) before judging. Never report on code you did not actually read.
- Do the entire review yourself; if the diff is large, work in passes and say so. Never dispatch a subagent or a second reviewer.]],
                tools = {
                  "git",
                  "read_file",
                  "grep_search",
                  "file_search",
                  "agent_skills",
                  "get_changed_files",
                  "get_diagnostics",
                },
                context_mode = "explicit",
                context_spec = [[The COMPLETE, filled-in code review template from the requesting-code-review skill, with every placeholder already substituted by you:
- DESCRIPTION (what was implemented)
- PLAN_OR_REQUIREMENTS (what it should do)
- BASE_SHA (starting commit, e.g. `git merge-base origin/main HEAD`)
- HEAD_SHA (ending commit, e.g. `git rev-parse HEAD`)
Plus any repo-specific background not obvious from the diff. Never pass session history.]],
                result_spec = [[A structured review exactly as the template's Output Format:
- Strengths (specific, file:line)
- Issues by severity — Critical / Important / Minor — each with File:line, what's wrong, why it matters, how to fix
- "Declined to judge": one line per set-aside behavior with reason, or "none"
- Recommendations
- Assessment: "Ready to merge: Yes | No | With fixes" + 1-2 sentence reasoning]],
              },
              web_researcher = {
                description = [[Searches the web to answer specific questions.
Use this subagent when you need to research topics, find current information, or investigate technical issues online.
Returns a comprehensive report with citations.]],
                system_prompt = [[You are a research specialist focused on web search and information synthesis.

Your workflow:
1. **Understand**: Peform a basic search to understand the question and gather background information.
2. **Plan**: Create a research plan outlining the key topics to investigate.
3. **Gather**: For each topic, perform targeted web searches to find relevant information, data, and sources.
4. **Synthesize**: Compile the research findings into a comprehensive report that directly answers the original question, including citations for all sources used.
]],
                mcp_servers = {},
                tools = { "tavily", "agent_skills", "github" },
                context_spec = "The question or topic to research",
                result_spec = [[A comprehensive research report that includes:
- A clear and concise answer to the research question
- Citations with links to sources (or file references for codebase research)
- Confidence levels for key claims (high/medium/low)
- Suggestions for further investigation if applicable]],
              },
            },
          },
        },
      },
    },
    dependencies = {
      "cairijun/codecompanion-subagents.nvim",
    },
  },
}
