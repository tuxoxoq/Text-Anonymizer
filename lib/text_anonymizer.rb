class TextAnonymizer
  # Правила поиска (регулярные выражения)
  RULES = {
    email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/,
    phone: /(?:\+?\d{1,3})?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}/,
    ip:    /\b(?:\d{1,3}\.){3}\d{1,3}\b/
  }

  def initialize(strategy)
    @strategy = strategy
  end

  def process(text)
    result = text.dup
    RULES.each do |type, regex|
      result.gsub!(regex) { |match| @strategy.call(match, type) }
    end
    result
  end
end