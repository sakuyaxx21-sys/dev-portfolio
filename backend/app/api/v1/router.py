from fastapi import APIRouter
from app.api.v1.endpoints import (
    health,
    users,
    auth,
    applications,
    admin,
)

api_router = APIRouter()

api_router.include_router(health.router, tags=["health"])
api_router.include_router(users.router, tags=["users"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(applications.router, tags=["applications"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])