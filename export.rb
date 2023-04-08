require 'net/http'
require 'faraday'
require 'json'
#require 'faraday-follow_redirects'
base = "https://huashengfe.yuque.com/api/v2"

TOKEN="WyHE70gXO3ebKeVocFOSSoy1PlFkeUcC6yCMepFJ"

def fetch(url)
    options = {
        headers: {
            'Content-Type' => 'application/json',
            'Accept'=>'application/json',
            'X-Auth-Token'=>TOKEN,
            'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36'}
      }
    conn = Faraday.new options do |f|
        #f.response :follow_redirects
        f.options.timeout = 5
        f.adapter Faraday.default_adapter
        #f.request :logger # logs request and responses
    end
    fetched = conn.get(url)
    puts fetched.status
    if fetched.status!=200 
        puts "fetch #{url} failed #{fetched}"
        nil
    else
        to_json fetched.body
    end
end

def to_json(data)
    JSON.load(data)
end



userInfo = fetch "#{base}/user"
login =  userInfo["data"]["login"]
#login = to_json

groups = fetch "#{base}/users/#{login}/groups"
puts "空间的login和名称对应关系:"
group_logins = []
groups["data"].each do |item|
    puts "#{item['login']}=>#{item['name']}"
    group_logins << item["login"]
end


Dir.mkdir("./markdown/") unless File.exists?("./markdown/")
Dir.mkdir("./json/") unless File.exists?("./json")

group_logins.each do |group_login|
    group_repos = fetch "#{base}/groups/#{group_login}/repos"
    group_repos["data"].each do |repo|
        repo["name"].gsub! "/","%2F"
        Dir.mkdir("./markdown/#{repo['name']}") unless File.exists? "./markdown/#{repo['name']}"
        Dir.mkdir("./json/#{repo['name']}") unless File.exists? "./json/#{repo['name']}"
    
        puts "new repo for #{login}, name:#{repo['name']},namespace:#{repo['namespace']},id:#{repo['id']}"
        repo_docs = fetch "#{base}/repos/#{repo['id']}/docs"
        repo_docs['data'].each do |doc|
            puts "\t title:#{doc['title']},slug:#{doc['slug']}"
            doc_resp = fetch "#{base}/repos/#{repo['namespace']}/docs/#{doc['slug']}"
            doc = doc_resp["data"]
            doc["title"].gsub! "/","%2F"
            File.open "./markdown/#{repo['name']}/#{doc['title']}.md","w" do |file|
                file.puts doc["body"]
            end
            File.open "./json/#{repo['name']}/#{doc["slug"]}.json","w" do |file|
                file.puts JSON.dump(doc)
            end
        end
    end
end
