class APIError(Exception):
    # Constructor for APIError
    def __init__(self, message, status_code=500):
        super().__init__(message)
        self.message = message 
        self.status_code = status_code

# Exception for when a resource is not found (HTTP 404)
class NotFoundError(APIError):
    def __init__(self, message="Resource not found"):
        super().__init__(message, 404)

# Exception for invalid input or validation failures (HTTP 400)
class ValidationError(APIError):
    def __init__(self, message="Validation failed", errors=None):
        super().__init__(message, 400)
        self.errors = errors if errors is not None else {}

# Exception for authentication failures (HTTP 401)
class UnauthorizedError(APIError):
    def __init__(self, message="Authentication required"):
        super().__init__(message, 401) 

# Exception for authorization failures (HTTP 403)
class ForbiddenError(APIError):
    def __init__(self, message="Permission denied"):
        super().__init__(message, 403) 

# Exception for conflicts, such as duplicate resource creation (HTTP 409)
class ConflictError(APIError):
    def __init__(self, message="Resource conflict"):
        super().__init__(message, 409)
