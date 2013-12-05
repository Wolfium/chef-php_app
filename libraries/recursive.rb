class Chef
  class Node
    class ImmutableMash
      def to_hash_recursive
        h = {}
        self.each do |k,v|
          if v.respond_to?('to_hash_recursive')
            h[k] = v.to_hash_recursive
          elsif v.respond_to?('to_hash')
            h[k] = v.to_hash
          else
            h[k] = v
          end
        end
        return h
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