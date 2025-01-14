require 'test_helper'

class WebflowClientTest < Minitest::Test
  def test_it_prefers_given_token_over_configured_api_token
    Webflow.config.api_token = 'api_token'

    client = Webflow::Client.new('given_token')

    assert_equal('given_token', client.instance_variable_get('@token'))
  end

  def test_it_uses_configured_api_token_when_token_is_not_given
    Webflow.config.api_token = 'api_token'

    client = Webflow::Client.new

    assert_equal('api_token', client.instance_variable_get('@token'))
  end

  def test_it_raises_rate_limit_errors
    VCR.use_cassette('test_it_raises_rate_limit_errors') do
      client = Webflow::Client.new(ENV.fetch('TEST_API_TOKEN'))
      # Retries once and fails after that
      assert_raises(Webflow::RateLimitError) do
        client.sites
      end
    end
  end
end
