
class String # :nodoc:

  # This method converts a CamelCaseString into an underscore_string.
  def underscore
    self.gsub(/([a-z][A-Z])/){ |match| "#{match[0]}_#{match[1]}" }.downcase
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
