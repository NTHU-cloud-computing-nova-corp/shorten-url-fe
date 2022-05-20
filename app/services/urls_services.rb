# frozen_string_literal: true

require 'http'
require_relative '../exception/AppException'

# Returns all urls belonging to an account
class UrlsServices
  def initialize(config)
    @config = config
  end

  def get(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.API_URL}/urls")

    JSON.parse(response.to_s)['data'].map { |m| m['attributes'] }
  end

  def call(current_account, short_url)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .get("#{@config.SHORT_URL}/#{short_url}")
    raise AppException::UnauthorizedError unless response.status.code == 200

    JSON.parse(response.to_s)['data']['attributes']
  end

  def create(current_account, long_url, description)
    HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls",
                                                           json: { long_url:, description: })
    raise AppException::ApiServerError unless response.status.code == 200
  end

  def delete(current_account, short_url)
    HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/delete")

    raise AppException::ApiServerError unless response.status.code == 200
  end

  def statuses(current_account)
    response = HTTP.auth("Bearer #{current_account.auth_token}").get("#{@config.API_URL}/statuses")
    raise AppException::UnauthorizedError unless response.status.code == 200

    JSON.parse(response.to_s)['data'].map { |m| m['data']['attributes'] }
  end

end
