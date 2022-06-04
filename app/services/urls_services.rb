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

      def shared_urls(current_account)
        response = HTTP.auth("Bearer #{current_account.auth_token}")
                       .get("#{@config.API_URL}/urls/shared_urls")
        raise Exceptions::UnauthorizedError unless response.status.code == 200

        JSON.parse(response.to_s)['data']
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

      def update(current_account, params)
        short_url = params['update_short_url']
        long_url = params['update_long_url']
        tags = params['update_tags']
        description = params['update_description']

        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/update",
                                                                          json: { short_url:, long_url:,
                                                                                  description:, tags: })

        raise Exceptions::ApiServerError unless response.status.code == 200
      end

      def lock(current_account, params)
        short_url = params['lock_short_url']
        password = params['password']
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/lock",
                                                                          json: { password: })

        raise Exceptions::ApiServerError unless response.status.code == 200
      end

      def open(current_account, params)
        short_url = params['open_short_url']
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/open")

        raise Exceptions::ApiServerError unless response.status.code == 200
      end

      def privatise(current_account, params)
        short_url = params['privatise_short_url']
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/privatise")

        raise Exceptions::ApiServerError unless response.status.code == 200
      end

      def share(current_account, params)
        short_url = params['share_short_url']
        emails = params['share_email_url']
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/share",
                                                                          json: { emails: })

        raise Exceptions::ApiServerError unless response.status.code == 200
      end

      def invite(current_account, params)
        short_url = params['invite_short_url']
        emails = params['invite_emails']
        message = params['invite_message']
        response = HTTP.auth("Bearer #{current_account.auth_token}").post("#{@config.API_URL}/urls/#{short_url}/invite",
                                                                          json: { emails:, message: })

        raise Exceptions::ApiServerError unless response.status.code == 200
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
