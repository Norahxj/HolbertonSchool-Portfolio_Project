"""
Script to create the database schema
Run this once to initialize the database
"""

from App import create_app
from App.Extensions import db

app = create_app()

# Create all tables
with app.app_context():
    db.create_all()
    print("✅ Database created successfully!")
    print("Tables created:")
    print("  - users")
    print("  - children")
    print("  - tasks")
