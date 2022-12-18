# frozen_string_literal: true

require 'dry/monads'

module LightofDay
  module Service
    # Retrieves array of all listed project entities
    class ListFocus
      include Dry::Monads::Result::Mixin

      def call
        puts 'test'
        focus_list = LightofDay::Repository::Focuses.find
        # focus_list = Repository::For.klass(OwnDb::Entity::Focus)
        #                     .find
        puts 'hhh'
        Success(focus_list)
      rescue StandardError
        Failure('Could not find focus')
      end
    end
  end
end
