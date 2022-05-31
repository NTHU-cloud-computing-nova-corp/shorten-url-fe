# frozen_string_literal: true

require 'roda'
require_relative './app'

module UrlShortener
  # Web controller for UrlShortener API
  class App < Roda
    route('error') do |routing|
      routing.on do
        routing.get '404' do
          view 'error/404'
        end
      end
    end
  end
end
