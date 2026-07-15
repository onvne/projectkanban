class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  allow_browser versions: :modern
    def configure_permitted_parameters
    # Разрешаем поле :name при регистрации
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    end
  # redirecting to root path after sign in
  def after_sign_in_path_for(resource)
    root_path
  end
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
