class MockRemoteUser
  def initialize(app)
    @app = app
  end

   def call(env)
    env['REMOTE_USER'] = 'admin123'
    @app.call(env)
  end
end
