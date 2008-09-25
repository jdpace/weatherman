require 'net/http'
require 'xmlsimple'
require 'weather_man_response'

# Raised if partner_id and license_key are not provided
class WeatherManNotConfiguredError < StandardError
end

# Raised when the API returns an error
class WeatherManApiError < StandardError
end

# Raised when a location is not found by id
class WeatherManLocationNotFoundError < StandardError
end

class WeatherMan
  VALID_UNITS = ['s', 'm']
  DEFAULT_UNIT = 's' #standard
  
  # partner id and license key can be obtained
  # when you sign up for the weather.com xml api at
  # http://www.weather.com/services/xmloap.html
  def self.partner_id; @@partner_id; end;
  def self.partner_id=(pid); @@partner_id = pid; end;
  def self.license_key; @@license_key; end;
  def self.license_key=(lk); @@license_key = lk; end;
  
  # id is the location id for the WeatherMan instance ie. 'USNY0996'
  # name is the human readable name of the location ie. 'New York, NY'
  attr_reader :id, :name
  
  def initialize(location_id, location_name = 'n/a', verify_location = true)
    @id = location_id
    @name = location_name
    
    self.class.check_authentication
    
    if verify_location
      # Send a call to the api to check that this location exists
      # raise(WeatherManLocationNotFoundError, "WeatherMan: A location could not be found using ID=#{location_id}")
    end
  end
  
  def fetch(options = {})
    options = default_forecast_options.merge(options)
    api_url = weather_url(options) 
    
    if response = self.class.fetch_response(api_url)
      WeatherManResponse.new(response, api_url)
    end
  end
  
  # Return an array of matching locations
  def self.search(where)
    # Make sure the partner id and license key have been provided
    check_authentication
    
    if response = fetch_response(search_url(:where => where))
      response['loc'] ? response['loc'].map {|location| new(location['id'], location['content'], false)} : []
    end
  end
  
  # TODO: REMOVE THIS!!!!!!!!!!!
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  def self.defaults
    @@partner_id = '1075758518'
    @@license_key = '7c731d27fae916fb'
  end
  
  protected
    # API url for accssing weather
    def weather_url(options = {})
      options = encode_options(options)

      url  = "http://xoap.weather.com/weather/local/#{self.id}"
      url << "?par=#{@@partner_id}"
      url << "&key=#{@@license_key}"
      url << "&prod=xoap"
      url << "&link=xoap"
      url << "&cc=*" if options[:current_conditions]
      url << "&dayf=#{options[:days]}" if options[:days] && (1..5).include?(options[:days].to_i)
      url << "&unit=#{options[:unit]}" if options[:unit] = (VALID_UNITS.include?(options[:unit]) ? options[:unit] : DEFAULT_UNIT)
      url
    end

    def default_forecast_options
      {
        :current_conditions => true,
        :days               => 5,
        :unit               => DEFAULT_UNIT
      }
    end
    
    # Encode a hash of options to be used as request parameters
    def encode_options(options)
      options.each do |key,value|
        options[key] = URI.encode(value.to_s)
      end
    end
    
    # Fetch Response from the api
    def self.fetch_response(api_url)
      xml_data = Net::HTTP.get_response(URI.parse(api_url)).body
      response = XmlSimple.xml_in(xml_data)
      
      # Check if API call threw an error
      if response['err']
        raise(WeatherManApiError, "WeatherMan Error #{response['err']['type']}: #{response['err']['content']}")
      end
      
      response
    end
    
    def self.check_authentication
      raise(WeatherManNotConfiguredError, 'A partner id and a license key must be provided before acessing the API') unless @@partner_id && @@license_key
    end
    
    # API url for searching for locations
    def self.search_url(options = {})
      "http://xoap.weather.com/search/search?where=#{URI.encode(options[:where])}"
    end
end