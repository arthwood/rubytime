var ActivitiesCalendar = function() {
  this.details = $('activity_details');
  this.onActiveCellOverDC = this.onActiveCellOver.bind(this);
  this.details.onmouseout = this.onDetailsOut.bind(this);
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
      this.details.down('ul').first().show();
      this.details.setPosition(cell.getPosition());
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
  }
};

Application.onLoad.add($D(null, function() {
  this.activitiesCalendar = new ActivitiesCalendar();
}));
