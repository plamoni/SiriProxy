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

class SiriAssistantUtteranceView < SiriObject
	def initialize(text="", speakableText=text, dialogIdentifier="Misc#ident")
		super("AssistantUtteranceView", "com.apple.ace.assistant")
		self.text = text
		self.speakableText = speakableText
		self.dialogIdentifier = dialogIdentifier
	end
end
add_property_to_class(SiriAssistantUtteranceView, :text)
add_property_to_class(SiriAssistantUtteranceView, :speakableText)
add_property_to_class(SiriAssistantUtteranceView, :dialogIdentifier)