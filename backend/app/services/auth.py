from sqlalchemy.orm import Session

from app.models.users import User
from app.core.security import create_access_token, verify_password
from app.core.exceptions import InvalidCredentialsError


def login_service(db: Session, email: str, password: str) -> str:
    user = db.query(User).filter(User.email == email).first()

    if user is None:
        raise InvalidCredentialsError("Invalid email or password")
    
    if not verify_password(password, user.hashed_password):
        raise InvalidCredentialsError("Invalid email or password")
    
    token = create_access_token(email=user.email)
    return token