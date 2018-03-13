require 'test_helper'

module AuthHub
  class EntiGestitiControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @ente_gestito = auth_hub_enti_gestiti(:one)
    end

    test "should get index" do
      get enti_gestiti_url
      assert_response :success
    end

    test "should get new" do
      get new_ente_gestito_url
      assert_response :success
    end

    test "should create ente_gestito" do
      assert_difference('EnteGestito.count') do
        post enti_gestiti_url, params: { ente_gestito: { destroy: @ente_gestito.destroy, show: @ente_gestito.show } }
      end

      assert_redirected_to ente_gestito_url(EnteGestito.last)
    end

    test "should show ente_gestito" do
      get ente_gestito_url(@ente_gestito)
      assert_response :success
    end

    test "should get edit" do
      get edit_ente_gestito_url(@ente_gestito)
      assert_response :success
    end

    test "should update ente_gestito" do
      patch ente_gestito_url(@ente_gestito), params: { ente_gestito: { destroy: @ente_gestito.destroy, show: @ente_gestito.show } }
      assert_redirected_to ente_gestito_url(@ente_gestito)
    end

    test "should destroy ente_gestito" do
      assert_difference('EnteGestito.count', -1) do
        delete ente_gestito_url(@ente_gestito)
      end

      assert_redirected_to enti_gestiti_url
    end
  end
end
