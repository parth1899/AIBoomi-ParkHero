#!/bin/bash

# ParkHero Backend Quick Start Script

echo "🚀 ParkHero Backend Setup"
echo "=========================="
echo ""

# Check if we're in the backend directory
if [ ! -f "manage.py" ]; then
    echo "❌ Error: Please run this script from the backend directory"
    exit 1
fi

echo "✅ Dependencies already installed via uv"
echo ""

# Run migrations
echo "📦 Running database migrations..."
uv run python manage.py migrate

if [ $? -ne 0 ]; then
    echo "❌ Migration failed"
    exit 1
fi

echo ""
echo "✅ Migrations completed successfully"
echo ""

# Create superuser
echo "👤 Creating superuser account..."
echo "   (You'll be prompted for username, email, and password)"
echo ""
uv run python manage.py createsuperuser

if [ $? -ne 0 ]; then
    echo "⚠️  Superuser creation skipped or failed"
else
    echo ""
    echo "✅ Superuser created successfully"
fi

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Start the development server:"
echo "   uv run python manage.py runserver"
echo ""
echo "2. Access the admin panel:"
echo "   http://localhost:8000/admin/"
echo ""
echo "3. Browse the API:"
echo "   http://localhost:8000/api/mobile/facilities/"
echo ""
echo "4. Get an auth token:"
echo "   POST http://localhost:8000/api/auth/token/"
echo "   Body: {\"username\": \"your_username\", \"password\": \"your_password\"}"
echo ""
echo "📚 See README.md for complete API documentation"
echo ""
