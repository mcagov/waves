# rubocop:disable all
module Submission::StateMachine
  class << self
    def included(base)
      base.include ActiveModel::Transitions

      base.state_machine auto_scopes: true do
        state :incomplete, enter: :build_defaults
        state :unassigned
        state :assigned
        state :referred
        state :completed
        state :referred
        state :cancelled

        event :unassigned do
          transitions to: :unassigned, from: :incomplete,
                      on_transition: :init_processing_dates,
                      guard: :actionable?
        end

        event :claimed do
          transitions to: :assigned,
                      from: [:unassigned, :cancelled],
                      on_transition: :add_claimant
        end

        event :unreferred do
          transitions to: :unassigned, from: :referred,
                      on_transition: :init_processing_dates
        end

        event :unclaimed do
          transitions to: :unassigned, from: :assigned,
                      on_transition: :remove_claimant
        end

        event :approved do
          transitions to: :completed, from: :assigned,
                      on_transition: :process_application,
                      guard: :approvable?
        end

        event :cancelled do
          transitions to: :cancelled, from: :assigned,
                      on_transition: :remove_claimant
        end

        event :referred do
          transitions to: :referred, from: :assigned,
                      on_transition: :remove_claimant
        end
      end
    end
  end
end
# rubocop:enable all