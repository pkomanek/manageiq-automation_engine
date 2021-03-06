class MiqAeMethodYaml
  attr_accessor :ae_method_obj
  attr_accessor :data
  def initialize(filename = nil)
    @filename = filename
    @ae_method_obj = YAML.load_file(@filename) if @filename
    load_method_file if @filename
  end

  def define_instance_variables
    @ae_method_obj['object']['attributes'].each do |k, v|
      instance_variable_set("@#{k}", v)
      singleton_class.class_eval { attr_accessor k.to_s }
      send("#{k}=", v)
    end
  end

  def load_method_file
    define_instance_variables
    file_name = method_file_name
    contents  = ""
    contents = File.open(file_name, &:read) if file_name
    instance_variable_set("@data", contents)
  end

  def method_file_name
    return nil if location.casecmp('builtin').zero?
    return nil if location.casecmp('uri').zero?
    return @filename.gsub('.yaml', '.rb') if language.casecmp('ruby').zero?
  end

  def field_names
    raise "ae_method_obj has not been set" unless @ae_method_obj

    define_instance_variables
    @ae_method_obj['object']['inputs'].collect { |item| item['field']['name'] }.flatten
  end

  def field_value_hash(name)
    raise "ae_method_obj has not been set" unless @ae_method_obj

    define_instance_variables
    value = @ae_method_obj['object']['inputs'].detect { |item| item['field']['name'].casecmp(name).zero? }
    raise "field name #{name} not found in instance #{@filename}" if value.nil?

    value['field']
  end
end
