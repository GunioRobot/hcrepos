require 'open-uri'
require 'rexml/document'
require 'rexml-expansion-fix'


class Trace < ActiveRecord::Base
  # ジオクリの位置情報履歴取得APIを叩いてDBにインポート
  # GOさんの移動履歴を取得し、ほしとの当たり判定を行う役割
  # cron で 'ruby script/runner 'Trace.import_feed_traces'' などとして呼ぶ
  def self.import_feed_traces
   # Trace.delete_all

    url_base = 'http://api.geoclip.jp/api/feed_trace.php'
    url = "#{url_base}?keyid=gXeLoucblRrhtplcxVoX&log_date_from=&log_date_to=&hit_per_page="
    @@stars = nil
    #測地系設定
    open(url) do |http|
      response = http.read
      doc = REXML::Document.new response
      doc.elements.each("response/rest") { |r| 
        location_id = ''
        latitude = ''
        longitude = ''
        altitude = ''
        log_date = ''
        create_date = ''
        REXML::XPath.match(r, "location_id").each{|e| location_id=e.text }
        REXML::XPath.match(r, "latitude").each{|e| latitude=e.text }
        REXML::XPath.match(r, "longitude").each{|e| longitude=e.text }
        REXML::XPath.match(r, "altitude").each{|e| altitude=e.text }
        REXML::XPath.match(r, "log_date").each{|e| log_date=e.text }
        REXML::XPath.match(r, "create_date").each{|e| create_date=e.text }
        # hash使えばもっと簡単に書ける。ひとまず放置。
        unless Trace.find(:first, :conditions => ["location_id = ?", location_id] )
          Trace.create(:location_id=>location_id,
                       #TODO:
                       #マッチしたらcreateする
                       #create時に星の位置座標を範囲指定SQLでチェックして、
                       #範囲が５０ｍくらいのときに回収フラグを真にする
                       :latitude=>latitude,
                       :longitude=>longitude,
                       :altitude=>altitude,
                       :log_date=>log_date,
                       :create_date=>create_date)
        end
      }
    end
  end


  def after_create
    trace_longitude_rad = convert_rad(self.longitude)
    trace_latitude_rad = convert_rad(self.latitude)

    @@stars ||= Star.find(:all, :conditions => ["end_flg is ? or end_flg = ?", nil, false])
    @@stars.each do |star|
      next if star.end_flg 
      star_longitude_rad = convert_rad(star.longitude)
      star_latitude_rad = convert_rad(star.latitude)

      if cast_long(trace_longitude_rad, trace_latitude_rad, star_longitude_rad, star_latitude_rad) < 100
        star.end_flg = true
        star.save
        req = Net::HTTP::Post.new("/statuses/update.xml")
        req.basic_auth 'gaziro2000', '11111111'
        req.set_form_data({'status' => "@#{star.title} #{star.subject}を取得しました"})
        Net::HTTP.start('twitter.com') {|http|
          http.request(req)
        }
        #TwitterのAPIを叩いて回収報告POSTを行う
      end
    end
  end

  def convert_rad(do_value)
    do_value * Math::PI / 180
  end

  def cast_long(trace_longitude_rad, trace_latitude_rad, star_longitude_rad, star_latitude_rad)
    avg_longitude_rad = (trace_longitude_rad + star_longitude_rad ) / 2
    avg_latitude_rad = (trace_latitude_rad + star_latitude_rad ) / 2

    deff_longitude_rad = trace_longitude_rad - star_longitude_rad
    deff_latitude_rad = trace_latitude_rad - star_latitude_rad

    Math.sqrt((deff_longitude_rad * 6378137 * Math.cos(trace_latitude_rad) )** 2 + 
              (deff_latitude_rad * 6378137 ) ** 2)

    #       temp = 1 - 0.006674*(Math.sin(deff_latitude_rad)*Math.sin(deff_latitude_rad))
    #       dmrad = 6334834 / Math.sqrt(temp * temp * temp)
    #       dvrad =  6377397 / Math.sqrt(temp)

    #       t1 = dmrad * deff_latitude_rad
    #       t2 = dvrad * Math.cos(avg_latitude_rad) * deff_longitude_rad

    #       Math.sqrt(t1*t1 + t2*t2)
  end

  # 渋谷駅から恵比寿駅
  # http://lab.uribou.net/ll2dist/?ll1=35.659249,139.703608&ll2=35.64669,139.710106
  # <distance>1512.93</distance>
  def self.measure_test
    n1 = '渋谷駅'
    lat1 = 35.659249
    lng1 = 139.703608
    n2 = '恵比寿駅'
    lat2 = 35.64669
    lng2 = 139.710106
    d = measure(lat1, lng1, lat2, lng2)
    puts "#{n1} #{n2} #{d}"
    # 1511.2673552511 になった。大体合っている
  end
  def self.measure(lat1, lng1, lat2, lng2)
    latd = lat1 - lat2
    lngd = lng1 - lng2
    # 緯度経度1度のメートル数を定数に
    latd *= 110880
    lngd *= 90360
    lt = latd * latd
    lg = lngd * lngd
    Math.sqrt(lt+lg)
  end
end
