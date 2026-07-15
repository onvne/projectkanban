class Task < ApplicationRecord
  belongs_to :project

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    in_testing: "in_testing",
    done: "done",
    rejected: "rejected"
  }, default: :todo

  # 1. The Global Rules (For the Dropdown and Validation)
  ALLOWED_TRANSITIONS = {
    "todo" => [ "in_progress" ],
    "in_progress" => [ "in_testing", "todo" ],
    "in_testing" => [ "done", "rejected" ],
    "done" => [],
    "rejected" => [ "in_progress" ]
  }.freeze

  # 2. Arrow Maps: Defines exactly what "Next" and "Previous" mean for each state
  NEXT_STATUS_MAP = {
    "todo" => "in_progress",
    "in_progress" => "in_testing",
    "in_testing" => "done",
    "rejected" => "in_progress"
  }.freeze

  PREVIOUS_STATUS_MAP = {
    "in_progress" => "todo",
    "in_testing" => "rejected"
  }.freeze

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validate :valid_status_transition, if: :status_changed?

  # ==========================================
  # Dropdown Helpers
  # ==========================================

  # Returns raw strings of allowed target statuses: e.g., ["in_testing", "todo"]
  def allowed_transitions
    ALLOWED_TRANSITIONS[status] || []
  end

  # Formats the allowed statuses for a standard Rails form dropdown select
  # e.g., [["In Testing", "in_testing"], ["To Do", "todo"]]
  def allowed_transitions_for_select
    allowed_transitions.map { |state| [ state.titleize, state ] }
  end

  # ==========================================
  # Arrow Button Helpers
  # ==========================================

  def can_move_forward?
    NEXT_STATUS_MAP.key?(status)
  end

  def can_move_backward?
    PREVIOUS_STATUS_MAP.key?(status)
  end

  def move_forward!
    return false unless can_move_forward?
    update(status: NEXT_STATUS_MAP[status])
  end

  def move_backward!
    return false unless can_move_backward?
    update(status: PREVIOUS_STATUS_MAP[status])
  end

  private

  def valid_status_transition
    return if new_record?

    old_status = status_was
    new_status = status

    allowed_next_states = ALLOWED_TRANSITIONS[old_status] || []

    unless allowed_next_states.include?(new_status)
      errors.add(:status, "cannot change from '#{old_status}' to '#{new_status}'.")
    end
  end
end
