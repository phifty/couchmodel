
# Extention of ruby's standard array.
class Array

  def resize(length, element = nil)
    case size <=> length
      when 1
        slice 0, length
      when -1
        result = self.dup
        result << element while result.size < length
        result
      when 0
        self
    end
  end

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
