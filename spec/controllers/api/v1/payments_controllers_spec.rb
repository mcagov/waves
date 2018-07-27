require "rails_helper"

describe Api::V1::PaymentsController, type: :controller do
  context "#create" do
    before do
      create(:incomplete_submission, id: "240cdfa3-c930-4829-99a0-6c160a631d2d")
      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers

      params = JSON.parse(File.read("spec/fixtures/new_payment.json"))
      post :create, params: params
    end

    it "sets the content type" do
      expect(response.content_type).to eq("application/json")
    end

    it "assigns the submission_id" do
      expect(assigns(:payment).submission_id).to be_present
    end
  end
end
