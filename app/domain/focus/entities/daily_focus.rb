# frozen_string_literal: true
require_relative '../lib/focus_calculator'

module LightofDay
  module Entity
    class DailyFocus < SimpleDelegator
      include Mixins::FocusCalculator
      def initialize(daily)
        @daily_list = daily
        # @avg_rest_time = 0
        # @avg_work_time = 0
        # @total_work_time = 0
        # @total_rest_time = 0
      end

      def daily_work
        @daily_list.map(&:work_time).sum
      end

      def daily_rest
        @daily_list.map(&:rest_time).sum
      end

      def avg_daily_work
        daily_work.to_f / @daily_list.length.to_f
      end

      def avg_daily_rest
        daily_rest.to_f / @daily_list.length.to_f
      end
    end
  end
end
