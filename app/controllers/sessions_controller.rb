class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to admin_path
    else
      redirect_to '/auth/github'
    end
  end

  def create
    client = Octokit::Client.new(access_token: auth_hash.credentials.token)
    username = auth_hash.info.nickname
    if admin_member?(username)
      cookies.permanent.signed[:username] = {value: username, httponly: true}
      redirect_to request.env['omniauth.origin'] || admin_path
    else
      flash[:error] = 'Access denied.'
      redirect_to root_path
    end
  end

  def destroy
    cookies.delete :user_id
    redirect_to root_path
  end

  def failure
    flash[:error] = 'There was a problem authenticating with GitHub, please try again.'
    redirect_to root_path
  end

  private

  def auth_hash
    @auth_hash ||= request.env['omniauth.auth']
  end

  def admin_member?(username)
    ENV['ADMIN_USERNAMES'].split(',').include?(username)
  end
end
