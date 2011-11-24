require 'tweakSiri'
require 'siriObjectGenerator'

#######
#
# 99.9% of the work was done by Noah Witherspoon (https://github.com/mahalis) with his iTunes plugin
# https://github.com/plamoni/SiriProxy/pull/39
# 
# I just made it work with Spotify.
#
# Examples:
# "what song is Spotify playing?" "Spotify, who is this by?" "Siri, tell Spotify to skip this."
# "Go back to the last song in Spotify." "Spotify, pause."
#
#######

class Spotify < SiriPlugin

	def speech_recognized(object, connection, command)
		if(command.match(/(spotify|spotter five|spot of phi|spot fie)/i)) # Siri doesn't really know how to spell "Spotify"
			self.plugin_manager.block_rest_of_session_from_server
			
			connection.inject_object_to_output_stream(object)
			
			utterance = nil
			nowPlaying = ""
			
			matchData = nil
			
			if(command.match(/(who|what (artist|band|singer|group)).+(this|playing)/i))
				nowArtist = commandSpotify("get artist of current track")
				return generate_siri_utterance(connection.lastRefId, "This is " + nowArtist + ".")
			elsif(command.match(/what.+(this|playing)/))
				return generate_siri_utterance(connection.lastRefId, "This is " + commandSpotify(detailedNowPlayingCommand()) + ".");
			elsif(command.match(/play/i))
				nowPlaying = commandSpotify("play", true)
				utterance = "playing " + nowPlaying
			elsif(command.match(/pause|because/i)) # Homophones :(
				commandSpotify("pause")
				utterance = "pausing"
			elsif(command.match(/skip|next/i))
				nowPlaying = commandSpotify("next track", true)
				utterance = "skipping to " + nowPlaying
			elsif(command.match(/rewind|go back/i))
				commandSpotify("previous track")
				utterance = "going back"
			end
			
			if utterance != nil
				return generate_siri_utterance(connection.lastRefId, "OK, " + utterance + ".")
			end
			
			return generate_siri_utterance(connection.lastRefId, "I’m sorry, I don't understand that.")
		end	
		
		
		object
	end
	
	def detailedNowPlayingCommand()
		return "set nowPlaying to current track\nreturn \"“\" & name of nowPlaying & \"” by \" & artist of nowPlaying"
	end
	
	def commandSpotify(scriptCommand, getResultingNowPlaying = false, useShortNowPlaying = false)
		extraCommand = ""
		if getResultingNowPlaying
			if useShortNowPlaying
				extraCommand = "return \"“\" & name of current track & \"”\""
			else
				extraCommand = detailedNowPlayingCommand()
			end
		end
		scriptCommand = scriptCommand + "\n" + extraCommand
		return (`osascript -e 'tell application "Spotify"\n#{scriptCommand}\nend'`).strip
	end
end