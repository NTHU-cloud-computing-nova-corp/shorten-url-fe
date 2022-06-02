# frozen_string_literal: true

require 'http'

module UrlShortener
  # Returns an authenticated user, or nil
  class AuthenticateGoogleAccount
    def initialize(config, session)
      @config = config
      @session = session
    end

    def call(access_token:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate-sso", json: { access_token: })
      Authenticate.new(@config, @session).call(response:)
    rescue HTTP::ConnectionError
      raise Exceptions::ApiServerError
    end
  end
end
