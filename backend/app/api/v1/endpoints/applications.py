from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.users import User
from app.schemas.applications import (
    ApplicationCreate,
    ApplicationListResponse,
    ApplicationResponse,
)
from app.services.applications import (
    create_application_service,
    get_my_applications_service,
)
from app.api.dependencies.auth import get_current_user

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


@router.get("/applications/me", response_model=ApplicationListResponse)
def get_my_applications(
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=10, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_my_applications_service(
        db=db,
        current_user=current_user,
        page=page,
        limit=limit,
    )
