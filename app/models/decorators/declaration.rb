class Decorators::Declaration < SimpleDelegator
  def initialize(declaration)
    @declaration = declaration
    super
  end

  def declaration_required?
    if Policies::Definitions.part_4?(submission)
      false
    elsif new_record?
      DeprecableTask.new(submission.task).declarations_required_on_add_owner?
    elsif not_required?
      false
    else
      true
    end
  end
end
