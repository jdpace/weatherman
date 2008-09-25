class WeatherManResponse
  attr_reader :current_conditions, :forecast, :api_url
  
  def initialize(simple_xml, api_url = nil)
    @current_conditions = simple_xml['cc']
    @forecast = simple_xml['dayf']
    @api_url = api_url
  end
end