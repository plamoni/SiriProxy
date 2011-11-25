require 'tweakSiri'
require 'siriObjectGenerator'

#######
#
# Ever wanted to be commander of your own Xcode empire? Well now's your chance!
# Order Siri to "prepare the build!" and he/she will do just that!
#
# Xcode will build and run the currently active build configuration
#
# Requires support for Asstistive Devices in Universal Access
#
#######

class Xcode < SiriPlugin

	def speech_recognized(object, connection, command)
		if(command.match(/(prepare the build)/i))
			self.plugin_manager.block_rest_of_session_from_server
			
			connection.inject_object_to_output_stream(object)
			
			buildXcode()
			return generate_siri_utterance(connection.lastRefId, "Build in progress, captain!")
		end
		
		object
	end
	
	def buildXcode()
	  (`osascript -e 'tell application "Xcode"
    	activate
    end tell

    tell application "System Events"
    	key code 15 using {command down}
    end tell
    '`).strip
  end
end