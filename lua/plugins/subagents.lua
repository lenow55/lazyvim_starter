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
                description = "Reviews code for bugs, style issues, and improvements",
                system_prompt = "You are an expert code reviewer. Analyze code for potential issues, suggest improvements, and provide constructive feedback.",
                tools = { "file_search", "get_changed_files", "grep_search", "read_file" },
                context_spec = "1) Background information of the changes or repo. 2) The code files to review.",
                result_spec = "A structured review with: issues found, severity, and suggestions",
                default_power = "high",
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
                mcp_servers = { "tavily", "github" },
                tools = { "fetch_webpage" },
                context_spec = "The question or topic to research",
                result_spec = [[A comprehensive research report that includes:
- A clear and concise answer to the research question
- Citations with links to sources (or file references for codebase research)
- Confidence levels for key claims (high/medium/low)
- Suggestions for further investigation if applicable]],
                default_power = "medium",
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
