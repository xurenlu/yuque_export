#!/usr/bin/env ruby
require 'net/http'
require 'fileutils'
require 'uri'
IMG_REGEX = /!\[.*?\]\((.+?)\)/
def fetch(url)
    Net::HTTP.get(URI(url))
end

def handle_file(markdown_file)

    markdown_text = File.read(markdown_file)
    markdown_text.gsub!(/\<a\s+.*?\s+name=[\"\'].*?[\"\'].*?\>.*?\<\/a\>/im, '')
    # 遍历所有图片引用并下载图片
    markdown_text.scan(IMG_REGEX).each do |img|
        remote_url = img[0].split("#")[0]
        
        local_path = File.join('img/', File.basename(remote_url).split('#')[0])
    
        # 下载图片并保存到本地文件系统
        open(local_path, 'wb') do |file|
            file << Net::HTTP.get_response(URI.parse(remote_url)).body
        end
        # 替换markdown文本中的远程图片链接为本地图片路径
        markdown_text.gsub!(remote_url, local_path)
    end

    # 将更新后的markdown文本写回到文件中
    new_path = File.dirname(markdown_file).sub 'markdown/','docx/'
    FileUtils.mkdir_p(new_path) unless  File.directory?(new_path)        
    File.write new_path+'/'+File.basename(markdown_file), 
        markdown_text
    puts "处理文件: #{markdown_file} done"
end

source_dir = ARGV[0]

Dir.glob(File.join(source_dir, '**/*.md')).each do |source_file|
    handle_file(source_file)
end