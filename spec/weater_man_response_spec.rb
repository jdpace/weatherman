$: << '../lib'
require 'weather_man_response'
require 'xmlsimple'

describe WeatherManResponse, 'built from a default response' do
  before :each do
    default_response = XmlSimple.xml_in(File.read('default_response.xml'))
    @weather = WeatherManResponse.new(default_response, 'test')
  end
  
  it 'should grab all the units' do
    @weather.unit_temperature.should eql('F')
    @weather.unit_distance.should eql('mi')
    @weather.unit_speed.should eql('mph')
    @weather.unit_pressure.should eql('in')
  end
  
  it 'should build a CurrentConditions object' do
    @weather.current_conditions.should be_kind_of(WeatherManCurrentConditions)
  end
  
  it 'should build the current conditions correctly' do
    cc = @weather.current_conditions
    cc.temperature.should eql('73')
    cc.feels_like.should eql('73')
    cc.description.should eql('Sunny')
    cc.icon_code.should eql('32')
    cc.humidity.should eql('66')
    cc.visibility.should eql('10.0')
    cc.dew_point.should eql('61')
    
    # Barometric Pressure
    cc.barometric_pressure.should be_kind_of(WeatherManBarometer)
    cc.barometric_pressure.reading.should eql('29.97')
    cc.barometric_pressure.description.should eql('steady')
    
    # Wind
    cc.wind.should be_kind_of(WeatherManWind)
    cc.wind.speed.should eql('calm')
    cc.wind.gust.should eql('N/A')
    cc.wind.degrees.should eql('0')
    cc.wind.direction.should eql('CALM')
    
    # UV
    cc.uv.should be_kind_of(WeatherManUV)
    cc.uv.index.should eql('0')
    cc.uv.description.should eql('Low')
    
    # Moon
    cc.moon.should be_kind_of(WeatherManMoon)
    cc.moon.icon_code.should eql('0')
    cc.moon.description.should eql('New')
  end
  
  it 'should build a forecast' do
    @weather.forecast.should be_kind_of(WeatherManForecast)
  end
  
  it 'should have a forecast for 5 days' do
    @weather.forecast.size.should eql(5)
  end
  
  it 'should build a correct forecast for today' do
    today = @weather.forecast.today
    today.should be_kind_of(WeatherManForecastDay)
    
    today.week_day.should eql('Monday')
    today.date.should eql(Date.parse('Sep 29'))
    today.high.should eql('N/A')
    today.low.should eql('59')
    today.sunrise.should eql('7:17 AM')
    today.sunset.should eql('7:09 PM')
    
    # Day time part
    today.day.should be_kind_of(WeatherManForecastPart)
    today.day.icon_code.should eql('44')
    today.day.description.should eql('N/A')
    today.day.chance_percipitation.should eql('10')
    today.day.humidity.should eql('N/A')
    today.day.wind.should be_kind_of(WeatherManWind)
    today.day.wind.speed.should eql('N/A')
    today.day.wind.gust.should eql('N/A')
    today.day.wind.degrees.should eql('N/A')
    today.day.wind.direction.should eql('N/A')
    
    # Nite time part
    today.night.should be_kind_of(WeatherManForecastPart)
    today.night.icon_code.should eql('29')
    today.night.description.should eql('Partly Cloudy')
    today.night.chance_percipitation.should eql('10')
    today.night.humidity.should eql('86')
    today.night.wind.should be_kind_of(WeatherManWind)
    today.night.wind.speed.should eql('3')
    today.night.wind.gust.should eql('N/A')
    today.night.wind.degrees.should eql('56')
    today.night.wind.direction.should eql('NE')
  end
  
  it 'should get a set of promotional links' do
    @weather.links.should_not be_empty
  end
  
  it 'should get exactly 4 links' do
    @weather.links.size.should eql(4)
  end
  
  it 'should have a set of links that are each objects' do
    @weather.links.each do |link|
      link.should be_kind_of(WeatherManPromotionalLink)
    end
  end
  
  it 'should build the promotional links correctly' do
    link = @weather.links.first
    link.text.should eql('Local Pollen Reports')
    link.url.should eql('http://www.weather.com/allergies?par=xoap&site=textlink&cm_ven=XOAP&cm_cat=TextLink&cm_pla=Link1&cm_ite=Allergies')
  end
end

describe WeatherManResponse, 'with only the current conditions' do
  before :each do
    cc_only_response = XmlSimple.xml_in(File.read('cc_only_response.xml'))
    @weather = WeatherManResponse.new(cc_only_response, 'test')
  end
  
  it 'should have a current_conditions object' do
    @weather.current_conditions.should be_kind_of(WeatherManCurrentConditions)
  end
  
  it 'should not have a forecast' do
    @weather.forecast.should be_nil
  end
end

describe WeatherManResponse, 'with only a 3 day forecast' do
  before :each do
    forecast_only_response = XmlSimple.xml_in(File.read('forecast_only_response.xml'))
    @weather = WeatherManResponse.new(forecast_only_response, 'test')
  end
  
  it 'should not have a current_conditions object' do
    @weather.current_conditions.should be_nil
  end
  
  it 'should have a forecast' do
    @weather.forecast.should be_kind_of(WeatherManForecast)
  end
  
  it 'should have a forecast for exactly 3 days' do
    @weather.forecast.size.should eql(3)
  end
end

describe WeatherManForecast, 'generated from a default response' do
  before :each do
    default_response = XmlSimple.xml_in(File.read('default_response.xml'))
    @forecast = WeatherManResponse.new(default_response, 'test').forecast
  end
  
  it 'should have some week day accessors' do
    @forecast.monday.should be_kind_of(WeatherManForecastDay)
    @forecast.tuesday.should be_kind_of(WeatherManForecastDay)
    @forecast.wednesday.should be_kind_of(WeatherManForecastDay)
    @forecast.thursday.should be_kind_of(WeatherManForecastDay)
    @forecast.friday.should be_kind_of(WeatherManForecastDay)
    @forecast.saturday.should be_nil
    @forecast.sunday.should be_nil
  end
  
  it 'should have some relative date helpers' do
    @forecast.today.should eql(@forecast.first)
    @forecast.tomorrow.should eql(@forecast[1])
  end
  
  it 'should be able to get the forecast given a date' do
    @forecast.for(Date.parse('Sep 29')).should eql(@forecast.today)
  end
  
  it 'should be able to get the forecast given a time' do
    @forecast.for(Time.at(1222750106)).should eql(@forecast.tomorrow)
  end
  
  it 'should be able to get the forecast given a string representing a date' do
    @forecast.for('Oct 1').should eql(@forecast.wednesday)
  end
  
  it 'should return nil when asked for the forecast of a date it doesnt have' do
    @forecast.for(Date.new(2050,1,1)).should be_nil
  end
end