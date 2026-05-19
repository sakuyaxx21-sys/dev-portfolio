from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.applications import Application
from app.models.users import User
from app.schemas.applications import (
    ApplicationCreate,
    ApplicationStatusUpdate,
)
from app.core.exceptions import (
    ApplicationNotFoundError,
    InvalidApplicationStatusError,
)


def create_application_service(
    db: Session,
    current_user: User,
    application: ApplicationCreate, 
) -> Application:
    db_application = Application(
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

    db.add(db_application)
    db.commit()
    db.refresh(db_application)
    return db_application


def get_my_applications_service(
    db: Session, 
    current_user: User,
    page: int = 1,
    limit: int = 10,
) -> dict[str, object]:
    query = (
        db.query(Application)
        .filter(Application.user_id == current_user.id)
    )
    return paginate_applications(query=query, page=page, limit=limit)


def get_all_applications_service(
    db: Session,
    status: str | None = None,
    user_id: int | None = None,
    keyword: str | None = None,
    page: int = 1,
    limit: int = 10,
) -> dict[str, object]:
    query = db.query(Application)

    if status:
        query = query.filter(Application.status == status)

    if user_id:
        query = query.filter(Application.user_id == user_id)

    if keyword:
        query = query.filter(Application.title.contains(keyword))

    return paginate_applications(query=query, page=page, limit=limit)


def paginate_applications(
    query,
    page: int,
    limit: int,
) -> dict[str, object]:
    total = query.count()
    total_pages = (total + limit - 1) // limit if total > 0 else 0
    offset = (page - 1) * limit
    applications = (
        query.order_by(Application.created_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )

    return {
        "items": applications,
        "total": total,
        "page": page,
        "limit": limit,
        "total_pages": total_pages,
    }


def update_application_status_service(
    db: Session,
    application_id: int,
    admin_user: User,
    payload: ApplicationStatusUpdate,
) -> Application:
    application = (
        db.query(Application)
        .filter(Application.id == application_id)
        .first()
    )

    if application is None:
        raise ApplicationNotFoundError(
            f"application_id={application_id} was not found"
        )

    if payload.status not in ("approved", "rejected"):
        raise InvalidApplicationStatusError("Invalid application status")

    application.status = payload.status
    application.reviewed_by = admin_user.id
    application.reviewed_at = datetime.now(timezone.utc)

    if payload.status == "rejected":
        application.reject_reason = payload.reject_reason
    else:
        application.reject_reason = None

    db.commit()
    db.refresh(application)
    return application
