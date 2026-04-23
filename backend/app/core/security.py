from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from pwdlib import PasswordHash

from app.core.config import settings


password_hash = PasswordHash.recommended()


def create_access_token(email: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.access_token_expire_minutes
    )

    payload = {
        "sub": email,
        "exp": expire,
    }
    
    token = jwt.encode(
        payload, 
        settings.secret_key, 
        algorithm=settings.algorithm,
    )
    return token


def verify_token(token: str) -> str | None:
    try:
        payload = jwt.decode(
            token, 
            settings.secret_key, 
            algorithms=[settings.algorithm],
        )

        email = payload.get("sub")
        if not isinstance(email, str):
            return None
        
        return email
    
    except JWTError:
        return None


def get_password_hash(password: str) -> str:
    return password_hash.hash(password)


def verify_password(password: str, hashed_password: str) -> bool:
    return password_hash.verify(password, hashed_password)