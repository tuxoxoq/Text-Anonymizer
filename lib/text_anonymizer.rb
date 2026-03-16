class TextAnonymizer
  RULES = {
    email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/,
    ip:    /\b(?:\d{1,3}\.){3}\d{1,3}\b/,
    phone: /(?:\+?7|8)[\s\(\)-]*?(\d[\s\(\)-]*?){10}/
  }

  def initialize(strategy)
    @strategy = strategy
    @combined_regex = Regexp.union(RULES.values)
  end

  def process(text)
    result = text.dup
    result.gsub!(@combined_regex) do |match|
      type = identify_type(match)
      @strategy.call(match, type)
    end
    result
  end

  private

  def identify_type(match)
    return :email if match.match?(RULES[:email])
    return :ip    if match.match?(RULES[:ip])
    return :phone if match.match?(RULES[:phone])
    :unknown
  end
end