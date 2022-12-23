# frozen_string_literal: true

require 'dry/monads'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class AnalyzeFocus
      include Dry::Monads::Result::Mixin

      def call
        puts 'test'
        focus_list = LightofDay::Mapper::WeeklyFocusMapper.new.day_summary
        puts 'hhh'
        Success(focus_list)
      rescue StandardError
        Failure('Could not find focus')
      end
    end
  end
end
