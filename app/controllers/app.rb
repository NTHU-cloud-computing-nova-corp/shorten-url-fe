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
      @current_account = CurrentSession.new(session).current_account
      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: self.get_current_account }
      end

      routing.get String do |short_url|
        routing.redirect '/error/404' if short_url == 'favicon.ico' || short_url.length != 5

        url = UrlsServices.new(App.config).call(@current_account, short_url)
        routing.redirect url['long_url'], 301 # use 301 Moved Permanently
      end
    rescue AppException::NotFoundError => e
      routing.redirect '/error/404'
    rescue AppException::UnauthorizedError => e
      flash[:error] = e.message
    end

    def get_current_account
      current_account = @current_account.account_info

      current_account['attributes'] unless current_account.nil?
    end
  end
end
