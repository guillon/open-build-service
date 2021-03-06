require File.expand_path(File.dirname(__FILE__) + "/..") + "/test_helper"

class ConfigurationsControllerTest < ActionController::IntegrationTest
  def setup
    prepare_request_valid_user
  end

  def test_show_and_update_configuration
    get '/configuration'
    assert_response :success
    config = @response.body
    put '/configuration?title="openSUSE Build Service"&description="Long description"', config
    assert_response 403 # Normal users can't change site-wide configuration
    prepare_request_with_user 'king', 'sunflower' # User with admin rights
    put '/configuration?title="openSUSE Build Service"&description="Long description"', config
    assert_response :success
  end
end
