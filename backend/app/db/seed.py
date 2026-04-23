from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.users import User
from app.core.security import get_password_hash


def seed():
    db: Session = SessionLocal()

    try:
        admin = db.query(User).filter(User.email == "admin@example.com").first()
        
        if admin:
            print("admin already exists")
            return
        
        admin = User(
            name="Admin",
            email="admin@example.com",
            hashed_password=get_password_hash("admin12345"),
            role="admin",
        )
        
        db.add(admin)
        db.commit()
        
        print("admin user created")

    finally:
        db.close()


if __name__ == "__main__":
    seed()