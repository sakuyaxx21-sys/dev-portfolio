from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import verify_token
from app.core.exceptions import (
    AuthorizationHeaderMissingError,
    InvalidTokenError,
    UserNotFoundError,
    PermissionDeniedError,
)
from app.db.session import get_db
from app.models.users import User
from app.repositories import user_repository


oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl=f"{settings.api_v1_prefix}/auth/token",
    # Let the app raise domain-specific auth errors instead of FastAPI defaults.
    auto_error=False,
)


def get_current_user(
    token: str | None = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    if token is None:
        raise AuthorizationHeaderMissingError("Authorization header is missing")

    email = verify_token(token)

    if email is None:
        raise InvalidTokenError("Invalid token")

    user = user_repository.get_user_by_email(db=db, email=email)

    if user is None:
        raise UserNotFoundError("User not found")

    return user


def get_current_admin(
    current_user: User = Depends(get_current_user),
) -> User:
    if current_user.role != "admin":
        raise PermissionDeniedError("Permission denied")

    return current_user
