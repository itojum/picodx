module PicoDX
end

Dir[File.join(__dir__, '../lib/picodx/**/*.rb')].sort.each do |f|
  require f unless f.end_with?('z_init.rb')
end
