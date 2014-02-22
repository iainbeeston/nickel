module InstanceFromHash

  def initialize(h)
    h.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
    super()
  end
end
