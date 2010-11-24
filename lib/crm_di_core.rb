
# crm_di_core
# lib/crm_di_core.rb
# Main plugin initializer

# Load some DI standard libraries
require File.join(File.dirname(__FILE__), "crm_di_core", "di_utils")

# add modules to path and change ActiveSupport handling
# changes reloading behaviour??????
%w{ models controllers helpers }.each do |dir|

  path = File.join(File.dirname(__FILE__), "../app", dir)

  $LOAD_PATH << path

  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)

end

# Load core modules
require File.join(File.dirname(__FILE__), "crm_di_core", "lookup_cache")
require File.join(File.dirname(__FILE__), "crm_di_core", "lookup_view_helpers")
require File.join(File.dirname(__FILE__), "crm_di_core", "lookup_form_helpers")

# Fat Free integration
require File.join(File.dirname(__FILE__), "crm_di_core", "lookup_ff_controller_hooks")
require File.join(File.dirname(__FILE__), "crm_di_core", "lookup_ff_view_hooks")
