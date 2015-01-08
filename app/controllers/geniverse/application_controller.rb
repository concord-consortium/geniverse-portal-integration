# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

module Geniverse
  class ApplicationController < ::ApplicationController
    helper :all # include all helpers, all the time
    protect_from_forgery # See ActionController::RequestForgeryProtection for details

    layout 'geniverse/application'

    # Scrub sensitive parameters from your log
    # filter_parameter_logging :password

    before_filter :set_cache_buster
    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    #Adjust JSON communication
    #Sproutcore uses the field guid for objects ids, but Rails calls this field id.
    def custom_hash(obj)
      guid = polymorphic_path(obj)
      attrs = obj.respond_to?('json_attributes') ? obj.json_attributes : obj.attributes
      
      # change each :belongs_to association from the column name (foo_id) to the association name (foo)
      # also change the value from a simple number id to a path id
      obj.class.reflect_on_all_associations(:belongs_to).each do |assoc|
        name = assoc.name.to_s
        attr_key = assoc.options[:foreign_key] || (name + "_id")
        attrs[name] = polymorphic_path(obj.send(name)) if obj.send(name)  
        if (attrs[name].kind_of? String)
          attrs[name].tr('\n\r\t','')
        end
        attrs.delete(attr_key)
      end

      ## change each :has_many association from the array of objects into an array of path ids
      obj.class.reflect_on_all_associations(:has_many).each do |assoc|
        name = assoc.name.to_s
        if obj.respond_to?('includeInJSon?') && obj.includeInJSon?(name)
          attrs[name] = obj.send(name) if obj.send(name)
          if attrs[name].kind_of? Array
            attrs[name] = attrs[name].map {|i| polymorphic_path(i) }
          end
        end
      end
      
      # remove these attributes
      attrs.delete('id')
      attrs.delete('created_at')
      attrs.delete('updated_at')
      
      attrs['guid'] = guid
      return camelcase_keys(attrs)
    end
   
    # like the inverse of above, convert sproutcore hashes to normal obj attributes.
    def paramify_json(hash)
      if request.format.json?
        hash.delete('guid')
        return underscore_keys(hash)
      end
      return hash
    end

    def custom_item_hash(obj)
      return {
        :content => custom_hash(obj),
        :location => polymorphic_path(obj)
      }
    end
    
    def custom_array_hash(arr)
      out = {:content => []}
      arr.each do |item|
        hash = custom_hash(item)
        out[:content] << hash
      end
      return out
    end
    
    def camelcase_keys(hash)
      hash.keys.each do |k|
        ck = k.camelcase(:lower)
        if ck != k
          hash[ck] = hash[k]
          hash.delete(k)
        end
      end
      return hash
    end

    def underscore_keys(hash)
      hash.keys.each do |k|
        ck = k.underscore
        if ck != k
          hash[ck] = hash[k]
          hash.delete(k)
        end
      end
      return hash  end
  end
end
