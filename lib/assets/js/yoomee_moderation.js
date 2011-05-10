var ModerationContent = {
  
  loading: function() {
    $('#moderation_right_inner').hide();
    $('#moderation_right_loader').show();
    // var active = $('#moderation_sidebar .active');
    // active.removeClass('active');
    // active.css('background','none');
  },
  finished: function() {
    $('#moderation_right_loader').hide();
    $('#moderation_right_inner').show();
  }
  
};

var ContentFlag = {
  
  showFiltered: function() {
    $('.flag_text.unfiltered').hide();
    $('.flag_text.filtered').show();
  },
  showUnfiltered: function() {
    $('.flag_text.unfiltered').show();
    $('.flag_text.filtered').hide();
  }
   
};

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
  setup_forms: function() {
    $('.content_flag_type_color_input').colorPicker();
    $('.content_flag_type_form')
      .bind("ajax:loading", function(event) {
        ContentFlagTypeForm.loading($(event.target).attr('data-cft'));
      })
      .bind("ajax:complete", function(event) {
        ContentFlagTypeForm.complete($(event.target).attr('data-cft'));
    });
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