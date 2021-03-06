class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :country_code, :currency, :password, :password_confirmation, :timezone)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :country_code, :password, :password_confirmation, :current_password)
  end
end