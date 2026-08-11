from typing import Literal

from pydantic import BaseModel, Field


class SelectedBankTask(BaseModel):
    bank_id: str

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

    reason: str = Field(
        min_length=10,
        max_length=500,
    )


class BankTaskSelection(BaseModel):
    tasks: list[SelectedBankTask]