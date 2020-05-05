text = File.open('cops_layout.md').read
helps = {}
current_cop = nil
text.each_line do |line|
  # title
  next if "# " == line[0..1]

  if "## " == line[0..2]
    current_cop = line[3..-2]
    helps[current_cop] = StringIO.new
    next
  end
  #print line
  unless current_cop.nil?
    #print line
    helps[current_cop].print(line)
  end
end



