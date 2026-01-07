# Folium - Tree Plantation Management Platform

A comprehensive tree plantation management application built with SvelteKit and Supabase. Track trees, volunteers, areas, and monitor plantation progress with real-time insights.

## Features

- **Dashboard** - Overview of plantation activities with key metrics (total trees, active volunteers, areas covered, tree health status)
- **Tree Management** - Track individual trees with species, location, status, and care history
- **Volunteer Management** - Monitor volunteer activities and contributions
- **Area Tracking** - Organize plantations by geographic areas
- **Insights & Analytics** - View plantation progress, species distribution, and trends
- **Authentication** - Secure user authentication with role-based access (admin, volunteer, viewer)

## Tech Stack

- **Frontend**: SvelteKit 2, Svelte 5, TypeScript
- **Backend**: Supabase (PostgreSQL, Auth, Row Level Security)
- **Styling**: CSS with custom design system
- **Deployment**: Netlify

## Getting Started

### Prerequisites

- Node.js 18+
- npm or pnpm
- Supabase account

### Installation

```sh
npm install
```

### Environment Variables

Create a `.env` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Development

Start the development server:

```sh
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

### Type Checking

```sh
npm run check
```

### Build

Create a production build:

```sh
npm run build
```

Preview the production build:

```sh
npm run preview
```

## Project Structure

```
src/
├── lib/
│   ├── components/     # Reusable UI components
│   ├── supabaseClient.ts  # Supabase client configuration
├── routes/
│   ├── +layout.svelte     # Main layout with navigation
│   ├── +page.svelte       # Dashboard home page
│   ├── auth/
│   │   └── callback/      # Auth callback handler
│   ├── insights/          # Analytics and insights page
│   ├── signin/            # Sign in page
│   ├── signup/            # Sign up page
│   └── trees/             # Tree management page
└── app.css                # Global styles
```

## Database Schema

The application uses the following main tables:

- **users** - User accounts with roles (admin, volunteer, viewer)
- **trees** - Tree records with species, location, status
- **volunteers** - Volunteer information and activity tracking
- **areas** - Geographic plantation areas
- **plantations** - Plantation events linking trees, volunteers, and areas

See `supabase-schema.sql` for the complete database schema including RLS policies, views, and seed data.

## Deployment

The project is configured for Netlify deployment. See `netlify.toml` for configuration.

## License

MIT
