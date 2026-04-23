class AppServiceError(Exception):
    """Base exception class for service layer errors."""
    pass


# =========================
# Resource Errors
# =========================

class ResourceNotFoundError(AppServiceError):
    """Raised when a requested resource is not found."""
    pass


class UserNotFoundError(ResourceNotFoundError):
    """Raised when the specified user cannot be found."""
    pass


class ApplicationNotFoundError(ResourceNotFoundError):
    """Raised when the specified application cannot be found."""
    pass


# =========================
# Conflict Errors
# =========================

class ConflictError(AppServiceError):
    """Raised when a conflict occurs (e.g., duplicate data)."""
    pass


class UserEmailAlreadyExistsError(ConflictError):
    """Raised when the email is already registered."""
    pass


class InvalidApplicationStatusError(ConflictError):
    """Raised when an invalid application status transition is attempted."""
    pass


# =========================
# Authentication Errors
# =========================

class AuthenticationError(AppServiceError):
    """Base exception for authentication failures."""
    pass


class InvalidCredentialsError(AuthenticationError):
    """Raised when email or password is incorrect."""
    pass


class InvalidTokenError(AuthenticationError):
    """Raised when the token is invalid or expired."""
    pass


class AuthorizationHeaderMissingError(AuthenticationError):
    """Raised when the Authorization header is missing."""
    pass


# =========================
# Authorization Errors
# =========================

class AuthorizationError(AppServiceError):
    """Base exception for authorization failures."""
    pass


class PermissionDeniedError(AuthorizationError):
    """Raised when the user does not have sufficient permissions."""
    pass