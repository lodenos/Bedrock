require "http/server"

module Cocaine
  VERSION = "0.1.0"

  alias RouteParams = Hash(String, String)
end

macro cocaine_generate_endpoint(descriptions)
  module Cocaine
    alias RouteParams = Hash(String, String) # I don't why I do to declare that twice ???

    # TODO: Add a check on compile time for descriptions to be sure is valid
    ############################################################################
    # Generate the Matching Function for each path
    ############################################################################

    {% for route in descriptions %}
      {% name = "#{ route["verb"].downcase.id }_#{ route["name"].downcase.id }?" %}
      private def self.{{ name.id }}(context : HTTP::Server::Context, reference, path) : Bool
        {% split = route["path"].split '/' %}
        split = path.split '/'
        # Check if have the same quantity of '/'
        if split.size == {{ split.size }}
          ######################################################################
          # Block
          ######################################################################
          {% firstCall = true %}
          {% condition = "" %}
          {% for index in 0...split.size %}
            {% unless split[index][0...1] == ":" %}
              {% if firstCall %}
                {% condition += "if split[#{ index.id }] == #{ split[index] }" %}
                {% firstCall = false %}
              {% else %}
                {% condition += " && split[#{ index.id }] == #{ split[index] }" %}
              {% end %}
            {% end %}
          {% end %}
          # Blit the complex condition form some few previous lines
          {{ condition.id }}
            # TODO: Add or not context
            # Build Param
            {% firstCall = true %}
            {% params = "{" %}
            {% for index in 0...split.size %}
              {% if split[index][0...1] == ":" %}
                {% if firstCall %}
                  {% params += " #{ split[index] } => split[#{ index.id }] " %}
                  {% firstCall = false %}
                {% else %}
                  {% params += ", #{ split[index] } => split[#{ index.id }]" %}
                {% end %}
              {% end %}
            {% end %}
            {% params += "}" %}
            {% if params == "{}"%}
              {{ route["callback"].id }} context, RouteParams.new
            {% else %}
              {{ route["callback"].id }} context, {{ params.id }}
            {% end %}
            return true
          end
        end
        false
      end
    {% end %}

    ############################################################################
    # Main Function
    ############################################################################

    # TODO: Be First on this Benchmark Here -> https://github.com/the-benchmarker/web-frameworks
    # 7 Bytes -> CONNECT, OPTIONS
    # 6 Bytes -> DELETE
    # 5 Bytes -> PATCH, TRACE
    # 4 Bytes -> HEAD, POST
    # 3 Bytes -> GET, PUT

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

################################################################################
# Define your Controllers
################################################################################

# def controller_index(context : HTTP::Server::Context, params : Cocaine::Param)
#   # context.response.content_type = "text/plain"
#   # context.response.write Pointer.new "> user", 6, true
# end

# def controller_user(context : HTTP::Server::Context, params : Cocaine::Param)
#   # puts params
#   # context.response.content_type = "text/plain"
#   # context.response.write Pointer.new "> user", 6, true
# end

################################################################################
# Endpoint Generation
################################################################################

# cocaine_generate_endpoint [
#   {
#     "name" => "index",
#     "path" => "/",
#     "verb" => "GET",
#     "callback" => controller_index
#   },
#   {
#     "name" => "user",
#     "path" => "/user/:id",
#     "verb" => "GET",
#     "callback" => controller_user
#   }
# ]

################################################################################
# Server
################################################################################

# server = HTTP::Server.new do |context|
#   elapsed_time = Time.measure do
#     Cocaine.match_endpoint context
#   end
#   puts elapsed_time.nanoseconds
# end
# puts "run"
# server.listen "0.0.0.0", 5000
