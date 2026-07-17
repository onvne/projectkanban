class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable
  has_many :projects, dependent: :destroy
  has_many :tasks, through: :projects

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :set_create_time
  before_save :update_last_activity

  def active?
    last_activity_time > 30.minutes.ago
  end

  def total_projects_count
    projects.count
  end

  private

  def set_create_time
    self.create_time ||= Time.current
  end

  def update_last_activity
    self.last_activity_time = Time.current if changed?
  end
end
