# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do
  before do
    @credentials = { username: 'ernesto', password: 'admin' }
    @mal_credentials = { username: 'ernesto', password: 'wrongpassword' }
    @api_account = { username: 'ernesto', email: 'ernesto@nthu.edu.tw' }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      auth_account_file = 'spec/fixtures/auth_account.json'

      auth_return_json = File.read(auth_account_file)

      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @credentials.to_json)
             .to_return(body: auth_return_json,
                        headers: { 'content-type' => 'application/json' })

      auth = UrlShortener::AuthenticateAccount.new.call(**@credentials)

      _(auth.account_info).wont_be_nil
      _(auth.account_info['username']).must_equal @api_account[:username]
      _(auth.account_info['email']).must_equal @api_account[:email]
    end

    it 'BAD: should not find a false authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @mal_credentials.to_json)
             .to_return(status: 401)
      _(proc {
        UrlShortener::AuthenticateAccount.new.call(**@mal_credentials)
      }).must_raise UrlShortener::Exceptions::UnauthorizedError
    end
  end
end
