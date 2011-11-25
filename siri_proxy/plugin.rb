require 'cora'

class SiriProxy::Plugin < Cora::Plugin
  def request_completed
    self.manager.send_request_complete_to_iphone
  end
  
  #use send_object(object, target: :guzzoni) to send to guzzoni
  def send_object(object, options={:target => :iphone})
    (object = object.to_hash) rescue nil #convert SiriObjects to a hash
  
    if(options[:target] == :iphone)
      self.manager.guzzoni_conn.inject_object_to_output_stream(object)
	elsif(options[:target] == :guzzoni)
	  self.manager.iphone_conn.inject_object_to_output_stream(object)
	end
  end
  
  def last_ref_id
    self.manager.iphone_conn.last_ref_id
  end
end