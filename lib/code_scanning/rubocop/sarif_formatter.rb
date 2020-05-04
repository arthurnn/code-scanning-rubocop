# frozen_string_literal: true

require 'rubocop/formatter/base_formatter'
require 'json'
require 'active_support/all'
require 'pathname'

module CodeScanning

  class SarifFormatter < RuboCop::Formatter::BaseFormatter
    def initialize(output, options = {})
      super
      @sarif = {}
    end

    def started(_target_files)
      @sarif['$schema'] = 'https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json'
      @sarif['version'] = '2.1.0'
      @rules_map = {}
      @results = []
      @rules = []
      @sarif['runs'] = [
        { 'tool' => {
            'driver' => { 'name' => 'Rubocop', 'rules' => @rules }
          },
          'results' => @results }
      ]
    end

    Rule = Struct.new(:name, :index)

    def set_rule(cop_name, severity)
      if r = @rules_map[cop_name]
        return r
      end

      desc = RuboCop::ConfigLoader.default_configuration[cop_name]['Description']
      h = {
        'id' => cop_name, 'name' => cop_name,
        'shortDescription' => {
          'text' => desc
        },
        'fullDescription' => {
          'text' => desc
        },
        'defaultConfiguration' => {
          'level' => sarif_severity(severity)
        },
        'properties' => {}
      }
      @rules << h
      @rules_map[cop_name] = Rule.new(cop_name, @rules.size - 1)
    end

    def sarif_severity(cop_severity)
      return cop_severity if cop_severity.in? %w[warning error]
      return 'note' if cop_severity.in? %w[refactor convention]
      return 'error' if cop_severity.in? %w[fatal]

      'none'
    end

    def file_finished(file, offenses)
      relative_path = RuboCop::PathUtil.relative_path(file)

      offenses.each do |o|
        rule = set_rule(o.cop_name, o.severity.name.to_s)

        @results << {
          "ruleId" => rule.name,
          'ruleIndex' => rule.index,
          'message' => {
            'text' => o.message
          },
          'locations' => [
            {
              'physicalLocation' => {
                'artifactLocation' => {
                  'uri' => relative_path,
                  'uriBaseId' => '%SRCROOT%',
                  'index' => 0
                },
                'region' => {
                  'startLine' => o.first_line,
                  'startColumn' => o.column,
                  'endColumn' => o.last_column
                }
              }
            }
          ],
          'partialFingerprints' => {
            # This will be computed by the upload action for now
          }
        }
      end
    end

    def finished(_inspected_files)
      json = JSON.pretty_generate(@sarif)
      output.print(json)
    end
  end
end
