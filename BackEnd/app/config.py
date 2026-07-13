from datetime import timedelta
import os


class Config:
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=60)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)

    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")

    @classmethod
    def validate(cls):
        missing_variables = []

        if not cls.SQLALCHEMY_DATABASE_URI:
            missing_variables.append("DATABASE_URL")

        if not cls.JWT_SECRET_KEY:
            missing_variables.append("JWT_SECRET_KEY")

        if missing_variables:
            missing = ", ".join(missing_variables)

            raise RuntimeError(
                f"Missing required environment variables: {missing}"
            )