module Formatting
  def replace_chars(string, before, after)
    puts string, before, after
    replacements = before.chars.zip(after.chars).to_h
    regex = Regexp.new(replacements.keys.map { |x| Regexp.escape(x) }.join('|'))
    p string.gsub(regex, replacements)
  end
end

Liquid::Template.register_filter(Formatting)
