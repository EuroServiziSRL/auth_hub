require 'test_helper'

module AuthHub
  class ApplicazioniEntesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @applicazioni_ente = auth_hub_applicazioni_ente(:one)
    end

    test "should get index" do
      get applicazioni_ente_index_url
      assert_response :success
    end

    test "should get new" do
      get new_applicazioni_ente_url
      assert_response :success
    end

    test "should create applicazioni_ente" do
      assert_difference('ApplicazioniEnte.count') do
        post applicazioni_ente_index_url, params: { applicazioni_ente: {  } }
      end

      assert_redirected_to applicazioni_ente_url(ApplicazioniEnte.last)
    end

    test "should show applicazioni_ente" do
      get applicazioni_ente_url(@applicazioni_ente)
      assert_response :success
    end

    test "should get edit" do
      get edit_applicazioni_ente_url(@applicazioni_ente)
      assert_response :success
    end

    test "should update applicazioni_ente" do
      patch applicazioni_ente_url(@applicazioni_ente), params: { applicazioni_ente: {  } }
      assert_redirected_to applicazioni_ente_url(@applicazioni_ente)
    end

    test "should destroy applicazioni_ente" do
      assert_difference('ApplicazioniEnte.count', -1) do
        delete applicazioni_ente_url(@applicazioni_ente)
      end

      assert_redirected_to applicazioni_ente_index_url
    end
  end
end
