# frozen_string_literal: true

require_relative '../lib/focus_calculator'

module LightofDay
  module Entity
    class DailyFocus < SimpleDelegator
      include Mixins::FocusCalculator
      attr_reader :daily_date

      def initialize(daily, index)
        @daily_list = daily
        @daily_date = Date.today - index
        # @avg_rest_time = 0
        # @avg_work_time = 0
        # @total_work_time = 0
        # @total_rest_time = 0
      end

      def daily_work
        return 0 if @daily_list.nil?

        @daily_list.map(&:work_time).sum
      end

      def daily_rest
        return 0 if @daily_list.nil?

        @daily_list.map(&:rest_time).sum
      end

      def avg_daily_work
        return 0 if @daily_list.nil?

        daily_work.to_f / @daily_list.length.to_f
      end

      def avg_daily_rest
        return 0 if @daily_list.nil?

        daily_rest.to_f / @daily_list.length.to_f
      end
    end
  end
end
