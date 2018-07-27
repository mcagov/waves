class RegistrationDate
  class << self
    def for(submission, starts_at)
      @submission = submission
      @starts_at = starts_at.to_datetime

      RegistrationDate.new(starts_at, ends_at)
    end

    def start_date(submission)
      registered_vessel = submission.registered_vessel
      return Time.zone.now unless registered_vessel.try(:registered_until)

      if registered_vessel.registered_until < 3.months.from_now
        registered_vessel.registered_until
      else
        Time.zone.now
      end
    end

    private

    def ends_at
      task = DeprecableTask.new(@submission.task)

      if task.provisional_registration?
        @starts_at.advance(days: 90)
      elsif task.change_vessel?
        @submission.registered_vessel.registered_until
      else
        @starts_at.advance(years: 5)
      end
    end
  end

  attr_reader :starts_at, :ends_at

  def initialize(starts_at, ends_at)
    @starts_at = ensure_date(starts_at)
    @ends_at = ends_at
  end

  private

  def ensure_date(input_date)
    input_date = DateTime.zone.now if input_date.blank?
    input_date.to_datetime
  end
end
