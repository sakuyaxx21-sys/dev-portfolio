from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.users import User
from app.schemas.applications import (
    ApplicationCreate,
    ApplicationStatusUpdate,
)
from app.core.exceptions import (
    ApplicationNotFoundError,
    InvalidApplicationStatusError,
)
from app.models.applications import Application
from app.repositories import application_repository


def create_application_service(
    db: Session,
    current_user: User,
    application: ApplicationCreate, 
) -> Application:
    return application_repository.create_application(
        db=db,
        user_id=current_user.id,
        title=application.title,
        content=application.content,
        amount=application.amount,
        application_date=application.application_date,
        status="pending",
        reject_reason=None,
        reviewed_by=None,
        reviewed_at=None,
    )


def get_my_applications_service(
    db: Session, 
    current_user: User,
    page: int = 1,
    limit: int = 10,
) -> dict[str, object]:
    query = application_repository.build_user_applications_query(
        db=db,
        user_id=current_user.id,
    )
    return application_repository.paginate_applications(
        query=query,
        page=page,
        limit=limit,
    )


def get_all_applications_service(
    db: Session,
    status: str | None = None,
    user_id: int | None = None,
    keyword: str | None = None,
    page: int = 1,
    limit: int = 10,
) -> dict[str, object]:
    query = application_repository.build_applications_query(
        db=db,
        status=status,
        user_id=user_id,
        keyword=keyword,
    )
    return application_repository.paginate_applications(
        query=query,
        page=page,
        limit=limit,
    )


def update_application_status_service(
    db: Session,
    application_id: int,
    admin_user: User,
    payload: ApplicationStatusUpdate,
) -> Application:
    application = application_repository.get_application_by_id(
        db=db,
        application_id=application_id,
    )

    if application is None:
        raise ApplicationNotFoundError(
            f"application_id={application_id} was not found"
        )

    if payload.status not in ("approved", "rejected"):
        raise InvalidApplicationStatusError("Invalid application status")

    reject_reason = (
        payload.reject_reason
        if payload.status == "rejected"
        else None
    )

    return application_repository.update_application_status(
        db=db,
        application=application,
        status=payload.status,
        reviewed_by=admin_user.id,
        reviewed_at=datetime.now(timezone.utc),
        reject_reason=reject_reason,
    )
