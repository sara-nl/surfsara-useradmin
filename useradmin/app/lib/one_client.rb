require 'opennebula'

module OneClient
  User = Struct.new(:id, :name, :group_ids) do
    def self.from_xml(xml)
      new(xml.id, xml.name, xml.groups)
    end
  end

  Group = Struct.new(:id, :name)

  PUBLIC_AUTH_DRIVER = 'public'.freeze

  class << self
    def users
      Rails.cache.fetch('one_client/users', expires_in: 5.minutes) do
        retrieve(user_pool).map do |user|
          User.new(user.id, user.name, user.groups)
        end
      end
    end

    def create_user(username, password)
      user = build_user
      rc = user.allocate(username, password, PUBLIC_AUTH_DRIVER)
      fail rc.message if OpenNebula.is_error?(rc)
      user.info
      User.from_xml(user)
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
      @client ||= OpenNebula::Client.new(
        Rails.application.config.one_client.credentials,
        Rails.application.config.one_client.endpoint
      )
    end

    def user_pool
      @user_pool ||= OpenNebula::UserPool.new(client)
    end

    def build_user(id = nil)
      OpenNebula::User.new(OpenNebula::User.build_xml(id), client)
    end

    def group_pool
      @group_pool ||= OpenNebula::GroupPool.new(client)
    end

    def retrieve(pool)
      rc = pool.info
      raise rc.message.inspect if OpenNebula.is_error?(rc)
      pool
    end
  end
end
