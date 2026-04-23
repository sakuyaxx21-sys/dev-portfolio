def make_email(prefix: str) -> str:
    return f"{prefix}@example.com"


def test_create_user(client):
    payload = {
        "name": "Test User Create",
        "email": make_email("test_create_user"),
    }

    response = client.post("/api/v1/users", json=payload)

    assert response.status_code == 200
    data = response.json()

    assert data["name"] == payload["name"]
    assert data["email"] == payload["email"]
    assert "id" in data


def test_get_users(client):
    payload = {
        "name": "Test User List",
        "email": make_email("test_get_users"),
    }
    client.post("/api/v1/users", json=payload)

    response = client.get("/api/v1/users")

    assert response.status_code == 200
    data = response.json()

    assert isinstance(data, list)
    assert len(data) == 1
    assert data[0]["name"] == payload["name"]
    assert data[0]["email"] == payload["email"]


def test_get_user(client):
    payload = {
        "name": "Test User Detail",
        "email": make_email("test_get_user"),
    }
    create_response = client.post("/api/v1/users", json=payload)
    created_user = create_response.json()
    user_id = created_user["id"]

    response = client.get(f"/api/v1/users/{user_id}")

    assert response.status_code == 200
    data = response.json()

    assert data["id"] == user_id
    assert data["name"] == payload["name"]
    assert data["email"] == payload["email"]


def  test_get_user_not_found(client):
    response = client.get("/api/v1/users/999999")

    assert response.status_code == 404
    assert response.json() == {"detail": "User not found"}


def test_create_user_email_already_exists(client):
    payload = {
        "name": "Test User Duplicate",
        "email": make_email("test_duplicate_user"),
    }

    first_response = client.post("/api/v1/users", json=payload)
    second_response = client.post("/api/v1/users", json=payload)

    assert first_response.status_code == 200
    assert second_response.status_code == 400
    assert second_response.json() == {"detail": "Email already exists"}


def test_update_user(client):
    create_payload = {
        "name": "Before Update",
        "email": make_email("before_update"),
    }
    create_response = client.post("/api/v1/users", json=create_payload)
    created_user = create_response.json()
    user_id = created_user["id"]

    update_payload = {
        "name": "After Update",
        "email": make_email("after_update"),
    }

    response = client.put(f"/api/v1/users/{user_id}", json=update_payload)

    assert response.status_code == 200
    data = response.json()

    assert data["id"] == user_id
    assert data["name"] == update_payload["name"]
    assert data["email"] == update_payload["email"]


def test_update_user_not_found(client):
    payload = {
        "name": "Not Found Update",
        "email": make_email("not_found_update"),
    }

    response = client.put("/api/v1/users/999999", json=payload)

    assert response.status_code == 404
    assert response.json() == {"detail": "User not found"}


def test_update_user_email_already_exists(client):
    payload_1 = {
        "name": "User One",
        "email": make_email("user_one"),
    }
    response_1 = client.post("/api/v1/users", json=payload_1)
    user_1 = response_1.json()

    payload_2 = {
        "name": "User Two",
        "email": make_email("user_two"),
    }
    response_2 = client.post("/api/v1/users", json=payload_2)
    user_2 = response_2.json()

    update_payload = {
        "name": "User Two Updated",
        "email": user_1["email"],
    }

    response = client.put(f"/api/v1/users/{user_2['id']}", json=update_payload)

    assert response.status_code == 400
    assert response.json() == {"detail": "Email already exists"}


def test_delete_user(client):
    payload = {
        "name": "Delete Target",
        "email": make_email("delete_target"),
    }
    create_response = client.post("/api/v1/users", json=payload)
    created_user = create_response.json()
    user_id = created_user["id"]

    delete_response = client.delete(f"/api/v1/users/{user_id}")

    assert delete_response.status_code == 200
    assert delete_response.json() == {"message": "User deleted successfully"}

    get_response = client.get(f"/api/v1/users/{user_id}")
    assert get_response.status_code == 404
    assert get_response.json() == {"detail": "User not found"}


def test_delete_user_not_found(client):
    response = client.delete("/api/v1/users/999999")

    assert response.status_code == 404
    assert response.json() == {"detail": "User not found"}