require 'opennebula'

module OneClient
  CREDENTIALS = "useradmin:useradmin"
  ENDPOINT    = "http://localhost:2633/RPC2"

  User = Struct.new(:id, :name, :group_ids)
  Group = Struct.new(:id, :name)

  class << self
    include OpenNebula

    def users
      Rails.cache.fetch('one_client/users', expires_in: 5.minutes) do
        retrieve(user_pool).map do |user|
          User.new(user.id, user.name, user.groups)
        end
      end
    end

    def groups
      Rails.cache.fetch('one_client/groups', expires_in: 5.minutes) do
        retrieve(group_pool).map do |group|
          Group.new(group.id, group.name)
        end
      end
    end

    private

    def client
      @client ||= Client.new(CREDENTIALS, ENDPOINT)
    end

    def user_pool
      @user_pool ||= UserPool.new(client)
    end

    def group_pool
      @group_pool ||= GroupPool.new(client)
    end

    def retrieve(pool)
      rc = pool.info
      raise rc.message.inspect if OpenNebula.is_error?(rc)
      pool
    end
  end
end
