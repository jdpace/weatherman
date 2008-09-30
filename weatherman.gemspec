Gem::Specification.new do |s|
  s.name     = "weatherman"
  s.version  = "0.1.0"
  s.date     = "2008-09-29"
  
  s.homepage = "http://github.com/jdpace/weatherman"
  s.summary  = "Ruby gem for accessing the Weather Channel XML API based on rweather"
  s.description = "A wrapper for the Weather Channel, inc (weather.com) XML api covers most features of the api. Current Conditions, Forecasting, and access to the promotional links that you are required to display as part of the API TOS."
  
  s.authors  = ["Jared Pace"]
  s.email    = "jared@codewordstudios.com"

  s.files    = ["lib/weather_man.rb", "lib/weather_man_response.rb", "spec/cc_only_response.xml", "spec/default_response.xml", "spec/forecast_only_response.xml", "spec/weather_man_response_spec.rb", "spec/weather_man_spec.rb"]
  
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.add_dependency("xml-simple", [">= 1.0.11"])
end
