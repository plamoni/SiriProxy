require 'cfpropertylist'
require 'siriproxy/interpret_siri'
require 'socket'
require "siriproxy/functions"
require 'cora'

class SiriProxy::Connection < EventMachine::Connection
  include EventMachine::Protocols::LineText2

  attr_accessor :other_connection, :name, :ssled, :output_buffer, :input_buffer, :processed_headers, :unzip_stream, :zip_stream, :consumed_ace, :unzipped_input, :unzipped_output, :last_ref_id, :plugin_manager
  def last_ref_id=(ref_id)
    @last_ref_id = ref_id
    self.other_connection.last_ref_id = ref_id if other_connection.last_ref_id != ref_id
  end

  def initialize
    super
    self.processed_headers = false
    self.output_buffer = ""
    self.input_buffer = ""
    self.unzipped_input = ""
    self.unzipped_output = ""
    self.unzip_stream = Zlib::Inflate.new
    self.zip_stream = Zlib::Deflate.new
    self.consumed_ace = false
    self.is_4S = false 			#bool if its iPhone 4S
    @auth_data = nil
    @faux = false
    @devicetype=nil
    @connectionfromguzzoni=false
    puts "[Info - SiriProxy] Created a connection!"
  end

  def post_init
    self.ssled = false
  end

  def encode_data(x)
    x = [x].pack("H*")
    x.blob = true
    x
  end

  def read_relative_file(x)
    val = nil
    begin
      val = File.open(File.expand_path(x), "r").read
    rescue SystemCallError
    end

    val
  end

  def write_relative_file(x, val)
    File.open(File.expand_path(x), "w") do |f|
      f.write(val)
    end
  end

  def read_auth_data
    map = Hash.new

    map["speech_id"] = read_relative_file("~/.siriproxy/speech_id")
    map["assistant_id"] = read_relative_file("~/.siriproxy/assistant_id")
    map["session_data"] = read_relative_file("~/.siriproxy/session_data")

    puts map
    map
  end

  def ssl_handshake_completed
    self.ssled = true

    @auth_data = read_auth_data()
    puts "[Info - #{self.name}] SSL completed for #{self.name}" if $LOG_LEVEL > 1
  end

  def receive_line(line) #Process header
    puts "[Header - #{self.name}] #{line}" if $LOG_LEVEL > 2
    if(line == "") #empty line indicates end of headers
      puts "[Debug - #{self.name}] Found end of headers" if $LOG_LEVEL > 3
      set_binary_mode
      self.processed_headers = true
    if self.name=="Guzzoni" 
        puts "   @connectionfromguzzoni=true "
        @connectionfromguzzoni=true
      end
      ##############
      #A Device has connected!!!
      #Check for User Agent and replace correctly
      
		elsif line.match(/^Host:/)
      line = "Host: guzzoni.apple.com"  #Keeps Apple from instantly knowing that
      #this is a Proxy Server.
		elsif line.match(/^User-Agent:/)   
      #if its and iphone4s
      self.clientport, self.clientip = Socket.unpack_sockaddr_in(get_peername) 
			if line.match(/iPhone4,1;/)
        puts "[RollEyes - Siri*-*Proxy]" 
        puts "[Info - SiriProxy] iPhone 4S connected from IP #{self.clientip}"        
        puts "[RollEyes - Siri*-*Proxy]" 
				self.is_4S = true
        @devicetype="iPhone4S"
      else # now seperates anything else exept 4s
        #we can close connections here .... and we can count them here       
        puts "[Info - Siriproxy] Curent connections [#{$conf.active_connections}]"
        #Some code in order connections to depend on the evailable keys
        #if no keys then maximize the connections in order to prevent max connection reach and 4s not be able to connect
        #
        @max_connections=$conf.max_connections
        @keysavailable=$keyDao.listkeys().count   
        
        if @keysavailable==0  #this is not needed anymore! will be removed
          @max_connections=700#max mem 
        elsif @keysavailable>0
          @max_connections=$conf.max_connections * @keysavailable
        end
        
        if $conf.active_connections>=@max_connections 
          self.close_connection() #close connections
          self.other_connection.close_connection() #close other          
          puts "[Warning - Siriproxy] Max Connections reached! Connections Closed...."
        end
        if  line.match(/iPhone3,1;/)
          #if its iphone4,etc	 			
          self.is_4S = false	
          @devicetype="GSM iPhone4"
          puts "[Info - SiriProxy] GSM iPhone 4 connected from IP #{self.clientip}"
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line["iPhone3,1"] = "iPhone4,1"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2      
        elsif  line.match(/iPhone3,3;/)
          self.is_4S = false				
          @devicetype="CDMA iPhone4"
          puts "[Info - SiriProxy] CDMA iPhone 4 connected from IP #{self.clientip}"
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line["iPhone3,3"] = "iPhone4,1"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
        elsif line.match(/iPad2,1;/)	
          self.is_4S = false				
          @devicetype="iPad2 Wifi Only"
          puts "[Info - SiriProxy] iPad2 Wifi Only connected from IP #{self.clientip}"						
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line["iPad/iPad2,1"] = "iPhone/iPhone4,1"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2				
        elsif line.match(/iPad2,2;/)	
          self.is_4S = false				
          @devicetype="iPad2 GSM"
          puts "[Info - SiriProxy] iPad2 GSM connected from IP #{self.clientip}"						
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line["iPad/iPad2,2"] = "iPhone/iPhone4,1"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2				
        elsif line.match(/iPad2,3;/)	
          self.is_4S = false				
          @devicetype="iPad2 CDMA"
          puts "[Info - SiriProxy] iPad2 CDMA connected from IP #{self.clientip}"						
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line["iPad/iPad2,3"] = "iPhone/iPhone4,1"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2				
        elsif line.match(/iPad1,1;/)		
          self.is_4S = false		
          @devicetype="iPad 1st generation"
          puts "[Info - SiriProxy] iPad 1st generation connected from IP #{self.clientip}"						
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line["iPad/iPad1,1"] = "iPhone/iPhone4,1"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2				
        elsif line.match(/iPod4,1;/)		
          self.is_4S = false	
          @devicetype="iPod touch 4th generation"
          puts "[Info - SiriProxy] iPod touch 4th generation connected from IP #{self.clientip}"					
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line["iPod touch/iPod4,1"] = "iPhone/iPhone4,1"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
        else
          #Everithing else like android devices, computer apps etc        
          #Change unknown to iPhone to make sure everything works..
          puts "[Info - SiriProxy] Unknow Device Connected from IP #{self.clientip}"	
          self.is_4S = false
          @devicetype="Unknown Device"
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2
          line = "User-Agent: Assistant(iPhone/iPhone4,1; iPhone OS/5.0.1/9A405) Ace/1.0"
          puts "[Info - SiriProxy] Changed header to iphone4s] "
          puts "[Info - SiriProxy] Original Header: " + line if $LOG_LEVEL > 2				
        end
      end
    end    
    
    self.output_buffer << (line + "\x0d\x0a") #Restore the CR-LF to the end of the line

    flush_output_buffer()
  end

  def receive_binary_data(data)
    self.input_buffer << data

    ##Consume the "0xAACCEE02" data at the start of the stream if necessary (by forwarding it to the output buffer)
    if(self.consumed_ace == false)
      self.output_buffer << input_buffer[0..3]
      self.input_buffer = input_buffer[4..-1]
      self.consumed_ace = true;
    end

    process_compressed_data()

    flush_output_buffer()
  end

  def flush_output_buffer
    return if output_buffer.empty?

    if other_connection.ssled
      puts "[Debug - #{self.name}] Forwarding #{self.output_buffer.length} bytes of data to #{other_connection.name}" if $LOG_LEVEL > 5
      #puts  self.output_buffer.to_hex if $LOG_LEVEL > 5
      other_connection.send_data(output_buffer)
      self.output_buffer = ""
    else
      puts "[Debug - #{self.name}] Buffering some data for later (#{self.output_buffer.length} bytes buffered)" if $LOG_LEVEL > 5
      #puts  self.output_buffer.to_hex if $LOG_LEVEL > 5
    end
  end

  def process_compressed_data    
    begin
      self.unzipped_input << unzip_stream.inflate(self.input_buffer)
    rescue	
      puts "[Warning - SiriProxy] Currupted Data!!! Clearing buffer!"
      self.unzipped_input = ""
    end
    self.input_buffer = ""
    puts "========UNZIPPED DATA (from #{self.name} =========" if $LOG_LEVEL > 5
    puts unzipped_input.to_hex if $LOG_LEVEL > 5
    puts "==================================================" if $LOG_LEVEL > 5

    while(self.has_next_object?)
      object = read_next_object_from_unzipped()

      if(object != nil) #will be nil if the next object is a ping/pong
        new_object = prep_received_object(object) #give the world a chance to mess with folks

        inject_object_to_output_stream(new_object) if new_object != nil #might be nil if "the world" decides to rid us of the object
      end
    end
  end

  def has_next_object?
    return false if unzipped_input.empty? #empty
    unpacked = unzipped_input[0...5].unpack('H*').first
    return true if(unpacked.match(/^0[34]/)) #Ping or pong
    begin
      if unpacked.match(/^[0-9][15-9]/)
        puts "ROGUE PACKET!!! WHAT IS IT?! TELL US!!! IN IRC!! COPY THE STUFF FROM BELOW"
        puts unpacked.to_hex
      end 
      objectLength = unpacked.match(/^0200(.{6})/)[1].to_i(16)
      return ((objectLength + 5) < unzipped_input.length) #determine if the length of the next object (plus its prefix) is less than the input buffer
    rescue 
      puts "[Bug - SiriProxy] Please contact Plamoni or somebody about this"
    end
  end

  def read_next_object_from_unzipped
    unpacked = unzipped_input[0...5].unpack('H*').first
    #the problem here is that the packet is now complete or something unknown for the match!
    #if first character is 0
    
    unpacked="0400000001" if !unpacked.match(/^0(.)(.{8})$/) # its the value that causes the bug! Will treat it as ping pong!!! Hope this resolves this
    #fingers crossed    
    info = unpacked.match(/^0(.)(.{8})$/) #some times this doesnt match! needs 10 chars !!!
   
    if unpacked==nil
      $stderr.puts "bug flash on unpacked"     
    end
    
    if info==nil
      $stderr.puts "bug flash on info"      #here lies the stupid bug!!!!!!!!!!!!!!!
      $stderr.puts unpacked
      
      #object=nil
      #return object
    end
    if info!=nil #lets hope for the magic fix
      if(info[1] == "3" || info[1] == "4") #Ping or pong -- just get these out of the way (and log them for good measure)
      #puts "Ping Pong #{unpacked}"
        object = unzipped_input[0...5]
      
        #debug
        if object==nil
          $stderr.puts "bug flash on object"         
        end
      
      
        self.unzipped_output << object

       type = (info[1] == "3") ? "Ping" : "Pong"
       puts "[#{type} - #{self.name}] (#{info[2].to_i(16)})" if $LOG_LEVEL > 3
       self.unzipped_input = unzipped_input[5..-1]

       flush_unzipped_output()
       return nil
     end
    end

    object_size = info[2].to_i(16)
    prefix = unzipped_input[0...5]
    object_data = unzipped_input[5...object_size+5]
    self.unzipped_input = unzipped_input[object_size+5..-1]
    parse_object(object_data)



  end


  def parse_object(object_data)
    plist = CFPropertyList::List.new(:data => object_data)
    object = CFPropertyList.native_types(plist.value)

    object
  end

  def inject_object_to_output_stream(object)
    if object["refId"] != nil && !object["refId"].empty?
      @block_rest_of_session = false if @block_rest_of_session && self.last_ref_id != object["refId"] #new session
      self.last_ref_id = object["refId"]
    end

    puts "[Info - Forwarding object to #{self.other_connection.name}] #{object["class"]}" if $LOG_LEVEL > 1

    object_data = object.to_plist(:plist_format => CFPropertyList::List::FORMAT_BINARY)

    #Recalculate the size in case the object gets modified. If new size is 0, then remove the object from the stream entirely
    obj_len = object_data.length

    if(obj_len > 0)
      prefix = [(0x0200000000 + obj_len).to_s(16).rjust(10, '0')].pack('H*')
      self.unzipped_output << prefix + object_data
    end

    flush_unzipped_output()
  end

  def flush_unzipped_output
    self.zip_stream << self.unzipped_output
    self.unzipped_output = ""
    self.output_buffer << zip_stream.flush

    flush_output_buffer()
  end

  def prep_received_object(object)
    if object["refId"] == self.last_ref_id && @block_rest_of_session
      puts "[Info - Dropping Object from Guzzoni] #{object["class"]}" if $LOG_LEVEL > 1
      pp object if $LOG_LEVEL > 3
      return nil
    end  
    
    #this comes as an reply from spire to set access token
    if(object["class"] == "CommandIgnored")
			puts "[Info - SiriProxy] Maybe a Bug or just ignoring the Authentication Token"
      if self.other_connection.activation_token_recieved==true and self.other_connection.activation_token.aceid==object["refId"]
        puts "[Info - SiriProxy] Letting the activation command ignored pass throught"
      else  
        return nil
      end			
		end

    if object["properties"] != nil
      if object["properties"]["sessionValidationData"] != nil
        if @ == false
          # We're on a 4S
          data = object["properties"]["sessionValidationData"].unpack('H*').join("")
          write_relative_file("~/.siriproxy/session_data", data)
        else
          if @auth_data == nil
            puts "[Error] No session data available."
          else
            puts "[Info] Found cached session data."
            object["properties"]["sessionValidationData"] = encode_data(@auth_data["session_data"])
          end
        end
      end

      if object["properties"]["speechId"] != nil
        if @faux == false
          # We're on a 4S
          data = object["properties"]["speechId"]
          write_relative_file("~/.siriproxy/speech_id", data)
        else
          if @auth_data == nil
            puts "[Error] No speech id available."
          else
            puts "[Info] Found cached speech id."
            object["properties"]["speechId"] = @auth_data["speech_id"]
          end
        end
      end

      if object["properties"]["assistantId"] != nil
        if @faux == false
          # We're on a 4S
          data = object["properties"]["assistantId"]
          write_relative_file("~/.siriproxy/assistant_id", data)
        else
          if @auth_data == nil
            puts "[Error] No assistant id available."
          else
            puts "[Info] Found cached assistant id."
            object["properties"]["assistantId"] = @auth_data["assistant_id"]
          end
        end
      end
    end

    puts "[Info - #{self.name}] Received Object: #{object["class"]}" if $LOG_LEVEL == 1
    puts "[Info - #{self.name}] Received Object: #{object["class"]} (group: #{object["group"]})" if $LOG_LEVEL == 2
    puts "[Info - #{self.name}] Received Object: #{object["class"]} (group: #{object["group"]}, ref_id: #{object["refId"]}, ace_id: #{object["aceId"]})" if $LOG_LEVEL > 2
    pp object if $LOG_LEVEL > 3

    #keeping this for filters
    new_obj = received_object(object)
    if new_obj == nil
      puts "[Info - Dropping Object from #{self.name}] #{object["class"]}" if $LOG_LEVEL > 1
      pp object if $LOG_LEVEL > 3
      return nil
    end

    #block the rest of the session if a plugin claims ownership
    speech = SiriProxy::Interpret.speech_recognized(object)
    if speech != nil
      inject_object_to_output_stream(object)
      block_rest_of_session if plugin_manager.process(speech)
      return nil
    end


    #object = new_obj if ((new_obj = SiriProxy::Interpret.unknown_intent(object, self, plugin_manager.method(:unknown_command))) != false)
    #object = new_obj if ((new_obj = SiriProxy::Interpret.speech_recognized(object, self, plugin_manager.method(:speech_recognized))) != false)

    object
  end

  #Stub -- override in subclass
  def received_object(object)

    object
  end

end
