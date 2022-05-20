# frozen_string_literal: true

# Returns an authenticated user, or nil
class AppException
  # Returns an unauthorizedError user, or nil
  class UnauthorizedError < StandardError
    def message = 'Incorrect username and password: please login again'
  end

  # Returns an API error
  class ApiServerError < StandardError
    def message = 'Unknown error: please try again'
  end

  # Returns a notfound error
  class NotFoundError < StandardError
    def message = 'Unknown error: please try again'
  end
end
