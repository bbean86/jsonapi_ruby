require_relative 'discovery'
module JsonApi
  module Resources

    module Base
      attr_reader :relationships
      def to_hash
        resource_hash = identifier_hash
        resource_hash['attributes'] = attributes_hash if attributes_hash.any?

        relationships.each do |relationship|
          resource_hash['relationships'] ||= {}
          resource_hash['relationships'][relationship.name] = relationship.to_hash
        end

        resource_hash['links'] = links_hash
        resource_hash
      end

      # Very basic. Eventually this will need to parse things like
      # "article.comments" and "article-comments", so, leaving the method here
      # but only supporting the most basic of things
      def parse_for_includes(includes)
        Array(includes).map(&:to_s)
      end

      def identifier_hash
        { 'id' => self.id, 'type' =>  self.type }
      end

      def links_hash
        { 'self' => JsonApi.configuration.base_url + self_link_path }
      end

      def self_link_path
        "/#{self.type}/#{self.id}"
      end

      def attributes_hash
        fields_array.inject({}) do |attrs, attr|
          meth = method(attr)
          attrs[attr.to_s] = meth.call
          attrs
        end
      end

      # Builds relationship resource classes
      def build_object_graph
        @relationships ||= []
        relationships_array.each do |relationship|
          included = includes.include?(relationship.name)
          rel = relationship.build_resources({parent_resource: self, included: included})
          @relationships << rel
        end
      end

      # Traverses fields set on super-class(es) and concatinates them into a
      # single set. Stores the set in `self.class.fields`, leaving super-class
      # `fields` sets untouched.
      def fields_array(klass = self.class)
        fields_list = concat_list(self.class.fields, klass.fields)
        unless klass.superclass == Resource
          return fields_array(klass.superclass)
        end
        fields_list
      end

      # Traverses relationships set on super-class(es) and concatinates them
      # into a single set. Stores the set in `self.class.relationships`,
      # leaving super-class `relationships` sets untouched.
      def relationships_array(klass = self.class)
        rel_list = concat_list(self.class.relationships, klass.relationships)
        unless klass.superclass == Resource
          return relationships_array(klass.superclass)
        end
        rel_list
      end

      private

      # Adds elements of the `concat_list` to the `target_list` if they are
      # not already present.
      def concat_list(target_list, concat_list)
        list = Array(target_list)
        not_in_list = Array(concat_list).reject do |item|
          list.include?(item)
        end
        not_in_list.each { |item| list << item }
        list
      end
    end

  end
end
