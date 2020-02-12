#
# Class for generating VyOS router configurations
#
class VyOSConfig
  attr_accessor :properties

  def initialize
    @properties = {}
  end

  def []=(key, value)
    @properties[key] ||= []
    @properties[key] << value
  end

  def [](key)
    @properties[key] ||= VyOSConfig.new
  end

  def method_missing(m, *args)
    # Hyphens are not allowed in method names
    # but VyOS uses them (and not underscores)
    name = m.to_s.gsub('_', '-')
    if name.match(/^(.+)=$/)
      self[$1] = args.first
    else
      name += " #{args.first}" if args.count > 0
      self[name]
    end
  end

  # Convert values to strings and add quotes, if required
  def escape_values(values)
    values.map do |value|
      str = value.to_s
      if str.empty? || str =~ /[^\w\-]/
        "'#{str}'"
      else
        str
      end
    end
  end

  # Create VyOS configuration string
  def to_s(depth=0)
    result = ''
    @properties.each_pair do |key, value|
      indent = ' ' * (depth*4)
      if value.is_a?(VyOSConfig)
        result += indent + "#{key} {\n"
        result += value.to_s(depth + 1)
        result += indent + "}\n"
      elsif value.is_a?(Array)
        escape_values(value).each do |v|
          result += indent + "#{key} #{v}\n"
        end
      end
    end
    result
  end

  # Create VyOS configuration commands
  def commands(path=[])
    result = []
    @properties.each_pair do |key, value|
      subpath = path.dup << key
      if value.is_a?(VyOSConfig)
        result += value.commands(subpath)
      elsif value.is_a?(Array)
        result += escape_values(value).map do |v|
          (['set'] + subpath + [v]).join(' ')
        end
      end
    end
    result
  end
end
