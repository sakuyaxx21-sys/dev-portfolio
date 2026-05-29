from pathlib import Path
import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

BASE_DIR = Path(__file__).resolve().parent.parent
TEST_DB_PATH = BASE_DIR / "pytest.db"
SQLALCHEMY_DATABASE_URL = f"sqlite:///{TEST_DB_PATH}"

# Set the test database before importing app settings and the engine.
os.environ["DATABASE_URL"] = SQLALCHEMY_DATABASE_URL

from app.db.base import Base  # noqa: E402
from app.db.session import get_db  # noqa: E402
from app.db import models  # noqa: F401, E402
from app.main import app  # noqa: E402


engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture()
def client():
    app.dependency_overrides[get_db] = override_get_db

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()


@pytest.fixture(autouse=True)
def reset_test_database():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    yield

    Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="session", autouse=True)
def cleanup_test_db_file():
    yield

    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()
