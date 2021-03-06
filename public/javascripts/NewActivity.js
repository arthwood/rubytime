var NewActivity = function() {
  this.container = $('activity');
  this.menu = $('menu');
  this.newActivityUserId = $('new_activity_user_id');
  
  this.addNewActivity = $$('.add_activity').first();
  this.addNewActivity.onclick = this.onAddNewActivity.bind(this);
  
  this.onNewActivityDC = this.onNewActivity.bind(this, true);
  this.onNewActivitySuccessD = $D(this, this.onNewActivitySuccess);
  this.onCancelNewActivityDC = this.onCancelNewActivity.bind(this, true);
  
  this.onEditActivityDC = this.onEditActivity.bind(this, true);
  this.onEditActivitySuccessD = $D(this, this.onEditActivitySuccess);
  this.onCancelEditActivityDC = this.onCancelEditActivity.bind(this, true);
  
  this.initNewForm();
  
  app.onResize.add($D(this, this.onResize));
  
  this.updateLayout();
};

NewActivity.prototype = {
  onResize: function(e) {
    this.updateLayout();
  },
  
  initNewForm: function() {
    var form = this.newForm = this.container.down('form').first();
    
    form.onsubmit = this.onNewActivityDC;
    
    var cancelNewActivity = form.down('.item.last a').first();
    
    cancelNewActivity.onclick = this.onCancelNewActivityDC;
  },
  
  initEditForm: function() {
    var form = this.editForm = this.container.down('form').second();
    
    form.onsubmit = this.onEditActivityDC;
    
    var cancelEditActivity = form.down('.item.last a').first();
    
    cancelEditActivity.onclick = this.onCancelEditActivityDC;
    
    app.datePicker.initField(form.down('.datepicker').first());
  },

  updateLayout: function() {
    this.updateContainerPosition();
  },
  
  updateContainerPosition: function() {
    var w = this.container.getSize(true).x;
    var rect = this.menu.getBounds();
    
    this.container.setPosition(rect.getRightBottom().sub(new Point(w, 0)));
  },
  
  onAddNewActivity: function(e) {
    this.controller && this.newActivityUserId && (this.newActivityUserId.value = this.controller.userId);
    this.displayContainer();
    
    return false;
  },
  
  onCancelNewActivity: function(a) {
    app.datePicker.calendar.hide();
    this.container.hide();
    
    return false;
  },
  
  onCancelEditActivity: function(a) {
    app.datePicker.calendar.hide();
    this.restoreForm();
    
    return false;
  },
  
  restoreForm: function() {
    this.newForm.show();
    this.editForm.remove();
    this.editForm = null;
    this.container.hide();
  },
  
  onEdit: function(form) {
    if (this.editForm) {
      form.replace(this.editForm);
    }
    else {
      form.putAfter(this.newForm);
    }
    
    this.newForm.hide();
    this.displayContainer();
    this.initEditForm();
  },
  
  onNewActivity: function(form) {
    $post(form.action, form.serialize(), this.onNewActivitySuccessD);
    
    return false;
  },
  
  onNewActivitySuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    
    if (json.success) {
      this.container.hide();
      
      app.flash.show('info', 'Activity successfully created!');
      
      this.controller && this.controller.onNewActivitySuccess(json.activity);
    }
    else {
      $P(json.html).replace(this.newForm);
      this.initNewForm();
      app.flash.show('error', 'There were errors while creating the activity');
    }
  },
  
  onEditActivity: function(form) {
    $put(form.action, form.serialize(), this.onEditActivitySuccessD);
    
    return false;
  },
  
  onEditActivitySuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    
    if (json.success) {
      this.restoreForm();
      
      app.flash.show('info', 'Activity successfully updated!');
      
      this.controller && this.controller.onEditActivitySuccess(json.activity);
    }
    else {
      $P(json.html).replace(this.editForm);
      this.initEditForm();
      app.flash.show('error', 'There were errors while updating the activity');
    }
  },
  
  displayContainer: function() {
    this.container.show();
    this.updateContainerPosition();
  }
};

Application.onLoad.add($D(null, function() {
  this.newActivity = new NewActivity();
}));
