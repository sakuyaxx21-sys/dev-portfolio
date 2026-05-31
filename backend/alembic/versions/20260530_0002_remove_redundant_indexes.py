"""remove redundant primary key indexes

Revision ID: 20260530_0002
Revises: 20260518_0001
Create Date: 2026-05-30 00:00:00.000000

"""

from typing import Sequence, Union

from alembic import op


revision: str = "20260530_0002"
down_revision: Union[str, None] = "20260518_0001"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_index(op.f("ix_applications_id"), table_name="applications")
    op.drop_index(op.f("ix_users_id"), table_name="users")

    op.drop_index(op.f("ix_users_email"), table_name="users")
    op.create_unique_constraint(op.f("uq_users_email"), "users", ["email"])


def downgrade() -> None:
    op.drop_constraint(op.f("uq_users_email"), "users", type_="unique")
    op.create_index(op.f("ix_users_email"), "users", ["email"], unique=True)

    op.create_index(
        op.f("ix_users_id"),
        "users",
        ["id"],
        unique=False,
    )
    op.create_index(
        op.f("ix_applications_id"),
        "applications",
        ["id"],
        unique=False,
    )
