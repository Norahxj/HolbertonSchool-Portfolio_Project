from typing import Literal

from pydantic import BaseModel, Field


class PlanIssue(BaseModel):
    issue_type: Literal[
        "PERFORMANCE",
        "STRATEGY",
        "BANK",
        "CREATIVE",
        "PLANNER",
    ]

    description: str = Field(
        min_length=5,
        max_length=250,
    )

    severity: Literal[
        "MEDIUM",
        "HIGH",
    ]


class PlanEvaluation(BaseModel):
    score: int = Field(
        ge=1,
        le=10,
    )

    approved: bool

    issues: list[PlanIssue]

    feedback: str = Field(
        min_length=5,
        max_length=400,
    )