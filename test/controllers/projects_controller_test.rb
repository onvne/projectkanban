require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:one)
    sign_in @user
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference -> { @user.projects.count }, 1 do
      post projects_url, params: {
        project: { title: "New Project", description: "Description" }
      }
    end

    assert_redirected_to root_path
    assert_equal "Project 'New Project' was successfully created.", flash[:notice]
  end

  test "should not create project with blank title" do
    assert_no_difference -> { @user.projects.count } do
      post projects_url, params: { project: { title: "", description: "Description" } }
    end

    assert_redirected_to root_path
    assert flash[:alert].present?
  end

  test "should destroy own project" do
    assert_difference -> { Project.count }, -1 do
      assert_difference -> { Task.count }, -2 do
        delete project_url(@project)
      end
    end

    assert_redirected_to root_path
    assert_equal "Project 'First Project' was deleted.", flash[:notice]
  end

  test "should not destroy another users project" do
    other_project = projects(:two)

    assert_no_difference -> { Project.count } do
      delete project_url(other_project)
    end

    assert_response :not_found
  end

  test "requires authentication" do
    sign_out @user

    delete project_url(@project)
    assert_redirected_to new_user_session_path
  end
end
