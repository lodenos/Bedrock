require "http/server"

module Cocaine
  VERSION = "0.1.0"
end

macro cocaine_generate_endpoint(descriptions)
  module Cocaine
    # TODO: Add a check on compile time for descriptions to be sure is valid

    ############################################################################
    # Collect all verbs
    ############################################################################

    {% verbs = [] of String %}
    {% for route in descriptions %}
      {% verbs << route["verb"] %}
    {% end %}
    {% verbs = verbs.uniq %}

    ############################################################################
    # Generate a variable routeParam
    ############################################################################

    {% routeParam = {} of String => Array(String) %}
    {% for route in descriptions %}
      {% array = [] of String %}
      {% split = route["path"].split "/" %}
      {% for item, index in split %}
        {% if item[0...1] == ":" %}
          {% array << item[1...item.size] %}
        {% end %}
      {% end %}
      {% routeParam[route["path"]] = array %}
    {% end %}

    ############################################################################
    # Generate Custum Struct for Route Parameter
    ############################################################################

    # INFO: if no param no build the struct

    {% for route in descriptions %}
      {% if routeParam[route["path"]].size > 0 %}
        # This is {{ route["name"].capitalize }}RouteParam custom structure for it's Route Params.
        # A Hash will have been simpler but it has a cost in memory and in speed of access due the keys of hash.
        struct {{ route["name"].capitalize.id }}Param
          {% params = routeParam[route["path"]] %}
          {% parameter = "" %}
          {% for item in params %}
            {% parameter += ", " unless parameter == "" %}
            {% parameter += "@#{ item.id }" %}
            getter {{ item.id }} : String
          {% end %}

          def initialize({{ parameter.id }})
          end
        end
      {% end %}
    {% end %}

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
              {{ route["callback"].id }} context
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
      {% if verbs.size == 1 %}
        if request.method == {{ verbs[0] }}
          case
          {% for route in descriptions %}
            {% name = "#{ route["verb"].downcase.id }_#{ route["name"].downcase.id }?" %}
            when self.{{ name.id }} context, {{ route["path"] }}, request.path
              return
          {% end %}
          else
            # TODO: code here for add an error callback
          end
        else
          # TODO: code here for add an error callback
        end
      {% else %}
        case request.method
        {% for method, index in verbs %}
          when {{ method }}
            case
            {% for route in descriptions %}
              {% if route["verb"] == method %}
                {% name = "#{ route["verb"].downcase.id }_#{ route["name"].downcase.id }?" %}
                when self.{{ name.id }} context, {{ route["path"] }}, request.path
                  return
              {% end %}
            {% end %}
            else
              # TODO: code here for add an error callback
            end
        {% end %}
        else
          # TODO: code here for add an error callback
        end
      {% end %}
    end
  end
end
