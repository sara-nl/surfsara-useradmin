require 'opennebula'

module OneClient
  User = Struct.new(:id, :name, :password, :group_ids) do
    def self.from_xml(xml)
      new(xml.id, xml.name, xml['PASSWORD'], xml.groups)
    end
  end

  Group = Struct.new(:id, :name) do
    def self.from_xml(xml)
      new(xml.id, xml.name)
    end
  end

  PUBLIC_AUTH_DRIVER = 'public'.freeze

  class << self
    def users
      perform { user_pool.info }
      user_pool.map { |user| User.from_xml(user) }
    end

    def find_user(username)
      users.find { |user| user.name == username }
    end

    def user_by_password(password)
      users.find { |user| user.password == password }
    end

    def create_user(username, password)
      user = build_user
      perform { user.allocate(username, password, PUBLIC_AUTH_DRIVER) }
      perform { user.info }
      User.from_xml(user)
    end

    def add_user_to_group(user_id, group_id)
      user = build_user(user_id)
      perform { user.addgroup(group_id) }
    end

    def groups
      perform { group_pool.info }
      group_pool.map { |group| Group.from_xml(group) }
    end

    def groups_for_admin(uid)
      perform { group_pool.info }
      group_pool
        .select { |group| group.contains_admin(uid) }
        .map { |group| Group.from_xml(group) }
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

    def perform(&block)
      rc = yield
      fail rc.message.inspect if OpenNebula.is_error?(rc)
    end
  end
end
