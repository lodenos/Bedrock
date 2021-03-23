require "http/server"



module Cocaine
  VERSION = "0.1.0"

  macro generate_endpoint(*descriptions)
    ############################################################################
    # Generate the Matching Function for each path
    ############################################################################
    {% for route in descriptions %}
      {% name = "#{ route["verb"].downcase.id }_#{ route["name"].downcase.id }?" %}

      private def self.{{ name.id }}(context : HTTP::Server::Context, reference, path) : Bool
        {% split = route["path"][0].split '/' %}
        split = path.split '/'
        # Check if have the same quantity of '/'
        if split.size == {{ split.size }}
          ##############################################################
          # Block
          ##############################################################
          {% firstCall = true %}
          {% condition = "" %}
          {% for index in 0...split.size %}
            {% next if split[index][0...1] == ':' %}
            {% if firstCall %}
              {% condition += "if split[#{ index.id }] == #{ split[index] }" %}
              {% firstCall = false %}
            {% else %}
              {% condition += " && split[#{ index.id }] == #{ split[index] }" %}
            {% end %}
          {% end %}
          # Blit the complex condition form some few previous lines
          {{ condition.id }}
            {{ route["function"] }} context
            return true
          end
        end
        false
      end
    {% end %}

    ############################################################################
    # Main Function
    ############################################################################
    def self.match(context : HTTP::Server::Context)
      request = context.request
      case request.method
      {% for method in METHODS %}
        # TODO: Can Optimized by length in first
        # TODO: Can compare by casting in UInt32 
        when {{ method }}
          ######################################################################
          # The switch for each route
          ######################################################################
          {% for route in DESCRIPTIONS %}
            case
            {% if route["verb"] == method %}
              {% name = "#{ route["verb"].downcase.id }_#{ route["name"].downcase.id }?" %}
              when self.{{ name.id }} context, {{ route["path"] }}, request.path then return
            {% end %}
            end
          {% end %} 
      {% end %}
      end
    end
  end
end

def function(context : HTTP::Server::Context)
  # puts "======== Function"
end

API_REST_DESCRIPTION = [
  {
    "name" => "service",
    "path" => [
      "/image",
      "/img"
    ],
    "verb" => "GET"
    # "function" => function
  }
]

Cocaine.generate_endpoint API_REST_DESCRIPTION

server = HTTP::Server.new do |context| 
end

server.bind_tcp "0.0.0.0", 5000
server.listen
