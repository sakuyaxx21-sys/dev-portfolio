# Import models so Alembic and metadata creation register every table.
from app.models.users import User  # noqa: F401
from app.models.applications import Application  # noqa: F401
