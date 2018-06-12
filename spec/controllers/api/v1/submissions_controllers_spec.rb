require "rails_helper"

describe Api::V1::SubmissionsController, type: :controller do
  context "#create" do
    before do
      headers = { "ACCEPT" => "application/json" }
      request.headers.merge! headers

      params = JSON.parse(File.read("spec/fixtures/new_registration.json"))
      post :create, params: params
    end

    it "sets the content type" do
      expect(response.content_type).to eq("application/json")
    end

    it "assigns the changeset" do
      expect(assigns(:submission).changeset).to be_present
    end

    it "assigns the vessel name" do
      expect(assigns(:submission).vessel.name).to be_present
    end

    it "assigns the applicant_name" do
      expect(assigns(:submission).applicant_name)
        .to eq("HORATIO NELSON")
    end

    it "assigns the applicant_email" do
      expect(assigns(:submission).applicant_email)
        .to eq("horatio-nelson.1@example.com")
    end
  end
end
