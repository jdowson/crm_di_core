
class DILookupCache

  @cache_loaded = false
  @lookup_cache = {}
  @lookup_item_cache = {}

  # Cache management methods
  # ---------------------------------------------------------------------
  def self.loaded?
    @cache_loaded
  end
  
  def self.load
    if !self.loaded?

      Lookup.find_all_by_status("Active").each do |l| 
        @lookup_cache[l.name] = { 
                                  :id          => l.id,
                                  :name        => l.name, 
                                  :description => l.description, 
                                  :type        => l.lookup_type,
                                  :parent      => l.parent_id.nil? ? nil : l.parent.name
                                }
      end

      LookupItem.find_all_by_status("Active", :order => "lookup_id, parent_id, sequence").each do |i|

        @lookup_item_cache[i.id] = { 
                                  :id          => i.id,
                                  :lookup_id   => i.lookup_id,
                                  :parent_id   => i.parent_id,
                                  :code        => i.code,
                                  :unique_code => i.unique_code,
                                  :description => i.description,
                                  :long_desc   => i.long_description,
                                  :type        => i.item_type,
                                  :color       => i.html_color,
                                  :sequence    => i.sequence,
                                  :locales     => {}
                                }
      end

      LookupItemLocale.all.each do |l|
        if(@lookup_item_cache.has_key?(l.lookup_item_id))
          @lookup_item_cache[l.lookup_item_id][:locales][l.language] = { 
                                  :description => l.description,
                                  :long_desc   => l.long_description,
                                }
        end
      end
      
      @cache_loaded = true

    end
    
  end
  
  
  # Base cache access methods
  # ---------------------------------------------------------------------
  def self.unload
    @lookup_cache.clear
    @lookup_item_cache.clear
    @cache_loaded = false
  end
  
  
  def self.reload
    self.unload
    self.load
  end

  
  def self.cache
    @lookup_cache
  end
  
  
  def self.item_cache
    @lookup_item_cache
  end
  
  
  # Cache access methods
  # ---------------------------------------------------------------------
  def self.lookup(lookup_name)
    @lookup_cache[lookup_name]
  end

  def self.parent_lookup(lookup_name)
    @lookup_cache[lookup_name][:parent]
  end
  
  def self.id_from_code(lookup_name, code)
    if(lookup_items = self.items_all_parents(lookup_name))
      code_matches =  lookup_items.select {|v| (v[:code] == code)}
      code_matches[0][:id] if !code_matches.empty?
    end
  end
  
  def self.parent_id_from_code(lookup_name, parent_code)
    self.id_from_code(parent_lookup(lookup_name), parent_code)
  end
  
  def self.u_itemdesc(id)
    if i = self.item(id)
      i[:description]
    else
      id
    end
  end
  
  def self.l_itemdesc(id, locale = nil)
    if i = self.localized_item(self.item(id), locale ||= I18n.locale  ||= I18n.default_locale)
      i[:description]
    else
      id
    end
  end
 
  def self.u_itemldesc(id)
    if i = self.item(id)
      i[:long_desc]
    else
      id
    end
  end
  
  def self.l_itemldesc(id, locale = nil)
    if i = self.localized_item(self.item(id), locale ||= I18n.locale  ||= I18n.default_locale)
      i[:long_desc]
    else
      id
    end
  end
 
  def self.itemcolor(id)
    if i = self.item(id)
      i[:color]
    end
  end
  
  def self.itemcode(id)
    if i = self.item(id)
      i[:code]
    end
  end
  
  def self.u_item(id)
    if i = self.item(id)
      i.reject {|k, v| k == :locales}
    end
  end
  
  def self.l_item(id, locale = nil)
    self.localized_item(self.item(id), locale ||= I18n.locale  ||= I18n.default_locale)
  end
 
  def self.u_items(lookup_name, parent_id = nil)
    if a = self.items(lookup_name, parent_id)
      a.map { |i| i.reject {|k, v| k == :locales} }
    end
  end
  
  def self.l_items(lookup_name, parent_id = nil, locale = nil)
    if a = self.items(lookup_name, parent_id)
      a.map { |i| localized_item(i, locale ||= I18n.locale  ||= I18n.default_locale) }
    end
  end

  def self.u_options(lookup_name, parent_id = nil, id = :id, description = :description)
    _options self.u_items(lookup_name, parent_id), id, description
  end
  
  def self.l_options(lookup_name, parent_id = nil, id = :id, description = :description, locale = nil)
    _options self.l_items(lookup_name, parent_id, locale), id, description
  end

  def self.u_groupoptions(lookup_name, parent_id = nil, id = :id, description = :description, groupdescription = :description)
    _groupoptions self.u_items(lookup_name, parent_id), id, description, groupdescription
  end

  def self.l_groupoptions(lookup_name, parent_id = nil, id = :id, description = :description, groupdescription = :description, locale = nil)
    _groupoptions self.l_items(lookup_name, parent_id, locale), id, description, groupdescription
  end

  def self.u_groupoptionsbyparent(lookup_name, parent_id = nil, id = :id, description = :description, groupdescription = :description)
    parent       = @lookup_cache[lookup_name][:parent]
    parent_items = _options(self.u_items(parent, parent_id), :id, groupdescription)
    items        = []
    parent_items.each do |p|
      child_items = _options(self.u_items(lookup_name, p[1]), id, description)
      items.push [p[0], child_items]
    end
    items
  end

  def self.l_groupoptionsbyparent(lookup_name, parent_id = nil, id = :id, description = :description, groupdescription = :description, locale = nil)
    parent       = parent_lookup(lookup_name)
    parent_items = _options(self.l_items(parent, parent_id, locale), :id, groupdescription)
    items        = []
    parent_items.each do |p|
      child_items = _options(self.l_items(lookup_name, p[1], locale), id, description)
      items.push [p[0], child_items] unless child_items.empty?
    end
    items
  end

  def self.has_groupings?(lookup_name, parent_id = nil)
    if a = self.u_items(lookup_name, parent_id)
      _a_has_groupings?(a)
    else
      false
    end
  end


  private
  
  def self._options(a, id = :id, description = :description)
    
    amain  = []

    if a
      
      a.each do |i|
        if(i[:type] != "Grouping")
          amain.push [ i[description], i[id] ]
        end
      end
    
    end

    amain
    
  end
                         
  def self._groupoptions(a, id = :id, description = :description, groupdescription = :description)
    
    grp    = false
    amain  = []
    agrp   = []

    if a
      
      a.each do |i|
        if(i[:type] == "Grouping")
          if(grp)
            amain.push agrp.dup
            agrp.clear
          end
          agrp[0] = i[groupdescription]
          agrp[1] = []
          grp = true
        else
          if(grp)
            agrp[1].push [ i[description], i[id] ]
          else
            amain.push [ i[description], i[id] ]
          end
        end
      end
    
      if(grp)
        amain.push agrp.dup
      end

    end

    amain
    
  end
                         
  def self._a_has_groupings?(a)
    if a
      t = false
      a.each {|i| t ||= (i[:type] == "Grouping")}
      t
    else
      false
    end
  end

  def self.item(id)
    if @lookup_item_cache.has_key?(id)
      @lookup_item_cache[id]
    end
  end

  def self.items(lookup_name, parent_id = nil)
    if lookup = @lookup_cache[lookup_name]
      @lookup_item_cache.select {|k, v| (v[:lookup_id] == lookup[:id]) && (v[:parent_id] == parent_id)}.values
    end
  end
  
  def self.items_all_parents(lookup_name)
    if lookup = @lookup_cache[lookup_name]
      @lookup_item_cache.select {|k, v| (v[:lookup_id] == lookup[:id])}.values
    end
  end
  
  def self.localized_item(item, locale)
    if(item)
      li = item.dup
      locales = li.delete(:locales)
      li.merge(locales[locale.to_s] ||= {})
    end
  end

  
end