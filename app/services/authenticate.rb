# frozen_string_literal: true

require 'http'

module UrlShortener
  # Returns an authenticated user, or nil
  class Authenticate
    def initialize(config, session)
      @config = config
      @session = session
    end

    def call(response:)
      response_data = JSON.parse(response.to_s)

      raise Exceptions::UnauthorizedError, response_data['message'] if response.code == 403
      raise Exceptions::BadRequestError if response.code == 400
      raise Exceptions::ApiServerError if response.code != 200

      account_info = response_data['attributes']
      current_account = Models::Account.new(account_info['account']['attributes'],
                                            account_info['auth_token'])

      Models::CurrentSession.new(@session).current_account = current_account
      current_account
    rescue HTTP::ConnectionError
      raise Exceptions::ApiServerError
    end
  end
end
