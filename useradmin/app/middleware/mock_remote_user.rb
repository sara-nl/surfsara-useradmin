class MockRemoteUser
  def initialize(app)
    @app = app
  end

   def call(env)
    env['REMOTE_USER'] = '123abc'
    @app.call(env)
  end
end
