require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class ConsoleIssues
      include Console

      def initialize(config)
        @previous_test_case = nil
        @issues = Hash.new { |h, k| h[k] = [] }
        @config = config
        @config.on_event(:test_case_finished) do |event|
          if event.test_case != @previous_test_case
            @previous_test_case = event.test_case
            @issues[event.result.to_sym] << event.test_case unless event.result.ok?(@config.strict)
          elsif event.result.passed?
            @issues[:flaky] << event.test_case unless Core::Test::Result::Flaky.ok?(@config.strict)
            @issues[:failed].delete(event.test_case)
          end
        end
      end

      def to_s
        return if @issues.empty?
        result = Core::Test::Result::TYPES.map { |type| scenario_listing(type, @issues[type]) }
        result.flatten.join("\n")
      end

      def any?
        @issues.any?
      end

      private

      def scenario_listing(type, test_cases)
        return [] if test_cases.empty?
        [ format_string("#{type_heading(type)} Scenarios:", type) ] + test_cases.map do |test_case|
          source = @config.source? ? format_string(" # #{test_case.keyword}: #{test_case.name}", :comment) : ''
          format_string("cucumber #{profiles_string}" + test_case.location, type) + source
        end
      end

      def type_heading(type)
        case type
        when :failed
          'Failing'
        else
          type.to_s.slice(0, 1).capitalize + type.to_s.slice(1..-1)
        end
      end

      def profiles_string
        return if @config.custom_profiles.empty?
        @config.custom_profiles.map { |profile| "-p #{profile}" }.join(' ') + ' '
      end
    end
  end
end
