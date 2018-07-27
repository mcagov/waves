class Admin::TasksController < InternalPagesController
  def index
    @tasks = []
    # DeprecableTask.default_task_types.map { |t| DeprecableTask.new(t[1]) }
  end
end
