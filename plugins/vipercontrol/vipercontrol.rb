require 'tweakSiri'
require 'siriObjectGenerator'
require 'json'
require 'open-uri'

#######
# Viper SmartStart Control Plugin
# Needs some work, very basic functionality
# I want to change the regex later to support commands like "Lock my car", "unlock my car", "start my car", etc...
#######

class Fiquett < ViperControl
	####
	# This gets called every time an object is received from the Guzzoni server
	def object_from_guzzoni(object, connection) 
		
		object
	end
		
	####
	# This gets called every time an object is received from an iPhone
	def object_from_client(object, connection)
		
		object
	end
	
	def send_command_to_car(viper_command,connection)
		Thread.new {
		
			status = JSON.parse(open("http://www.yourserver.com/viper_control.php?action=#{viper_command}").read)
			connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Viper Connection Established"))
			puts "#{status["Return"]}"
			if(status["Return"]["ResponseSummary"]["StatusCode"] == 0) #successful
					
				if(status["Return"]["Results"]["Device"]["Action"] == "arm")
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Vehicle security engaged!"))
				elsif(status["Return"]["Results"]["Device"]["Action"] == "disarm")
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Vehicle security disabled!"))
				elsif(status["Return"]["Results"]["Device"]["Action"]  == "remote")
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Vehicle ignition has been triggered"))
				elsif(status["Return"]["Results"]["Device"]["Action"]  == "trunk")
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Vechile trunk has been opened"))
				end
			else
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Sorry, could not connect to your vehicle."))
			end
		}	
	
		return "One moment while I connect to your vehicle..."
	end
	
	####
	# When the server reports an "unkown command", this gets called. It's useful for implementing commands that aren't otherwise covered
	def unknown_command(object, connection, command)		
		if(command.match(/vehicle/i))	
			self.plugin_manager.block_rest_of_session_from_server		
			if(command.match(/lock/i) || command.match(/disarm/i))
				response = send_command_to_car("disarm",connection)
			elsif(command.match(/unlock/i) || command.match(/arm/i))
				response = send_command_to_car("arm",connection)
			elsif(command.match(/start/i) || command.match(/stop/i))
				response = send_command_to_car("remote",connection)
			else response = "Please specify a command to send to your vehicle!"
			end
			
			return generate_siri_utterance(connection.lastRefId, response)
	end
		
		
		object
	end

	
end 