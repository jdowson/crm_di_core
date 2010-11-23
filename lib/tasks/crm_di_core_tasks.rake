
# Update public assets
namespace :crm do

  namespace :di do

    namespace :core do  

      desc "Setup di_core plugin, installing public assets"  
      task :setup do
        #system "rsync -ruv vendor/plugins/crm_di_core/db/migrate db"  
        system "rsync -ruv vendor/plugins/crm_di_core/public ."  
      end

    end
  
  end

end
