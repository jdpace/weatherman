require 'ostruct'

class WeatherManResponse
  attr_reader :current_conditions, :forecast, :api_url, :unit_temperature, :unit_distance, :unit_speed, :unit_pressure, :links
  
  def initialize(simple_xml, url = nil)
    @current_conditions = simple_xml['cc'] ? build_current_conditions(simple_xml['cc'][0]) : nil
    @forecast = simple_xml['dayf'] ? build_forecast(simple_xml['dayf'][0]['day']) : nil
    
    # Promotional links required by Weather Channel, Inc.
    @links = simple_xml['lnks'] ? build_links(simple_xml['lnks'][0]['link']) : nil
    
    # Capture the units
    @unit_temperature = simple_xml['head'][0]['ut'][0]
    @unit_distance    = simple_xml['head'][0]['ud'][0]
    @unit_speed       = simple_xml['head'][0]['us'][0]
    @unit_pressure    = simple_xml['head'][0]['up'][0]
    
    # The api url that was called to generate this response
    @api_url = url
  end
  
  protected
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
      cc.barometric_pressure  = WeatherManBarometer.new({
                                  :reading      => response['bar'][0]['r'][0],
                                  :description  => response['bar'][0]['d'][0]
                                })
      cc.wind                 = WeatherManWind.new({
                                  :speed        => response['wind'][0]['s'][0],
                                  :gust         => response['wind'][0]['gust'][0],
                                  :degrees      => response['wind'][0]['d'][0],
                                  :direction    => response['wind'][0]['t'][0]
                                })
      cc.uv                   = WeatherManUV.new({
                                  :index        => response['uv'][0]['i'][0],
                                  :description  => response['uv'][0]['t'][0]
                                })
      cc.moon                 = WeatherManMoon.new({
                                  :icon_code    => response['moon'][0]['icon'][0],
                                  :description  => response['moon'][0]['t'][0]
                                })
      cc    
    end
  
    def build_forecast(days = [])
      return nil if days.nil? || days.empty?
    
      f = WeatherManForecast.new
      days.each do |day|
        f << WeatherManForecastDay.build(day)
      end
      f
    end
    
    def build_links(links = [])
      return nil if links.nil? || links.empty?
      
      links.map {|link| WeatherManPromotionalLink.new({
        :text => link['t'][0],
        :url  => link['l'][0]
      })}
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
  
  # Assign a forecast day to a week day accessor as it gets added
  # allows for accessors like forecast.monday -> <WeatherManForecastDay>
  def <<(day)
    super
    eval("@#{day.week_day.downcase} = day")
  end
  
  def today
    self[0]
  end
  
  def tomorrow
    self[1]
  end
  
  # Returns a forecast for a day given by a Date, DateTime,
  # Time, or a string that can be parsed to a date
  def for(date = Date.today)
    # Format date into a Date class
    date = case date.class.name
           when 'String'
             Date.parse(date)
           when 'Date'
             date
           when 'DateTime'
             Date.new(date.year, date.month, date.day)
           when 'Time'
             Date.new(date.year, date.month, date.day)
           end
    
    day = nil
    # find the matching forecast day, if any
    self.each do |fd|
      day = fd if date == fd.date
    end
    return day
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
  
  # Build a new WeatherManForecastDay based on
  # A response from the Weather Channel
  def self.build(response = {})
    fd = new
    fd.week_day = response['t']
    fd.date     = Date.parse(response['dt'])
    fd.high     = response['hi'][0]
    fd.low      = response['low'][0]
    fd.sunrise  = response['sunr'][0]
    fd.sunset   = response['suns'][0]
    fd.day      = build_part(response['part'].first)
    fd.night    = build_part(response['part'].last)
    fd
  end
  
  protected
    # Build a part day
    def self.build_part(part)
      WeatherManForecastPart.new({
        :icon_code            => part['icon'][0],
        :description          => part['t'][0],
        :chance_percipitation => part['ppcp'][0],
        :humidity             => part['hmid'][0],
        :wind                 => WeatherManWind.new({
                                   :speed     => part['wind'][0]['s'][0],
                                   :gust      => part['wind'][0]['gust'][0],
                                   :degrees   => part['wind'][0]['d'][0],
                                   :direction => part['wind'][0]['t'][0]     
                                 })
      })
    end
end

# =================================
# WeatherMan Response classes
# used for tracking groups of data
# ie. Forecast parts, Barometer,
# UV, Moon, and Wind
# =================================
class WeatherManForecastPart < OpenStruct
end

class WeatherManBarometer < OpenStruct
end

class WeatherManUV < OpenStruct
end

class WeatherManMoon < OpenStruct
end

class WeatherManWind < OpenStruct
end

class WeatherManPromotionalLink < OpenStruct
end