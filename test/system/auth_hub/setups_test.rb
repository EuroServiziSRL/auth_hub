require "application_system_test_case"

module AuthHub
  class SetupsTest < ApplicationSystemTestCase
    setup do
      @setup = auth_hub_setups(:one)
    end

    test "visiting the index" do
      visit setups_url
      assert_selector "h1", text: "Setups"
    end

    test "creating a Setup" do
      visit setups_url
      click_on "New Setup"

      click_on "Create Setup"

      assert_text "Setup was successfully created"
      click_on "Back"
    end

    test "updating a Setup" do
      visit setups_url
      click_on "Edit", match: :first

      click_on "Update Setup"

      assert_text "Setup was successfully updated"
      click_on "Back"
    end

    test "destroying a Setup" do
      visit setups_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Setup was successfully destroyed"
    end
  end
end
