
class String

  def underscore
    self.gsub(/([a-z][A-Z])/){ |match| "#{match[0]}_#{match[1]}" }.downcase
  end

  def camelize
    self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end

end
