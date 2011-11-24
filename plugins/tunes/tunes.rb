require 'tweakSiri'
require 'siriObjectGenerator'

#######
#
# iTunes controls! Hooray!
# NOTE: all commands have to include the word "iTunes", to distinguish from the built-in iPod controls.
# Otherwise, works roughly as you would expect it to. It's pretty flexible.
#
# Examples:
# "what song is iTunes playing?" "iTunes, who is this by?" "Siri, tell iTunes to skip this."
# "Give this song four stars in iTunes." "Go back to the last song in iTunes." "iTunes, pause."
#
#######

class Tunes < SiriPlugin

	def speech_recognized(object, connection, command)
		if(command.match(/i ?tunes/i))
			self.plugin_manager.block_rest_of_session_from_server
			
			connection.inject_object_to_output_stream(object)
			
			utterance = nil
			nowPlaying = ""
			
			matchData = nil
			
			if(command.match(/(who|what (artist|band|singer|group)).+(this|playing)/i))
				nowArtist = commandiTunes("get artist of current track")
				return generate_siri_utterance(connection.lastRefId, "This is " + nowArtist + ".")
			elsif(command.match(/what.+(this|playing)/))
				return generate_siri_utterance(connection.lastRefId, "This is " + commandiTunes(detailedNowPlayingCommand()) + ".");
			elsif(command.match(/play/i))
				nowPlaying = commandiTunes("play", true)
				utterance = "playing " + nowPlaying
			elsif(command.match(/pause|because/i)) # Homophones :(
				commandiTunes("pause")
				utterance = "pausing"
			elsif(command.match(/skip|next/i))
				nowPlaying = commandiTunes("next track", true)
				utterance = "skipping to " + nowPlaying
			elsif(command.match(/rewind|go back/i))
				commandiTunes("previous track")
				utterance = "going back"
			# Homophones :(
			elsif(matchData = command.match(/(rate|give|great|write|rating) .*(zero|no|know|one|won|two|to|too|three|four|for|fore|five|[0-5])(\*| stars?)/i))
				desiredRating = -1
				case matchData[2]
					when "zero", "0", "no", "know"
						desiredRating = 0
					when "one", "won", "1"
						desiredRating = 1
					when "two", "to", "too", "2"
						desiredRating = 2
					when "three", "3"
						desiredRating = 3
					when "four", "for", "fore", "4"
						desiredRating = 4
					when "five", "5"
						desiredRating = 5
				end
				
				if(desiredRating >= 0)
					numericRating = desiredRating * 20
					nowPlaying = commandiTunes("set rating of current track to #{numericRating}", true, true)
					utterance = "I rated " + nowPlaying + " #{desiredRating} stars"
				end
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
	
	def commandiTunes(scriptCommand, getResultingNowPlaying = false, useShortNowPlaying = false)
		extraCommand = ""
		if getResultingNowPlaying
			if useShortNowPlaying
				extraCommand = "return \"“\" & name of current track & \"”\""
			else
				extraCommand = detailedNowPlayingCommand()
			end
		end
		scriptCommand = scriptCommand + "\n" + extraCommand
		return (`osascript -e 'tell application "iTunes"\n#{scriptCommand}\nend'`).strip
	end
end