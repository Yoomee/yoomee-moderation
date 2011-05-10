module ContentFlagTypesHelper
  
  def content_flag_type_javascript
    javascript_tag do
      <<-JS
      var ContentFlagTypeForm = {
        complete: function(unique_id) {
          $('#' + unique_id + '_content_flag_type_ajax_loader').hide();
          $('#' + unique_id + '_content_flag_type_edit_link').show();
        },
        hide_form: function (unique_id) {
          $('#' + unique_id + '_content_flag_type_form').hide(0, function() {
            $('#' + unique_id + '_content_flag_type_display').show();
            $('#' + unique_id + '_content_flag_type_edit_link').html('edit');
            $('#' + unique_id + '_content_flag_type_delete_link').show();
            $('#' + unique_id + '_content_flag_type_save_link').hide();
          });
        },
        loading: function(unique_id) {
          $('#' + unique_id + '_content_flag_type_form').hide(0, function() {
            $('#' + unique_id + '_content_flag_type_display').hide();
            $('#' + unique_id + '_content_flag_type_ajax_loader').show();
            $('#' + unique_id + '_content_flag_type_edit_link').hide();
            $('#' + unique_id + '_content_flag_type_delete_link').hide();
            $('#' + unique_id + '_content_flag_type_save_link').hide();
          })
        },
        show_form: function(unique_id) {
            $('#' + unique_id + '_content_flag_type_form').show(0, function() {
              $('#' + unique_id + '_content_flag_type_display').hide();
              $('#' + unique_id + '_content_flag_type_edit_link').html('cancel');
              $('#' + unique_id + '_content_flag_type_delete_link').hide();
              $('#' + unique_id + '_content_flag_type_save_link').show();
              $('#' + unique_id + '_content_flag_type_form .content_flag_type_name_input').focus();
            });
        },
        toggle_form: function(unique_id) {
          $('#' + unique_id + '_content_flag_type_ajax_loader').hide(0, function() {
            if ($('#' + unique_id + '_content_flag_type_form').is(':visible')) {
              ContentFlagTypeForm.hide_form(unique_id);
            } else {
              ContentFlagTypeForm.show_form(unique_id);
            }
          });
        },
        show_new_form: function() {
          $('#new_content_flag_type_form').show(0,function() {
            $('#new_content_flag_type_link').hide();
            $('#new_content_flag_type_form .content_flag_type_name_input').focus();
          });
        },
        hide_new_form: function() {
          $('#new_content_flag_type_form').hide(0,function() {
            $('#new_content_flag_type_link').show();
          });
        },
        toggle_new_form: function() {
          if ($('#new_content_flag_type_form').is(':visible')) {
            ContentFlagTypeForm.hide_new_form();
          } else {
            ContentFlagTypeForm.show_new_form();
          }
        }
      };
      JS
    end
  end

  
end