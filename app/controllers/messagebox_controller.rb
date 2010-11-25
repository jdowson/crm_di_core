
class MessageboxController < ApplicationController

  #----------------------------------------------------------------------------
  # GET /messagebox                                                        HTML
  #----------------------------------------------------------------------------
  def show

    # map.match 'messagebox/:caption/:icon/*target/buttons/*buttons'
    # e.g /messagebox/msg_update_cache:di:lookups/question/admin/lookups/
    #         buttons/update_cache:put:update_cache_button:di:lookups/script:cancel:no
    
    caption_ref   = params[:caption]
    abuttons_ref  = params[:buttons]
    
    # manipulate the passed parameters
    @icon                = params[:icon]
    @caption             = getcaption(caption_ref.split(":"))
    @buttons             = abuttons_ref.map { |b| getbutton(b.split(":")) }

    respond_to do |format|
      format.js   { render :layout => false, :content_type => 'text/html' }
      format.html { render :layout => false, :content_type => 'text/html' }
    end

  end
  
  
  private
  
  def getcaption(ary)
    
    key = ary.shift.to_sym
    
    if ary.empty?
      I18n.t key
    else
      scope = ary.map { |l| l.to_sym }
      I18n.t key, :scope => scope
    end
    
  end
  
  def getbutton(button)
    
    b = Hash.new
    
    b[:action]  = button.shift.to_sym
    b[:method]  = button.shift.to_sym
    b[:type]    = button.shift.to_sym
    b[:icon]    = button.shift.to_s
    b[:caption] = getcaption(button)
    
    if b[:action] == :script
      b[:method] = 'Modalbox.hide()' if b[:method] == :cancel
    end
    
    b
    
  end
 
end