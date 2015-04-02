class String

  def one_of? array
    array.include? self
  end

  def value
    self
  end

end