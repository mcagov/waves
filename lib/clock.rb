require "clockwork"

# Require the full rails environment if needed
require "./config/boot"
require "./config/environment"

include Clockwork

every 1.day, "daily_jobs", at: "04:30" do
  rake "waves:unclaim_claimed_submissions"
  rake "waves:expire_referrals"
  rake "waves:process_reminders"
  rake "waves:close_terminated_vessels"
end
