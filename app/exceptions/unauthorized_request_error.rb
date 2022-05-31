# frozen_string_literal: true

module UrlShortener
  module Exceptions
    # Bad request exception
    class UnauthorizedError < StandardError
      def initialize(msg = 'Unauthorized Request', exception_type = 'custom')
        @exception_type = exception_type
        @status_code = 400
        super(msg)
      end
    end
  end
end
