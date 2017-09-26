require "http/server" # from crystal
require "http/client" # from crystal
require "option_parser" # from crystal

port = "" # port as string
OptionParser.parse! do |parser|
  parser.banner = "Usage: salute [arguments]"
  parser.on("-port", "--port=PORT", "Used PORT") { |uport| port = uport } # --port option
end

server = HTTP::Server.new(port.to_i) do |context|
  params = {} of String => String
  context.request.query_params.each do |k, v|
    params[k] = v
  end
  if params.has_key?("get")
    HTTP::Client.get(params["get"]) do |res|
      context.response.content_type = res.content_type.to_s
      context.response.status_code = res.status_code
      res.headers.each do |k, v|
        next if k == "Content-Encoding"
        next if k == "Content-Length"
        next if k == "Transfer-Encoding"
        context.response.headers[k] = v
      end
      context.response.print res.body_io.gets_to_end
    end
  else
    context.response.content_type = "text/plain"
    context.response.print "you must use GET method,ex.  yourserver.com/?get=http://yoururl.com/"
  end
end

# bad practice
begin
  puts "Listening on http://127.0.0.1:#{port}"
  server.listen
rescue
end
