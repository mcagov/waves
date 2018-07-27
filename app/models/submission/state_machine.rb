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
        state :cancelled

        # This state is used when initializing a new submission.
        # This prevents the :incomplete enter: build_defaults
        # from firing.
        state :initializing

        event :unassigned do
          transitions to: :unassigned, from: :incomplete,
                      guard: :actionable?
        end

        event :claimed do
          transitions to: :assigned,
                      from: [:unassigned, :cancelled],
                      on_transition: :add_claimant
        end

        event :unreferred do
          transitions to: :unassigned, from: :referred
        end

        event :unclaimed do
          transitions to: :unassigned, from: :assigned,
                      on_transition: :remove_claimant
        end

        event :approved, timestamp: :completed_at do
          transitions to: :completed, from: :assigned,
                      on_transition: :process_application,
                      guard: :approvable?
        end

        event :approve_electronic_delivery do
          transitions to: :completed, from: :unassigned,
                      on_transition: :process_application
        end

        event :cancelled do
          transitions to: :cancelled, from: :assigned,
                      on_transition: [
                        :remove_claimant,
                        :cancel_name_approval,
                        :remove_pending_vessel]
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
