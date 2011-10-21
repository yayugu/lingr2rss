# coding: utf-8

require 'bundler/setup'
require 'sinatra'
require 'rss/maker'
require 'json'
require 'yaml/store'

$db = YAML::Store.new './data.yaml'
def db
  $db
end

def make_items(maker, room_name)
  db.transaction do
    db[room] ||= []
    db[room].reverse.take(200).each do |mes|
      item = maker.items.new_item
      item.title = mes['room'] 
      item.link = "lingr.com/room/#{mes['room']}/chat"
      item.description = "<img src='#{mes['icon_url']}' />#{mes['speaker_id']}: #{mes['text']} "
      item.date = Time.parse(mes['timestamp'])
    end
  end
end

get '/:room' do |room|
  RSS::Maker.make('2.0') do |maker|
    maker.channel.title = "Lingr"
    maker.channel.description = ' '
    maker.channel.link = "lingr.com"
    maker.items.do_sort = true
    make_items(maker, room)
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
        db[room] ||= []
        db[room] << e['message']
      end
    end
  end
  ''
end
