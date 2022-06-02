# frozen_string_literal: true

require 'roda'
require_relative './app'

module UrlShortener
  # Web controller for UrlShortener API
  class App < Roda
    route('urls') do |routing|
      routing.on do
        routing.get do
          urls = Services::Urls.new(App.config).get(@current_account)
          statuses = Services::Urls.new(App.config).statuses(@current_account)
          view 'url', locals: { urls:, statuses: }
        end

        routing.post 'delete' do
          Services::Urls.new(App.config).delete(@current_account, routing.params['delete_short_url'])

          flash[:notice] = 'URL has been deleted!'
          routing.redirect '/urls'
        end

        routing.post 'update' do
          Services::Urls.new(App.config).update(@current_account,
                                                routing.params)
          flash[:notice] = 'URL updated!'
          routing.redirect '/urls'
        end

        routing.post 'lock' do
          Services::Urls.new(App.config).lock(@current_account,
                                              routing.params)
          flash[:notice] = 'URL Locked!'
          routing.redirect '/urls'
        end

        routing.post 'open' do
          Services::Urls.new(App.config).open(@current_account,
                                              routing.params)
          flash[:notice] = 'URL is public!'
          routing.redirect '/urls'
        end

        routing.post 'privatise' do
          Services::Urls.new(App.config).privatise(@current_account,
                                                   routing.params)
          flash[:notice] = 'URL is private!'
          routing.redirect '/urls'
        end

        routing.post 'share' do
          Services::Urls.new(App.config).share(@current_account,
                                               routing.params)
          flash[:notice] = 'URL is shared!'
          routing.redirect '/urls'
        end

        routing.post 'invite' do
          Services::Urls.new(App.config).invite(@current_account,
                                               routing.params)
          flash[:notice] = 'Invitation sent!'
          routing.redirect '/urls'
        end

        routing.post do
          result = Services::Urls.new(App.config).create(@current_account, routing.params['long_url'], routing.params['description'])

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
