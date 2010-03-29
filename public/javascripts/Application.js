var Application = function() {
  ArtJs.globalize();
  ArtJs.doInjection();
  
  this.flash = new Flash();
  this.datePicker = new DatePicker();
};
 
Application.prototype = {
};
 
window.onload = function() {
  this.app = new Application();
};
