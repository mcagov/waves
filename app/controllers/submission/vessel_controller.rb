class Submission::VesselController < InternalPagesController
  before_action :load_submission_and_vessel

  def update
    @vessel.assign_attributes(Transformer.upcase_params(vessel_params))
    @submission.vessel = @vessel
    @submission.save

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  protected

  def load_submission_and_vessel
    @submission = Submission.find(params[:submission_id])
    @vessel = @submission.vessel
  end

  def vessel_params
    params.require(:vessel).permit(
      :name, :hin, :mmsi_number, :number_of_hulls,
      :make_and_model, :radio_call_sign, :vessel_type,
      :vessel_type_other, :length_in_meters)
  end
end