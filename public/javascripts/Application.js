var Application = function() {
  ArtJs.globalize();
  ArtJs.doInjection();
  
  this.flash = new Flash();
  this.datePicker = new DatePicker();
  
  this.newActivityContainer = $('new_activity');
  this.addNewActivity = $$('.add_activity').first();
  this.addNewActivity.onclick = $DC(this, this.onAddNewActivity);
};
 
Application.prototype = {
  onAddNewActivity: function(e) {
    this.newActivityContainer.toggle();
    
    return false;
  }
};
 
window.onload = function() {
  this.app = new Application();
};
