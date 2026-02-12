# Technology Stack

## Web Application

### Core Framework
- React 19.2.4 with TypeScript 5.8.2
- Vite 6.2.0 for build tooling and dev server
- React DOM for rendering

### Key Libraries
- `@google/genai` (1.39.0) - Google Gemini AI integration for horoscope generation
- `lucide-react` (0.563.0) - Icon library for UI components

### Build System
- Vite with React plugin (`@vitejs/plugin-react`)
- TypeScript with experimental decorators enabled
- Path aliases: `@/*` maps to workspace root

### Environment Configuration
- API keys stored in `.env.local`
- Environment variables injected at build time via Vite config
- `GEMINI_API_KEY` required for AI functionality

## Android Application

### Framework
- Kotlin with Jetpack Compose
- Material3 design system
- Coroutines for async operations

### Architecture
- Repository pattern for data access (`GeminiRepository`)
- Model classes for type safety (`Models.kt`)
- Activity-based navigation (`MainActivity`)

## Common Commands

### Development
```bash
npm install          # Install dependencies
npm run dev          # Start dev server on port 3000
npm run build        # Production build
npm run preview      # Preview production build
```

### Configuration
- Dev server runs on `http://0.0.0.0:3000`
- Hot module replacement enabled
- TypeScript strict mode disabled for flexibility

## API Integration

All horoscope content is generated via Google Gemini AI with:
- Structured JSON responses using response schemas
- System prompts defining "Zodi" personality
- Turkish language output
- Real-time generation (no caching)
