# frozen_string_literal: true

class AuthenticationTokenService
  HMAC_SECRET = ENV['JWT_HMAC_SECRET']
  ALGORITHM_TYPE = 'HS256'

  def self.call(user_id)
    payload = { user_id: }

    JWT.encode payload, HMAC_SECRET, ALGORITHM_TYPE
  end

  def self.decode(token)
    decoded_token = JWT.decode token, HMAC_SECRET, true, { algorith: ALGORITHM_TYPE }
    puts 'decoded token: '
    p decoded_token
    decoded_token[0]['user_id']
  end
end
