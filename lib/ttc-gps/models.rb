require 'rubygems'
require 'geokit'

# Extensions to Geokit.
module Geokit
  class Bounds
    def expand_by_radius units
      ret = Bounds.new LatLng.new(@sw.lat,@sw.lng), LatLng.new(@ne.lat, @ne.lng)
      ret.expand_by_radius! units
      ret
    end
    
    def expand_by_radius! units
      sw.lat = sw.lat - units
      sw.lng = sw.lng - units
      ne.lon = ne.lon + units
      ne.lng = ne.lng + units
    end
  end
end

module TTC
  # <vehicle lon='-79.3582' secsSinceReport='7' predictable='true' speedKmHr='0.0' dirTag='504_westbound' id='4142' heading='54' lat='43.677082' routeTag='504'/>
  class Vehicle
    attr_accessor :id, :route, :position, :heading, :dir, :secs_since_report, :predictable

    def to_s
      inspect
    end

    # Parses an XML element into a Vehicle instance
    def Vehicle.parse_element element
      attrs = element.attributes

      v = Vehicle.new
      v.id = attrs["id"]
      v.route = attrs["routeTag"]
      
      lon = Float(attrs["lon"])
      lat = Float(attrs["lat"])
      v.position = Geokit::LatLng.new(lat, lon)
      
      v.heading = Float(attrs["heading"])
      v.dir = attrs["dirTag"]
      v.secs_since_report = Integer(attrs["secsSinceReport"])
      v.predictable = Boolean(attrs["predictable"])
      v    
    end
  end
  
  # <route lonMin='-79.5444325' title='501- Queen' tag='501' color='e92127' latMax='43.6739102' lonMax='-79.2817125' oppositeColor='ffffff' latMin='43.591831'>
  class Route
    attr_accessor :tag, :title, :bounds, :stop_map, :directions
    
    def initialize
      @stop_map = {}
      @directions = {}
    end
    
    def add_stop stop
      @stop_map[stop.tag] = stop
    end
    
    def add_stop_to_direction direction, stop_tag
      if !@stop_map[stop_tag]
        puts "No stop found with tag, tag='#{stop_tag}'"
        return
      end
      
      dir_arr = @directions[direction] || []
      dir_arr << @stop_map[stop_tag]
      @directions[direction] = dir_arr
    end
    
    def contains? latlon, radius=0
      @bounds.contains? latlon
    end
    
    def get_closest_stops latlon, direction
      @directions[direction].sort do |a, b|
        latlon.distance_to(a.position) <=> latlon.distance_to(b.position)
      end
    end
    
    def get_closest_stop latlon, direction
      get_closest_stops[0]
    end
    
    def to_s
      inspect
    end
    
    def Route.parse_element element
      attrs = element.attributes
      
      r = Route.new
      r.tag = attrs["tag"]
      r.title = attrs["title"]
      
      lat_min = Float(attrs["latMin"])
      lat_max = Float(attrs["latMax"])
      lon_min = Float(attrs["lonMin"])
      lon_max = Float(attrs["lonMax"])
      
      r.bounds = Geokit::Bounds.new(
        Geokit::LatLng.new(lat_min, lon_min), 
        Geokit::LatLng.new(lat_max, lon_max))
      
      r
    end
  end
  
  # <stop lon='-79.5407149' title='Lake Shore Blvd W At 39th' tag='lake39th_e' dirTag='501_eastbound' stopId='6503' lat='43.5928211'/>
  class Stop
    attr_accessor :id, :title, :position, :dir, :tag
    
    def to_s
      inspect
    end
    
    # Parses an XML element into a Stop instance
    def Stop.parse_element element
      attrs = element.attributes
      
      s = Stop.new
      s.id = attrs["stopId"]
      s.title = attrs["title"]
      lat = Float(attrs["lat"])
      lon = Float(attrs["lon"])
      s.position = Geokit::LatLng.new(lat, lon)
      s.dir = attrs["dirTag"]
      s.tag = attrs["tag"]
      s
    end
  end
end