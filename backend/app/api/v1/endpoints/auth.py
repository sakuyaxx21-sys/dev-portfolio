from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.auth import LoginRequest, TokenResponse
from app.services.auth import login_service

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
def login(
    request: LoginRequest,
    db: Session = Depends(get_db),
):
    token = login_service(
        db=db,
        email=request.email,
        password=request.password,
    )

    return {
        "access_token": token,
        "token_type": "bearer",
    }


@router.post("/token", response_model=TokenResponse)
def login_for_access_token(
    # Form endpoint used by OAuth2 password flow and Swagger UI.
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    token = login_service(
        db=db,
        email=form_data.username,
        password=form_data.password,
    )

    return {
        "access_token": token,
        "token_type": "bearer",
    }
