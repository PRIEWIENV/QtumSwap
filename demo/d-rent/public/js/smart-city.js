jQuery(document).ready(function($){
	//open popup
  console.log("loaded");
  
  $('.industrie').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-industrie').addClass('is-visible');
  });
  $('.software').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-software').addClass('is-visible');
  });
  $('.banking').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-banking').addClass('is-visible');
  });
  $('.telco').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-telco').addClass('is-visible');
  });
  $('.gesundheit').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-gesundheit').addClass('is-visible');
  });
  $('.luftfahrt').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-luftfahrt').addClass('is-visible');
  });
  $('.energie').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-energie').addClass('is-visible');
  });
  $('.transport').on('click', function(event){
    event.preventDefault();
    $('.cd-popup-transport').addClass('is-visible');
  });
  
	//close popup
	$('.cd-popup').on('click', function(event){
		if( $(event.target).is('.cd-popup-close') || $(event.target).is('.cd-popup') ) {
			event.preventDefault();
			$(this).removeClass('is-visible');
		}
	});
	//close popup when clicking the esc keyboard button
	$(document).keyup(function(event){
    	if(event.which=='27'){
    		$('.cd-popup').removeClass('is-visible');
	    }
    });
  
  // TODO if modal open then pop out items
});