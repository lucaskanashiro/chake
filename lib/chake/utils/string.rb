class String
  def colorized(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red_message 
    colorized(31)
  end

  def green_message
    colorized(32)
  end

  def yellow_message
    colorized(33)
  end
end
