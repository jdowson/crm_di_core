
class DICoreFFViewHooks < FatFreeCRM::Callback::Base

  # Some HAML fragments
  
  # New fields for contact object
  HAML_CONTACT_FORM_EXT = <<EOS
%tr
  %td{ :valign => :top, :colspan => span }
    %table(width="500" cellpadding="0" cellspacing="0")
      %tr
        %td{ :valign => :top }
          .label 
            = I18n.t(:type, :scope => [:di, :contacts]) << ":" 
            %small 
              = I18n.t(:type_help, :scope => [:di, :contacts])
          = f.lookup_select :contact_type_id, "contact.type", { :include_blank => '[NO T]' }, { :style => "width:240px" }
        %td= spacer
        %td{ :valign => :top }
          #stype
            .label 
              = I18n.t(:sub_type, :scope => [:di, :contacts]) << ":"
            = f.lookup_select :contact_sub_type_id, { :lookup => "contact.type.subtype", :parent => :contact_type_id, :lookup_options => { :select_first => false, :include_blank_if_empty => "NO SUBTYPES" } }, { :include_blank => "NO ST SEL" }, { :style => "width:240px" }
      %tr
        %td{ :valign => :top }
          #sstype
            .label 
              Sub-subtype:
            -#= f.lookup_select :contact_sub_sub_type_id, { :lookup => "contact.type.subtype.subsubtype", :parent => :contact_sub_type_id, :lookup_options => { :hide_element => "sstype" }  }, { }, { :style => "width:240px" }
        %td= spacer
        %td
          #xdiv
            .label
              Unbound2:
            = lookup_select_tag :new_ctrl2, { :lookup => "contact.type.subtype", :parent_id => @contact.contact_type_id, :parent_control => "contact_contact_type_id" }, @contact.contact_sub_type_id, { :style => "width:240px" }
      %tr
        %td
          #ncdiv
            .label
              Unbound:
            = lookup_select_tag :new_ctrl, {:lookup => "contact.type", :lookup_options => { :option_key_type => :code } }, @contact.contact_type_id, { :style => "width:240px" }
        %td= spacer
        %td{ :valign => :top }
          #ostype
            .label 
              = I18n.t(:sub_type, :scope => [:di, :contacts]) << "X:"
            -#= f.lookup_select :contact_osub_type_id, { :lookup => "contact.type.subtype.subsubtype", :parent_control => :new_ctrl, :parent_id => @contact.contact_type_id, :lookup_options => { :include_blank_if_empty => '[NO OST]', :hide_element => 'ostype', :parent_group => true } }, { }, { :style => "width:240px" }
EOS

  HAML_CONTACT_SIDEBAR_EXT = <<EOS
= side_bar_item(t(:type,     :scope => [:di, :contacts]), model.contact_type_id)
= side_bar_item(t(:sub_type, :scope => [:di, :contacts]), model.contact_sub_type_id)
EOS

  # DI standard style inclusions
  INLINE_STYLES_LOOKUPS = <<EOS
li.lookup .active
    :background lightgreen
li.lookup .unpublished
    :background lightblue
li.lookup .inactive
    :background gainsboro
li.lookup_item .active
    :background lightgreen
li.lookup_item .unpublished
    :background lightblue
li.lookup_item .inactive
    :background gainsboro
div .disubform
    :background gainsboro
    :margin-bottom 4px
    :margin-top 4px
    :padding-left 4px
    :padding-right 4px
    :border 1px solid darkgray
div .discope
    :background antiquewhite
    :margin 4px
    :padding 4px
    :border 1px solid darkgray
    :font-size 0.8em
div .discopeside
    :background antiquewhite
    :margin 2px
    :padding 4px
    :border 1px solid darkgray
    :font-size 1.0em
EOS


  # Install javascript_includes hook
  define_method :"javascript_includes" do |view, context|
    includes =  view.javascript_include_tag 'event.simulate.js'
  end


  # Install inline_styles hook
  define_method :"inline_styles" do |view, context|

    if(view.controller.action_name == 'index' || view.controller.action_name == 'show')
      styles = case view.controller.controller_name
        when "lookups"      then INLINE_STYLES_LOOKUPS
        when "lookup_items" then INLINE_STYLES_LOOKUPS
        else ""
      end
    end

    Sass::Engine.new(styles).render unless styles.empty?

  end

  # Install view hooks for models
  [ :contact ].each do |model|

    define_method :"#{model}_top_section_bottom" do |view, context|
      sendd __FILE__, "Hook Start #{model}_top_section_bottom"
      Haml::Engine.new(HAML_CONTACT_FORM_EXT).render(view, :f => context[:f], :span => 3)
    end

    define_method :"show_#{model}_sidebar_bottom" do |view, context|
      sendd __FILE__, "Hook Start show_#{model}_sidebar_bottom"
      Haml::Engine.new(HAML_CONTACT_SIDEBAR_EXT).render(view, :model => context[model])
    end

  end

  
end
