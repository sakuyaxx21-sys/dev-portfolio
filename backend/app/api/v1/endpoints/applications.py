from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies.auth import get_current_user
from app.db.session import get_db
from app.models.users import User
from app.schemas.applications import (
    ApplicationCreate, 
    ApplicationResponse,
)
from app.services.applications import (
    create_application_service,
    get_my_applications_service,
)

router = APIRouter()


@router.post("/applications", response_model=ApplicationResponse)
def create_application(
    application: ApplicationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return create_application_service(
        db=db, 
        current_user=current_user, 
        application=application,
    )


@router.get("/applications/me", response_model=list[ApplicationResponse])
def get_my_applications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_my_applications_service(
        db=db, 
        current_user=current_user,
    )