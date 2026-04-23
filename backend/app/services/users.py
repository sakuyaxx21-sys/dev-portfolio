from sqlalchemy.orm import Session

from app.models.users import User
from app.schemas.users import UserCreate, UserUpdate
from app.core.exceptions import (
    UserNotFoundError,
    UserEmailAlreadyExistsError,
)
from app.core.security import get_password_hash


def get_users_service(db: Session, limit: int = 10) -> list[User]:
    users = db.query(User).limit(limit).all()
    return users


def get_user_service(db: Session, user_id: int) -> User:
    user = db.query(User).filter(User.id == user_id).first()

    if user is None:
        raise UserNotFoundError(f"user_id={user_id} was not found")
    
    return user


def create_user_service(db: Session, user: UserCreate) -> User:
    existing_user = db.query(User).filter(User.email == user.email).first()
    
    if existing_user:
        raise UserEmailAlreadyExistsError(f"email={user.email} already exists")
    
    db_user = User(
        name=user.name, 
        email=user.email,
        hashed_password=get_password_hash(user.password),
        role="user",
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return db_user


def update_user_service(db: Session, user_id: int, user: UserUpdate) -> User:
    db_user = db.query(User).filter(User.id == user_id).first()

    if db_user is None:
        raise UserNotFoundError(f"user_id={user_id} was not found")
    
    existing_user = (
        db.query(User)
        .filter(User.email == user.email, User.id != user_id)
        .first()
    )
    
    if existing_user:
        raise UserEmailAlreadyExistsError(f"email={user.email} already exists")
    
    db_user.name = user.name
    db_user.email = user.email

    db.commit()
    db.refresh(db_user)

    return db_user


def delete_user_service(db: Session, user_id: int) -> User:
    db_user = db.query(User).filter(User.id == user_id).first()

    if db_user is None:
        raise UserNotFoundError(f"user_id={user_id} was not found")
    
    db.delete(db_user)
    db.commit()

    return db_user