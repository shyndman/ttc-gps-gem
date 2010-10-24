module TTC
  module UrlTemplates
    STREET_CAR_LOCATIONS = 'http://webservices.nextbus.com/service/publicXMLFeed?command=vehicleLocations&a=ttc&t=0&r=%s'
    ROUTE_CONFIG = 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=ttc&r=%s'
  end

  ROUTES = ('501'..'506').to_a + ('508'..'512').to_a
end