class BaseStrategy
  def call(match, type)
    raise NotImplementedError, "Implement 'call' in subclass"
  end
end