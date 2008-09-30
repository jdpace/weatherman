$: << '../lib'
require 'weather_man'

describe WeatherMan, 'trying to access the api before being configured' do
  it 'should throw an error when searching' do
    lambda {
      WeatherMan.search('test')
    }.should raise_error(WeatherManNotConfiguredError)
  end
  
  it 'should throw an error when initializing' do
    lambda {
      WeatherMan.new('28115')
    }.should raise_error(WeatherManNotConfiguredError)
  end
end

describe WeatherMan, 'dealing with locations' do
  before :each do
    load_default_authentication
  end
  
  it 'should be able to search for locations' do
    WeatherMan.search('Charlotte').should_not be_empty
  end
  
  it 'should return an array of instances when searching' do
    WeatherMan.search('Charlotte').each do |location|
      location.should be_kind_of(WeatherMan)
    end
  end
  
  it 'should be be able to able to initialize from a location id' do
    WeatherMan.new('28115').should_not be_nil
  end
end

describe WeatherMan, 'using a bad partner id / license key' do
  before :each do
    WeatherMan.partner_id = 'test'
    WeatherMan.license_key = 'test'
    @weatherman = WeatherMan.new('28115')
  end
  
  it 'should raise an error when fetching the weather' do
    lambda {
      @weatherman.fetch
    }.should raise_error(WeatherManApiError)
  end
end

describe WeatherMan, 'trying to use a bad location id' do
  before :each do
    load_default_authentication
    @weatherman = WeatherMan.new('test')
  end
  
  it 'should raise an error when fetching the weather' do
    lambda {
      @weatherman.fetch
    }.should raise_error(WeatherManApiError)
  end
end

describe WeatherMan, 'fetching the weather' do
  before :each do
    load_default_authentication
    @weather = WeatherMan.new('28277').fetch
  end
  
  it 'should get the current conditions' do
    @weather.current_conditions.should_not be_nil
  end
  
  it 'should get a forecast' do
    @weather.forecast.should_not be_nil
  end
  
  it 'should get a forecast of 5 days by default' do
    @weather.forecast.size.should eql(5)
  end
  
  it 'should get the weather in standard units by default' do
    @weather.unit_distance.should eql('mi')
  end
end

describe WeatherMan, 'asking for different kinds of weather' do
  before :each do
    load_default_authentication
    @charlotte = WeatherMan.new('28277')
  end
  
  it 'should only not get the forecast when asking for 0 forecast days' do
    weather = @charlotte.fetch(:days => 0)
    weather.forecast.should be_nil
  end
  
  it 'should only get the amount of days you ask for' do
    weather = @charlotte.fetch(:days => 3)
    weather.forecast.size.should eql(3)
  end
  
  it 'should not get the current conditions if you tell it not to' do
    weather = @charlotte.fetch(:current_conditions => false)
    weather.current_conditions.should be_nil
  end
  
  it 'should get the weather in metric when ask for it that way' do
    weather = @charlotte.fetch(:unit => :metric)
    weather.unit_distance.should eql('km')
  end
end

def load_default_authentication
  # Hey! Get your own.
  # heres the link: http://www.weather.com/services/xmloap.html
  WeatherMan.partner_id = '1075758518'
  WeatherMan.license_key = '7c731d27fae916fb'
end