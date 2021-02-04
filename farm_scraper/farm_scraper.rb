require 'csv'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'byebug'

@browser = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1'




doc = Nokogiri::HTML(URI.open("https://farm.ewg.org/top_recips.php?fips=19000&progcode=totalfarm&regionname=Iowa",
                        'User-Agent' => '#{@browser}'))