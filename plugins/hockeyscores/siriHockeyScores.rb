require './tweaksiri'
require './siriobjectgenerator'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check tonight's hockey scores
# Example usage: "What's the score of the Avalanche game?"
#############

class SiriHockeyScores < SiriPlugin
  @firstTeamName = ""
  @firstTeamScore = ""
  @secondTeamName = ""
  @secondTeamScore = ""
	
	def score(connection, userTeam)
	  Thread.new {
	    doc = Nokogiri::HTML(open("http://www.nhl.com/ice/m_scores.htm"))
      scores = doc.css(".gmDisplay")
      
      scores.each {
        |score|
        team = score.css(".blkcolor")
        team.each {
          |teamname|
          if(teamname.content.strip == userTeam)
            firstTeam = score.css("tr:nth-child(2)").first
            @firstTeamName = firstTeam.css(".blkcolor").first.content.strip
            @firstTeamScore = firstTeam.css("td:nth-child(2)").first.content.strip
            secondTeam = score.css("tr:nth-child(3)").first
            @secondTeamName = secondTeam.css(".blkcolor").first.content.strip
            @secondTeamScore = secondTeam.css("td:nth-child(2)").first.content.strip
            break
          end
        }
      }
      if((@firstTeamName == "") || (@secondTeamName == ""))
        response = "No games involving the " + userTeam + " were found playing tonight"
      else 
        response = "The score for the " + userTeam + " game is: " + @firstTeamName + " (" + @firstTeamScore + "), " + @secondTeamName + " (" + @secondTeamScore + ")"
			end  
			connection.inject_object_to_output_stream(generate_siri_utterance(connection.lastRefId, response))
		}
		
		return "Checking on tonight's hockey games"
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
		
		
		object
	end
	
	def speech_recognized(object, connection, phrase)	
    if(phrase.match(/score/i) && (phrase.match(/anaheim/i) || phrase.match(/ducks/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Ducks"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/boston/i) || phrase.match(/bruins/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Bruins"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/buffalo/i) || phrase.match(/sabres/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Sabres"))
		end
		
    if(phrase.match(/score/i) && (phrase.match(/calgary/i) || phrase.match(/flames/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Flames"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/carolina/i) || phrase.match(/hurricanes/i) || phrase.match(/canes/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Hurricanes"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/chicago/i) || phrase.match(/blackhawks/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Blackhawks"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/colorado/i) || phrase.match(/avalanche/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Avalanche"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/columbus/i) || phrase.match(/blue jackets/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Blue Jackets"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/dallas/i) || phrase.match(/stars/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Stars"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/detroit/i) || phrase.match(/red wings/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Red Wings"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/edmonton/i) || phrase.match(/oilers/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Avalanche"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/florida/i) || phrase.match(/panthers/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Panthers"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/l.a./i) || phrase.match(/los angeles/i) || phrase.match(/kings/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Kings"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/minnesota/i) || phrase.match(/wild/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Wild"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/montreal/i) || phrase.match(/canadiens/i) || phrase.match(/canadians/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Canadiens"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/nashville/i) || phrase.match(/predators/i) || phrase.match(/preds/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Predators"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/new jersey/i) || phrase.match(/devils/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Devils"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/new york islanders/i) || phrase.match(/islanders/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Islanders"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/new york rangers/i) || phrase.match(/rangers/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Rangers"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/ottawa/i) || phrase.match(/senators/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Senators"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/philadelphia/i) || phrase.match(/philly/i) || phrase.match(/flyers/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Flyers"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/phoenix/i) || phrase.match(/coyotes/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Coyotes"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/pittsburgh/i) || phrase.match(/penguins/i) || phrase.match(/pens/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Penguins"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/san jose/i) || phrase.match(/sharks/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Sharks"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/st. louis/i) || phrase.match(/blues/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Blues"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/tampa bay/i) || phrase.match(/lightning/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Lightning"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/toronto/i) || phrase.match(/leafs/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Maple Leafs"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/vancouver/i) || phrase.match(/canucks/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Canucks"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/washington/i) || phrase.match(/capitals/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Capitals"))
		end
		
		if(phrase.match(/score/i) && (phrase.match(/winnipeg/i) || phrase.match(/jets/i)) && phrase.match(/game/i))
			self.plugin_manager.block_rest_of_session_from_server
			connection.inject_object_to_output_stream(object)
			return generate_siri_utterance(connection.lastRefId, score(connection, "Jets"))
		end
		
		object
	end
end
