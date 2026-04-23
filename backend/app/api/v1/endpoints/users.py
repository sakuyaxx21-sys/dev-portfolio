from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.users import UserCreate, UserUpdate, UserResponse
from app.services.users import (
    get_users_service, 
    get_user_service, 
    create_user_service,
    update_user_service,
    delete_user_service,
)

from app.api.dependencies.auth import get_current_user
from app.models.users import User

router = APIRouter()


@router.get("/users", response_model=list[UserResponse])
def get_users(limit: int = 10, db: Session = Depends(get_db)):
    return get_users_service(db=db, limit=limit)


@router.get("/users/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    return get_user_service(db=db, user_id=user_id)


@router.post("/users", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    return create_user_service(db=db, user=user)


@router.put("/users/{user_id}", response_model=UserResponse)
def update_user(user_id: int, user: UserUpdate, db: Session = Depends(get_db)):
    return update_user_service(db=db, user_id=user_id, user=user)


@router.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    delete_user_service(db=db, user_id=user_id)
    return {"message": "User deleted successfully"}