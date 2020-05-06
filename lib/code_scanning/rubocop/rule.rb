# frozen_string_literal: true

require "pathname"

module CodeScanning
  class Rule
    def initialize(cop_name, severity = nil)
      @cop_name = cop_name
      @severity = severity.to_s
      @cop = RuboCop::Cop::Cop.registry.find_by_cop_name(cop_name)
      @help = StringIO.new
    end

    def id
      @cop_name
    end

    def append_help(line)
      @help.print(line)
    end

    def help_empty?
      @help.size.zero?
    end

    def ==(other)
      badge.match?(other.badge)
    end
    alias eql? ==

    def badge
      @cop.badge
    end

    def sarif_severity
      cop_severity = @cop.new.send(:find_severity, nil, @severity)
      return cop_severity if %w[warning error].include?(cop_severity)
      return "note" if %w[refactor convention].include?(cop_severity)
      return "error" if cop_severity == "fatal"

      "none"
    end

    # The URL for the docs are in this format:
    # https://docs.rubocop.org/en/stable/cops_layout/#layoutblockendnewline
    def query_uri
      kind = badge.department.to_s.downcase
      full_name = "#{kind}#{badge.cop_name.downcase}"
      "https://docs.rubocop.org/en/stable/cops_#{kind}/##{full_name}"
    end

    def to_json(opts = {})
      to_h.to_json(opts)
    end

    def cop_config
      @config ||= RuboCop::ConfigStore.new.for(Pathname.new(Dir.pwd))
      @cop_config ||= @config.for_cop(@cop.department.to_s)
                             .merge(@config.for_cop(@cop))
    end

    def to_h
      properties = {
        "precision" => "very-high"
      }

      h = {
        "id" => @cop_name,
        "name" => @cop_name,
        "defaultConfiguration" => {
          "level" => sarif_severity
        },
        "properties" => properties
      }

      desc = cop_config["Description"]
      unless desc.nil?
        h["shortDescription"] = { "text" => desc }
        h["fullDescription"] = { "text" => desc }
        properties["description"] = desc
      end

      unless help_empty?
        help = @help.string
        h["help"] = {
          "text" => help,
          "markdown" => help
        }
        properties["queryURI"] = query_uri if badge.qualified?
      end

      if badge.qualified?
        kind = badge.department.to_s
        properties["tags"] = [kind.downcase]
      end
      h
    end
  end
end
