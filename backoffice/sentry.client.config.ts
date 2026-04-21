import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,

  // Capture 10% of transactions for performance monitoring in production
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,

  // Capture 100% of session replays for errors
  replaysOnErrorSampleRate: 1.0,

  // Capture 10% of all sessions
  replaysSessionSampleRate: 0.1,

  // Only enable debug mode in development
  debug: process.env.NODE_ENV === 'development',

  integrations: [
    Sentry.replayIntegration(),
  ],
})
