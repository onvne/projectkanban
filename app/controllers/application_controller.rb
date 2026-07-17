class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_sidebar_projects, if: :user_signed_in?
  allow_browser versions: :modern

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def set_sidebar_projects
    @projects = current_user.projects.order(:created_at).to_a
  end

  stale_when_importmap_changes
end
