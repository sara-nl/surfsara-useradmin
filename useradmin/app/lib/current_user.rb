CurrentUser = Struct.new(:request) do
  def uid
    request.get_header('REMOTE_USER') || request.get_header('HTTP_REMOTE_USER')
  end

  def common_name
    request.get_header('Shib-commonName')
  end

  def role
    return 'admin' if uid.in? %w(admin isaac)
    return 'groupadmin' if uid == 'groupadmin123'
  end

  def shibboleth_headers
    Hash[request.headers.select { |k, _| k.starts_with?('Shib-') }]
  end

  def admin?
    role == 'admin'
  end

  def groupadmin?
    role == 'groupadmin'
  end
end
