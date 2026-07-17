class Task < ApplicationRecord
  belongs_to :project

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    in_testing: "in_testing",
    done: "done",
    rejected: "rejected"
  }, default: :todo

  ALLOWED_TRANSITIONS = {
    "todo" => [ "in_progress" ],
    "in_progress" => [ "in_testing", "todo" ],
    "in_testing" => [ "done", "rejected" ],
    "done" => [],
    "rejected" => [ "in_progress" ]
  }.freeze

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

  validates :title, presence: true, length: { maximum: 100 }
  validate :valid_status_transition, if: :status_changed?

  def allowed_transitions
    ALLOWED_TRANSITIONS[status] || []
  end

  def allowed_transitions_for_select
    allowed_transitions.map { |state| [ state.titleize, state ] }
  end

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
