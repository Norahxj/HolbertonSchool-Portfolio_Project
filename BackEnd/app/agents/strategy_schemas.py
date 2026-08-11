from typing import Literal

from pydantic import BaseModel, Field


class CategoryDistribution(BaseModel):
    RELIGIOUS: int = Field(ge=0, le=7)
    FINANCIAL: int = Field(ge=0, le=7)
    MORAL: int = Field(ge=0, le=7)
    SOCIAL: int = Field(ge=0, le=7)


class WeeklyPlanStrategy(BaseModel):
    total_tasks: int = Field(
        ge=3,
        le=7,
    )

    bank_tasks: int = Field(
        ge=0,
        le=7,
    )

    generated_tasks: int = Field(
        ge=0,
        le=7,
    )

    category_distribution: CategoryDistribution

    focus: str = Field(
        min_length=10,
        max_length=500,
    )

    avoid: list[str]

    strategy_reasoning: str = Field(
        min_length=10,
        max_length=1000,
    )