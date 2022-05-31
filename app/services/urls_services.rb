# frozen_string_literal: true

require 'http'

module UrlShortener
  module Services
    # Returns all urls belonging to an account
    class Urls
      def initialize(config)
        @config = config
      end

      def get(current_account)
        response = HTTP.auth("Bearer #{current_account.auth_token}")
                       .get("#{@config.API_URL}/urls")
        raise Exceptions::UnauthorizedError unless response.status.code == 200

        JSON.parse(response.to_s)['data'].map { |m| m['attributes'] }
      end

      def info(current_account, short_url)
        response = if current_account.auth_token.nil?
                     HTTP.get("#{@config.SHORT_URL}/#{short_url}")
                   else
                     HTTP.auth("Bearer #{current_account.auth_token}")
                         .get("#{@config.SHORT_URL}/#{short_url}")
                   end

        raise Exceptions::UnauthorizedError unless response.status.code == 200

        JSON.parse(response.to_s)['data']['attributes']
      end

      def unlock(password, short_url)
        response = HTTP.post("#{@config.SHORT_URL}/#{short_url}/unlock", json: { password: })

        raise Exceptions::UnauthorizedError unless response.status.code == 200

        JSON.parse(response.to_s)['data']['attributes']
      end

      def update(current_account,
                 short_url,
                 long_url,
                 status_code,
                 tags,
                 description)
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/update",
                                                                          json: { short_url:, long_url:, status_code:,
                                                                                  description:, tags: })

        raise Exceptions::ApiServerError unless response.status.code == 200

        @status_code = status_code
      end

      def create(current_account, long_url, description)
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls",
                                                                          json: { long_url:, description: })
        raise Exceptions::ApiServerError unless response.status.code == 201

        JSON.parse(response.to_s)['data']['attributes']
      end

      def delete(current_account, short_url)
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/delete")

        raise Exceptions::ApiServerError unless response.status.code == 200
      end

      def statuses(current_account)
        response = HTTP.auth("Bearer #{current_account.auth_token}").get("#{@config.API_URL}/statuses")
        raise Exceptions::ApiServerError unless response.status.code == 200

        JSON.parse(response.to_s)['data'].map { |m| m['data']['attributes'] }
      end

    end
  end
end
