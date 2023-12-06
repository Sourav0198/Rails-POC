# frozen_string_literal: true

class ResponseWrapper
  def self.success(data = {}, message = 'Success', status_code = 200)
    {
      status: 'Success',
      status_code:,
      message:,
      data:
    }
  end

  def self.failure(data = {}, error = {}, status_code = 400)
    {
      status: 'Error',
      status_code:,
      message: 'Some Error Occurred',
      data:,
      error:
    }
  end
end
