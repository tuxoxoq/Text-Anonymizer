require 'colorize'
require_relative 'base_strategy'

class ColorizeStrategy < BaseStrategy
  COLOR_MAP = {
    'красн' => :red, 'син' => :blue, 'зелен' => :green,
    'желт' => :yellow, 'бел' => :white, 'черн' => :black,
    'голуб' => :cyan, 'фиолетов' => :magenta
  }.freeze

  def call(match, type)
    return match unless type == :color
    root = COLOR_MAP.keys.find { |k| match.downcase.start_with?(k) }
    root ? match.send(COLOR_MAP[root]) : match
  end
end