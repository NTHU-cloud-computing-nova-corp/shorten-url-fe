# frozen_string_literal: true

require 'http'

module UrlShortener
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    def initialize(config, session)
      @config = config
      @session = session
    end

    def call(username:, password:)
      response = HTTP.post("#{@config.API_URL}/auth/authenticate", json: { username:, password: })
      Authenticate.new(@config, @session).call(response:)
    rescue HTTP::ConnectionError
      raise Exceptions::ApiServerError
    end
  end
end