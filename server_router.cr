require "router"
require "http/client"

class ProfiledServer
  include Router

  def run
    profile_handler = ProfileHandler.new
    route_handler = RouteHandler.new
    draw(route_handler) do
      get "/", API.new { |context, params|
        res = HTTP::Client.get params["get"]
        context.response.content_type = res.content_type.to_s
        context.response.status_code = res.status_code
        context.response.content_length = res.body.size
        context.response.print res.body
        context
      }
    end
    server = HTTP::Server.new(80, [profile_handler, route_handler])
    server.listen
  end
end

profiled_server = ProfiledServer.new
profiled_server.run
