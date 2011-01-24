module RubytimeHelper
  def current_user=(u)
    session[:user_id] = u.id
  end
  
  def current_user
    @current_user ||= (id = session[:user_id]) && User.find(id)
  end
  
  def logged_in?
    current_user.present?
  end
end
