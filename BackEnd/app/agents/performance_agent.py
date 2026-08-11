import json
import os

from dotenv import load_dotenv
from langchain_openrouter import ChatOpenRouter

from app.agents.performance_schemas import (
    ChildPerformanceAnalysis,
)


load_dotenv()


class PerformanceAgent:
    def __init__(self):
        api_key = os.getenv("OPENROUTER_API_KEY")
        model_name = os.getenv("OPENROUTER_MODEL")

        if not api_key:
            raise ValueError("OPENROUTER_API_KEY is missing")

        if not model_name:
            raise ValueError("OPENROUTER_MODEL is missing")

        self.llm = ChatOpenRouter(
            model=model_name,
            api_key=api_key,
        )

        self.structured_llm = self.llm.with_structured_output(
            ChildPerformanceAnalysis,
            include_raw=True,
        )

    def analyze(self, child_context):
        prompt = self._build_prompt(child_context)

        response = self.structured_llm.invoke(prompt)

        print("\n=== RAW RESPONSE ===")
        print(response.get("raw"))

        print("\n=== PARSED RESPONSE ===")
        print(response.get("parsed"))

        print("\n=== PARSING ERROR ===")
        print(response.get("parsing_error"))

        result = response.get("parsed")

        if result is None:
            raise ValueError(
            "PerformanceAgent failed to return structured output."
            )

        result.is_cold_start = not (
            child_context
        .get("history_summary", {})
        .get("has_enough_history", False)
        )

        return result

    def _build_prompt(self, child_context):
        context_json = json.dumps(
            child_context,
            ensure_ascii=False,
            indent=2,
            default=str,
        )

        return f"""
You are the Performance Analysis Agent for Asalah.

Your only responsibility is to analyze the child's
historical performance and recommend an appropriate
weekly workload.

You MUST NOT create or suggest any tasks.

CHILD DATA:
{context_json}

Analyze:

- the child's age
- overall task completion
- rejected tasks
- pending tasks
- performance across categories
- previous task points
- points history
- active wishlist goals

If history_summary.has_enough_history is false:

- treat the child as a cold-start case
- do not invent strengths or weaknesses
- recommend a small and manageable starter workload

Determine:

1. Overall performance level:
   LOW, MODERATE, or HIGH.

2. Recommended number of tasks for the next week.

3. Recommended total achievable weekly points.

4. Difficulty level:
   LOW, MEDIUM, or HIGH.

5. Strong categories based only on evidence.

6. Weak categories based only on evidence.

7. A concise explanation of your analysis.

General guidance:

- Children with low completion should receive fewer
  and easier tasks.

- Children with consistently strong completion may
  receive slightly more tasks.

- Do not overload the child simply to reach a wishlist
  goal faster.

- Do not invent facts about the child.

Important interpretation rules:

- total_earned and total_spent are historical totals.
  Never interpret them as weekly or monthly values unless
  the child data explicitly provides a time period.

- A weak category does NOT automatically mean it should
  be avoided.

- Weak categories usually need gradual improvement using
  easier or more suitable tasks.

- Recommend avoiding a category entirely only when there
  is strong evidence that including it would be inappropriate.

- Do not infer behavioral causes from statistics alone.
  A rejected task does not prove why the child rejected it.

Return only the required structured analysis.
"""