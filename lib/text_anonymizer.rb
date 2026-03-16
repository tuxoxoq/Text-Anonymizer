class TextAnonymizer
  RULES = {
    email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}/,
    ip:    /\b(?:\d{1,3}.){3}\d{1,3}\b/,
    phone: /(?:\+?7|8)[\s()-]?(\d[\s()-]?){10}/
  }

  def initialize(strategy)
    @strategy = strategy
    # Склеиваем все правила в одно супер-правило
    @combined_regex = Regexp.union(RULES.values)
  end

  def process(text)
    result = text.dup
    # Проходимся по тексту ТОЛЬКО ОДИН РАЗ
    result.gsub!(@combined_regex) do |match|
      type = identify_type(match)
      @strategy.call(match, type)
    end
    result
  end

  private

  def identify_type(match)
    RULES.each { |type, regex| return type if match.match?(regex) }
    :unknown
  end
end