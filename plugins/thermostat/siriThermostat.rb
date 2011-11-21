#!/usr/bin/env ruby
require 'tweakSiri'
require 'siriObjectGenerator'
require 'json' 
require 'open-uri'
require 'httparty'

#############
# This example plugin is more of a demonstration than anything else. If you happen to have a RadioThermostat thermostat, then you can
# use it if you like. But it's mostly for demonstration purposes. Check out the code and see what all you can do!
#############

THERMOSTAT_HOST = "192.168.2.71"

class SiriThermostat < SiriPlugin
	def status_of_thermostat(connection)
		
		Thread.new {
			status = JSON.parse(open("http://#{THERMOSTAT_HOST}/tstat").read)
		
			connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "The temperature is currently #{status["temp"]} degrees."))
			connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, " The heater and air conditioner are turned off." )) if(status["tmode"] == 0)
			
			if(status["tmode"] == 1)
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, " The heater is set to engage at #{status["t_heat"]} degrees."))
				response = " The heater is off." if(status["tstate"] == 0)
				response = " The heater is running." if(status["tstate"] == 1)
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, response))
			elsif(status["tmode"] == 2)
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, " The air conditioner is set to engage at #{status["t_cool"]} degrees."))
				response = " The air conditioner is off." if(status["tstate"] == 0)
				response = " The air conditioner running." if(status["tstate"] == 2)
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, response))
			end
			
		}
		
		return "Checking the status of the thermostat"
	end
		Thread.new {
			status = JSON.parse(open("http://#{THERMOSTAT_HOST}/tstat").read)
		
			connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "The temperature is currently #{status["temp"]} degrees."))
			connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, " The heater and air conditioner are turned off." )) if(status["tmode"] == 0)
			
			if(status["tmode"] == 1) #heat
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, " The heater is set to engage below #{status["t_heat"]} degrees."))
				response = " The heater is off." if(status["tstate"] == 0)
				response = " The heater is running." if(status["tstate"] == 1)
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, response))
			elsif(status["tmode"] == 2) #a/c
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, " The air conditioner is set to engage at #{status["t_cool"]} degrees."))
				response = " The air conditioner is off." if(status["tstate"] == 0)
				response = " The air conditioner running." if(status["tstate"] == 2)
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, response))
			end
			
		}
	
	def set_thermostat(temp, connection)
		Thread.new {
			status = JSON.parse(open("http://#{THERMOSTAT_HOST}/tstat").read)
		
			if(status["tmode"] == 1) #heat
				status = HTTParty.post("http://#{THERMOSTAT_HOST}/tstat", {:body => "{\"tmode\":1,\"t_heat\":#{temp.to_i}}"})
					
				if(status["success"] == 0)
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "The heater has been set to #{temp} degrees."))
				else
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Sorry, there was a problem setting the temperature"))
				end
			elsif(status["tmode"] == 2) #a/c
				res = Net::HTTP.post_form(URI("http://#{THERMOSTAT_HOST}/tstat"), 'tmode' => 2, 't_cool' => temp.to_i)
				status = JSON.parse(res.body) 
				
				if(status["success"] == 0)
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "The air conditioner has been set to #{temp} degrees."))
				else
					connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Sorry, there was a problem setting the temperature"))
				end
			else
				connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "Sorry, the thermostat is off."))
			end
		}	
	
		return "One moment while I set the thermostat to #{temp} degrees"
	end
	
	def temperature(connection)
		Thread.new {
			status = JSON.parse(open("http://#{THERMOSTAT_HOST}/tstat").read)
		
			connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, "The current inside temperature is #{status["temp"]} degrees."))		
		}
		
		return "Checking the inside temperature."
	end
	
	
	#plusgin implementations:
	def object_from_guzzoni(object, connection) 
		
		object
	end
	
	
	#Don't forget to return the object!
	def object_from_client(object, connection)
		
		
		object
	end
	
	
	def unknown_command(object, connection, command)		
		if(command.match(/thermostat/i))	
			self.plugin_manager.block_rest_of_session_from_server		
			if(temp = command.match(/([0-9]+)/)[1] rescue false)
				response = set_thermostat(temp, connection)
			elsif(command.match(/status/i))
				response = status_of_thermostat(connection)
			end
			
			return generate_siri_utterance(connection.lastRefId, response)
		end
		
		object
	end
	
	def speech_recognized(object, connection, phrase)	
		if(phrase.match(/temperature/i) && phrase.match(/inside/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, temperature(connection))
		end
		
		if(phrase.match(/thermostat/i) && phrase.match(/status/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, status_of_thermostat(connection))
		end
		
		object
	end
end