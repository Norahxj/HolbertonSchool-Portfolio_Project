from typing import Literal

from pydantic import BaseModel, Field


class PlannedTask(BaseModel):
    source: Literal[
        "TASK_BANK",
        "AI_GENERATED",
    ]

    bank_id: str | None = None

    title_en: str
    title_ar: str

    description_en: str
    description_ar: str

    category: Literal[
        "RELIGIOUS",
        "FINANCIAL",
        "MORAL",
        "SOCIAL",
    ]

    points: int = Field(
        ge=1,
        le=50,
    )

    frequency: Literal[
        "ONCE",
        "DAILY",
        "WEEKLY",
        "MONTHLY",
    ]

    reason: str


class WeeklyPlanDraft(BaseModel):
    summary_en: str = Field(
        min_length=10,
        max_length=500,
    )

    summary_ar: str = Field(
        min_length=10,
        max_length=500,
    )

    total_tasks: int = Field(
        ge=3,
        le=7,
    )

    weekly_points: int = Field(
        ge=1,
        le=500,
    )

    is_cold_start: bool

    tasks: list[PlannedTask]