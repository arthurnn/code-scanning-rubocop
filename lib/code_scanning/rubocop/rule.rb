module CodeScanning

  class Rule
    def initialize(cop_name, cfg)
      @cop_name = cop_name
      @cop_config = cfg
      @help = StringIO.new
    end

    attr_reader :cop_name

    def append_help(s)
      @help.print(s)
    end

    def ==(other)
      self.badge.match?(other.badge)
    end
    alias eql? ==

    def badge
      @badge ||= RuboCop::Cop::Badge.parse(@cop_name)
    end

    def to_h
      desc = RuboCop::ConfigLoader.default_configuration[@cop_name]['Description']
      properties = {
        "precision" => "very-high",
        "id" => @cop_name,
        "kind" => badge.department.to_s,
      }

      h = {
        "id" => @cop_name,
        "name"  => @cop_name,
        "defaultConfiguration" => { },# TODO: severity
        "properties" => properties
      }

      unless desc.nil?
        h['shortDescription'] = desc
        h['fullDescription'] = desc
        properties["description"] = desc
      end

      help = @help.string
      if help.size > 0
        h["help"] = {
          "text" => help,
          "markdown" => help,
        }
      end

      {
        "tags" => [ "maintainability", "readability", "language-features" ],
        "queryURI" => "https://github.com/Semmle/ql/tree/master/cpp/ql/src/Likely Bugs/ReturnConstType.ql",
        "name" => "Constant return type",
        #"problem.severity" => "warning"
      }
      h
    end
  end

end
