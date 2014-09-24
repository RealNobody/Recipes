class PageApplication
  @@current_instances = {}

  attr_accessor :current_user
  attr_accessor :current_user_password
  attr_accessor :is_mobile
  attr_accessor :app_host

  alias :is_mobile? :is_mobile

  class << self
    def current_instance
      @@current_instances[self.name] ||= self.new
    end

    def method_missing(method_sym, *arguments, &block)
      if self.current_instance.respond_to?(method_sym, true)
        self.current_instance.send(method_sym, *arguments)
      else
        super
      end
    end

    def respond_to?(method_sym, include_private = false)
      if self.current_instance.respond_to?(method_sym, include_private)
        true
      else
        super
      end
    end
  end

  def pages_module
    raise Exception("not implemented")
  end

  def is_page_name?(method_name)
    is_page_name = false
    if method_name =~ /^[@a-z0-9_]+$/i
      base_class = pages_module

      is_page_name = true
      method_name.split("__").each do |module_name|
        unless base_class.const_defined?(module_name.camelize, false)
          is_page_name = false
          break
        end

        base_class = "#{base_class}::#{module_name.camelize}".constantize
      end
    end

    is_page_name
  end

  def method_missing(method_sym, *arguments, &block)
    method_name = method_sym.to_s
    if is_page_name?(method_name)
      return_page = instance_variable_get("@#{method_name}")
      unless return_page
        return_page = "#{pages_module.to_s}::#{method_name.split("__").map(&:camelize).join("::")}".constantize.new
        instance_variable_set("@#{method_name}", return_page)
      end

      return_page
    else
      super
    end
  end

  def respond_to?(method_sym, include_private = false)
    method_name = method_sym.to_s

    if is_page_name?(method_name)
      true
    else
      super
    end
  end
end