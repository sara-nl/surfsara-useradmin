module One
  class CreateUser < Operation
    def process(params)
      create_or_update_user(params.fetch(:current_user), params.fetch(:invite))
    end

    private

    def create_or_update_user(current_user, invite)
      user = OneClient.find_user(current_user.one_username)
      user = OneClient.create_user(current_user.one_username, current_user.one_password) if user.nil?
      OneClient.add_user_to_group(user.id, invite.group_id) unless user.group_ids.include?(invite.group_id)
    end
  end
end
