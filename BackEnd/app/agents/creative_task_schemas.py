from typing import Literal

from pydantic import BaseModel, Field


class GeneratedTask(BaseModel):
    title_en: str = Field(
        min_length=3,
        max_length=150,
    )

    title_ar: str = Field(
        min_length=3,
        max_length=150,
    )

    description_en: str = Field(
        min_length=5,
        max_length=500,
    )

    description_ar: str = Field(
        min_length=5,
        max_length=500,
    )

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

    reason: str = Field(
        min_length=10,
        max_length=500,
    )


class GeneratedTaskSelection(BaseModel):
    tasks: list[GeneratedTask]