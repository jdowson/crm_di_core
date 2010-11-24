
class DICoreLookupFFControllerHooks < FatFreeCRM::Callback::Base

  # attaching to: ApplicationController:before_filter "hook(:app_before_filter, self)"
  define_method :"app_before_filter" do |controller, context|

    # Ensure lookup cache loaded
    DILookupCache.load unless DILookupCache.loaded?  

  end
  
end

 
