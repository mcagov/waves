class Submission::BeneficialOwnersController < InternalPagesController
  before_action :load_submission

  def create
    @beneficial_owner = BeneficialOwner.new(beneficial_owner_params)
    @beneficial_owner.parent = @submission
    @beneficial_owner.save!

    respond_with_update
  end

  def update
    @beneficial_owner = BeneficialOwner.find(params[:id])
    @beneficial_owner.update_attributes(beneficial_owner_params)

    respond_with_update
  end

  def destroy
    @beneficial_owner = BeneficialOwner.find(params[:id])
    @beneficial_owner.destroy

    respond_with_update
  end

  private

  def beneficial_owner_params
    params.require(:beneficial_owner).permit(Customer.attribute_names)
  end

  def respond_with_update
    respond_to do |format|
      @modal_id = params[:modal_id]
      format.js do
        render "/submissions/extended/forms/beneficial_owners/update"
      end
    end
  end
end
