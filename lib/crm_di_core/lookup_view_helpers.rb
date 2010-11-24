
module CRMDICore

  module LookupViewHelpers

    def lkup_d(id, locale = nil)
      DILookupCache.l_itemdesc(id, locale)
    end
 
    def lkup_ld(id, locale = nil)
      DILookupCache.l_itemldesc(id, locale)
    end
 
    def lkup_color(id)
      DILookupCache.itemcolor(id)
    end
 
    def lkup(id, locale = nil)
      DILookupCache.l_item(id, locale)
    end
 
    def lkups(lookup_name, parent_id = nil, locale = nil)
      DILookupCache.l_items(lookup_name, parent_id, locale)
    end

    def lkups_options(lookup_name, parent_id = nil, id = :id, description = :description, locale = nil)
      DILookupCache.l_options(lookup_name, parent_id, id, description, locale)
    end

    def lkups_groupoptions(lookup_name, parent_id = nil, id = :id, description = :description, locale = nil)
      DILookupCache.l_groupoptions(lookup_name, parent_id, id, description, groupdescription, locale)
    end
  
    def lkups_groupoptionsbyparent(lookup_name, parent_id = nil, id = :id, description = :description, groupdescription = :description, locale = nil)
      DILookupCache.l_groupoptionsbyparent(lookup_name, parent_id, id, description, groupdescription, locale)
    end

    def lkup_id_from_code(lookup_name, code)
      DILookupCache.id_from_code(lookup_name, code)
    end
  
    def lkup_parent_id_from_code(lookup_name, parent_code)
      DILookupCache.parent_id_from_code(lookup_name, parent_code)
    end
    
  end

end

ActionView::Base.send(:include, CRMDICore::LookupViewHelpers)
