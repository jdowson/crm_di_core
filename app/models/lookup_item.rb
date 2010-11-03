# Schema
#
#      t.integer    :lookup_id,        :null => false, :default => nil
#      t.integer    :sequence,         :null => false, :default => nil
#      t.integer    :parent_id,        :null => true,  :default => nil
#      t.string     :code,             :null => false, :default => nil,           :limit => 50
#      t.string     :language,         :null => false, :default => 'en-US',       :limit => 10
#      t.string     :description,      :null => false, :default => '',            :limit => 255
#      t.string     :long_description, :null => false, :default => '',            :limit => 255
#      t.string     :html_color,       :null => false, :default => '',            :limit => 50
#      t.string     :item_type,        :null => false, :default => 'Standard',    :limit => 50
#      t.string     :status,           :null => false, :default => 'Unpublished', :limit => 50
#      t.datetime   :deleted_at
#      t.timestamps


class LookupItem < ActiveRecord::Base

  # Attributes accessible from outside the model
  attr_accessible    :lookup_id, :sequence, :parent_id, :code, :language, 
                     :description, :long_description, :html_color, :item_type, :status

  # Model Callbacks
  before_destroy     :check_if_has_children

  # Relationships
  has_many   :items, :foreign_key => 'parent_id',
                     :class_name  => 'LookupItem'
                     # ,:dependent   => :destroy
  
  belongs_to :lookup

  # Standard Plugins
  acts_as_paranoid

  # Default behaviour
  default_scope   :order      => 'sequence ASC'
  
  simple_column_search :code, :description, :long_description, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }

  # Validations
  validates_presence_of   :code, :language, :status

  validates_uniqueness_of :code, :case_sensitive => false

  validates_length_of     :code,             :maximum => 50
  validates_length_of     :description,      :maximum => 255, :allow_blank => true
  validates_length_of     :long_description, :maximum => 255, :allow_blank => true
  validates_length_of     :html_color,       :maximum => 50,  :allow_blank => true

  
  # Named scopes

  # Child lookups of the lookup
  #----------------------------------------------------------------------------
  #named_scope :root_lookups, :conditions => { :parent_id => nil }


  # Get the parent lookup of a child lookup
  #----------------------------------------------------------------------------
  #def parent
  #  self.class.find_by_id(self.parent_id) unless self.parent_id.nil?
  #end
  
  # Is the lookupItem active?
  #----------------------------------------------------------------------------
  def active?
    self.status == "Active"
  end

  # Set a lookupItem to be active
  #----------------------------------------------------------------------------
  def activate
    self.status = "Active"
  end
  
  # Activate a lookupItem immediately
  #----------------------------------------------------------------------------
  def activate!
    self.update_attribute(:status, "Active")
  end
  
  # Is the lookupItem unpublished?
  #----------------------------------------------------------------------------
  def unpublished?
    self.status == "Unpublished"
  end  
  
  # Set a lookupItem to be unpublished
  #----------------------------------------------------------------------------
  def unpublish
    self.status = "Unpublished"
  end

  # Unpublish a lookupItem immediately
  #----------------------------------------------------------------------------
  def unpublish!
    self.update_attribute(:status, "Unpublished")
  end
    
  # Is the lookupItem inactive?
  #----------------------------------------------------------------------------
  def inactive?
    self.status == "Inactive"
  end
  
  # Set the lookupItem to be inactive
  #----------------------------------------------------------------------------
  def inactivate
    self.status = "Inactive"
  end
  
  # Inactivate a lookupItem immediately
  #----------------------------------------------------------------------------
  def inactivate!
    self.update_attribute(:status, "Inactive")
  end
  

  private
  

  # Prevent deleting a lookup if it has child lookups
  #----------------------------------------------------------------------------
  def check_if_has_children
    false #self.lookups.count == 0
  end
  
  
end