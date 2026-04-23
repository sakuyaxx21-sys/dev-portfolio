from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field


class ApplicationCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    content: str = Field(min_length=1, max_length=2000)
    amount: int = Field(gt=0)
    application_date: date


class ApplicationStatusUpdate(BaseModel):
    status: str
    reject_reason: str | None = None


class ApplicationResponse(BaseModel):
    id: int
    user_id: int
    title: str
    content: str
    amount: int
    application_date: date
    status: str
    reject_reason: str | None
    reviewd_by: int | None
    reviewed_at: datetime | None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)