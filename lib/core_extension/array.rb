
class Array # :nodoc:

  # This wrap method is taken from ActiveSupport and simply
  # wraps an object into an array.
  def self.wrap(object)
    if object.nil?
      [ ]
    elsif object.respond_to?(:to_ary)
      object.to_ary
    else
      [ object ]
    end
  end
  
end
