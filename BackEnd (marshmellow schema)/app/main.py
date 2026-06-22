from app import create_app

# Create an instance of the Flask application
app = create_app()

# Run the application if this script is executed directly
if __name__ == '__main__':
    app.run(debug=True)
