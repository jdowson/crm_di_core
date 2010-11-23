
class DICoreFFViewHooks < FatFreeCRM::Callback::Base

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

end
