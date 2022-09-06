desc "Create News For Home Page"
task :news => :environment do
    xml = Nokogiri::XML(open("http://feeds.feedburner.com/latest-news-ogj?format=xml"))
    index = 0
    xml.xpath("//item").each do |item|
        if index < 5
            $redis.set('news_title_' + index.to_s, item.xpath('title').text)
            $redis.set('news_summary_' + index.to_s, summary = ActionView::Base.full_sanitizer.sanitize(item.xpath('description').text))
            $redis.set('news_link_' + index.to_s, link = item.xpath('link').text)


        end
        index += 1
    end
end