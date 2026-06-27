from datetime import timedelta


class Config:
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=60)