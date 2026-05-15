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
