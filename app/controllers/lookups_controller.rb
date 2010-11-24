
class LookupsController < ApplicationController

  #----------------------------------------------------------------------------
  # GET lookups/get_children                                               HTML
  #----------------------------------------------------------------------------
  def get_children

    @parent             = params[:parent_id]
    @child              = params[:child]
    @lookup             = params[:lookup].to_options
    @options            = params[:options] ||= { }

    @parent_key_type    = @lookup[:parent_key_type].to_sym

    @parent_id = case @parent_key_type
      when :code then DILookupCache.parent_id_from_code(@lookup[:lookup_name], @parent)
      else @parent.to_i
    end

    @lookup[:parent_id] = @parent_id

    respond_to do |format|
      format.js
      format.html
    end

  end
 
end 
