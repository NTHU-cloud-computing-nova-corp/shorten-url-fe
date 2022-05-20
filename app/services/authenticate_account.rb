# frozen_string_literal: true

require 'http'

module UrlShortener
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    def initialize(config)
      @config = config
    end

    def call(username:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate",
                           json: { username:, password: })

      raise(AppException::UnauthorizedError) if response.code == 403
      raise(AppException::ApiServerError) if response.code != 200

      account_info = JSON.parse(response.to_s)['attributes']

      { account: account_info['account'],
        auth_token: account_info['auth_token'] }
    rescue HTTP::ConnectionError
      raise AppException::ApiServerError
    end
  end
end
