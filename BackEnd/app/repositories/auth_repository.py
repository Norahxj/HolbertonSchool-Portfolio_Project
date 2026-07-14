from sqlalchemy.exc import IntegrityError
from app.extensions import db
from app.models.revoked_token_model import RevokedToken

class AuthRepository:
    def get_revoked_token_by_jti(self, jti):
        return RevokedToken.query.filter_by(jti=jti).first()

    def revoke_token(self, jti):
        existing_token = self.get_revoked_token_by_jti(jti)

        if existing_token:
            return True

        try:
            revoked_token = RevokedToken(jti=jti)
            db.session.add(revoked_token)
            db.session.commit()
            return True

        except IntegrityError:
            db.session.rollback()
            return True

        except Exception:
            db.session.rollback()
            return False