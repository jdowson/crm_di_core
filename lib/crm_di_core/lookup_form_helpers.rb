
require "rubygems"
require "rexml/document"

module ActionView

  module Helpers
    
    def lookup_select_defaults(lookup = nil, options = nil)

      # Apply these default settings
      l = { :parent_id              => nil, 
            :no_observer            => false,
            :parent_key_type        => :id,
            :option_key_type        => :id, 
            :option_value_type      => :description,
            :group_label_type       => :description,
            :hide_groups            => false,
            :include_blank          => false,
            :include_blank_if_empty => true,
            :hide_element_if_empty  => nil,
            :disable_if_empty       => false,
            :select_first           => true,
            :cascade                => true,
            :parent_group           => false
          }

      l[:include_blank] = options[:include_blank] unless options.nil? || !options.has_key?(:include_blank)

      l.merge!(lookup.is_a?(Hash) ? lookup : { :lookup_name => lookup })
      
      # Tidy up if passed through a controller
      [:no_observer, :hide_groups, :include_blank, :include_blank_if_empty, :disable_if_empty, :select_first, :cascade, :parent_group].each do |k|
        l[k] = false if l[k] == "false"
        l[k] = true  if l[k] == "true"
      end
      
      [:parent_key_type, :option_key_type, :option_value_type, :group_label_type, :hide_element_if_empty].each do |k|
        l[k] = (l[k].nil? || l[k].empty?) ? nil : l[k].to_sym
      end
      
      return l
      
    end

    
    def lookup_select_options(lookup)
      
      optionsinfo = { :options => [], :has_groupings => true, :first_value => nil }

      # Get appropriate type of list from cache
      if(lookup[:parent_group])
        optionsinfo[:options] = DILookupCache.l_groupoptionsbyparent(
                                                                      lookup[:lookup_name], 
                                                                      lookup[:parent_id], 
                                                                      lookup[:option_key_type], 
                                                                      lookup[:option_value_type], 
                                                                      lookup[:group_label_type]
                                                                    )
      else
        if DILookupCache.has_groupings?(lookup[:lookup_name], lookup[:parent_id]) && !lookup[:hide_groups]
          optionsinfo[:options] = DILookupCache.l_groupoptions(
                                                                        lookup[:lookup_name], 
                                                                        lookup[:parent_id], 
                                                                        lookup[:option_key_type], 
                                                                        lookup[:option_value_type], 
                                                                        lookup[:group_label_type]
                                                                      )
        else
          optionsinfo[:has_groupings] = false
          optionsinfo[:options] = DILookupCache.l_options(
                                                                        lookup[:lookup_name], 
                                                                        lookup[:parent_id], 
                                                                        lookup[:option_key_type], 
                                                                        lookup[:option_value_type]
                                                                      )
        end
      end
      
      # Identify first value in list
      if(optionsinfo[:has_groupings])
        optionsinfo[:options].each do |o|
          optionsinfo[:first_value] = o[1][0][1] if optionsinfo[:first_value].nil? && o[1].kind_of?(Array) && !o[1].empty?
        end
      else
        optionsinfo[:first_value] = optionsinfo[:options][0][1] unless optionsinfo[:options].empty?
      end
      
      # Handle empty lists
      if(optionsinfo[:empty] = optionsinfo[:options].empty?)

        optionsinfo[:has_groupings] = false
        sblank = (lookup[:include_blank_if_empty].to_s != "false") ? lookup[:include_blank_if_empty].to_s : ((lookup[:include_blank].to_s != "false") ? lookup[:include_blank].to_s : nil)
        optionsinfo[:options].unshift([ sblank == "true" ? "" : sblank , nil]) unless sblank.nil?
      
      end
      
      return optionsinfo

    end
    
    
    def lookup_observer(parent, child, lookup = {}, options = {})
      observe_field parent, :url => { :controller => 'lookups', :action => 'get_children', :child => child, :lookup => lookup, :options => options }, :method => :get, :with => "parent_id"
    end

    
    def options_or_groups_from_lookup_for_select(lookup_name, parent_id = nil, selected = nil)
      option_groups_from_lookup_for_select lookup_name, parent_id, selected
    end


    def option_groups_from_lookup_for_select(lookup_name, parent_id = nil, selected_key = nil, group_label_method = :description, option_key_method = :id, option_value_method = :description)
      if DILookupCache.has_groupings?(lookup_name, parent_id)
        options = DILookupCache.l_groupoptions(lookup_name, parent_id, id = option_key_method, description = option_value_method, groupdescription = group_label_method)
        grouped_options_for_select options, selected_key
      else
        options_from_lookup_for_select lookup_name, parent_id, selected_key, option_key_method, option_value_method
      end
    end


    def option_groups_from_lookup_by_parent_for_select(lookup_name, parent_id = nil, selected_key = nil, group_label_method = :description, option_key_method = :id, option_value_method = :description)
      options = DILookupCache.l_groupoptionsbyparent(lookup_name, parent_id, id = option_key_method, description = option_value_method, groupdescription = group_label_method)
      grouped_options_for_select options, selected_key
    end


    def options_from_lookup_for_select(lookup_name, parent_id = nil, selected = nil, value_method = :id, text_method = :description)
      options_for_select DILookupCache.l_options(lookup_name, parent_id, value_method, text_method), selected
    end
    

    def lookup_select_tag(name, lookup, value = nil, options = {})

      l         = lookup_select_defaults(lookup, options)
      o         = lookup_select_options(l)
      observer  = ""
      html_name = (options[:multiple] == true && !name.to_s.ends_with?("[]")) ? "#{name}[]" : name

      options.delete(:include_blank)
      
      value = o[:first_value] if value.nil? && l[:select_first]

      if o[:has_groupings]
        option_tags = grouped_options_for_select(o[:options], value)
      else
        option_tags = options_for_select(o[:options], value)
      end

      html      = content_tag :select, option_tags, { "name" => html_name, "id" => sanitize_to_id(name), "include_blank" => false }.update(options.stringify_keys)

      if !(l[:parent_control].nil? || l[:no_observer])
        this_control_id = sanitize_to_id(name)
        parent_control_id = l[:parent_control]
        observer = lookup_observer(parent_control_id, this_control_id, l, options)
      end
      
      html << observer

    end

    def lookup_select(object, method, lookup, options = {}, html_options = {})

      l        = lookup_select_defaults(lookup, options)
      o        = lookup_select_options(l)
      observer = ""
      html     = ""
      
      options.delete(:include_blank)      
      
      if o[:has_groupings]
        html = InstanceTag.new(object, method, self, options.delete(:object)).to_grouped_select_tag(o[:options], options, html_options)
      else
        html = InstanceTag.new(object, method, self, options.delete(:object)).to_select_tag(o[:options], options, html_options)
      end

      if !((l[:parent].nil? && l[:parent_control].nil?) || l[:no_observer])
        this_control_id = REXML::Document.new(html).root.attributes["id"]
        parent_control_id = l[:parent_control] ||= (object.to_s + "_" + l[:parent].to_s)
        observer = lookup_observer(parent_control_id, this_control_id, l, options)
      end

      html << observer

    end

    class FormBuilder

      def lookup_select(method, lookup, options = {}, html_options = {})
        
        l = { :parent_id         => nil,
              :parent            => nil,
              :parent_control    => nil 
          }.merge(lookup.is_a?(Hash) ? lookup : { :lookup_name => lookup })

        if !l[:parent].nil? && l[:parent_id].nil? 
          l[:parent_id] = (@object.nil? || !@object.respond_to?(l[:parent]) ? nil : @object.send(l[:parent]))
          if(l.has_key?(:parent_key_type) && (l[:parent_key_type] == :code)) 
            l[:parent_id] = DILookupCache.parent_id_from_code(l[:lookup_name], l[:parent_id])
          end 
        end

        @template.lookup_select(@object_name, method, l, objectify_options(options), @default_options.merge(html_options))
        
      end
      
    end

    
    class InstanceTag #:nodoc:
      include FormOptionsHelper

      def to_grouped_select_tag(choices, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        selected_value = options.has_key?(:selected) ? options[:selected] : value
        disabled_value = options.has_key?(:disabled) ? options[:disabled] : nil
        content_tag("select", add_options(grouped_options_for_select(choices, :selected => selected_value, :disabled => disabled_value), options, selected_value), html_options)
      end

    end

    
  end
  
end
