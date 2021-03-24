require "http/server"

macro cocaine_generate_endpoint(descriptions)
  module Cocaine
    VERSION = "0.1.0"

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
          ######################################################################
          # Block
          ######################################################################
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

    def self.match_endpoint(context : HTTP::Server::Context)
      request = context.request
      case request.method
        {% for method in %w(GET POST) %}
          # TODO: Can Optimized by length in first
          # TODO: Can compare by casting in UInt32
          when {{ method }} # Method mean verb HTTP like GET, POST, ...` 
            case
            {% for route in descriptions %}
              {% if route["verb"] == method %}
                {% name = "#{ route["verb"].downcase.id }_#{ route["name"].downcase.id }?" %}
                when self.{{ name.id }} context, {{ route["path"] }}, request.path
                  return
              {% end %}
            {% end %}
          end 
        {% end %}
      end
    end
  end
end

################################################################################
# Basic Test
################################################################################

cocaine_generate_endpoint [
  {
    "name" => "service",
    "path" => [
      "/image",
      "/img"
    ],
    "verb" => "GET",
    "function" => function
  }
]

def function(context : HTTP::Server::Context)
  context.response.content_type = "text/plain"
  context.response.print "Hello world, got #{ context.request.path } !\n"
end

server = HTTP::Server.new do |context| 
  Cocaine.match_endpoint context
end

server.bind_tcp "0.0.0.0", 5000
puts "run"
server.listen

