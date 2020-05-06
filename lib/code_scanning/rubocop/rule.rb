require 'pathname'
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

    def append_help(s)
      @help.print(s)
    end

    def ==(other)
      self.badge.match?(other.badge)
    end
    alias eql? ==

    def badge
      @cop.badge
    end

    def sarif_severity
      cop_severity = @cop.new.send(:find_severity, nil, @severity)
      return cop_severity if %w[warning error].include?(cop_severity)
      return 'note' if %w[refactor convention].include?(cop_severity)
      return 'error' if cop_severity == 'fatal'
      'none'
    end

    def to_json(opts={})
      to_h.to_json(opts)
    end

    def cop_config
      @config ||= RuboCop::ConfigStore.new.for(Pathname.new(Dir.pwd))
      @cop_config ||= @config.for_cop(@cop.department.to_s)
                        .merge(@config.for_cop(@cop))
    end

    def to_h
      properties = {
        "id" => @cop_name,
        "precision" => "very-high",
        "problem.severity" => sarif_severity,
      }

      h = {
        "id" => @cop_name,
        "name"  => @cop_name,
        "defaultConfiguration" => {
          'level' => sarif_severity
        },
        "properties" => properties
      }

      desc = cop_config['Description']
      unless desc.nil?
        h['shortDescription'] = {"text" => desc}
        h['fullDescription'] = {"text" => desc}
        properties["description"] = desc
      end

      help = @help.string
      if help.size > 0
        h["help"] = {
          "text" => help,
          "markdown" => help,
        }
      end

      if badge.qualified?
        kind = badge.department.to_s
        properties["tags"] = [kind.downcase]
        properties["kind"] = kind
      end

       # TODO: add to properties
#      {
#        "queryURI" => "https://github.com/Semmle/ql/tree/master/cpp/ql/src/Likely Bugs/ReturnConstType.ql",
#        "name" => "Constant return type",
#      }
      h
    end
  end

end
