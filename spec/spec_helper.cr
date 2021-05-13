require "spec"
require "../src/cocaine"

cocaine_generate_endpoints [
  {
    "name" => "index",
    "path" => "/",
    "verb" => "GET",
    "handler" => Controller.index
  },
  {
    "name" => "user",
    "path" => "/user",
    "verb" => "GET",
    "handler" => Controller.user
  },
  {
    "name" => "user_id",
    "path" => "/user/:id",
    "verb" => "GET",
    "handler" => Controller.user_id
  }
]

module Controller
  extend self

  def index(context : HTTP::Server::Context)
    response = context.response
    response.status = Status::OK
    response.write ""
  end

  def user(context : HTTP::Server::Context)
    response = context.response
    response.status = Status::OK
    response.write ""
  end

  def user_id(context : HTTP::Server::Context, params : Cocaine::Param::UserId)
    response = context.response
    response.status = Status::OK
    response.write ""
  end
end

class ServerTest
  @server : HTTP::Server

  def initialize(@host : String, @port : Int32)
    @server = HTTP::Server.new { |context| Cocaine.match_endpoint context }
  end

  def close
    @server.close
  end

  def run
    spawn do
      @server.bind_tcp @host, @port
      @server.listen
    end
    interval = Time::Span.new nanoseconds: 1000
    until @server.listening?
      sleep interval
    end
  end
end
