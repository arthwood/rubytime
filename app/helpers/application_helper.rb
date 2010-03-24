module ApplicationHelper
  def set_c_and_a
    @c = params[:controller]
    @a = params[:action]
  end
end
