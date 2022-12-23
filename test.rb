# frozen_string_literal: true

# require 'json'
# require 'yaml'
# puts 'test'
# require_relative 'require_app'
# require_app
# # require_app(%w[infrastructure models])
# TOPIC_ID = 'xjPR4hlkBGA'
# key_path = File.expand_path('./config/secrets.yml', __dir__)
# CONFIG = YAML.safe_load(File.read(key_path))
# puts CONFIG['development']['UNSPLASH_SECRETS_KEY']
# UNSPLAH_TOKEN = CONFIG['development']['UNSPLASH_SECRETS_KEY']

# topics = LightofDay::Unsplash::TopicMapper
#          .new(UNSPLAH_TOKEN)
#          .find_all_topics
# puts topics
# view = LightofDay::Unsplash::ViewMapper
#        .new(UNSPLAH_TOKEN, TOPIC_ID)
#        .find_a_photo
# puts view

# my_repo =
#   LightofDay::Database::FocusOrm.create(id: '123', ssid: 'eeeee', uuid: 'cccccc', rest_time: 20,
#                                         work_time: 40, date: Time.now)
# LightofDay::Database::FocusOrm.create(ssid: 'eeeee1', uuid: 'ccccc1c', rest_time: 20, work_time: 40,
#                                       date: Time.now.strftime('%Y-%m-%d %H:%M:%S').split(' ').first)

puts Random.new.rand(20..100)

module Mixins
  def total_rest_time
    focustimes.map(&:time).sum
  end

  def rest_time
    value
  end
end

class Test
  include Mixins
  attr_reader :value, :time

  def initialize
    @value = Random.new.rand(20..100)
    @time = Random.new.rand(20..100)
  end
end

arr = (1..10).to_a.map do
  Test.new
end

class A
  include Mixins
  def initialize(arr)
    @cac = arr
  end

  # def total_time
  #   @cac.map(&:time).sum
  # end
  def total_time
    @cac.map(&:rest_time).sum
  end

  # def total_time
  #   @cac.map { |single| single.value }.sum
  # end
end

puts arr
puts A.new(arr).total_time
