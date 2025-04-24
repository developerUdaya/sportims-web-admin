$(document).ready(function () {
    var bannercarousel = $('.bannercarousel');
        bannercarousel.owlCarousel({
            loop: false,
            nav: false,
            dots: false,
            smartSpeed: 450,
            autoplay: false,
            autoplayTimeout: 5000,
            margin: 20,
            responsive: {
                320: { items: 1},
                480: { items: 1},
                600: { items: 1},
                960: { items: 1},
                1200: { items:1}
            }
        });


    $(".accordion .accordion-title").eq(0).addClass('active');
    $(".accordion .accordion-detail").eq(0).slideDown('10');
    $(".accordion .accordion-title").click(function () {      
            $(this).next(".accordion-detail").slideToggle("10").siblings(".accordion-detail:visible").slideUp("10");
            $(this).toggleClass("active");
            $(this).siblings(".accordion-title").removeClass("active");
        });
    
    $('.fancybox1').fancybox();
    AOS.init();
  //$(".mobileNavWrapper ul>li,.navbar ul>li").find("ul").parent().prepend('<span class="hasSub"></span>');
  // $(".mobileNavWrapper ul li .hasSub,.navbar ul>li .hasSub").click(function(){
  //   $(this).siblings("ul").slideToggle();
  // });
  $('#header .mobilesearch .iconsearch').click(function(){
        $('#header .mobilesearch .midform').slideToggle();
    });
  
});
$(document).ready(function(){
    $('#headersearch').on('click', function(event) {                    
        $('#search').addClass('open');
        $('#search > form > input[type="search"]').focus();
    });            
    $('#search, #search button.close').on('click keyup', function(event) {
        if (event.target == this || event.target.className == 'close' || event.keyCode == 27) {
            $(this).removeClass('open');
        }
    });            
});


$(document).ready(function(){
  $(".navbar-nav li>a").on('click', function() {
    if (this.hash !== "") {
    var hash = this.hash;
  $('html, body').animate({scrollTop: $(hash).offset().top - 80}, 800, function(){   
        window.location.hash = hash;
      });
    }
  });
// sidemu js
$('.openmenu-toggler').click(function(e){
    $('#sidenavmenu').addClass('menuactive');
    e.stopPropagation();
});
$('#sidenavinner').click(function(e){
    e.stopPropagation();
});
$('.closetogglerbtn,html').click(function(e){
   $('#sidenavmenu').removeClass('menuactive'); 
})

});

 $(window).scroll(function(){ 
      if ($(this).scrollTop() > 150) { 
   $('#header').addClass("fixed");
         // $('#header+*').css('padding-top', $('#header').outerHeight() + 'px');
       }else{
   $('#header').removeClass("fixed");     
         // $('#header+*').css('padding-top', '0');
       } 
   });

// Back to top button
var $backToTop = $("#backtotop");
 $backToTop.hide();


// $(window).on('scroll', function() {
// if ($(this).scrollTop() > 100) {
// $backToTop.fadeIn();
// } else {
// $backToTop.fadeOut();
// }
// });

$backToTop.on('click', function(e) {
$("html, body").animate({scrollTop: 0}, 500);
});

$(document).ready(function(){
    // Add minus icon for collapse element which is open by default
    $(".collapse.show").each(function(){
      $(this).prev(".card-header").find(".fa").addClass("fa-minus").removeClass("fa-plus");
    });
    
    // Toggle plus minus icon on show hide of collapse element
    $(".collapse").on('show.bs.collapse', function(){
      $(this).prev(".card-header").find(".fa").removeClass("fa-plus").addClass("fa-minus");
    }).on('hide.bs.collapse', function(){
      $(this).prev(".card-header").find(".fa").removeClass("fa-minus").addClass("fa-plus");
    });
});

// count Down timer
// const daysEl = document.getElementById('days');
// const hoursEl = document.getElementById('hours');
// const minsEL = document.getElementById('mins');
// const secondsEL = document.getElementById('seconds');

// const newYears = '30 January 2023 10:00:00 ';

// function countdown() {
//     const newYearsDate = new Date(newYears);
//     const currentDate = new Date();

//     const totalSeconds = (newYearsDate - currentDate) /1000;
//     const minutes = Math.floor(totalSeconds/ 60) % 60;
//     const hours = Math.floor(totalSeconds /3600) % 24;
//     const days = Math.floor(totalSeconds /3600/ 24);
//     const seconds = Math.floor(totalSeconds) % 60;
    
    
// daysEl.innerText = days;
// hoursEl.innerText = hours;
// minsEL.innerText = minutes;
// secondsEL.innerText = seconds;

    
// }

// setInterval(countdown, 1000);

// counter increament on scroll
var counted = 0;
$(window).scroll(function() {

  var oTop = $('#counter').offset().top - window.innerHeight;
  if (counted == 0 && $(window).scrollTop() > oTop) {
    $('.count').each(function() {
      var $this = $(this),
        countTo = $this.attr('data-count');
      $({
        countNum: $this.text()
      }).animate({
          countNum: countTo
        },

        {

          duration: 2000,
          easing: 'swing',
          step: function() {
            $this.text(Math.floor(this.countNum));
          },
          complete: function() {
            $this.text(this.countNum);
            //alert('finished');
          }

        });
    });
    counted = 1;
  }

});