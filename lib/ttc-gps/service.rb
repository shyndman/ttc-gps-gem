require 'rexml/document'
require 'open-uri'

module TTC
  class TTCService
    def get_route route_tag
      route = nil
      
      open TTC::UrlTemplates::ROUTE_CONFIG % route_tag do |file|
        config_xml = REXML::Document.new file
        
        route = Route.parse_element config_xml.root.elements['route']
        
        config_xml.root.elements.each 'route/stop' do |element|
          route.add_stop TTC::Stop::parse_element element
        end
        
        config_xml.root.elements.each 'route/direction' do |element|
          dir = element.attributes["title"].downcase!
          element.elements.each 'stop' do |element|
            route.add_stop_to_direction dir, element.attributes["tag"]
          end
        end
      end
      
      route
    end
    
    def get_vehicle_locations route_tag
      res = {}
      vehicles = []
      
      open TTC::UrlTemplates::STREET_CAR_LOCATIONS % route_tag do |file|
        route_xml = REXML::Document.new file
        root = route_xml.root
        root.elements.each 'vehicle' do |element|
          vehicles << TTC::Vehicle::parse_element(element)
        end
        
        if root.elements['lastTime']
          res['last_time'] = Integer(root.elements['lastTime'].attributes['time'])
        end
      end
      
      res['vehicles'] = vehicles
      res
    end
  end
end