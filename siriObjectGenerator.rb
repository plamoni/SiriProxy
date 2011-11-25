require 'rubygems'
require 'uuidtools'

def generate_siri_utterance(ref_id, text, speakableText=text, listenAfterSpeaking=false)
  object = SiriAddViews.new
  object.make_root(ref_id)
  object.views << SiriAssistantUtteranceView.new(text, speakableText, "Misc#ident", listenAfterSpeaking)
  return object.to_hash
end

def generate_request_completed(ref_id, callbacks=nil)
  object = SiriRequestCompleted.new()
  object.callbacks = callbacks if callbacks != nil
  object.make_root(ref_id)
  return object.to_hash
end

class SiriObject
  attr_accessor :klass, :group, :properties
  
  def initialize(klass, group)
    @klass = klass
    @group = group
    @properties = {}
  end
  
  #watch out for circular references!
  def to_hash
    hash = {
      "class" => self.klass,
      "group" => self.group,
      "properties" => {}
    }
    
    (hash["refId"] = ref_id) rescue nil
    (hash["aceId"] = ace_id) rescue nil
    
    properties.each_key { |key|
      if properties[key].class == Array
        hash["properties"][key] = []
        self.properties[key].each { |val| hash["properties"][key] << (val.to_hash rescue val) }
      else
        hash["properties"][key] = (properties[key].to_hash rescue properties[key])
      end
    }

    hash
  end
  
  def make_root(ref_id=nil, ace_id=nil)
    self.extend(SiriRootObject)
  
    self.ref_id = (ref_id || random_ref_id) 
    self.ace_id = (ace_id || random_ace_id)
  end
end

def add_property_to_class(klass, prop)
  klass.send(:define_method, (prop.to_s + "=").to_sym) { |value|
    self.properties[prop.to_s] = value
  }
  
  klass.send(:define_method, prop.to_s.to_sym) {
    self.properties[prop.to_s]
  }
end

module SiriRootObject
  attr_accessor :ref_id, :ace_id
  
  def random_ref_id
    UUIDTools::UUID.random_create.to_s.upcase
  end
  
  def random_ace_id
    UUIDTools::UUID.random_create.to_s
  end
end

class SiriAddViews < SiriObject
  def initialize(scrollToTop=false, temporary=false, dialogPhase="Completion", views=[])
    super("AddViews", "com.apple.ace.assistant")
    self.scrollToTop = scrollToTop
    self.views = views
    self.temporary = temporary
    self.dialogPhase = dialogPhase
  end
end
add_property_to_class(SiriAddViews, :scrollToTop)
add_property_to_class(SiriAddViews, :views)
add_property_to_class(SiriAddViews, :temporary)
add_property_to_class(SiriAddViews, :dialogPhase)

#####
# VIEWS
#####

class SiriAssistantUtteranceView < SiriObject
  def initialize(text="", speakableText=text, dialogIdentifier="Misc#ident", listenAfterSpeaking=false)
    super("AssistantUtteranceView", "com.apple.ace.assistant")
    self.text = text
    self.speakableText = speakableText
    self.dialogIdentifier = dialogIdentifier
    self.listenAfterSpeaking = listenAfterSpeaking
  end
end
add_property_to_class(SiriAssistantUtteranceView, :text)
add_property_to_class(SiriAssistantUtteranceView, :speakableText)
add_property_to_class(SiriAssistantUtteranceView, :dialogIdentifier)
add_property_to_class(SiriAssistantUtteranceView, :listenAfterSpeaking)

class SiriMapItemSnippet < SiriObject
  def initialize(userCurrentLocation=true, items=[])
    super("MapItemSnippet", "com.apple.ace.localsearch")
    self.userCurrentLocation = userCurrentLocation
    self.items = items
  end
end
add_property_to_class(SiriMapItemSnippet, :userCurrentLocation)
add_property_to_class(SiriMapItemSnippet, :items)

class SiriButton < SiriObject
  def initialize(text="Button Text", commands=[])
    super("Button", "com.apple.ace.assistant")
    self.text = text
    self.commands = commands
  end
end
add_property_to_class(SiriButton, :text)
add_property_to_class(SiriButton, :commands)

class SiriAnswerSnippet < SiriObject
  def initialize(answers=[], confirmationOptions=nil)
    super("Snippet", "com.apple.ace.answer")
    self.answers = answers

    if confirmationOptions
      # need to figure out good way to do API for this
      self.confirmationOptions = confirmationOptions
    end

  end
end
add_property_to_class(SiriAnswerSnippet, :answers)
add_property_to_class(SiriAnswerSnippet, :confirmationOptions)

#####
# Items
#####

class SiriMapItem < SiriObject
  def initialize(label="Apple Headquarters", location=SiriLocation.new, detailType="BUSINESS_ITEM")
    super("MapItem", "com.apple.ace.localsearch")
    self.label = label
    self.detailType = detailType
    self.location = location
  end
end
add_property_to_class(SiriMapItem, :label)
add_property_to_class(SiriMapItem, :detailType)
add_property_to_class(SiriMapItem, :location)

#####
# Commands
#####

class SiriSendCommands < SiriObject
  def initialize(commands=[])
    super("SendCommands", "com.apple.ace.system")
    self.commands=commands
  end
end
add_property_to_class(SiriSendCommands, :commands)

class SiriConfirmationOptions < SiriObject
  def initialize(submitCommands=[], cancelCommands=[], denyCommands=[], confirmCommands=[], denyText="Cancel", cancelLabel="Cancel", submitLabel="Send", confirmText="Send", cancelTrigger="Deny")
    super("ConfirmationOptions", "com.apple.ace.assistant")

    self.submitCommands = submitCommands
    self.cancelCommands = cancelCommands
    self.denyCommands = denyCommands
    self.confirmCommands = confirmCommands

    self.denyText = denyText 
    self.cancelLabel = cancelLabel 
    self.submitLabel = submitLabel 
    self.confirmText = confirmText 
    self.cancelTrigger = cancelTrigger 
  end
end
add_property_to_class(SiriConfirmationOptions, :submitCommands)
add_property_to_class(SiriConfirmationOptions, :cancelCommands)
add_property_to_class(SiriConfirmationOptions, :denyCommands)
add_property_to_class(SiriConfirmationOptions, :confirmCommands)
add_property_to_class(SiriConfirmationOptions, :denyText)
add_property_to_class(SiriConfirmationOptions, :cancelLabel)
add_property_to_class(SiriConfirmationOptions, :submitLabel)
add_property_to_class(SiriConfirmationOptions, :confirmText)
add_property_to_class(SiriConfirmationOptions, :cancelTrigger)

class SiriConfirmSnippetCommand < SiriObject
  def initialize(request_id = "")
    super("ConfirmSnippet", "com.apple.ace.assistant")
    self.request_id = request_id
  end
end
add_property_to_class(SiriConfirmSnippetCommand, :request_id)

class SiriCancelSnippetCommand < SiriObject
  def initialize(request_id = "")
    super("ConfirmSnippet", "com.apple.ace.assistant")
    self.request_id = request_id
  end
end
add_property_to_class(SiriCancelSnippetCommand, :request_id)

#####
# Objects
#####

class SiriLocation < SiriObject
  def initialize(label="Apple", street="1 Infinite Loop", city="Cupertino", stateCode="CA", countryCode="US", postalCode="95014", latitude=37.3317031860352, longitude=-122.030089795589)
    super("Location", "com.apple.ace.system")
    self.label = label
    self.street = street
    self.city = city
    self.stateCode = stateCode
    self.countryCode = countryCode
    self.postalCode = postalCode
    self.latitude = latitude
    self.longitude = longitude
  end
end
add_property_to_class(SiriLocation, :label)
add_property_to_class(SiriLocation, :street)
add_property_to_class(SiriLocation, :city)
add_property_to_class(SiriLocation, :stateCode)
add_property_to_class(SiriLocation, :countryCode)
add_property_to_class(SiriLocation, :postalCode)
add_property_to_class(SiriLocation, :latitude)
add_property_to_class(SiriLocation, :longitude)

class SiriAnswer < SiriObject
  def initialize(title="", lines=[])
    super("Object", "com.apple.ace.answer")
    self.title = title
    self.lines = lines
  end
end
add_property_to_class(SiriAnswer, :title)
add_property_to_class(SiriAnswer, :lines)

class SiriAnswerLine < SiriObject
  def initialize(text="", image="")
    super("ObjectLine", "com.apple.ace.answer")
    self.text = text
    self.image = image
  end
end
add_property_to_class(SiriAnswerLine, :text)
add_property_to_class(SiriAnswerLine, :image)

#####
# Guzzoni Commands (commands that typically come from the server side)
#####

class SiriGetRequestOrigin < SiriObject
  def initialize(desiredAccuracy="HundredMeters", searchTimeout=8.0, maxAge=1800)
    super("GetRequestOrigin", "com.apple.ace.system")
    self.desiredAccuracy = desiredAccuracy
    self.searchTimeout = searchTimeout
    self.maxAge = maxAge
  end
end
add_property_to_class(SiriGetRequestOrigin, :desiredAccuracy)
add_property_to_class(SiriGetRequestOrigin, :searchTimeout)
add_property_to_class(SiriGetRequestOrigin, :maxAge)

class SiriRequestCompleted < SiriObject
  def initialize(callbacks=[])
    super("RequestCompleted", "com.apple.ace.system")
    self.callbacks = callbacks
  end
end
add_property_to_class(SiriRequestCompleted, :callbacks)

#####
# iPhone Responses (misc meta data back to the server)
#####

class SiriStartRequest < SiriObject
  def initialize(utterance="Testing", handsFree=false, proxyOnly=false)
    super("StartRequest", "com.apple.ace.system")
    self.utterance = utterance
    self.handsFree = handsFree
    if proxyOnly # dont send local when false since its non standard
      self.proxyOnly = proxyOnly
    end
  end
end
add_property_to_class(SiriStartRequest, :utterance)
add_property_to_class(SiriStartRequest, :handsFree)
add_property_to_class(SiriStartRequest, :proxyOnly)


class SiriSetRequestOrigin < SiriObject
  def initialize(longitude=-122.030089795589, latitude=37.3317031860352, desiredAccuracy="HundredMeters", altitude=0.0, speed=1.0, direction=1.0, age=0, horizontalAccuracy=50.0, verticalAccuracy=10.0)
    super("SetRequestOrigin", "com.apple.ace.system")
    self.horizontalAccuracy = horizontalAccuracy
    self.latitude = latitude
    self.desiredAccuracy = desiredAccuracy
    self.altitude = altitude
    self.speed = speed
    self.longitude = longitude
    self.verticalAccuracy = verticalAccuracy
    self.direction = direction
    self.age = age
  end
end
add_property_to_class(SiriSetRequestOrigin, :horizontalAccuracy)
add_property_to_class(SiriSetRequestOrigin, :latitude)
add_property_to_class(SiriSetRequestOrigin, :desiredAccuracy)
add_property_to_class(SiriSetRequestOrigin, :altitude)
add_property_to_class(SiriSetRequestOrigin, :speed)
add_property_to_class(SiriSetRequestOrigin, :longitude)
add_property_to_class(SiriSetRequestOrigin, :verticalAccuracy)
add_property_to_class(SiriSetRequestOrigin, :direction)
add_property_to_class(SiriSetRequestOrigin, :age)



