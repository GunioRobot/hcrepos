


class Mitter
  USERS = [
    "yuiseki",
    "skashu",
    "llcheesell",
    "retlet",
    "vaac",
    "delphie",
    "urabi_sama",
    "yusukezzz",
    "jazzanova", 
    "otsune"
  ]

  def self.logs_of_groups
    agent = WWW::Mechanize.new
    agent.max_history = 1
    page = agent.get('http://mitter.jp/groups/25/posts')
    page.body = page.body.toutf8
    videos=[]
    page.search('div.video').each do |log|
      title = log.search('div.video-info').search('a').first.get_attribute(:title)
      url = log.search('span.service').search('a').first.get_attribute(:href)
      name = log.search('div.date').search('a').first.inner_text
      time_row = log.search('div.date').search('span').first.get_attribute(:title)
      time = Time.parse(time_row)+(60*60*9)
      videos.push({:title => title.chomp, :url => url.chomp, :time => time, :user => name})
    end
    return videos
  end

  def self.logs_of_users
    agent = WWW::Mechanize.new
    agent.max_history = 1
    USERS.each do |user|
      url = "http://mitter.jp/" + user
      page = agent.get(url)
      page.body = page.body.toutf8
      videos=[]
      page.search('div.log-details').each do |log|
        title = log.search('h3.title').search('a').first.inner_text
        url = log.search('span.service').search('a').first.get_attribute(:href)
        time_row = log.search('span.watched-at').first.get_attribute(:title)
        time = Time.parse(time_row)+(60*60*9)
        videos.push({:title => title.chomp, :url => url.chomp, :time => time})
      end
    end
    return videos
  end

end