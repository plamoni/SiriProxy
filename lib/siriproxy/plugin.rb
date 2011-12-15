require 'cora'

class SiriProxy::Plugin < Cora::Plugin
  def initialize(config)

  end

  def request_completed
    self.manager.send_request_complete_to_iphone
  end

  #use send_object(object, target: :guzzoni) to send to guzzoni
  def send_object(object, options={})
    (object = object.to_hash) rescue nil #convert SiriObjects to a hash
    options[:target] = options[:target] ||= :iphone

    if(options[:target] == :iphone)
      self.manager.guzzoni_conn.inject_object_to_output_stream(object)
  	elsif(options[:target] == :guzzoni)
  	  self.manager.iphone_conn.inject_object_to_output_stream(object)
  	end
  end

  def last_ref_id
    self.manager.iphone_conn.last_ref_id
  end

  #direction should be :from_iphone, or :from_guzzoni
  def process_filters(object, direction)
    return nil if object == nil
    f = filters[object["class"]]
    if(f != nil && (f[:direction] == :both || f[:direction] == direction))
      object = instance_exec(object, &f[:block])
    end

    object
  end

  class << self
    def filter(class_names, options={}, &block)
      [class_names].flatten.each do |class_name|
        filters[class_name] = {
          direction: (options[:direction] ||= :both),
          block: block
        }
      end
    end

    def filters
      @filters ||= {}
    end
  end

  def filters
    self.class.filters
  end

end
