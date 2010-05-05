
class String # :nodoc:

  # This method converts a CamelCaseString into an underscore_string.
  def underscore
    word = self.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
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

end
