class InviteToken
  attr_reader :raw

  def self.random
    new(SecureRandom.hex)
  end

  def initialize(token)
    @raw = token
  end

  def hashed
    Digest::SHA2.hexdigest(raw)
  end
end
