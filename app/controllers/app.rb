# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'json'

module LightofDay
  # Web App
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets/'
    plugin :common_logger, $stderr
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :status_handler

    use Rack::MethodOverride
    status_handler(404) do
      view('404')
    end

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'

      topics_mapper = LightofDay::TopicMapper.new(App.config.UNSPLASH_SECRETS_KEY)
      topics_data = topics_mapper.topics

      # GET /
      routing.root do
        view 'picktopic', locals: { topics: topics_data }
      end

      # GET /list_topics/{sort_by}
      routing.on 'list_topics', String do |sort_by|
        routing.get do
          topics_data = topics_mapper.created_time if sort_by == 'created_time'
          topics_data = topics_mapper.activeness if sort_by == 'activeness'
          topics_data = topics_mapper.popularity if sort_by == 'popularity'
          view 'picktopic', locals: { topics: topics_data }
        end
      end

      routing.on 'favorite-list' do
        routing.is do
          session[:watching] ||= []

          # Load previously viewed projects
          favorite_list = Repository::For.klass(Unsplash::Entity::View)
                                         .find_origin_ids(session[:watching])

          session[:watching] = favorite_list.map(&:origin_id)

          flash.now[:notice] = '  Make some collections to get started' if favorite_list.none?
          # favorite_list = Repository::For.klass(Unsplash::Entity::View).all

          view 'favoritelist', locals: { favoriteList: favorite_list }
        end
      end

      routing.on 'light-of-day' do
        routing.is do
          # POST /light-of-day/
          routing.post do
            topic_id = routing.params['topic_id']
            topic_data = topics_data.find { |topic| topic.topic_id == topic_id }
            if topic_data.nil?
              flash[:error] = ' Please pick a topic !'
              routing.redirect '/'
            end
            # routing.halt 404 unless topic_data
            routing.redirect "light-of-day/topic/#{topic_data.slug}"
          end
        end

        routing.on 'topic', String do |topic_slug|
          # GET /light-of-day/topic/{topic}
          routing.get do
            topic_data = topics_data.find { |topic| topic.slug == topic_slug }
            routing.halt 404 unless topic_data
            view_data = LightofDay::Unsplash::ViewMapper.new(App.config.UNSPLASH_SECRETS_KEY,
                                                             topic_data.topic_id).find_a_photo
            puts view_data.instance_variables
            # @wait_data << view_data
            # puts @wait_data.length
            # Repository::For.entity(view_data).create(view_data)
            view 'view', locals: { view: view_data, is_saved: false }
          end
        end

        routing.on 'favorite' do
          routing.is do
            # POST /light-of-day/favorite/
            routing.post do
              fin = JSON.parse(routing.params['favorite'])
              ins_record = LightofDay::FavQs::Entity::Inspiration.new(
                id: fin['@attributes']['inspiration']['@attributes']['id'],
                origin_id: fin['@attributes']['inspiration']['@attributes']['origin_id'],
                topics: fin['@attributes']['inspiration']['@attributes']['topics'],
                author: fin['@attributes']['inspiration']['@attributes']['author'],
                quote: fin['@attributes']['inspiration']['@attributes']['quote']
              )

              view_record = LightofDay::Unsplash::Entity::View.new(
                id: fin['@attributes']['id'],
                origin_id: fin['@attributes']['origin_id'],
                topics: fin['@attributes']['topics'],
                width: fin['@attributes']['width'],
                height: fin['@attributes']['height'],
                urls: fin['@attributes']['urls'],
                urls_small: fin['@attributes']['urls_small'],
                creator_name: fin['@attributes']['creator_name'],
                creator_bio: fin['@attributes']['creator_bio'],
                creator_image: fin['@attributes']['creator_image'],
                inspiration: ins_record
              )
              session[:watching] ||= []
              session[:watching].insert(0, view_record.origin_id).uniq!

              Repository::For.entity(view_record).create(view_record)
              view_id = routing.params['view_data']
              flash[:notice] = ' Add successfully to your favorite !'
              # routing.halt 404 unless view_id
              routing.redirect "favorite/#{view_id}"
            end
          end
          routing.on String do |view_id|
            # GET /light-of-day/favorite/{view_id}
            routing.get do
              lightofday_data = Repository::For.klass(Unsplash::Entity::View).find_origin_id(view_id)
              # routing.halt 404 unless view_data && inspiration_data
              view 'view', locals: { view: lightofday_data, inspiration: lightofday_data.inspiration, is_saved: true }
            end
            # test by hsuan
            routing.delete do
              origin_id = view_id.to_s
              session[:watching].delete(origin_id)
              routing.redirect 'favorite-list/'
            end
          end
        end
      end
    end
  end
end
