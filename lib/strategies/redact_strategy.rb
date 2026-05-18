require_relative 'base_strategy'

class RedactStrategy < BaseStrategy
  def call(match, type)
    
    return match if type == :color
    
    
    '█' * match.length
  end
end