require 'socket'                                    # Require socket from Ruby Standard Library (stdlib)

host = 'localhost'
port = 2000

server = TCPServer.open(host, port)                 # Socket to listen to defined host and port
puts "Server started on #{host}:#{port} ..."        # Output to stdout that server started

loop do                                             # Server runs forever
  client = server.accept                            # Wait for a client to connect. Accept returns a TCPSocket

  lines = []
  headers = []
  while (line = client.gets.chomp) && !line.empty?  # Read the request and collect it until it's empty
    lines << line
  end
  puts lines                                        # Output the full request to stdout

  filename = lines[0].gsub(/GET \//, '').gsub(/\ HTTP.*/, '')

  if File.exists?(filename)
  	body = File.read(filename)
  	headers << "HTTP/1.1 200 OK"
  	headers << "Content-Type: text/html" # should reflect the appropriate content type (HTML, CSS, text, etc)
		headers << "Content-Length: #{body.length}" # should be the actual size of the response body
		headers << "Connection: close"
	else
  	body = "File Not Found\n" # need to indicate end of the string with \n
  	headers << "HTTP/1.1 404 Not Found"
		headers << "Content-Type: text/plain" # is always text/plain
		headers << "Content-Length: #{body.length}" # should the actual size of the response body
		headers << "Connection: close"
	end

	headers = headers.join('\r\n')
	response = [headers, body].join('\r\n\r\n')

	client.puts(response)
	client.puts(Time.now.ctime)
  client.close                                      # Disconnect from the client
end