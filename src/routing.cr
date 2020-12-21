require "http/server"
require "uri"

module Bedrock
  abstract class Routing
    @request : HTTP::Request?
    @pathFinded = false

    def path_finded?
      @pathFinded
    end

    private def match_route(path : String)
      parameter = {} of String => String
      return yield parameter if path == "*"
      pathRef = path.split '/'
      path = @request.not_nil!.path.split '/'
      return if path.size != pathRef.size
      index = 0
      loop do
        return if index >= pathRef.size
        if pathRef[index].size == 0
          index += 1
          next
        end
        if pathRef[index][0] == ':'
          parameter[pathRef[index][1...]] = path[index]
          break if index >= path.size - 1
        elsif pathRef[index] != path[index]
          return
        end
        break if index >= pathRef.size - 1
        index += 1
      end
      yield parameter
      @pathFinded = true
    end

    def dead_links(&block)
      return if self.path_finded?
      yield
    end

    def broken_links(&block)
      return if self.path_finded?
      yield
    end

    {% begin %}
      {% methods = %w(CONNECT DELETE GET HEAD OPTIONS PATCH POST PUT TRACE) %}
      {% for method in methods %}
        def {{ method.downcase.id }}(path : String, &block)
          return unless @request.not_nil!.method == {{ method }}
          return if self.path_finded?
          self.match_route path do |params|
            params["query"] = URI.parse(path).query_params
            yield params
          end
        end
      {% end %}
    {% end %}
  end
end
