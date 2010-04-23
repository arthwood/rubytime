var ActivitiesCalendar = function() {
  this.details = $('activity_details');
  this.template = $('activity_template');
  
  this.onCellOverD = $D(this, this.onCellOver);
  this.onCellOutD = $D(this, this.onCellOut);
  
  this.detailsMC = new MouseController(this.details);
  this.detailsMC.onOut.add($D(this, this.onDetailsOut));
  
  this.onEditDC = this.onEdit.bind(this);
  this.onDeleteDC = this.onDelete.bind(this);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.userSelect = $('user_id');
  this.timeSpentInjectDC = this.timeSpentInject.bind(this);
  this.detectDayDC = this.detectDay.bind(this);
  this.initActivityActionsDC = this.initActivityActions.bind(this);
  
  $$('table.calendar td.active').each(this.activateCell.bind(this));
};

ActivitiesCalendar.prototype = {
  activateCell: function(i) {
    var mc = MouseController.find(i);
    
    if (!mc) {
      mc = new MouseController(i);
    }
    
    mc.onOver.add(this.onCellOverD);
    mc.onOut.add(this.onCellOutD);
  },
  
  dectivateCell: function(i) {
    var mc = MouseController.find(i);
    
    mc.onOver.remove(this.onCellOverD);
    mc.onOut.remove(this.onCellOutD);
  },
  
  onCellOver: function(e, mc) {
    this.updateDetails(mc.element);
  },
  
  onCellOut: function(e, mc) {
    if (!e.relatedTarget.descendantOf(this.details, true)) {
      this.hideDetails();
    }
    else {
      this.detailsCell = mc.element;
    }
  },
  
  onDetailsOut: function(e, mc) {
    if (e.relatedTarget != this.detailsCell) {
      this.hideDetails();
    }
      
    this.detailsCell = null;
  },
  
  hideDetails: function() {
    this.details.innerHTML = '';
    this.details.hide();
  },
  
  updateDetails: function(cell) {
    this.details.innerHTML = cell.innerHTML;
    
    var content = this.details.down('.content').first();
    
    content.down('.activity').each(this.initActivityActionsDC);
    content.show();
    this.details.setPosition(cell.getPosition(true).add(cell.getSize().times(0.6)));
    this.details.show();
  },
  
  initActivityActions: function(activity) {
    var actions = activity.down('.actions').first();
    var links = actions.down('a');
    
    links.first().onclick = this.onEditDC;
    links.second().onclick = this.onDeleteDC;
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
  
  onNewActivitySuccess: function(activity) {
    this.dayToDetect = activity.date;
    
    var day = $$('.calendar .day').detect(this.detectDayDC);
    
    if (day) {
      var cell = day.up('.cell');
      var activities = cell.down('.activities').first();
      var e = this.template.elements().first().clone(true);
      
      activities.appendChild(e);
      
      this.updateData(e, activity);
      this.updateDom(e, activity);
      this.updateCell(cell);
    }
  },
  
  onEditActivitySuccess: function(activity) {
    var e = $('activity_' + activity.id);
    var cell = e.up('.cell');
    var date = cell.down('.day').first().innerHTML.trim();
    
    this.updateData(e, activity);
    
    if (activity.date != date) {
      this.dayToDetect = activity.date;
      
      var day = $$('.calendar .day').detect(this.detectDayDC);
      
      if (day) {
        var targetCell = day.up('.cell');
        var targetActivities = targetCell.down('.activities').first();
        
        targetActivities.appendChild(e);
        
        this.updateCell(targetCell);
      }
      else {
        e.remove();
      }
    }
    
    this.updateCell(cell);
  },
  
  detectDay: function(e) {
    return this.dayToDetect == e.getContent().trim();
  },
  
  updateData: function(e, activity) {
    var project = e.down('.project').first();
    var comments = e.down('.comments').first();
    
    project.down('.name').first().innerHTML = activity.project.name;
    project.down('.time').first().innerHTML = activity.time_spent;
    comments.innerHTML = activity.comments;
  },
  
  updateCell: function(cell) {
    this.updateTotal(cell);
    
    if (cell.down('.activity').empty()) {
      cell.removeClass('active');
      this.dectivateCell(cell);
    }
    else {
      cell.addClass('active');
      this.activateCell(cell);
    }
  },

  updateDom: function(e, activity) {
    var id = activity.id;
    
    e.id = 'activity_' + id;
      
    var actions = e.down('.actions a');
    var editLink = actions.first();
    var deleteLink = actions.first();
      
    editLink.href = '/activities/' + id + '/edit';
    actions.href = '/activities/' + id;
  },
  
  updateTotal: function(cell) {
    var times = cell.down('.activity .project .time');
    var values = times.map(ElementUtils.getContentDC);
    var minutes = values.inject(0, this.timeSpentInjectDC);
    var total = cell.down('.total span').first();
    
    total.setContent(DateUtils.minutesToHM(minutes));
  },
  
  timeSpentInject: function(mem, i) {
    return mem + DateUtils.hmToMinutes(i.trim());
  },
  
  getCurrentUserId: function() {
    return this.userSelect.value;
  }
};

Application.onLoad.add($D(null, function() {
  this.activitiesCalendar = new ActivitiesCalendar();
  this.newActivity.controller = this.activitiesCalendar;
}));
