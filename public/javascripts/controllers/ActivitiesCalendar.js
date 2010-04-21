var ActivitiesCalendar = function() {
  this.details = $('activity_details');
  this.onActiveCellOverDC = this.onActiveCellOver.bind(this);
  this.details.onmouseout = this.onDetailsOut.bind(this);
  this.onEditDC = this.onEdit.bind(this);
  this.onDeleteDC = this.onDelete.bind(this);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.userSelect = $('user_id');
  
  $$('table.calendar td.active').each(this.initDetails.bind(this));
};

ActivitiesCalendar.prototype = {
  initDetails: function(i) {
    i.onmouseover = this.onActiveCellOverDC;
  },
  
  onActiveCellOver: function(e) {
    var cell = e.currentTarget;
    
    $MBC.update(e, cell);
    
    if ($MBC.enteredLandmark) {
      this.details.innerHTML = cell.innerHTML;
      var content = this.details.down('.content').first();
      var actions = content.down('.actions').first();
      var links = actions.down('a');
      
      links.first().onclick = this.onEditDC;
      links.second().onclick = this.onDeleteDC;
      links.second().href += ('&user_id=' + this.userSelect.value);
      content.show();
      this.details.setPosition(cell.getPosition(true));
      this.details.show();
    }
  },
  
  onDetailsOut: function(e) {
    var cell = e.currentTarget;
    
    $MBC.update(e, cell);
    
    if ($MBC.leftLandmark) {
      this.details.innerHTML = '';
      this.details.hide();
    }
  },
  
  onEdit: function(e) {
    var link = e.currentTarget;
    
    $get(link.href, null, this.onEditSuccessD);
    
    return false;
  },
  
  onDelete: function(e) {
    if (confirm('Really remove this activity?')) {
      this.doRemove(e);
    }
    
    return false;
  },
  
  doRemove: function(e) {
    $del(e.currentTarget.href, null, this.onDeleteSuccessD);
  },
  
  onEditSuccess: function(ajax) {
    newActivity.onEdit($P(ajax.getResponseText()));
  },
  
  onDeleteSuccess: function(ajax) {
    app.flash.show('info', 'Activity successfully deleted!');
  },
  
  onEditActivitySuccess: function(activity) {
    
  }
};

Application.onLoad.add($D(null, function() {
  this.activitiesCalendar = new ActivitiesCalendar();
}));
