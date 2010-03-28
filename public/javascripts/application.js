var Application = function() {
  ArtJs.globalize();
  ArtJs.doInjection();
  
  //this.initFlash();
  this.datePicker = new DatePicker();
};

Application.prototype = {
  initFlash: function() {
    this.flash = $('flash');
    
    var content = this.flash.innerHTML;
    var show = !content.empty();
    
    this.flash.setVisible(show);
    
    this.flash.centerH();
  }  
};

window.onload = function() {
  this.app = new Application();
};
