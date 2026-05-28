from fastapi import FastAPI

from app.core.config import settings
from app.core.exceptions import AppServiceError
from app.api.error_handlers import app_service_exception_handler
from app.api.v1.router import api_router


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    debug=settings.debug,
)

app.add_exception_handler(AppServiceError, app_service_exception_handler)


@app.get("/")
def root():
    return {
        "message": f"Welcome to {settings.app_name}",
        "version": settings.app_version,
        "debug": settings.debug,
    }


app.include_router(api_router, prefix=settings.api_v1_prefix)
