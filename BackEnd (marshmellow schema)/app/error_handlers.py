from flask import jsonify
from app.exceptions.api_exceptions import APIError, NotFoundError, ValidationError, UnauthorizedError, ForbiddenError, ConflictError

# handle Marshmallow ValidationErrors (if Marshmallow is used directly in routes without schemas)
# from marshmallow import ValidationError as MarshmallowValidationError
# @app.errorhandler(MarshmallowValidationError)
# def handle_marshmallow_validation_error(error):
#     response = jsonify({
#         "success": False,
#         "message": "Validation failed for request data.",
#         "errors": error.messages
#     response.status_code = 400
#     return response

def register_error_handlers(app):
    
    @app.errorhandler(APIError)
    def handle_api_error(error):
        response = jsonify({
            "success": False,
            "message": error.message,
            "errors": error.errors if hasattr(error, 'errors') else {}
        })
        response.status_code = error.status_code
        return response

    @app.errorhandler(404)
    def handle_not_found_error(error):
        response = jsonify({
            "success": False,
            "message": "The requested URL was not found on the server."
        })
        response.status_code = 404
        return response

    @app.errorhandler(405)
    def handle_method_not_allowed(error):
        response = jsonify({
            "success": False,
            "message": "The method is not allowed for the requested URL."
        })
        response.status_code = 405
        return response

    @app.errorhandler(500)
    def handle_internal_server_error(error):
        response = jsonify({
            "success": False,
            "message": "An unexpected error occurred on the server."
        })
        response.status_code = 500
        return response
