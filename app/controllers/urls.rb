# frozen_string_literal: true

require 'roda'
require_relative './app'

module UrlShortener
  # Web controller for UrlShortener API
  class App < Roda
    route('urls') do |routing|
      routing.on do
        routing.get do
          updated_url = routing.params['updated_url']
          urls = Services::Urls.new(App.config).get(@current_account)

          urls = Services::Urls.new(App.config).modify_url(urls, updated_url)
          statuses = Services::Urls.new(App.config).statuses(@current_account)
          view 'url', locals: { urls:, statuses:, updated_url: }
        end

        routing.post 'delete' do
          Services::Urls.new(App.config).delete(@current_account, routing.params['delete_short_url'])

          flash[:notice] = 'URL has been deleted!'
          routing.redirect '/urls'
        end

        routing.post 'update' do
          Services::Urls.new(App.config).update(@current_account,
                                                routing.params)
          flash[:notice] = 'URL Updated!'
          session[:affected_url] = routing.params['short_url']

          routing.redirect "/urls?updated_url=#{routing.params['update_short_url']}"
        end

        routing.post 'lock' do
          Services::Urls.new(App.config).lock(@current_account,
                                              routing.params)
          flash[:notice] = 'URL Locked!'
          # routing.redirect '/urls'
          routing.redirect "/urls?updated_url=#{routing.params['lock_short_url']}"
        end

        routing.post 'open' do
          Services::Urls.new(App.config).open(@current_account,
                                              routing.params)
          flash[:notice] = 'URL is public!'
          session[:affected_url] = routing.params['short_url']

          # routing.redirect '/urls'
          routing.redirect "/urls?updated_url=#{routing.params['open_short_url']}"
        end

        routing.post 'privatise' do
          Services::Urls.new(App.config).privatise(@current_account,
                                                   routing.params)
          flash[:notice] = 'URL is private!'
          session[:affected_url] = routing.params['short_url']

          # routing.redirect '/urls'
          routing.redirect "/urls?updated_url=#{routing.params['privatise_short_url']}"
        end

        routing.post 'share' do
          Services::Urls.new(App.config).share(@current_account,
                                               routing.params)
          flash[:notice] = 'URL Shared!'
          session[:affected_url] = routing.params['short_url']
          # routing.redirect '/urls'
          routing.redirect "/urls?updated_url=#{routing.params['share_short_url']}"
        end

        routing.post 'invite' do
          Services::Urls.new(App.config).invite(@current_account,
                                                routing.params)
          flash[:notice] = 'Invitation sent!'
          # routing.redirect '/urls'
          routing.redirect "/urls?updated_url=#{routing.params['invite_short_url']}"
        end

        routing.post do
          result = Services::Urls.new(App.config).create(@current_account, routing.params['long_url'], routing.params['description'])

          flash.now[:notice] = 'URL created!'
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
