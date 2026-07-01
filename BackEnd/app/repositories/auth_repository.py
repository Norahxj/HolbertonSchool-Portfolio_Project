from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.user_model import User
from app.models.child_model import Child
from app.models.revoked_token_model import RevokedToken

class AuthRepository:
    def get_user_by_email(self, email):
        return User.query.filter_by(email=email).first()

    def get_user_by_id(self, user_id):
        return db.session.get(User, user_id)

    def get_child_by_id(self, child_id):
        return db.session.get(Child, child_id)

    def get_child_by_access_code(self, access_code):
        return Child.query.filter_by(access_code=access_code).first()

    def create_user(self, user):
        try:
            db.session.add(user)
            db.session.commit()
            return user, None
        except IntegrityError:
            db.session.rollback()
            return None, "Email already registered"

    def get_revoked_token_by_jti(self, jti):
        return RevokedToken.query.filter_by(jti=jti).first()

    def revoke_token(self, jti):
        existing_token = self.get_revoked_token_by_jti(jti)
        if not existing_token:
            revoked_token = RevokedToken(jti=jti)
            db.session.add(revoked_token)
            db.session.commit()
        return True