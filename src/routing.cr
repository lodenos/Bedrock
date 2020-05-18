require "http/server"

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
      pathRef = path.split('/')
      path = @request.not_nil!.path.split('/')
      return if path.size > pathRef.size
      index = 0
      loop do
        return if index >= pathRef.size
        if pathRef[index].size == 0
          index = index + 1
          next
        end
        if pathRef[index][0] == ':'
          if index >= path.size
            parameter[pathRef[index][1...]] = ""
            break
          end
          parameter[pathRef[index][1...]] = path[index]
        elsif pathRef[index] != path[index]
          return
        end
        break if index >= pathRef.size - 1
        index = index + 1
      end
      yield parameter
      @pathFinded = true
    end

    def get(path : String, &block)
      return unless @request.not_nil!.method == "GET"
      return if self.path_finded?
      self.match_route path do |params|
        yield params
      end
    end
  end
end



# "connect", "delete", "get", "head", "options", "path", "post", "put", "trace"
#
# get('/users/:userId/books/:bookId', function (req, res) {
#   res.send(req.params)
# })
#
# app.METHOD(PATH, HANDLER)
#
# case
# when "DELETE" t
