require "rails_helper"

describe Submission::ApprovalsController, type: :controller do
  before do
    sign_in claimant
  end

  let!(:claimant) { create(:user) }

  describe "in general" do
    context "#create" do
      let(:submission) { create(:assigned_submission) }

      let(:approval_params) do
        {
          notification_attachments: "foo",
          registration_starts_at: "1/1/2011",
          closure_at: "2/2/2022",
          closure_reason: "some text",
        }
      end

      let(:params) do
        {
          submission_id: submission.id,
          submission_approval: approval_params,
        }
      end

      context "succesfully" do
        before do
          allow_any_instance_of(Submission)
            .to receive(:approved!)
            .with(approval_params)
            .and_return(true)

          expect(Registration)
            .to receive(:find_by)
            .and_return(double(:registration))

          post :create, params: params
        end

        it "redirects to the registration page" do
          expect(response).to redirect_to(/registrations/)
        end

        it "creates a notification for the applicant" do
          expect(Notification::ApplicationApproval.count).to eq(1)
        end

        it "sets the notification#actioned_by" do
          expect(Notification::ApplicationApproval.first.actioned_by)
            .to eq(claimant)
        end
      end

      context "unsuccessfully" do
        before do
          allow_any_instance_of(Submission)
            .to receive(:approved!).and_return(false)
          post :create, params: params
        end

        it "is still :assigned" do
          expect(assigns[:submission]).to be_assigned
        end

        it "renders the errors page" do
          expect(response).to render_template("errors")
        end
      end
    end
  end
end