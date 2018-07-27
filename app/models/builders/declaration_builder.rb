class Builders::DeclarationBuilder
  class << self
    def create(submission, owners, declared_by_emails, shareholder_groups)
      @submission = submission
      @owners = owners || []
      @declared_by_emails = declared_by_emails || []
      @shareholder_groups = shareholder_groups || []

      build_declarations
      build_notifications unless @submission.source.to_sym == :manual_entry
      build_declaration_groups
    end

    private

    def build_declarations # rubocop:disable Metrics/MethodLength
      @owners.each do |owner|
        declaration =
          Declaration.create(
            submission: @submission,
            owner: build_owner(owner),
            state: initial_state_for_task,
            shares_held: owner[:shares_held].to_i,
            entity_type: owner[:entity_type] || :individual)

        if @declared_by_emails.include?(declaration.owner_email)
          declaration.declared! if declaration.can_transition? :declared
        end
      end
    end

    def build_notifications
      @submission.declarations.incomplete.each do |declaration|
        Notification::OutstandingDeclaration.create(
          recipient_name: declaration.owner.name,
          recipient_email: declaration.owner.email,
          notifiable: declaration)
      end
    end

    def build_declaration_groups
      @shareholder_groups.each do |shareholder_group|
        declaration_group =
          @submission.declaration_groups.create(
            shares_held: shareholder_group[:shares_held])

        shareholder_group[:group_member_keys].each do |group_member|
          declaration_group
            .declaration_group_members
            .create(declaration_owner_id: owner_id_for(group_member))
        end
      end
    end

    def owners_list
      Declaration.where(submission: @submission).map do |d|
        [d.owner.id, d.owner.name.to_s, d.owner.email.to_s]
      end
    end

    def owner_id_for(owner_key)
      owner_name = owner_key.split(";")[0].to_s
      owner_email = owner_key.split(";")[1].to_s

      declaration = owners_list.find do |owner|
        (owner[1].to_s == owner_name) && (owner[2].to_s == owner_email)
      end

      declaration[0]
    end

    def initial_state_for_task
      if DeprecableTask.new(@submission.task).declarations_required_on_create?
        :incomplete
      else
        :not_required
      end
    end

    def build_owner(owner)
      Declaration::Owner.new(owner.except(:id, :type))
    end
  end
end
