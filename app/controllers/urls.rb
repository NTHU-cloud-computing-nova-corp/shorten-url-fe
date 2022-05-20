# frozen_string_literal: true

require 'roda'
require_relative './app'
require_relative '../exception/AppException'

module UrlShortener
  # Web controller for UrlShortener API
  class App < Roda
    route('urls') do |routing|
      routing.on do
        routing.get do
          urls = UrlsServices.new(App.config).get(@current_account)
          statuses = UrlsServices.new(App.config).statuses(@current_account)
          view 'url', locals: { urls:, statuses: }
        end

        routing.post 'delete' do
          UrlsServices.new(App.config).delete(@current_account, routing.params['delete-short-url'])

          flash[:notice] = 'URL has been deleted!'
          routing.redirect '/urls'
        end

        routing.post do
          result = UrlsServices.new(App.config).create(@current_account, routing.params['long_url'], routing.params['description'])

          flash[:notice] = 'URL created!'
          view 'home',
               locals: { short_url: "#{request.base_url}/#{result['short_url']}",
                         long_url: result['long_url'],
                         description: result['description'],
                         current_account: self.get_current_account }
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
end
