from sqlalchemy.orm import Session

from app.models.users import User


def list_users(db: Session, limit: int = 10) -> list[User]:
    return db.query(User).limit(limit).all()


def get_user_by_id(db: Session, user_id: int) -> User | None:
    return db.query(User).filter(User.id == user_id).first()


def get_user_by_email(db: Session, email: str) -> User | None:
    return db.query(User).filter(User.email == email).first()


def get_user_by_email_except_id(
    db: Session,
    email: str,
    user_id: int,
) -> User | None:
    return (
        db.query(User)
        .filter(User.email == email, User.id != user_id)
        .first()
    )


def create_user(
    db: Session,
    name: str,
    email: str,
    hashed_password: str,
    role: str = "user",
) -> User:
    db_user = User(
        name=name,
        email=email,
        hashed_password=hashed_password,
        role=role,
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return db_user


def update_user(
    db: Session,
    user: User,
    name: str,
    email: str,
) -> User:
    user.name = name
    user.email = email

    db.commit()
    db.refresh(user)

    return user


def delete_user(db: Session, user: User) -> User:
    db.delete(user)
    db.commit()

    return user
