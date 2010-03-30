var Application = function() {
  ArtJs.globalize();
  ArtJs.doInjection();
  
  this.flash = new Flash();
  this.datePicker = new DatePicker();
  this.layout = new Layout();
  
  this.initUI();
};

Application.prototype = {
  initUI: function() {
    // available only when logged in 
    this.newActivityContainer = $('new_activity');
  
    if (this.newActivityContainer) {
      this.addNewActivity = $$('.add_activity').first();
      this.addNewActivity.onclick = $DC(this, this.onAddNewActivity);
    }
  },
  
  onAddNewActivity: function(e) {
    this.newActivityContainer.toggle();
    
    return false;
  }
};
 
window.onload = function() {
  this.app = new Application();
};
