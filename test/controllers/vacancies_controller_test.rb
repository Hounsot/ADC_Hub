require "test_helper"

class VacanciesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get vacancies_index_url
    assert_response :success
  end

  test "should get show" do
    get vacancies_show_url
    assert_response :success
  end

  test "should get new" do
    get vacancies_new_url
    assert_response :success
  end

  test "should get create" do
    get vacancies_create_url
    assert_response :success
  end

  test "should get edit" do
    get vacancies_edit_url
    assert_response :success
  end

  test "should get update" do
    get vacancies_update_url
    assert_response :success
  end

  test "should get destroy" do
    get vacancies_destroy_url
    assert_response :success
  end
end
