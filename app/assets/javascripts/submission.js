$(document).ready(function() {
  // Submission#edit: Promote an alternative vessel name
  $('.promote_alt_name').on('click', function() {
    var original_vessel_name = $('#submission_vessel_name').val();
    var new_vessel_name = $('#submission_vessel_' + this.id).val();

    $('#submission_vessel_name').val(new_vessel_name);
    $('#submission_vessel_' + this.id).val(original_vessel_name);
    return false;
  });

  // On the submission details page we display a font-awesome star next
  // to "similar" attributes in the "similar vessels" pane.
  // With this script, we set the reciprocal attribute in the vessel pane.
  if ($('#similar-vessels .similar-name').length) {
    $('#vessel-name .fa-star-o.hidden').removeClass('hidden');
  }
  if ($('#similar-vessels .similar-hin').length) {
    $('#vessel-hin .fa-star-o.hidden').removeClass('hidden');
  }
  if ($('#similar-vessels .similar-mmsi_number').length) {
    $('#vessel-mmsi_number .fa-star-o.hidden').removeClass('hidden');
  }
  if ($('#similar-vessels .similar-radio_call_sign').length) {
    $('#vessel-radio_call_sign .fa-star-o.hidden').removeClass('hidden');
  }

  // Submissions#new: toggle Official No / Vessel Name field
  if ($('form #submission_application_type').length > 0) { set_application_type_depenencies(); }

  $('form #submission_application_type').on('change', function(){
    set_application_type_depenencies();
  })

  function set_application_type_depenencies() {
    var current_application_type = $('form #submission_application_type').val();
    var name_field_array = ['new_registration', 'provisional'];
    var display_name_field = $.inArray(current_application_type, name_field_array) > -1;

    if ( display_name_field ) {
      $('#submission_vessel_name').removeClass('hidden');
      $('#submission_vessel_reg_no').addClass('hidden');
    }
    else{
      $('#submission_vessel_name').addClass('hidden');
      $('#submission_vessel_reg_no').removeClass('hidden');
    }
  };

  // Toggle the safety management fields
  $('#toggle_safety_management_fields').on('click', function(){
     $('#safety_management_fields').toggle('slow');
  });

  // Set the Vessel Type Label for extended submissions
  function set_vessel_type_label() {
    sel_value = $('#submission_vessel_vessel_category').val();
    var prefix = $('#vessel_type_label_prefix').html();

    $('.vessel_type_label').html(prefix + sel_value);
  };

  $('#submission_vessel_vessel_category').on('change', function(){
    set_vessel_type_label();
  })
  set_vessel_type_label();
});
