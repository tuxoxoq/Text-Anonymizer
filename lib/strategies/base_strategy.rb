class BaseStrategy
  def call(match, type)
    raise NotImplementedError, "Метод 'call' должен быть реализован в подклассе"
  end
end