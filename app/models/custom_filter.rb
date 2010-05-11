class CustomFilter
  def initialize(params)
    params && params.each do |k, v|
      send "#{k}=", v
    end
  end
end
