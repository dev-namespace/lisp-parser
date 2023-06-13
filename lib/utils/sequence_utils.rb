module SequenceUtils
  def self.recursive_map(func, array)
    array.map do |element|
      if element.is_a?(Array)
        recursive_map(func, element)
      else
        func.call(element)
      end
    end
  end
end
