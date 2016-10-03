CurrentUser = Struct.new(:uid, :common_name, :home_organization, :remote_user, :edu_person_entitlement) do
  def self.from_request(request)
    remote_user = get_request_header(request, 'REMOTE_USER')
    return AnonymousUser.new if remote_user.blank?
    new(
      get_request_header(request, 'Shib-uid'),
      get_request_header(request, 'Shib-commonName'),
      get_request_header(request, 'Shib-homeOrganization'),
      remote_user,
      get_request_header(request, 'Shib-eduPersonEntitlement'),
    )
  end

  def self.get_request_header(request, header)
    request.get_header(header) || request.get_header('HTTP_' + header.upcase.tr('-', '_'))
  end

  def proposed_one_username
    "#{uid}@#{home_organization}"
  end

  def one_user
    @one_user ||= one_client.user_by_password(remote_user)
  end

  def admin_groups
    @admin_groups ||= get_admin_groups
  end

  def role
    return Role.surfsara_admin if surfsara_admin?
    return Role.group_admin if group_admin?
  end

  def surfsara_admin?
    (edu_person_entitlement || '').split(',').include?(Rails.application.config.surfsara_admin_entitlement)
  end

  def group_admin?
    return false if surfsara_admin?
    admin_groups.any?
  end

  def can_administer_groups?
    admin_groups.any?
  end

  def authenticated?
    true
  end

  private

  def get_admin_groups
    return one_client.groups if surfsara_admin?
    return [] unless one_user
    one_client.groups_for_admin(one_user.id)
  end

  def one_client
    @one_client ||= One::Client.new
  end
end
