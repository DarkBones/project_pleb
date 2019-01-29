$(document).on('turbolinks:load', ()=> {
  $('#create-transaction-button').on('click', () => {
    ToggleCardForm('#transactionmenu');
    //$(".accountmenu__name").focus();
  });

  if ($('#transaction_type').val().toLowerCase() == 'transfer') {
    $('.transactions_menu_multiple_accounts').show();
    $('.transactions_menu_single_account').hide();
  } else {
    $('.transactions_menu_multiple_accounts').hide();
    $('.transactions_menu_single_account').show();
  }

  if ($('#transaction_multiple_transactions').is(':checked')) {
    $('.transactions_menu_multiple').show();
    $('.transactions_menu_single').hide();
  } else{
    $('.transactions_menu_multiple').hide();
    $('.transactions_menu_single').show();
  }

  $('#transaction_multiple_transactions').change(function() {
    if($(this).is(":checked")) {
      $('.transactions_menu_multiple').show();
      $('.transactions_menu_single').hide();
    } else {
      $('.transactions_menu_multiple').hide();
      $('.transactions_menu_single').show();
    }
  });

  $('#transaction_type').change(function() {
    if($(this).val().toLowerCase() == 'transfer'){
      $('.transactions_menu_multiple_accounts').show();
      $('.transactions_menu_single_account').hide();
    } else {
      $('.transactions_menu_multiple_accounts').hide();
      $('.transactions_menu_single_account').show();
    }
  });

  $('.show-child-transactions').on('click', (event) => {
    $(event.currentTarget).nextAll('.child_transactions:first').slideToggle(100);

    if ($(event.currentTarget).find('img').hasClass('rotated')) {
      $(event.currentTarget).find('img').removeClass('rotated');
      $(event.currentTarget).find('img').addClass('rotated-back');
    } else {
      $(event.currentTarget).find('img').removeClass('rotated-back');
      $(event.currentTarget).find('img').addClass('rotated');
    }
  });
});