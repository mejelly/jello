module OmniAuthTestHelper
  def valid_auth0_login_setup
    if Rails.env.test?
      OmniAuth.config.test_mode = true
      credentials = OmniAuth::AuthHash.new({
        expires: true,
        id_token: 'mock_id_token',
        token: 'mock_token',
        token_type: 'Bearer'
       })

      extra = OmniAuth::AuthHash.new({
         raw_info: OmniAuth::AuthHash.new({
            blog: 'mock.blog.com',
            clientID: 'mock_clientID',
            created_at: '2016-11-01T14:19:11.892Z',
            email: 'mock@email_mock.com',
            email_verified: true,
        })
     })

      OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new({
        credentials: credentials,
        extra: extra,
        info: OmniAuth::AuthHash::InfoHash.new({
            email: 'mock@email_mock.com',
            first_name: nil,
            image: 'https://avatars.githubusercontent.com/u/12345?v=3',
            last_name: nil,
            location: nil,
            name: 'Mock name',
            nickname: 'mock nickname'
        }),
        provider: 'auth0',
        uid: 'github|123545',
      })
    end
  end
end
