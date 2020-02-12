#
# Class for generating VyOS router configurations
#
class VyOSConfig
  # If properties is 'nil', then it is a Valueless Node
  # If properties is empty, then it has an empty set of properties
  attr_accessor :properties

  def initialize
    @properties = nil
  end

  def []=(key, value)
    @properties ||= {}
    @properties[key] ||= []
    @properties[key] << value
  end

  def [](key)
    @properties ||= {}
    @properties[key] ||= VyOSConfig.new
  end

  def empty
    @properties = {}
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
        if value.properties.nil?
          result += indent + "#{key}\n"
        else
          result += indent + "#{key} {\n"
          result += value.to_s(depth + 1)
          result += indent + "}\n"
        end
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
    if @properties.nil? or @properties.empty?
      result << (['set'] + path).join(' ')
    else
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
    end
    result
  end
end
