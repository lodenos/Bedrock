require "http/server"
# Locally Import
# require "./param"

module Cocaine
  VERSION = "0.1.0"
end

macro cocaine_generate_endpoint(descriptions)
  module Cocaine
    # TODO: Add a check for descriptions

    # INFO: Collect every methods possible
    #-----
    {% methods = [] of String %}
    {% for description in descriptions %}
      {% for key in description["methods"] %}
        {% methods << key %}
      {% end %}
    {% end %}
    {% methods = methods.uniq %}
    #-----

    # INFO: associates each path with a method
    #-----
    {% methodPaths = {} of String => Array(String) %}
    {% for method in methods %}
      {% methodPaths[method] = [] of String %}
    {% end %}
    {% for description in descriptions %}
      {% for method in description["methods"] %}
        {% methodPaths[method] << description["path"] %}
      {% end %}
    {% end %}
    #-----

    # INFO: Pre-analyze the path to know the indexes where the parameters are located
    #-----
    {% pathParamsIndexs = {} of String => Hash(String, Array(UInt32)) %}
    {% for method in methods %}
      {% pathParamsIndexs[method] = {} of String => Array(UInt32) %}
    {% end %}
    {% for description in descriptions %}
      {% for method in description["methods"] %}
        {% path = description["path"] %}
        {% pathParamsIndexs[method][path] = [] of UInt32 %}
        {% onColon = false %}
        {% for index in (0..path.size) %}
          {% if path[index..index] == ":" && onColon == false %}
            {% pathParamsIndexs[method][path] << index %}
            {% onColon = true %}
          {% elsif path[index..index] == "/" && onColon == true %}
            {% pathParamsIndexs[method][path] << index %}
            {% onColon = false %}
          {% elsif index + 1 == path.size && onColon == true %}
            {% pathParamsIndexs[method][path] << index %}
          {% end %}
        {% end %}
      {% end %}
    {% end %}
    #-----

    # INFO: Global StaticArray for Params Indexs
    #-----
    # Method => Paths => Indez
    {% paramsIndexs = [] of Array(Array(UInt32)) %}
    {% indexA = 0 %}
    {% for method in pathParamsIndexs %}
      {% indexB = 0 %}
      {% for path in pathParamsIndexs[method] %}
        {% for indexs in pathParamsIndexs[method][path] %}
          {% paramsIndexs[indexA] << indexs %}
        {% end %}
        {% indexB += 1 %}
      {% end %}
      {% indexA += 1 %}
    {% end %}

    {% puts paramsIndexs %}

    PARAMS_INDEXS = StaticArray[[[0]]]
    #-----

    ############################################################################
    # Main Function
    ############################################################################

    def self.match_endpoint(context : HTTP::Server::Context)
      request = context.request
      # INFO: Method Switcher
      {% if methods.size == 1 %}
        # INFO: For only one Method
        if request.method == {{ methods[0] }}
          # INFO: Path Matching
        end
      {% else %}
        # INFO: For multi Methods
        case request.method
        {% for method, methodIndex in methods %}
          when {{ method }}
            # INFO: Path Matching
            path = request.path.to_unsafe
            
            {% for path, index in methodPaths[method] %}

              # puts PARAMS_INDEXS[{{ methodIndex }}]


            {% end %}
          {% end %}
        end
      {% end %}
    end
  end
end

################################################################################
#
################################################################################

def fun_get
  puts "fun_get"
end

def fun_post
  puts "fun_post"
end

def fun_delete
  puts "fun_delete"
end

def fun_patch
  puts "fun_patch"
end

def fun_put
  puts "fun_put"
end

cocaine_generate_endpoint [
  {
    "cors" => true,
    "methods" => {
      "GET" => fun_get,
      "POST" => fun_post,
      "DELETE" => fun_delete,
      "PATCH" => fun_patch,
      "PUT" => fun_put
    },
    "name" => "Test", # Name for the struct exemple PosTest
    "path" => "/user/:id" # /user & /user/ it's exactly the same
  },
  {
    "cors" => true,
    "methods" => {
      "GET" => fun_get,
      "POST" => fun_post,
      "DELETE" => fun_delete,
      "PATCH" => fun_patch,
      "PUT" => fun_put
    },
    "name" => "Test", # Name for the struct exemple PosTest
    "path" => "/user/:id/:oo" # /user & /user/ it's exactly the same
  },
]

puts "------>"
server = HTTP::Server.new do |context|
  delta = Time.measure do
    Cocaine.match_endpoint context
  end
  time = delta.nanoseconds
  puts "> #{ time } ns >> #{ 1_000_000_000 / time }"
end
server.listen "0.0.0.0", 5000
