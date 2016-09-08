class Role
  def self.all
    [
      admin,
      member
    ]
  end

  def self.admin
    'admin'
  end

  def self.member
    'member'
  end
end
