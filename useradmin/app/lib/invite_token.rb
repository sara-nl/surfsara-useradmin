class InviteToken
  attr_reader :raw

  def self.random
    new(SecureRandom.hex)
  end

  def initialize(token)
    @raw = token
  end

  def encrypted
    Digest::SHA2.hexdigest(raw)
  end
end
