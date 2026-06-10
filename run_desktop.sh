flutter run -d linux --dart-define=GEMINI_API_KEY=$(grep GEMINI_API_KEY .env | cut -d= -f2)
