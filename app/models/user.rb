class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :trackable, :validatable,
         :recoverable, :rememberable

  enum access_level:
    [:read_only, :operational_user, :team_leader, :system_manager]

  validates :name, uniqueness: true, presence: true

  def to_s
    name
  end
end
