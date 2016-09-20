class Role
  def self.for_group
    [
      group_admin,
      member
    ]
  end

  def self.surfsara_admin
    'surfsara_admin'
  end

  def self.group_admin
    'group_admin'
  end

  def self.member
    'member'
  end
end
