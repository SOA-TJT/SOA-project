# frozen_string_literal: true

require 'securerandom'
require 'dry/monads'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class StoreFocus
      include Dry::Monads::Result::Mixin

      def call(work_time, rest_time)
        puts Time.now.strftime('%Y-%m-%d %H:%M:%S').split(' ').first
        puts SecureRandom.uuid
        focus = create_focus(work_time.to_i, rest_time.to_i)
        puts 'ddd'
        focus_time =
          Repository::For.entity(focus).create(focus)
        puts 'fff'
        Success(focus_time)
      rescue StandardError => e
        # App.logger.error e.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      def create_focus(work_time, rest_time)
        LightofDay::OwnDb::Entity::Focus.new(
          id: nil,
          ssid: SecureRandom.uuid,
          uuid: SecureRandom.uuid,
          rest_time:,
          work_time:,
          date: Time.now.strftime('%Y-%m-%d %H:%M:%S').split(' ').first
        )
      end
    end
  end
end
