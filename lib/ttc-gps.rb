require 'ttc-gps/extensions'
require 'ttc-gps/constants'
require 'ttc-gps/models'
require 'ttc-gps/service'
require 'rubygems'
require 'geokit'
require 'yaml'

include TTC

service = TTCService.new
route = service.get_route(ROUTES[0])

me = Geokit::LatLng.new 43.6038156, -79.4930397
puts route.contains? me
puts (route.get_closest_stops me, "westbound").to_yaml