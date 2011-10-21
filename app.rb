# coding: utf-8

require 'bundler/setup'
require 'sinatra'
require 'rss/maker'
require 'json'
require 'yaml/store'

$db = YAML::Store.new File.join(__FILE__, 'data.yaml')
def db
  p $db
  $db
end
db.transaction do
  db['messages'] = [] unless db['messages']
end

def make_items(maker)
  db.transaction do
    db['messages'].reverse.take(200).each do |mes|
      item = maker.items.new_item
      item.title = mes['room'] 
      item.link = "lingr.com/room/#{mes['room']}/chat"
      item.description = "#{mes['speaker_id']} <br /> <img src='#{mes['icon_url']}' /> #{mes['text']} "
      item.date = Time.parse(mes['timestamp'])
    end
  end
end

get '/rss' do
  RSS::Maker.make('2.0') do |maker|
    maker.channel.title = "Lingr"
    maker.channel.description = ' '
    maker.channel.link = "lingr.com"
    maker.items.do_sort = true
    make_items(maker)
  end.to_s
end

get '/lingr' do
  "hi I'm a bot"
end

post '/lingr' do
  j = JSON.parse request.body.read
  j['events'].each do |e|
    if e['message']
      db.transaction do
        db['messages'] << e['message']
      end
    end
  end
  ''
end
