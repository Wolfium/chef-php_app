class Chef
  class Node
    class ImmutableMash
      def to_hash_recursive
        h = {}
        self.each do |k,v|
          if v.respond_to?('to_hash_recursive')
            h[k] = v.to_hash_recursive
          elsif v.respond_to?('to_array_recursive')
            h[k] = v.to_array_recursive
          else
            h[k] = v
          end
        end
        return h
      end
    end

    class ImmutableArray
      def to_array_recursive
        a = []
        self.each do |v|
          if v.respond_to?('to_hash_recursive')
            a << v.to_hash_recursive
          elsif v.respond_to?('to_array_recursive')
            a << v.to_array_recursive
          else
            a << v
          end
        end
        return a
      end
    end
  end
end

class ::Hash
  def merge_recursive(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
end