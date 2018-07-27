class WorkLog < ApplicationRecord
  belongs_to :submission_task,
             class_name: "Submission::Task",
             foreign_key: :submission_task_id

  belongs_to :actioned_by, class_name: "User"

  scope :in_part, ->(part) { where(part: part.to_sym) }

  validates :submission_task_id, presence: true
  validates :actioned_by_id, presence: true
  validates :part, presence: true

  class << self
    def for(submission_task)
      find_by(submission_task: submission_task)
    end
  end
end
