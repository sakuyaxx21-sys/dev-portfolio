from fastapi import Depends, Header
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import verify_token
from app.models.users import User
from app.core.exceptions import (
    AuthorizationHeaderMissingError,
    InvalidTokenError,
    UserNotFoundError,
    PermissionDeniedError,
)


def get_current_user(
    authorization: str | None = Header(default=None, alias="Authorization"),
    db: Session = Depends(get_db),
) -> User:
    if authorization is None:
        raise AuthorizationHeaderMissingError("Authorization header is missing")
    
    if not authorization.startswith("Bearer "):
        raise InvalidTokenError("Invalid token format")
    
    token = authorization.replace("Bearer ", "")
    email = verify_token(token)

    if email is None:
        raise InvalidTokenError("Invalid token")
    
    user = db.query(User).filter(User.email == email).first()

    if user is None:
        raise UserNotFoundError("User not found")
    
    return user


def get_current_admin(
    current_user: User = Depends(get_current_user),
) -> User:
    if current_user.role != "admin":
        raise PermissionDeniedError("Permission denied")
    
    return current_user