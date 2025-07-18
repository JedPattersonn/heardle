# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Heardle.fun is a music guessing game that allows users to search for artists and test their knowledge by guessing songs from short audio clips. The project consists of a Next.js web application and an iOS companion app.

## Development Commands

### Web Application (from /web directory)
- **Development**: `npm run dev --turbopack` (uses Turbopack for faster builds)
- **Build**: `npm run build`
- **Production**: `npm run start`
- **Lint**: `npm run lint`

### Database Operations
- **Generate migrations**: `bunx drizzle-kit generate`
- **Push schema**: `bunx drizzle-kit push`
- **Studio**: `bunx drizzle-kit studio`

## Architecture

### Web Application Structure
- **Framework**: Next.js 15 with App Router
- **Database**: PostgreSQL with Drizzle ORM
- **Styling**: Tailwind CSS with shadcn/ui components
- **State Management**: React hooks and context
- **Analytics**: PostHog for product analytics, Vercel Analytics
- **Authentication**: Apple Music API integration with JWT tokens

### Key Directories
- `/web/src/app/` - Next.js App Router pages and API routes
- `/web/src/components/` - Reusable React components including Game.tsx (main game logic)
- `/web/src/db/` - Database schema and connection (schema.ts)
- `/web/src/types/` - TypeScript type definitions
- `/Heardle/` - iOS Swift app with SwiftUI

### API Integration
- **Apple Music API**: Fetches artist songs and metadata using Apple Developer credentials
- **Database API**: CRUD operations for artists stored in PostgreSQL
- **Search API**: Artist search functionality

### Core Game Flow
1. User searches and selects an artist
2. App fetches songs from Apple Music API using JWT authentication
3. Game component manages audio playback, scoring, and guess validation
4. Songs are categorized by difficulty (easy/medium/hard) based on popularity
5. Score calculated based on speed and accuracy with streak bonuses

### Environment Variables Required
- `DATABASE_URL` - PostgreSQL connection string
- `APPLE_TEAM_ID` - Apple Developer team ID
- `APPLE_KEY_ID` - Apple Music API key ID  
- `APPLE_PRIVATE_KEY` - Apple Music API private key
- PostHog configuration for analytics

### Mobile App Integration
The iOS app (`/Heardle/`) shares the same backend APIs and artist database, using Apple Music integration for audio playback and the web API for artist data.