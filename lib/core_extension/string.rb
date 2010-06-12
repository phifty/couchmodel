
class String # :nodoc:

  # This method converts a CamelCaseString into an underscore_string.
  def underscore
    self.class.underscore self.to_s.dup
  end

  # This method converts an underscore_string into a CamelCaseString.
  def camelize
    self.camelize_path.camelize_name
  end

  def camelize_path
    self.gsub(/\/(.?)/) { "::#{$1.upcase}" }
  end

  def camelize_name
    self.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

  def self.underscore(word)
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

end
