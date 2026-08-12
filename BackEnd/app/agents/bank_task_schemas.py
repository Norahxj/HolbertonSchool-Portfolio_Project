from pydantic import BaseModel, Field


class SelectedBankTaskDecision(BaseModel):
    bank_id: str

    points: int = Field(
        ge=1,
        le=50,
    )

    reason: str = Field(
        min_length=10,
        max_length=250,
    )


class BankTaskSelectionDecision(BaseModel):
    tasks: list[SelectedBankTaskDecision]


class SelectedBankTask(BaseModel):
    bank_id: str

    title_en: str
    title_ar: str

    description_en: str
    description_ar: str

    category: str

    points: int = Field(
        ge=1,
        le=50,
    )

    frequency: str

    reason: str = Field(
        min_length=10,
        max_length=250,
    )


class BankTaskSelection(BaseModel):
    tasks: list[SelectedBankTask]