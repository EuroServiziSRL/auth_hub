require 'test_helper'

module AuthHub
  class SuperadminControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get superadmin_index_url
      assert_response :success
    end

  end
end
