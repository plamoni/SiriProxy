#!/usr/bin/env ruby
require 'tweaksiri'
require 'siriobjectgenerator'
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
      status = JSON.parse open("http://#{THERMOSTAT_HOST}/tstat").read

      connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, "The temperature is currently #{status["temp"]} degrees.")
      connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, " The heater and air conditioner are turned off.") if status["tmode"] == 0

      case status["tmode"]
      when 1
        connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, " The heater is set to engage at #{status["t_heat"]} degrees.")
        response = case status["tstate"]
        when 0
          " The heater is off."
        when 1
          " The heater is running."
        end
        connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, response)
      when 2
        connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, " The air conditioner is set to engage at #{status["t_cool"]} degrees.")
        response = case status["tstate"]
        when
          " The air conditioner is off."
        when 2
          " The air conditioner running."
        end
        connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, response)
      end
    }

    "Checking the status of the thermostat"
  end

  def set_thermostat(temp, connection)
    Thread.new {
      status = JSON.parse open("http://#{THERMOSTAT_HOST}/tstat").read

      case status["tmode"]
      when 1 #heat
        status = HTTParty.post "http://#{THERMOSTAT_HOST}/tstat", :body => "{\"tmode\":1,\"t_heat\":#{temp.to_i}}"

        if status["success"] == 0
          connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, "The heater has been set to #{temp} degrees.")
        else
          connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, "Sorry, there was a problem setting the temperature")
        end
      when 2 #a/c
        res = Net::HTTP.post_form URI("http://#{THERMOSTAT_HOST}/tstat"), 'tmode' => 2, 't_cool' => temp.to_i
        status = JSON.parse res.body

        if status["success"] == 0
          connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, "The air conditioner has been set to #{temp} degrees.")
        else
          connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, "Sorry, there was a problem setting the temperature")
        end
      else
        connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, "Sorry, the thermostat is off.")
      end
    }

    "One moment while I set the thermostat to #{temp} degrees"
  end

  def temperature(connection)
    Thread.new {
      status = JSON.parse open("http://#{THERMOSTAT_HOST}/tstat").read

      connection.inject_object_to_output_stream generate_siri_utterance(connection.lastRefId, "The current inside temperature is #{status["temp"]} degrees.")
    }

    "Checking the inside temperature."
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
    if command.match(/thermostat/i)
      self.plugin_manager.block_rest_of_session_from_server
      response = case command
      when /([0-9]+)/
        set_thermostat $1, connection
      when /status/i
        status_of_thermostat connection
      end

      return generate_siri_utterance(connection.lastRefId, response)
    end

    object
  end

  def speech_recognized(object, connection, phrase)
    if phrase.match(/temperature/i) && phrase.match(/inside/i)
      self.plugin_manager.block_rest_of_session_from_server
      connection.inject_object_to_output_stream object
      return generate_siri_utterance(connection.lastRefId, temperature(connection))
    end

    if phrase.match(/thermostat/i) && phrase.match(/status/i)
      self.plugin_manager.block_rest_of_session_from_server
      connection.inject_object_to_output_stream object
      return generate_siri_utterance(connection.lastRefId, status_of_thermostat(connection))
    end

    object
  end
end
