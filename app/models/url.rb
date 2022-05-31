# frozen_string_literal: true

module UrlShortener
  module Models
    # Behaviors of the currently logged in account
    class Url
      attr_reader :id, :name, :repo_url

      def initialize(proj_info)
        @id = proj_info['attributes']['id']
        @short_url = proj_info['attributes']['short_url']
        @long_url = proj_info['attributes']['long_url']
        @description = proj_info['attributes']['description']
      end
    end
  end
end
