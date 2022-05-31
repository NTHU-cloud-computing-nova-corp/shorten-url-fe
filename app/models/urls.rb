# frozen_string_literal: true

require_relative 'url'

module UrlShortener
  module Models
    # Behaviors of the currently logged in account
    class Urls
      attr_reader :all

      def initialize(projects_list)
        @all = projects_list.map do |url|
          Url.new(url)
        end
      end
    end
  end
end
