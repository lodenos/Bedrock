require "http/server"

module Bedrock
  abstract class Routing
    @request : HTTP::Request

    def initialize
      @pathFinded = false
    end

    def path_finded?
      @pathFinded
    end

    private def match_route(path : String)
      parameter = {} of String => String
      return yield parameter if pathReference == "*"
      reference = path.split('/')
      path = @request.path.split('/')
      return if path.size > reference.size
      index = 0
      loop do
        return if index >= reference.size
        if reference[index].size == 0
          index = index + 1
          next
        end
        if reference[index][0] == ':'
          if index >= path.size
            parameter[reference[index][1...]] = ""
            break
          end
          parameter[reference[index][1...]] = path[index]
        elsif reference[index] != path[index]
          return
        end
        break if index >= reference.size - 1
        index = index + 1
      end
      yield parameter
      @pathFinded = true
    end

    def get(path : String, &block)
      return unless @request.method == "GET"
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
