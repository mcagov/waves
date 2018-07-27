require "rails_helper"

describe Submission::SignaturesController, type: :controller do
  before do
    sign_in claimant
  end

  let!(:claimant) { create(:user) }

  describe "#update" do
    let!(:submission) { create(:submission, state: :assigned) }

    context "for a valid change_vessel" do
      let!(:registered_vessel) { create(:registered_vessel) }

      before do
        patch :update,
              params: {
                submission_id: submission.id,
                submission: {
                  application_type: :change_vessel,
                  vessel_reg_no: registered_vessel.reg_no } }
      end

      it "redirects_to submissions#show" do
        expect(response).to redirect_to(submission_path(submission))
      end
    end

    context "when the vessel is invalid" do
      before do
        patch :update,
              params: {
                submission_id: submission.id,
                submission: {
                  application_type: :change_vessel,
                  vessel_reg_no: "foo" } }
      end

      it "renders the edit template" do
        expect(response).to render_template(:show)
      end
    end
  end
end
