# frozen_string_literal: true

require 'http'

module UrlShortener
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    def call(username:, password:)
      response = HTTP.post("#{ENV.fetch('API_URL', nil)}/auth/authenticate", json: { username:, password: })
      raise Exceptions::UnauthorizedError if response.code == 401

      Authenticate.new.call(response:)
    rescue HTTP::ConnectionError
      raise Exceptions::ApiServerError
    end
  end
end
