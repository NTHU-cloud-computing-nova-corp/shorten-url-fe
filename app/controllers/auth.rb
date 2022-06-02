# frozen_string_literal: true

require 'roda'
require_relative './app'

require 'google/apis/gmail_v1'

module UrlShortener
  # Web controller for UrlShortener API
  class App < Roda
    def gg_oauth_url(config, short_url = '')
      client = Signet::OAuth2::Client.new({
                                            client_id: config.GOOGLE_API_CLIENT_ID,
                                            client_secret: config.GOOGLE_API_CLIENT_SECRET,
                                            authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
                                            scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
                                            state: short_url,
                                            redirect_uri: "http://127.0.0.1:9292/auth/sso_callback"
                                          })
      client.authorization_uri.to_s
    end

    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.on 'login' do

        # GET /auth/login
        routing.on String do |short_url|
          routing.get do
            view :login, locals: {
              gg_oauth_url: gg_oauth_url(App.config, short_url).to_s
            }
          end
        end

        routing.get do
          view :login, locals: {
            gg_oauth_url: gg_oauth_url(App.config)
          }
        end

        # POST /auth/login
        routing.post do
          short_url_redirect = session[:short_url_tmp]
          session[:short_url_tmp] = nil

          current_account = AuthenticateAccount.new(App.config, session).call(
            username: routing.params['username'],
            password: routing.params['password']
          )

          flash[:notice] = "Welcome back #{current_account.username}!"
          if short_url_redirect.nil?
            routing.redirect '/'
          else
            routing.redirect "/#{short_url_redirect}"
          end
        rescue Exceptions::UnauthorizedError
          flash.now[:error] = 'Username and password did not match our records'
          response.status = 401
          view :login
        rescue Exceptions::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @oauth_callback = '/auth/sso_callback'
      routing.on 'sso_callback' do
        client = Signet::OAuth2::Client.new({
                                              client_id: App.config.GOOGLE_API_CLIENT_ID,
                                              client_secret: App.config.GOOGLE_API_CLIENT_SECRET,
                                              token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                              redirect_uri: 'http://127.0.0.1:9292/auth/sso_callback',
                                              code: routing.params['code']
                                            })

        sso_response = client.fetch_access_token!
        session[:access_token] = sso_response['access_token']
        current_account = AuthenticateGoogleAccount.new(App.config, session).call(
          access_token: sso_response['access_token']
        )

        flash[:notice] = "Welcome #{current_account.username}!"

        # GET /auth/sso_callback
        routing.get do
          routing.redirect "/#{routing['state']}"
        rescue Exceptions::UnauthorizedError
          flash[:error] = 'Could not login with Github'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end

      @logout_route = '/auth/logout'
      routing.is 'logout' do
        # GET /auth/logout
        routing.get do
          Models::CurrentSession.new(session).delete
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            account_data = JsonRequestBody.symbolize(routing.params)
            VerifyRegistration.new(App.config).call(account_data)

            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue VerifyRegistration::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            routing.redirect @register_route
          rescue StandardError => e
            App.logger.error "Could not verify registration: #{e.inspect}"
            flash[:error] = 'Registration details are not valid'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          new_account = SecureMessage.decrypt(registration_token)
          view :register_confirm,
               locals: { new_account:,
                         registration_token: }
        end
      end
    end
  end
end
