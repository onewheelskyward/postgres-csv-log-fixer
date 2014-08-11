require 'CSV'

unless ARGV[0] and File.exist? ARGV[0]
  puts 'Usage: parseme.rb [postgres csv filename]'
  exit
end

prev_line = nil
parsed_queries = []

File.open(ARGV[0]).each_line do |line|
  line.gsub! /\n/, ''
  # puts line
  if line.match(/^(\s+|;)/)
    prev_line = prev_line.to_s + line
    next
  elsif prev_line
    data = CSV.parse_line(prev_line)

    match = data[13].scan(/SELECT .*/)  # I only really care about selects for indexing.
    unless match[0].nil?
      unless data[14].nil?
        param_matches = data[14].scan(/(\$\d+) = '(.*?)'/)
        parsed_query = match[0]
        param_matches.each do |key, value|
          parsed_query = parsed_query.sub key, "'#{value}'"
        end
      end
      parsed_queries.push parsed_query
    end
  end
  prev_line = line
  # puts CSV.parse(line).inspect
end

parsed_queries.uniq.each do |q|
  puts q
end
puts "#{parsed_queries.uniq.count} queries."