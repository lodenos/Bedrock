require "./routing"

module Bedrock
  VERSION = "0.1.0"

  # TODO: Put your code here
end

class Test < Bedrock::Routing
  @request : HTTP::Request

  def run
    server = HTTP::Server.new do |context|
      @request = context.request

      get "/toutou" do |handler|
        puts handler
      end
    end
    server.listen 8080
  end
end

test = Test.new
test.run
