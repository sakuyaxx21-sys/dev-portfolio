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
            db.query(Application).filter(Application.id == application_id).first()
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


def test_get_my_applications_empty_list_returns_one_total_page(client):
    user = create_test_user("empty_pagination_user@example.com")

    response = client.get(
        "/api/v1/applications/me",
        headers=auth_headers(user.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert data["items"] == []
    assert data["total"] == 0
    assert data["page"] == 1
    assert data["limit"] == 10
    assert data["total_pages"] == 1


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


def test_get_my_applications_requires_authorization_header(client):
    response = client.get("/api/v1/applications/me")

    assert response.status_code == 401
    assert response.json() == {"detail": "Authorization header is missing"}


def test_create_application_sets_initial_review_fields(client):
    user = create_test_user("create_application_user@example.com")

    response = client.post(
        "/api/v1/applications",
        headers=auth_headers(user.email),
        json={
            "title": "Initial Application",
            "content": "Initial Application content",
            "amount": 1000,
            "application_date": str(date(2026, 4, 1)),
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["user_id"] == user.id
    assert data["status"] == "pending"
    assert data["reject_reason"] is None
    assert data["reviewed_by"] is None
    assert data["reviewed_at"] is None


def test_create_application_requires_authorization_header(client):
    response = client.post(
        "/api/v1/applications",
        json={
            "title": "Unauthorized Application",
            "content": "Unauthorized Application content",
            "amount": 1000,
            "application_date": str(date(2026, 4, 1)),
        },
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "Authorization header is missing"}


def test_create_application_rejects_invalid_payload(client):
    user = create_test_user("invalid_application_payload_user@example.com")

    invalid_payloads = [
        {
            "title": "",
            "content": "Valid content",
            "amount": 1000,
            "application_date": str(date(2026, 4, 1)),
        },
        {
            "title": "Valid title",
            "content": "",
            "amount": 1000,
            "application_date": str(date(2026, 4, 1)),
        },
        {
            "title": "Valid title",
            "content": "Valid content",
            "amount": 0,
            "application_date": str(date(2026, 4, 1)),
        },
        {
            "title": "Valid title",
            "content": "Valid content",
            "amount": 1000,
            "application_date": "invalid-date",
        },
    ]

    for payload in invalid_payloads:
        response = client.post(
            "/api/v1/applications",
            headers=auth_headers(user.email),
            json=payload,
        )

        assert response.status_code == 422


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


def test_admin_applications_empty_list_returns_one_total_page(client):
    admin = create_test_user(
        "empty_admin_pagination@example.com",
        role="admin",
        name="Empty Admin Pagination",
    )

    response = client.get(
        "/api/v1/admin/applications",
        headers=auth_headers(admin.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert data["items"] == []
    assert data["total"] == 0
    assert data["page"] == 1
    assert data["limit"] == 10
    assert data["total_pages"] == 1


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


def test_admin_applications_filters_by_user_id(client):
    admin = create_test_user(
        "user_filter_admin@example.com",
        role="admin",
        name="User Filter Admin",
    )
    target_user = create_test_user("target_filter_user@example.com")
    other_user = create_test_user("other_filter_user@example.com")
    target_application = create_application(
        client,
        target_user.email,
        "Target User Application",
    )
    create_application(client, other_user.email, "Other User Application")

    response = client.get(
        f"/api/v1/admin/applications?user_id={target_user.id}",
        headers=auth_headers(admin.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 1
    assert data["items"][0]["id"] == target_application["id"]
    assert data["items"][0]["user_id"] == target_user.id


def test_admin_applications_filters_by_keyword(client):
    admin = create_test_user(
        "keyword_filter_admin@example.com",
        role="admin",
        name="Keyword Filter Admin",
    )
    user = create_test_user("keyword_filter_user@example.com")
    matching_application = create_application(
        client,
        user.email,
        "Taxi Expense",
    )
    create_application(client, user.email, "Train Expense")

    response = client.get(
        "/api/v1/admin/applications?keyword=Taxi",
        headers=auth_headers(admin.email),
    )

    assert response.status_code == 200
    data = response.json()
    assert data["total"] == 1
    assert data["items"][0]["id"] == matching_application["id"]
    assert data["items"][0]["title"] == "Taxi Expense"


def test_admin_applications_rejects_non_admin_user(client):
    user = create_test_user("non_admin_list_user@example.com")

    response = client.get(
        "/api/v1/admin/applications",
        headers=auth_headers(user.email),
    )

    assert response.status_code == 403
    assert response.json() == {"detail": "Permission denied"}


def test_admin_applications_requires_authorization_header(client):
    response = client.get("/api/v1/admin/applications")

    assert response.status_code == 401
    assert response.json() == {"detail": "Authorization header is missing"}


def test_admin_applications_limit_has_upper_bound(client):
    admin = create_test_user(
        "admin_limit_user@example.com",
        role="admin",
        name="Admin Limit User",
    )

    response = client.get(
        "/api/v1/admin/applications?page=1&limit=101",
        headers=auth_headers(admin.email),
    )

    assert response.status_code == 422


def test_admin_applications_page_has_lower_bound(client):
    admin = create_test_user(
        "admin_page_user@example.com",
        role="admin",
        name="Admin Page User",
    )

    response = client.get(
        "/api/v1/admin/applications?page=0&limit=10",
        headers=auth_headers(admin.email),
    )

    assert response.status_code == 422


def test_applications_limit_has_upper_bound(client):
    user = create_test_user("limit_user@example.com")

    response = client.get(
        "/api/v1/applications/me?page=1&limit=101",
        headers=auth_headers(user.email),
    )

    assert response.status_code == 422


def test_applications_page_has_lower_bound(client):
    user = create_test_user("page_user@example.com")

    response = client.get(
        "/api/v1/applications/me?page=0&limit=10",
        headers=auth_headers(user.email),
    )

    assert response.status_code == 422


def test_update_application_status_not_found(client):
    admin = create_test_user(
        "not_found_admin@example.com",
        role="admin",
        name="Not Found Admin",
    )

    response = client.patch(
        "/api/v1/admin/applications/999999/status",
        headers=auth_headers(admin.email),
        json={
            "status": "approved",
        },
    )

    assert response.status_code == 404
    assert response.json() == {"detail": "Application not found"}


def test_update_application_status_requires_authorization_header(client):
    response = client.patch(
        "/api/v1/admin/applications/1/status",
        json={"status": "approved"},
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "Authorization header is missing"}


def test_update_application_status_approves_application(client):
    admin = create_test_user(
        "approve_admin@example.com",
        role="admin",
        name="Approve Admin",
    )
    user = create_test_user("approve_user@example.com")
    application = create_application(client, user.email, "Approve Application")

    response = client.patch(
        f"/api/v1/admin/applications/{application['id']}/status",
        headers=auth_headers(admin.email),
        json={"status": "approved"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "approved"
    assert data["reviewed_by"] == admin.id
    assert data["reviewed_at"] is not None
    assert data["reject_reason"] is None


def test_update_application_status_rejects_application_with_reason(client):
    admin = create_test_user(
        "reject_admin@example.com",
        role="admin",
        name="Reject Admin",
    )
    user = create_test_user("reject_user@example.com")
    application = create_application(client, user.email, "Reject Application")

    response = client.patch(
        f"/api/v1/admin/applications/{application['id']}/status",
        headers=auth_headers(admin.email),
        json={
            "status": "rejected",
            "reject_reason": "Receipt is missing",
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "rejected"
    assert data["reviewed_by"] == admin.id
    assert data["reviewed_at"] is not None
    assert data["reject_reason"] == "Receipt is missing"


def test_update_application_status_approval_clears_reject_reason(client):
    admin = create_test_user(
        "clear_reject_reason_admin@example.com",
        role="admin",
        name="Clear Reject Reason Admin",
    )
    user = create_test_user("clear_reject_reason_user@example.com")
    application = create_application(
        client,
        user.email,
        "Clear Reject Reason Application",
    )
    client.patch(
        f"/api/v1/admin/applications/{application['id']}/status",
        headers=auth_headers(admin.email),
        json={
            "status": "rejected",
            "reject_reason": "Needs more detail",
        },
    )

    response = client.patch(
        f"/api/v1/admin/applications/{application['id']}/status",
        headers=auth_headers(admin.email),
        json={"status": "approved"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "approved"
    assert data["reject_reason"] is None


def test_update_application_status_rejects_non_admin_user(client):
    user = create_test_user("non_admin_update_user@example.com")
    application = create_application(
        client,
        user.email,
        "Non Admin Update Application",
    )

    response = client.patch(
        f"/api/v1/admin/applications/{application['id']}/status",
        headers=auth_headers(user.email),
        json={"status": "approved"},
    )

    assert response.status_code == 403
    assert response.json() == {"detail": "Permission denied"}


def test_update_application_status_rejects_invalid_status(client):
    admin = create_test_user(
        "invalid_status_admin@example.com",
        role="admin",
        name="Invalid Status Admin",
    )
    user = create_test_user("invalid_status_user@example.com")
    application = create_application(
        client,
        user.email,
        "Invalid Status Application",
    )

    response = client.patch(
        f"/api/v1/admin/applications/{application['id']}/status",
        headers=auth_headers(admin.email),
        json={
            "status": "pending",
        },
    )

    assert response.status_code == 400
    assert response.json() == {"detail": "Invalid application status"}
