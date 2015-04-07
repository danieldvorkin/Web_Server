require 'socket'

host = 'localhost'
port = 2000

server = TCPServer.open(host, port)                 # Socket to listen to defined host and port
puts "Server started on #{host}:#{port} ..."        # Output to stdout that server started

loop do                                             # Server runs forever
  begin
	client = server.accept                            # Wait for a client to connect. Accept returns a TCPSocket

	lines = []
	headers = []
	
	while (line = client.gets) && !line.chomp.empty?  # Read the request and collect it until it's empty
		lines << line.chomp
	end
	
	puts lines                                        # Output the full request to stdout
	puts

	filename = lines[0].gsub(/GET \//, '').gsub(/\ HTTP.*/, '')
	puts "FILENAME: #{filename}"

	if File.exists?(filename)
	  	body = File.read(filename)

		case filename
			when /\.css/
				type = "text/css"
			when /\.js/
				type = "text/javascript"
			when /\.png/
				type = "image/png"
			when /\.jpe?g/
				type = "image/jpeg"
			when /\.otf/
				type = "application/vnd.ms-fontobject"
			when /\.woff$/
				type = "application/font-woff"
			when /\.woff.$/
				type = "application/font-woff2"
			else
				type = "text/html"
		end

	  	headers << "HTTP/1.1 200 OK"
		headers << "Content-Length: #{body.length}" # should be the actual size of the response body
  		headers << "Content-Type: #{type}" # should reflect the appropriate content type (HTML, CSS, text, etc)
		headers << "Connection: close"
	else
	  	body = "File Not Found\n" # need to indicate end of the string with \n
	  	headers << "HTTP/1.1 404 Not Found"
		headers << "Content-Type: text/plain" # is always text/plain
		headers << "Content-Length: #{body.length}" # should the actual size of the response body
		headers << "Connection: close"
	end

	headers = headers.join("\r\n")
	response = [headers, body].join("\r\n\r\n")

	client.puts(response)
	client.puts(Time.now.ctime)
	client.close                                      # Disconnect from the client

	rescue => e
		p e
	end
end