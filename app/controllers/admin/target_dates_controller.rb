class Admin::TargetDatesController < InternalPagesController
  def index
    @holidays = Holiday.all
    @start_date = start_date_params if params[:start_date]
    @start_date ||= Time.zone.today
  end

  private

  def start_date_params
    Date.civil(
      params[:start_date][:year].to_i,
      params[:start_date][:month].to_i,
      params[:start_date][:day].to_i)
  rescue
    nil
  end
end
