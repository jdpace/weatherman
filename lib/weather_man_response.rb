class WeatherManResponse
  attr_reader :current_conditions, :forecast, :api_url
  
  def initialize(simple_xml, api_url = nil)
    @current_conditions = build_current_conditions(simple_xml['cc'][0])
    @forecast = build_forecast(simple_xml['dayf'][0]['day'])
    
    # The api url that was called to generate this response
    @api_url = api_url
  end
  
  def build_current_conditions(response = {})
    return nil if response.nil? || response.empty?
    
    cc = WeatherManCurrentConditions.new
    
    # Parse out Current Conditions
    cc.temperature          = response['tmp'][0]
    cc.feels_like           = response['flik'][0]
    cc.description          = response['t'][0]
    cc.icon_code            = response['icon'][0]
    cc.humidity             = response['hmid'][0]
    cc.visibility           = response['vis'][0]
    cc.dew_point            = response['dewp'][0]
    cc.barometric_pressure  = {
                                :reading      => response['bar'][0]['r'][0],
                                :description  => response['bar'][0]['d'][0]
                              }
    cc.wind                 = {
                                :speed        => response['wind'][0]['s'][0],
                                :gust         => response['wind'][0]['gust'][0],
                                :degrees      => response['wind'][0]['d'][0],
                                :direction    => response['wind'][0]['t'][0]
                              }
    cc.uv                   = {
                                :index        => response['uv'][0]['i'][0],
                                :description  => response['uv'][0]['t'][0]
                              }
    cc.moon                 = {
                                :icon_code    => response['moon'][0]['icon'][0],
                                :description  => response['moon'][0]['t'][0]
                              }
    cc    
  end
  
  def build_forecast(days = {})
    return nil if days.nil? || days.empty?
    
    f = WeatherManForecast.new
    days.each do |day|
      f << WeatherManForecastDay.build(day)
    end
    f
  end
end

class WeatherManCurrentConditions
  attr_accessor :temperature,
                :feels_like,
                :description,
                :icon_code, 
                :humidity,
                :visibility, 
                :dew_point,
                :barometric_pressure,
                :wind,
                :uv,
                :moon
end

class WeatherManForecast < Array
  WEEK_DAYS = %w(sunday monday tuesday wednesday thursday friday saturday)
  WEEK_DAYS.each {|day| attr_reader day.to_sym}
  
  def <<(day)
    super
    offset = Time.now.wday
    wday = (self.size - 1) + offset
    wday = wday > 6 ? wday - 6 : wday # I know theres a better way to do this, too tired now
    eval("@#{WEEK_DAYS[wday]} = day")
  end
end

class WeatherManForecastDay
  attr_accessor :week_day,
                :date,
                :high,
                :low,
                :sunrise,
                :sunset,
                :day,
                :night
                
  def self.build(response = {})
    fd = new
    fd.week_day = response['t']
    fd.date     = response['dt']
    fd.high     = response['hi'][0]
    fd.low      = response['low'][0]
    fd.sunrise  = response['sunr'][0]
    fd.sunset   = response['suns'][0]
    fd.day      = build_part(response['part'].first)
    fd.night    = build_part(response['part'].last)
    fd
  end
  
  protected
    def self.build_part(part)
      {
        :icon_code            => part['icon'][0],
        :description          => part['t'][0],
        :chance_percipitation => part['ppcp'][0],
        :humidity             => part['hmid'][0],
        :wind                 => {
                                   :speed     => part['wind'][0]['s'][0],
                                   :gust      => part['wind'][0]['gust'][0],
                                   :degrees   => part['wind'][0]['d'][0],
                                   :direction => part['wind'][0]['t'][0]
                                 }
      }
    end
end