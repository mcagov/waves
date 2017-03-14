require "rails_helper"

describe SubmissionsController, type: :controller do
  before do
    sign_in user
  end

  let!(:user) { create(:user) }

  context "#create" do
    before do
      session[:current_activity] = :part_4
      post :create, params: {
        submission: {
          part: :part_4,
          received_at: "2001-1-1",
          task: :change_vessel } }
    end

    it "sets the state to unassigned" do
      expect(assigns(:submission)).to be_unassigned
    end

    it "sets the source to manual entry" do
      expect(assigns(:submission).source.to_sym).to eq(:manual_entry)
    end

    it "sets the part" do
      expect(assigns(:submission).part.to_sym).to eq(:part_4)
    end

    it "sets the task" do
      expect(assigns(:submission).task.to_sym).to eq(:change_vessel)
    end

    it "sets the received_at" do
      expect(assigns(:submission).received_at).to eq("2001-1-1")
    end
  end

  context "#show" do
    let(:readonly_double) { double(:readonly) }
    let(:submission) { create(:submission) }

    before do
      expect(Policies::Actions)
        .to receive(:readonly?)
        .with(submission, user)
        .and_return(readonly_double)

      get :show, params: { id: submission.id }
    end

    it "assigns @readonly to the readonly? Policy" do
      expect(assigns(:readonly)).to eq(readonly_double)
    end
  end
end
