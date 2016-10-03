class AnonymousUser < CurrentUser
  def proposed_one_username
    "anonymous"
  end

  def one_user
    nil
  end

  def admin_groups
    []
  end

  def role
    nil
  end

  def surfsara_admin?
    false
  end

  def group_admin?
    false
  end

  def can_administer_groups?
    false
  end

  def authenticated?
    false
  end
end
