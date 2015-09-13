require 'nokogiri'
require 'open-uri'
require 'chronic'
require 'active_support'
require 'active_support/core_ext'

require 'ri_cal'
require 'sffsoccer2ical/version'

begin
  require 'awesome_print'
rescue LoadError; end

class SFFSoccer2ICal
  BASE_URL = 'http://sff-soccer.ezleagues.ezfacility.com'
  LATEST_URL = "#{BASE_URL}/leagues/171030/Coed-Intermediate-Monday.aspx"

  attr_accessor :team

  def initialize(options)
    fail 'Team name not given!' if options[:team].nil?
    @team = options[:team]
    Time.zone = 'Pacific Time (US & Canada)'
    Chronic.time_class = Time.zone
  end

  def process
    puts "Headed to #{LATEST_URL} ..."
    document = Nokogiri::HTML(open(LATEST_URL))

    matches = []

    rows = document.xpath("//div[contains(@id, '_pnlSchedule')]//tr")
    rows.each do |row|
      cell = row.xpath('td/a')
      home = cell[1].to_s
      away = cell[2].to_s
      if team_matches?(home) || team_matches?(away)
        matches << construct_game(cell)
      end
    end

    ical = generate_ical(matches)
    File.write('games.ical', ical)
  end

  def generate_ical(matches)
    calname = "#{@team.capitalize} Games"
    ::RiCal.Calendar do
      add_x_property 'x_wr_calname', calname
      matches.each do |match|
        desc = "#{match[:home]} vs #{match[:away]} at #{match[:location]}"
        start_date = Chronic.parse("#{match[:date]} at #{match[:starts_at]}")
        end_date = start_date + 60.minutes

        event do
          summary     desc
          dtstart     start_date
          dtend       end_date
          location    match[:location]
        end
      end
    end.to_s
  end

  def team_matches?(str)
    str =~ /#{@team}/i
  end

  def construct_game(cell)
    {
      :uid       => uid(cell),
      :date      => date(cell),
      :url       => url(cell),
      :home      => home(cell),
      :away      => away(cell),
      :starts_at => starts_at(cell),
      :location  => location(cell)
    }
  end

  def uid(cell)
    cell[3]['href'].scan(%r{games/(\d+)/}).flatten[0].to_i
  end

  def date(cell)
    month_day = cell[0].text.split('-').last
    "#{month_day} #{Time.now.year}"
  end

  def url(cell)
    cell[0]['href'].sub('../..', BASE_URL)
  end

  def home(cell)
    cell[1].text
  end

  def away(cell)
    cell[2].text
  end

  def starts_at(cell)
    cell[3].text
  end

  def location(cell)
    if cell[4].text =~ /Loomis/
      'Loomis Field'
    else
      'Mission Bay Community Park'
    end
  end
end
