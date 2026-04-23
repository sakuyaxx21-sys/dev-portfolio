from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse

from app.core.exceptions import (
    AppServiceError,
    ResourceNotFoundError,
    ConflictError,
    AuthenticationError,
    AuthorizationError,
    UserNotFoundError,
    UserEmailAlreadyExistsError,
    InvalidCredentialsError,
    AuthorizationHeaderMissingError,
    InvalidTokenError,
    PermissionDeniedError,
)


def handle_user_service_exception(exc: AppServiceError) -> None:
    if isinstance(exc, UserNotFoundError):
        raise HTTPException(status_code=404, detail="User not found")
    
    if isinstance(exc, UserEmailAlreadyExistsError):
        raise HTTPException(status_code=400, detail="Email already exists")
    
    raise exc


def handle_auth_service_exception(exc: AppServiceError) -> None:
    if isinstance(exc, InvalidCredentialsError):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    if isinstance(exc, AuthorizationHeaderMissingError):
        raise HTTPException(status_code=401, detail="Authorization header is missing")
    
    if isinstance(exc, InvalidTokenError):
        raise HTTPException(status_code=401, detail="Invalid token")
    
    raise exc


def handle_authorization_exception(exc: AppServiceError) -> None:
    if isinstance(exc, PermissionDeniedError):
        raise HTTPException(status_code=403, detail="Permission denied")
    
    raise exc


def handle_service_exception(exc: AppServiceError) -> None:
    if isinstance(exc, (UserNotFoundError, UserEmailAlreadyExistsError)):
        handle_user_service_exception(exc)

    if isinstance(
        exc, 
        (
            InvalidCredentialsError,
            AuthorizationHeaderMissingError,
            InvalidTokenError,
        ),
    ):
        handle_auth_service_exception(exc)

    if isinstance(exc, PermissionDeniedError):
        handle_authorization_exception(exc)

    if isinstance(exc, ResourceNotFoundError):
        raise HTTPException(status_code=404, detail="Resource not found")
    
    if isinstance(exc, ConflictError):
        raise HTTPException(status_code=400, detail="Conflict detected")
    
    if isinstance(exc, AuthenticationError):
        raise HTTPException(status_code=401, detail="Authentication failed")
    
    if isinstance(exc, AuthorizationError):
        raise HTTPException(status_code=403, detail="Authorization failed")
    
    raise exc


async def app_service_exception_handler(
    request: Request, 
    exc: Exception,
) -> JSONResponse:
    if not isinstance(exc, AppServiceError):
        raise exc
    
    try:
        handle_service_exception(exc)
    except HTTPException as http_exc:
        return JSONResponse(
            status_code=http_exc.status_code,
            content={"detail": http_exc.detail},
        )
    
    raise exc