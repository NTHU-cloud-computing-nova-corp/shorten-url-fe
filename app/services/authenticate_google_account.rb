# frozen_string_literal: true

require 'http'

module UrlShortener
  # Returns an authenticated user, or nil
  class AuthenticateGoogleAccount
    def initialize(config)
      @config = config
    end

    def call(access_token:)
      response = HTTP.post("#{ENV.fetch('API_URL', nil)}/auth/authenticate-sso", json: { access_token: })
      Authenticate.new.call(response:)
    rescue HTTP::ConnectionError
      raise Exceptions::ApiServerError
    end
  end
end
