module One
  class CreateUser < Operation
    def process(_params)
      add_user_to_group unless user_already_member_of_group?
      add_user_as_group_admin if become_group_admin? && !user_already_admin_of_group?
    end

    private

    def invite
      @params.fetch(:invite)
    end

    def one_user
      @one_user ||= find_or_create_user
    end

    def find_or_create_user
      one_client.user_by_password(current_user.edu_person_principal_name) ||
        one_client.create_user(current_user.proposed_one_username, current_user.edu_person_principal_name)
    end

    def add_user_to_group
      one_client.add_user_to_group(one_user.id, invite.group_id)
    end

    def add_user_as_group_admin
      one_client.make_user_group_admin(one_user.id, invite.group_id)
    end

    def user_already_member_of_group?
      one_user.group_ids.include?(invite.group_id)
    end

    def become_group_admin?
      invite.role == Role.group_admin
    end

    def user_already_admin_of_group?
      one_client.user_admin_of_group?(one_user.id, invite.group_id)
    end

    def one_client
      @one_client ||= One::Client.new
    end
  end
end
