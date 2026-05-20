from datetime import date, datetime

from sqlalchemy.orm import Query, Session

from app.models.applications import Application


def create_application(
    db: Session,
    user_id: int,
    title: str,
    content: str,
    amount: int,
    application_date: date,
    status: str = "pending",
    reject_reason: str | None = None,
    reviewed_by: int | None = None,
    reviewed_at: datetime | None = None,
) -> Application:
    db_application = Application(
        user_id=user_id,
        title=title,
        content=content,
        amount=amount,
        application_date=application_date,
        status=status,
        reject_reason=reject_reason,
        reviewed_by=reviewed_by,
        reviewed_at=reviewed_at,
    )

    db.add(db_application)
    db.commit()
    db.refresh(db_application)

    return db_application


def get_application_by_id(
    db: Session,
    application_id: int,
) -> Application | None:
    return (
        db.query(Application)
        .filter(Application.id == application_id)
        .first()
    )


def build_user_applications_query(
    db: Session,
    user_id: int,
) -> Query[Application]:
    return db.query(Application).filter(Application.user_id == user_id)


def build_applications_query(
    db: Session,
    status: str | None = None,
    user_id: int | None = None,
    keyword: str | None = None,
) -> Query[Application]:
    query = db.query(Application)

    if status:
        query = query.filter(Application.status == status)

    if user_id:
        query = query.filter(Application.user_id == user_id)

    if keyword:
        query = query.filter(Application.title.contains(keyword))

    return query


def paginate_applications(
    query: Query[Application],
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


def update_application_status(
    db: Session,
    application: Application,
    status: str,
    reviewed_by: int,
    reviewed_at: datetime,
    reject_reason: str | None = None,
) -> Application:
    application.status = status
    application.reviewed_by = reviewed_by
    application.reviewed_at = reviewed_at
    application.reject_reason = reject_reason

    db.commit()
    db.refresh(application)

    return application
