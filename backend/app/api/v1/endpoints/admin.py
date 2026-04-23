from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies.auth import get_current_admin
from app.db.session import get_db
from app.models.users import User
from app.schemas.applications import (
    ApplicationResponse,
    ApplicationStatusUpdate,
)
from app.services.applications import (
    get_all_applications_service,
    update_application_status_service,
)

router = APIRouter()


@router.get(
    "/applications", 
    response_model=list[ApplicationResponse],
    dependencies=[Depends(get_current_admin)],
)
def get_all_applications(
    status: str | None = None,
    user_id: int | None = None,
    keyword: str | None = None,
    db: Session = Depends(get_db),
):
    return get_all_applications_service(
        db=db, 
        status=status, 
        user_id=user_id, 
        keyword=keyword,
    )


@router.patch(
    "/applications/{application_id}/status", 
    response_model=ApplicationResponse,
)
def update_application_status(
    application_id: int,
    payload: ApplicationStatusUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    return update_application_status_service(
        db=db, 
        application_id=application_id, 
        admin_user=current_admin,
        payload=payload,
    )