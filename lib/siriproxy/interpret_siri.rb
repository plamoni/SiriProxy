######
# The idea behind this class is that you can call the different
# methods to get different interpretations of a Siri object.
# For instance, you can "unknown_intent" and it will check 
# to see if an object is a "Common#unknownIntent" response and 
# call the provided processor method with the appropriate info.
# processor method signatures are provided in comments above each
# method.
# 
# each method will return "nil" if the object is not the valid
# type. If it is, it will return the result of the processor.
#####
class SiriProxy::Interpret
  class << self
    #Checks if the object is Guzzoni responding that it can't 
    #determine the intent of the query
    #processor(object, connection, unknown_text)
    def unknown_intent(object, connection, processor) 
      return false if object == nil
      return false if (!(object["properties"]["views"][0]["properties"]["dialogIdentifier"] == "Common#unknownIntent") rescue true)
      
      searchUtterance =  object["properties"]["views"][1]["properties"]["commands"][0]["properties"]["commands"][0]["properties"]["utterance"]
      searchText = searchUtterance.split("^")[3]
      return processor.call(object, connection, searchText)
      
      return false
    end
    
    #Checks if the object is Guzzoni responding that it recognized
    #speech. Sends "best interpretation" phrase to processor
    #processor(object, connection, phrase)
    def speech_recognized(object)
      return nil if object == nil
      return nil if (!(object["class"] == "SpeechRecognized") rescue true)
      phrase = ""
      
      object["properties"]["recognition"]["properties"]["phrases"].map { |phraseObj| 
        phraseObj["properties"]["interpretations"].first["properties"]["tokens"].map { |token|
          tokenProps = token["properties"]
          
          phrase = phrase[0..-2] if tokenProps["removeSpaceBefore"]
          phrase << tokenProps["text"]
          phrase << " " if !tokenProps["removeSpaceAfter"]
        }
      }
      
      phrase
    end
  end
end
