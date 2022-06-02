# frozen_string_literal: true

require 'roda'
require_relative './app'

module UrlShortener
  # Web controller for UrlShortener API
  class App < Roda
    route('shared_urls') do |routing|
      routing.get do
        urls = Services::Urls.new(App.config).shared_urls(@current_account)
        view :shared_urls, locals: { urls: }
      rescue CreateAccount::InvalidAccount => e
        flash[:error] = e.message
        routing.redirect '/auth/register'
      rescue StandardError => e
        flash[:error] = e.message
        routing.redirect '/error/404'
      end
    end
  end
end
