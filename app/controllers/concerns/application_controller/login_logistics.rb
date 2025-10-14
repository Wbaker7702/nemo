# frozen_string_literal: true

module ApplicationController::LoginLogistics
  extend ActiveSupport::Concern

  # logs out user if not already logged out
  # might be called /after/ get_user_and_mission due to filter order
  # so should undo that method's changes
  def ensure_logged_out
    return unless user_session = UserSession.find
    user_session.destroy
    @current_user = nil
    @current_mission = nil
  end

  # Tasks that should be run after the user successfully logs in OR successfully resets their password
  # Redirects to the appropriate place.
  def post_login_housekeeping(options = {})
    # Get the session
    @user_session = UserSession.find

    # Reset the perishable token for security's sake
    @user_session.user.reset_perishable_token!

    # Set the locale based on the user's pref_lang (if it's supported)
    set_locale_or_default(@user_session.user.pref_lang)

    return if options[:dont_redirect]

    # Redirect to most relevant mission
    best_mission = @user_session.user.best_mission
    redirect_back_or_default(if best_mission
                               mission_root_path(mission_name: best_mission.compact_name)
                             else
                               basic_root_path
                             end)
  end

  # resets the Rails session but preserves the :return_to key
  # used for security purposes
  def reset_session_preserving_return_to
    tmp = session[:return_to]
    reset_session
    session[:return_to] = tmp
  end

  # Store the intended location and redirect to the login page.
  #
  # Renders an error if AJAX (but this should never happen; the script
  # should catch this error and redirect to the login page itself).
  def redirect_to_login
    if request.xhr?
      flash[:error] = nil
      render(plain: "LOGIN_REQUIRED", status: :unauthorized)
    else
      store_location
      redirect_to(login_url)
    end
  end

  # Store the intended location of the request so we can return the user after interruption.
  def store_location
    session[:return_to] = if request.get?
                            request.fullpath
                          elsif request.referer
                            # No need to redirect to the login page if that's where they came from
                            # (e.g. for InvalidAuthenticityToken).
                            request.referer unless request.referer.match?(%r{/login\z})
                            # Otherwise store nothing.
                          end
  end

  def forget_location
    session[:return_to] = nil
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    forget_location
  end
end
