'use client'

import * as Sentry from '@sentry/nextjs'
import React from 'react'

interface Props {
  children: React.ReactNode
}

interface State {
  hasError: boolean
  eventId: string | null
}

export default class SentryErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, eventId: null }
  }

  static getDerivedStateFromError(): Partial<State> {
    return { hasError: true }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    const eventId = Sentry.captureException(error, {
      extra: { componentStack: errorInfo.componentStack },
    })
    this.setState({ eventId })
  }

  handleReportFeedback = () => {
    if (this.state.eventId) {
      Sentry.showReportDialog({ eventId: this.state.eventId })
    }
  }

  handleRetry = () => {
    this.setState({ hasError: false, eventId: null })
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="bg-white rounded-2xl shadow-sm p-8 max-w-md w-full text-center space-y-4">
            <div className="text-5xl">⚠️</div>
            <h1 className="text-xl font-bold text-gray-900">
              Une erreur inattendue s&apos;est produite
            </h1>
            <p className="text-gray-500 text-sm">
              Notre équipe a été automatiquement notifiée. Vous pouvez réessayer
              ou signaler le problème.
            </p>
            <div className="flex gap-3 justify-center pt-2">
              <button
                onClick={this.handleRetry}
                className="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-xl text-sm font-medium transition-colors"
              >
                Réessayer
              </button>
              {this.state.eventId && (
                <button
                  onClick={this.handleReportFeedback}
                  className="px-4 py-2 border border-gray-200 hover:bg-gray-50 text-gray-700 rounded-xl text-sm font-medium transition-colors"
                >
                  Signaler le problème
                </button>
              )}
            </div>
            {this.state.eventId && (
              <p className="text-xs text-gray-400">
                Référence : {this.state.eventId}
              </p>
            )}
          </div>
        </div>
      )
    }

    return this.props.children
  }
}
