#!/usr/bin/env ruby
require 'rubygems'
require 'uuidtools'

def generate_siri_utterance(refId, text, speakableText=text)
	object = SiriAddViews.new
	object.make_root(refId)
	object.views << SiriAssistantUtteranceView.new(text, speakableText)
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
		
		(hash["refId"] = self.refId) rescue nil
		(hash["aceId"] = self.aceId) rescue nil
		
		self.properties.each_key { |key|
			if self.properties[key].class == Array
				hash["properties"][key] = []
				self.properties[key].each { |val| hash["properties"][key] << (val.to_hash rescue val) }
			else
				hash["properties"][key] = (self.properties[key].to_hash rescue self.properties[key])
			end
		}

		hash
	end
	
	def make_root(refId=nil, aceId=nil)
		self.extend(SiriRootObject)
	
		self.refId = (refId or self.random_refId) 
		self.aceId = (aceId or self.random_aceId)
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
	attr_accessor :refId, :aceId
	
	def random_refId
		UUIDTools::UUID.random_create.to_s.upcase
	end
	
	def random_aceId
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
	def initialize(utterance="Testing", handsFree=false)
		super("StartRequest", "com.apple.ace.system")
		self.utterance = utterance
		self.handsFree = handsFree
	end
end
add_property_to_class(SiriStartRequest, :utterance)
add_property_to_class(SiriStartRequest, :handsFree)


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
