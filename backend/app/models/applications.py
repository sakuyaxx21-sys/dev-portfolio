from datetime import date, datetime

from sqlalchemy import Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.db.base import Base


class Application(Base):
    __tablename__ = "applications"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"), 
        nullable=False,
        index=True,
    )

    title: Mapped[str] = mapped_column(String, nullable=False)

    content: Mapped[str] = mapped_column(Text, nullable=False)

    amount: Mapped[int] = mapped_column(Integer, nullable=False)

    application_date: Mapped[date] = mapped_column(Date, nullable=False)

    status: Mapped[str] = mapped_column(
        String, 
        nullable=False, 
        default="pending",
        index=True,
    )

    reject_reason: Mapped[str | None] = mapped_column(Text, nullable=True)

    reviewd_by: Mapped[int | None] = mapped_column(
        ForeignKey("users.id"), 
        nullable=True,
    )

    reviewed_at: Mapped[datetime | None] = mapped_column(
        DateTime, 
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False, 
        server_default=func.now(),
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False, 
        server_default=func.now(),
        onupdate=func.now(),
    )