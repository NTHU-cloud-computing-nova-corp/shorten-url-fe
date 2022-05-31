# frozen_string_literal: true

require 'roda'
require 'slim'

module UrlShortener
  # Base class for UrlShortener Web Application
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :public, root: 'app/presentation/public'
    plugin :multi_route
    plugin :flash

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = Models::CurrentSession.new(session).current_account
      @current_route = routing.instance_variable_get(:@remaining_path)

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: @current_account }
      end

      routing.on String do |short_url|
        routing.redirect '/error/404' if short_url == 'favicon.ico' || short_url.length != 5
        @url = Services::Urls.new(App.config).info(@current_account, short_url)

        routing.post 'unlock' do
          password = routing.params['password']
          Services::Urls.new(App.config).unlock(password, short_url)

          routing.redirect @url['long_url'], 301 # use 301 Moved Permanently
        rescue StandardError
          flash[:error] = 'Incorrect password! Please try again'
          routing.redirect "/#{short_url}"
        end

        routing.get do
          if @url['status_code'].eql?('L')
            view :unlock_url, locals: { short_url: }
          else
            routing.redirect @url['long_url'], 301 # use 301 Moved Permanently
          end
        end

      end
    rescue Exceptions::ApiServerError => e
      App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
      flash[:error] = e.message
      response.status = e.instance_variable_get(:@status_code)
      routing.redirect '/'
    rescue Exceptions::UnauthorizedError, Exceptions::BadRequestError => e
      flash.now[:error] = "Error: #{e.message}"
      response.status = e.instance_variable_get(:@status_code)
      view :login
    end

    def get_current_account
      current_account = @current_account.account_info

      current_account['attributes'] unless current_account.nil?
    end
  end
end
