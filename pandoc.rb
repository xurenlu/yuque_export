require 'fileutils'

Dir.glob('./docx/**/*.md') do |file|
  basename = File.basename(file, '.md')
  dir = File.dirname(file).sub 'docx/','target/'
  FileUtils.mkdir_p dir unless File.directory? dir
  output_file = "#{dir}/#{basename}.docx"
  puts output_file
  next if File.exist? output_file
  `pandoc "#{file}" -o "#{output_file}"`
end
