
# crm_di_core
# lib/crm_di_core.rb
# Main plugin initializer

# add modules to path and change ActiveSupport handling
# changes reloading behaviour??????
%w{ models controllers helpers }.each do |dir|

  path = File.join(File.dirname(__FILE__), "../app", dir)

  $LOAD_PATH << path

  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)

end

# load some standard libraries
require "di_utils"

sendd __FILE__, "Booting"

# Fat Free integration
require File.join(File.dirname(__FILE__), "crm_di_core", "fat_free_view_hooks")
require File.join(File.dirname(__FILE__), "crm_di_core", "fat_free_view_helpers")