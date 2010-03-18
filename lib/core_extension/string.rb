
class String

  # This method converts a CamelCaseString into an underscore_string.
  def underscore
    self.gsub(/([a-z][A-Z])/){ |match| "#{match[0]}_#{match[1]}" }.downcase
  end

  # This method converts an underscore_string into a CamelCaseString.
  def camelize
    self.gsub(/\/(.?)/) do
      "::#{$1.upcase}"
    end.gsub(/(?:^|_)(.)/) do
      $1.upcase
    end
  end

end
