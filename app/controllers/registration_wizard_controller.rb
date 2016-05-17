class RegistrationWizardController < ApplicationController
  include Wicked::Wizard::Translated

  steps :prerequisites, :vessel_info, :owner_info

  def show
    case step
    when I18n.t("wicked.prerequisites")
      @registration = Registration.new
    when I18n.t("wicked.vessel_info")
      @registration = Registration.find(params[:registration_id])
    end

    render_wizard
  end

  def update
    @registration = Registration.create(
      prerequisite_params.merge(
        status: :initiated,
        browser: request.env["HTTP_USER_AGENT"] || "Unknown"
      )
    )

    redirect_to next_wizard_path(registration_id: @registration.id)
  end

  private

  def prerequisite_params
    params.require(:registration).permit(
      :not_registered_before_on_ssr,
      :not_registered_under_part_1,
      :owners_are_uk_residents,
      :user_eligible_to_register
    )
  end
end
