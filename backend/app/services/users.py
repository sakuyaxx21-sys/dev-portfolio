from sqlalchemy.orm import Session

from app.core.exceptions import (
    UserNotFoundError,
    UserEmailAlreadyExistsError,
)
from app.core.security import get_password_hash
from app.models.users import User
from app.repositories import user_repository
from app.schemas.users import UserCreate, UserUpdate


def get_users_service(db: Session, limit: int = 10) -> list[User]:
    return user_repository.list_users(db=db, limit=limit)


def get_user_service(db: Session, user_id: int) -> User:
    user = user_repository.get_user_by_id(db=db, user_id=user_id)

    if user is None:
        raise UserNotFoundError(f"user_id={user_id} was not found")

    return user


def create_user_service(db: Session, user: UserCreate) -> User:
    existing_user = user_repository.get_user_by_email(
        db=db,
        email=user.email,
    )

    if existing_user:
        raise UserEmailAlreadyExistsError(f"email={user.email} already exists")

    return user_repository.create_user(
        db=db,
        name=user.name,
        email=user.email,
        hashed_password=get_password_hash(user.password),
        role="user",
    )


def update_user_service(db: Session, user_id: int, user: UserUpdate) -> User:
    db_user = user_repository.get_user_by_id(db=db, user_id=user_id)

    if db_user is None:
        raise UserNotFoundError(f"user_id={user_id} was not found")

    existing_user = user_repository.get_user_by_email_except_id(
        db=db,
        email=user.email,
        user_id=user_id,
    )

    if existing_user:
        raise UserEmailAlreadyExistsError(f"email={user.email} already exists")

    return user_repository.update_user(
        db=db,
        user=db_user,
        name=user.name,
        email=user.email,
    )


def delete_user_service(db: Session, user_id: int) -> User:
    db_user = user_repository.get_user_by_id(db=db, user_id=user_id)

    if db_user is None:
        raise UserNotFoundError(f"user_id={user_id} was not found")

    return user_repository.delete_user(db=db, user=db_user)
