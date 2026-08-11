from typing import Literal

from pydantic import BaseModel, Field


class ChildPerformanceAnalysis(BaseModel):
    performance_level: Literal[
        "LOW",
        "MODERATE",
        "HIGH",
    ]

    recommended_task_count: int = Field(
        ge=3,
        le=7,
    )

    recommended_weekly_points: int = Field(
        ge=40,
        le=120,
    )

    difficulty_level: Literal[
        "LOW",
        "MEDIUM",
        "HIGH",
    ]

    strong_categories: list[
        Literal[
            "RELIGIOUS",
            "FINANCIAL",
            "MORAL",
            "SOCIAL",
        ]
    ]

    weak_categories: list[
        Literal[
            "RELIGIOUS",
            "FINANCIAL",
            "MORAL",
            "SOCIAL",
        ]
    ]

    is_cold_start: bool

    analysis: str = Field(
        min_length=10,
        max_length=1000,
    )