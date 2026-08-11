from langgraph.graph import END, START, StateGraph

from app.agents.bank_agent import BankAgent
from app.agents.creative_agent import CreativeAgent
from app.agents.evaluator_agent import EvaluatorAgent
from app.agents.performance_agent import PerformanceAgent
from app.agents.planner_agent import PlannerAgent
from app.agents.strategy_agent import StrategyAgent
from app.agents.weekly_plan_state import WeeklyPlanState


class WeeklyPlanWorkflow:
    def __init__(self):
        self.performance_agent = PerformanceAgent()
        self.strategy_agent = StrategyAgent()
        self.bank_agent = BankAgent()
        self.creative_agent = CreativeAgent()
        self.planner_agent = PlannerAgent()
        self.evaluator_agent = EvaluatorAgent()

        self.graph = self._build_graph()

    def _build_graph(self):
        builder = StateGraph(WeeklyPlanState)

        # -----------------------------------
        # Nodes
        # -----------------------------------

        builder.add_node(
            "performance",
            self._performance_node,
        )

        builder.add_node(
            "strategy",
            self._strategy_node,
        )

        builder.add_node(
            "bank",
            self._bank_node,
        )

        builder.add_node(
            "creative",
            self._creative_node,
        )

        builder.add_node(
            "planner",
            self._planner_node,
        )

        builder.add_node(
            "evaluator",
            self._evaluator_node,
        )

        # -----------------------------------
        # Normal forward flow
        # -----------------------------------

        builder.add_edge(
            START,
            "performance",
        )

        builder.add_edge(
            "performance",
            "strategy",
        )

        builder.add_edge(
            "strategy",
            "bank",
        )

        builder.add_edge(
            "bank",
            "creative",
        )

        builder.add_edge(
            "creative",
            "planner",
        )

        builder.add_edge(
            "planner",
            "evaluator",
        )

        # -----------------------------------
        # Evaluation routing
        # -----------------------------------

        builder.add_conditional_edges(
            "evaluator",
            self._route_after_evaluation,
            {
                "approved": END,
                "max_revisions": END,
                "performance": "performance",
                "strategy": "strategy",
                "bank": "bank",
                "creative": "creative",
                "planner": "planner",
            },
        )

        return builder.compile()

    # ==========================================================
    # Nodes
    # ==========================================================

    def _performance_node(
        self,
        state: WeeklyPlanState,
    ):
        result = self.performance_agent.analyze(
            state["child_context"]
        )

        return {
            "performance_analysis": result,
        }

    def _strategy_node(
        self,
        state: WeeklyPlanState,
    ):
        result = self.strategy_agent.create_strategy(
            state["child_context"],
            state["performance_analysis"],
        )

        return {
            "strategy": result,
        }

    def _bank_node(
        self,
        state: WeeklyPlanState,
    ):
        result = self.bank_agent.select_tasks(
            state["child_context"],
            state["performance_analysis"],
            state["strategy"],
        )

        return {
            "bank_selection": result,
        }

    def _creative_node(
        self,
        state: WeeklyPlanState,
    ):
        result = self.creative_agent.generate_tasks(
            state["child_context"],
            state["performance_analysis"],
            state["strategy"],
            state["bank_selection"],
        )

        return {
            "creative_selection": result,
        }

    def _planner_node(
        self,
        state: WeeklyPlanState,
    ):
        result = self.planner_agent.build_plan(
            state["child_context"],
            state["performance_analysis"],
            state["strategy"],
            state["bank_selection"],
            state["creative_selection"],
        )

        return {
            "plan": result,
        }

    def _evaluator_node(
        self,
        state: WeeklyPlanState,
    ):
        result = self.evaluator_agent.evaluate(
            state["child_context"],
            state["performance_analysis"],
            state["strategy"],
            state["bank_selection"],
            state["creative_selection"],
            state["plan"],
        )

        revision_count = state.get(
            "revision_count",
            0,
        )

        if not result.approved:
            revision_count += 1

        return {
            "evaluation": result,
            "revision_count": revision_count,
        }

    # ==========================================================
    # Conditional routing
    # ==========================================================

    def _route_after_evaluation(
        self,
        state: WeeklyPlanState,
    ):
        evaluation = state["evaluation"]

        # -----------------------------------
        # Plan accepted
        # -----------------------------------

        if evaluation.approved:
            return "approved"

        # -----------------------------------
        # Stop infinite revision loops
        # -----------------------------------

        revision_count = state.get(
            "revision_count",
            0,
        )

        max_revisions = state.get(
            "max_revisions",
            3,
        )

        if revision_count >= max_revisions:
            return "max_revisions"

        # -----------------------------------
        # No explicit issue
        # -----------------------------------

        if not evaluation.issues:
            return "strategy"

        # -----------------------------------
        # Find the most important issue
        # -----------------------------------

        severity_priority = {
            "HIGH": 3,
            "MEDIUM": 2,
            "LOW": 1,
        }

        ownership_priority = {
            "PERFORMANCE": 5,
            "STRATEGY": 4,
            "BANK": 3,
            "CREATIVE": 2,
            "PLANNER": 1,
        }

        most_important_issue = max(
            evaluation.issues,
            key=lambda issue: (
                severity_priority.get(
                    issue.severity,
                    0,
                ),
                ownership_priority.get(
                    issue.issue_type,
                    0,
                ),
            ),
        )

        issue_type = (
            most_important_issue
            .issue_type
        )

        # -----------------------------------
        # Route to responsible agent
        # -----------------------------------

        if issue_type == "PERFORMANCE":
            return "performance"

        if issue_type == "STRATEGY":
            return "strategy"

        if issue_type == "BANK":
            return "bank"

        if issue_type == "CREATIVE":
            return "creative"

        if issue_type == "PLANNER":
            return "planner"

        # Defensive fallback
        return "strategy"

    # ==========================================================
    # Public API
    # ==========================================================

    def generate(
        self,
        child_context,
        max_revisions=3,
    ):
        initial_state = {
            "child_context": child_context,
            "revision_count": 0,
            "max_revisions": max_revisions,
        }

        result = self.graph.invoke(
            initial_state
        )

        return result