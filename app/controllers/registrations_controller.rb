# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_api_request?

  def create
    user = User.new(user_params)

    if user.save
      token = generate_token(user)

      render json: {
        token: token,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          role: user.role
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :password, :username)
  end

  def generate_token(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i,
      iat: Time.current.to_i
    }
    JWT.encode(payload, Rails.application.secrets.secret_key_base, 'HS256')
  end

  def json_api_request?
    request.format.json?
  end
end