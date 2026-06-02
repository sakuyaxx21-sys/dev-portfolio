from app.core.security import create_access_token


def test_openapi_uses_oauth2_password_flow(client):
    schema = client.get("/openapi.json").json()

    security_scheme = schema["components"]["securitySchemes"]["OAuth2PasswordBearer"]

    assert security_scheme["type"] == "oauth2"
    assert security_scheme["flows"]["password"]["tokenUrl"] == "/api/v1/auth/token"
    assert schema["paths"]["/api/v1/users/me"]["get"]["security"] == [
        {"OAuth2PasswordBearer": []}
    ]


def test_token_endpoint_returns_access_token(client):
    password = "password123"
    user_payload = {
        "name": "Token User",
        "email": "token_user@example.com",
        "password": password,
    }
    client.post("/api/v1/users", json=user_payload)

    response = client.post(
        "/api/v1/auth/token",
        data={
            "username": user_payload["email"],
            "password": password,
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["token_type"] == "bearer"
    assert data["access_token"]


def test_token_endpoint_rejects_unknown_email(client):
    response = client.post(
        "/api/v1/auth/token",
        data={
            "username": "unknown_token_user@example.com",
            "password": "password123",
        },
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid email or password"}


def test_token_endpoint_rejects_wrong_password(client):
    user_payload = {
        "name": "Wrong Token Password User",
        "email": "wrong_token_password_user@example.com",
        "password": "password123",
    }
    client.post("/api/v1/users", json=user_payload)

    response = client.post(
        "/api/v1/auth/token",
        data={
            "username": user_payload["email"],
            "password": "wrongpassword",
        },
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid email or password"}


def test_login_endpoint_returns_access_token(client):
    password = "password123"
    user_payload = {
        "name": "Login User",
        "email": "login_user@example.com",
        "password": password,
    }
    client.post("/api/v1/users", json=user_payload)

    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": user_payload["email"],
            "password": password,
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["token_type"] == "bearer"
    assert data["access_token"]


def test_login_rejects_unknown_email(client):
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "unknown_login_user@example.com",
            "password": "password123",
        },
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid email or password"}


def test_login_rejects_wrong_password(client):
    user_payload = {
        "name": "Wrong Password User",
        "email": "wrong_password_user@example.com",
        "password": "password123",
    }
    client.post("/api/v1/users", json=user_payload)

    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": user_payload["email"],
            "password": "wrongpassword",
        },
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid email or password"}


def test_login_rejects_invalid_request_payload(client):
    invalid_payloads = [
        {
            "email": "not-an-email",
            "password": "password123",
        },
        {
            "email": "short_password_login_user@example.com",
            "password": "short",
        },
    ]

    for payload in invalid_payloads:
        response = client.post("/api/v1/auth/login", json=payload)

        assert response.status_code == 422


def test_users_me_requires_authorization_header(client):
    response = client.get("/api/v1/users/me")

    assert response.status_code == 401
    assert response.json() == {"detail": "Authorization header is missing"}


def test_users_me_accepts_bearer_token(client):
    password = "password123"
    user_payload = {
        "name": "Authenticated User",
        "email": "authenticated_user@example.com",
        "password": password,
    }
    client.post("/api/v1/users", json=user_payload)
    token_response = client.post(
        "/api/v1/auth/token",
        data={
            "username": user_payload["email"],
            "password": password,
        },
    )
    token = token_response.json()["access_token"]

    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == user_payload["email"]
    assert data["name"] == user_payload["name"]
    assert data["role"] == "user"


def test_users_me_rejects_invalid_bearer_token(client):
    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": "Bearer invalid-token"},
    )

    assert response.status_code == 401
    assert response.json() == {"detail": "Invalid token"}


def test_users_me_rejects_token_for_missing_user(client):
    token = create_access_token("missing_token_user@example.com")

    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 404
    assert response.json() == {"detail": "User not found"}
