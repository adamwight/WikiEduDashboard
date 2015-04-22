class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable

  def mediawiki
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      remember_me @user
      sign_in_and_redirect @user
    else
      redirect_to root_url
    end
  end
end