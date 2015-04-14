#exampleapp.rb
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'mongo'
require 'json'

include Mongo

configure do
	mongo = MongoClient.new
 	set :db, mongo.db('sinatra')
end

$coll = settings.db.collection('contacts')

helpers do
  def mongoId val
    BSON::ObjectId.from_string(val)
  end
  def getContact id
    id = mongoId(id) if String === id
    $coll.find_one(:_id => id).to_json
  end
end

#Default Page
get '/contacts' do 
	content_type :json
	$coll.find.to_a.to_json
end

#Summary content from Database
post '/contact' do
	content_type :json
	data = JSON.parse request.body.read
	id = $coll.insert data
	getContact(id)
end

put '/contact/:id' do
	content_type :json
	data = JSON.parse request.body.read
	id = mongoId(params[:id])
	$coll.update({:_id => id}, data)
	getContact(id)
end

delete '/contact/:id' do
	content_type :json
	id = mongoId(params[:id])
	if $coll.find_one(id)
		$coll.remove(:_id => id)
		{:success => true}.to_json
	else
		{:success => false}.to_json
	end
end

