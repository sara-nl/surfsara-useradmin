CurrentUser = Struct.new(:request) do
  def uid
    request.get_header('REMOTE_USER') || request.get_header('HTTP_REMOTE_USER')
  end

  def common_name
    request.get_header('Shib-commonName')
  end

  def home_organization
    request.get_header('Shib-homeOrganization')
  end

  def edu_person_target_id
    request.get_header('Shib-eduPersonTargetID')
  end

  def role
    return Role.surfsara_admin if uid.in? %w(admin isaac)
    return Role.group_admin if group_admin?
  end

  def shibboleth_headers
    Hash[request.headers.select { |k, _| k.starts_with?('Shib-') }]
  end

  def surfsara_admin?
    role == Role.surfsara_admin
  end

  def one_username
    "#{home_organization}-#{uid}"
  end

  def one_password
    edu_person_target_id
  end

  def admin?
    role == 'admin'
  end

  def group_admin?
    !surfsara_admin? && admin_groups.any?
  end

  def one_user
    @one_user ||= OneClient.user_by_password(uid)
  end

  def admin_groups
    @admin_groups ||= get_admin_groups
  end

  private

  def get_admin_groups
    return OneClient.groups if surfsara_admin?
    OneClient.groups_for_admin(one_user.id)
  end
end
