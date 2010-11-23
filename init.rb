
# crm_di_core
# init.rb
# Plugin initialization point
#
# Keep to a minimum in here due to rails EVAL'ing rather than require'ing this file.
# Delegate most functionality to main initializer.

require "fat_free_crm"

# Plugin Registration
FatFreeCRM::Plugin.register(:crm_di_core, initializer) do

          name "Fat Free Delta Indigo Core"
       authors "Delta Indigo"
       version "0.1"
   description "Adds baseline Delta Indigo enhancements to Fat Free CRM"
  dependencies :haml, :simple_column_search

  # Remove non-functional admin tabs
  tab :admin do |tabs|
#    tabs.delete_at(1)                                 # Delete settings tab.
#    tabs.delete_at(1)                                 # Delete plugins tab.
  end
  
  # New admin tabs
  tab :admin, :text => "Lookups", :url => { :controller => "lookups" }

end
  
# delegate the rest to lib/crm_di_core.rb
require File.join(File.dirname(__FILE__), "lib", "crm_di_core")
