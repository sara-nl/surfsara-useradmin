module One
  class MigrationForm < Reform::Form
    property :username, virtual: true
    property :password, virtual: true
    property :accept_terms_of_service, virtual: true

    validate :accept_terms_of_service do
      errors.add(:accept_terms_of_service, :not_accepted) if accept_terms_of_service != '1'
    end
  end

  class MigrationModel
    include ActiveModel::Model
  end

  class MigrateUser < Operation
    contract MigrationForm

    def process(params)
      validate(params[:reform]) do
        return unless authenticate_user
        return unless check_password_available
        migrate_user
      end
    end

    def model!(_params)
      MigrationModel.new
    end

    private

    def authenticate_user
      if one_user.blank?
        self.errors.add(:base, :could_not_be_authenticated)
        invalid!
        return false
      end
      true
    end

    def one_user
      @one_user ||= find_one_user
    end

    def find_one_user
      user_client.find_user(username)
    rescue RuntimeError => e
      raise unless e.message =~ /User couldn't be authenticated/
    end

    def user_client
      @user_client ||= One::Client.new(credentials: credentials)
    end

    def check_password_available
      if admin_client.user_by_password(current_user.one_password).present?
        self.errors.add(:base, :account_already_linked)
        invalid!
        return false
      end
      true
    end

    def admin_client
      @admin_client ||= One::Client.new
    end

    def migrate_user
      user_client.migrate_user(one_user.id, current_user.one_password)
    end

    def credentials
      "#{username}:#{password}"
    end

    def username
      @params[:reform][:username]
    end

    def password
      @params[:reform][:password]
    end
  end
end
