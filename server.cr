require "http/server"
require "http/client"
require "option_parser"

port = ""
OptionParser.parse! do |parser|
  parser.banner = "Usage: salute [arguments]"
  parser.on("-port", "--port=PATH", "Used PORT") { |uport| port = uport }
end

server = HTTP::Server.new(port.to_i) do |context|
  params = {} of String => String
  context.request.query_params.each do |k, v|
    params[k] = v
  end
  if params.has_key?("get")
    res = HTTP::Client.get params["get"]
    context.response.content_type = res.content_type.to_s
    context.response.status_code = res.status_code
    context.response.content_length = res.body.size
    context.response.print res.body
  else
    context.response.content_type = "text/plain"
    context.response.print "you must use GET method,ex.  yourserver.com/?get=http://yoururl.com/"
  end
end

begin
  puts "Listening on http://127.0.0.1:#{port}"
  server.listen
rescue
end
