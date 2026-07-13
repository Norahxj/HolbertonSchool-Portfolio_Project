from app import create_app
from app.models.revoked_token_model import RevokedToken
from flask import Flask

app = create_app()

if __name__ == "__main__":
    app.run()
