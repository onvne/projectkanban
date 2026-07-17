require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "requires title" do
    project = Project.new(user: users(:one))
    assert_not project.valid?
    assert_includes project.errors[:title], "can't be blank"
  end

  test "destroys dependent tasks" do
    project = projects(:one)
    assert project.tasks.any?

    assert_difference -> { Task.count }, -project.tasks.count do
      project.destroy
    end
  end
end
