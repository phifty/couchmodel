
class String

  def underscore
    self.gsub(/([a-z][A-Z])/){ |match| "#{match[0]}_#{match[1]}" }.downcase
  end

end
