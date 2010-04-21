var ActivitiesCalendar = function() {
  this.details = $('activity_details');
  this.onActiveCellOverDC = this.onActiveCellOver.bind(this);
  this.details.onmouseout = this.onDetailsOut.bind(this);
  this.onEditDC = this.onEdit.bind(this);
  this.onDeleteDC = this.onDelete.bind(this);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.userSelect = $('user_id');
  this.timeSpentInjectDC = this.timeSpentInject.bind(this);
  this.detectDayDC = this.detectDay.bind(this);
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
    newActivity.onEdit(this, $P(ajax.getResponseText()));
  },
  
  onDeleteSuccess: function(ajax) {
    app.flash.show('info', 'Activity successfully deleted!');
  },
  
  onEditActivitySuccess: function(activity) {
    var e = $('activity_' + activity.id);
    var date = e.up('.day').innerHTML.trim();
    var project = e.down('.project').first();
    var comments = e.down('.comments').first();
    
    project.innerHTML = activity.project.name;
    project.down('span').first().innerHTML = activity.time_spent;
    comments.innerHTML = activity.comments;
    
    if (activity.date == date) {
      this.updateTotal(e);
    }
    else {
      this.dayToDetect = activity.date;
      
      var day = $$('.calendar .day').detect(this.detectDayDC);
      
      if (day) {
        day.up('.cell').down('.activities').first().appendChild(e);
        this.updateTotal(e);
      }
      else {
        this.updateTotal(e);
        e.remove();
      }
    }
  },
  
  detectDay: function(e) {
    return this.dayToDetect == e.getContent().trim();
  },
  
  updateTotal: function(e) {
    var content = e.up('.content');
    var times = content.down('.activity .project span').map(ElementUtils.getContentDC).inject(0, this.timeSpentInjectDC);
    var total = content.down('.total').first();
    
    total.setContent(DateUtils.minutesToHM(total));
  },
  
  timeSpentInject: function(mem, i) {
    return mem + DateUtils.hmToMinutes(i);
  }
};

Application.onLoad.add($D(null, function() {
  this.activitiesCalendar = new ActivitiesCalendar();
}));
