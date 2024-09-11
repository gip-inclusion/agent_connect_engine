class AuthController < ApplicationController
  def callback
    if authentication.success?
      render json: authentication.user_info
    else
      render json: { error: "Could not authenticate user" }, status: :unauthorized
    end
  end
end