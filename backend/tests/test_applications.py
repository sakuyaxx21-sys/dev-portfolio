from datetime import date

from app.core.security import create_access_token, get_password_hash
from app.models.applications import Application
from app.models.users import User
from tests.conftest import TestingSessionLocal


def create_test_user(
    email: str,
    role: str = "user",
    name: str = "Test User",
) -> User:
    db = TestingSessionLocal()
    try:
        user = User(
            name=name,
            email=email,
            hashed_password=get_password_hash("password123"),
            role=role,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    finally:
        db.close()


def auth_headers(email: str) -> dict[str, str]:
    token = create_access_token(email)
    return {"Authorization": f"Bearer {token}"}


def create_application(
    client,
    email: str,
    title: str,
) -> dict:
    response = client.post(
        "/api/v1/applications",
        headers=auth_headers(email),
        json={
            "title": title,
            "content": f"{title} content",
            "amount": 1000,
            "application_date": str(date(2026, 4, 1)),
        },
    )
    assert response.status_code == 200
    return response.json()


def update_application_status(application_id: int, status: str) -> None:
    db = TestingSessionLocal()
    try:
        application = (
            db.query(Application)
            .filter(Application.id == application_id)
            .first()
        )
        assert application is not None
        application.status = status
        db.commit()
    finally:
        db.close()


def test_get_my_applications_returns_paginated_response(client):
    user = create_test_user("pagination_user@example.com")
    for index in range(5):
        create_application(client, user.email, f"My Application {index}")

    response = client.get(
        "/api/v1/applications/me?page=2&limit=2",
        headers=auth_headers(user.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 2
    assert data["total"] == 5
    assert data["page"] == 2
    assert data["limit"] == 2
    assert data["total_pages"] == 3


def test_get_my_applications_only_returns_current_user_items(client):
    current_user = create_test_user("current_user@example.com")
    other_user = create_test_user("other_user@example.com")
    create_application(client, current_user.email, "Current User Application")
    create_application(client, other_user.email, "Other User Application")

    response = client.get(
        "/api/v1/applications/me",
        headers=auth_headers(current_user.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 1
    assert data["items"][0]["title"] == "Current User Application"


def test_admin_applications_returns_paginated_response(client):
    admin = create_test_user(
        "pagination_admin@example.com",
        role="admin",
        name="Pagination Admin",
    )
    user = create_test_user("admin_pagination_user@example.com")
    for index in range(3):
        create_application(client, user.email, f"Admin Application {index}")

    response = client.get(
        "/api/v1/admin/applications?page=1&limit=2",
        headers=auth_headers(admin.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 2
    assert data["total"] == 3
    assert data["page"] == 1
    assert data["limit"] == 2
    assert data["total_pages"] == 2


def test_admin_applications_paginates_after_filters(client):
    admin = create_test_user(
        "filter_admin@example.com",
        role="admin",
        name="Filter Admin",
    )
    user = create_test_user("filter_user@example.com")
    pending_application = create_application(
        client,
        user.email,
        "Pending Expense",
    )
    approved_application = create_application(
        client,
        user.email,
        "Approved Expense",
    )
    update_application_status(approved_application["id"], "approved")

    response = client.get(
        "/api/v1/admin/applications?status=pending&page=1&limit=10",
        headers=auth_headers(admin.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 1
    assert data["total_pages"] == 1
    assert data["items"][0]["id"] == pending_application["id"]
    assert data["items"][0]["status"] == "pending"


def test_applications_limit_has_upper_bound(client):
    user = create_test_user("limit_user@example.com")

    response = client.get(
        "/api/v1/applications/me?page=1&limit=101",
        headers=auth_headers(user.email),
    )

    assert response.status_code == 422
