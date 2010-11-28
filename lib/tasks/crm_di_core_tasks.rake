
namespace :crm do

  namespace :di do

    def create_lookup(lookup_name, description, parent = nil, status = "Active")
      if (t = Lookup.find_by_name(lookup_name))
        puts "#{lookup_name} lookup exists"
      else
        puts "Creating #{lookup_name} lookup"
        t = (parent.nil? ? Lookup : parent.lookups).create(:name => lookup_name, :description => description, :status => status)
        t.save!
        puts "Created #{lookup_name} lookup"
      end
      return t
    end
    

    def add_lookup_items(items, parent_lookup = nil, parent_item = nil)
      items.each do |x|
        lookup_name = x[0]
        code        = x[1]
        description = x[2]
        color       = x[3]
        children    = x[4]
        parent      = Lookup
        parent      = parent_lookup.lookups unless parent_lookup.nil?
        l           = parent.find_by_name(lookup_name)

        item        = parent_lookup.nil? ? l.items.find_by_code(code.to_s) : l.items.find_by_code_and_parent_id(code, parent_item.id)
        if(item)
          puts "'#{lookup_name}' code '#{code}' exists"
          puts "-" * 80
        else
          puts "Creating '#{lookup_name}' code '#{code}'"
          item = l.items.new
          item.code = code.to_s
          item.description = description
          item.long_description = description
          item.html_color = color
          item.parent_id = parent_item.nil? ? nil : parent_item.id
          item.assign_next_sequence
          item.activate
          item.save
          puts "Created '#{lookup_name}' code '#{code}'"
          puts "-" * 80
        end
        
        if !l.nil? && !children.empty?
          add_lookup_items children, l, item
        end

      end
      
    end

    
    def check_lookups_for_items(items, lookups = {  }, parent_lookup = nil)

      items.each do |x|

        lookup_name = x[0]
        children    = x[4]
        parent      = Lookup
        parent      = parent_lookup.lookups unless parent_lookup.nil?
        l           = parent.find_by_name(lookup_name)
        
        if !lookups.has_key?(lookup_name)
          puts "Checking for lookup #{lookup_name}"
          lookups[lookup_name] = !l.nil?
          if(lookups[lookup_name])
            puts "Lookup #{lookup_name} found."
          else
            puts "Lookup #{lookup_name} not found!"   
          end
          puts "-" * 80
        end
        
        if !l.nil? && !children.empty?
          lookups = check_lookups_for_items(children, lookups, l)
        end
        
      end
      
      return lookups
      
    end
    

    # Update public assets
    namespace :core do  

      desc "Setup di_core plugin"  
      task :setup do
        puts "=" * 80
        puts "crm_di_core Plugin Setup Start"
        puts "=" * 80
        puts "crm_di_core Plugin Setup Complete"
        puts "=" * 80
      end

    end
  
  end

end
