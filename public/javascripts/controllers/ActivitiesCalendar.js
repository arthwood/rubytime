var ActivitiesCalendar = function() {
  this.details = $('activity_details');
  this.editor = env.user.editor;
  
  if (this.editor) {
    this.template = $('activity_template');
    
    this.onEditDC = this.onEdit.bind(this);
    this.onDeleteDC = this.onDelete.bind(this);
    this.onEditSuccessD = $D(this, this.onEditSuccess);
    this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
    this.userId = $('user_id').value;
    this.timeSpentInjectDC = this.timeSpentInject.bind(this);
    this.initActivityActionsDC = this.initActivityActions.bind(this);
    this.onDayOffDC = this.onDayOff.bind(this);
    this.onRevertDayOffDC = this.onRevertDayOff.bind(this);
    this.onDayOffSuccessD = $D(this, this.onDayOffSuccess);
    this.onRevertDayOffSuccessD = $D(this, this.onRevertDayOffSuccess);
    
    var dayOffTags = $('day_off_tag').elements();
    
    this.dayOffTag = dayOffTags.first();
    this.revertDayOffTag = dayOffTags.second();
  }
  
  this.onCellOverD = $D(this, this.onCellOver);
  this.onCellOutD = $D(this, this.onCellOut);
  
  this.detailsMC = new MouseController(this.details);
  this.detailsMC.onOut.add($D(this, this.onDetailsOut));
  
  $$('table.calendar td.enabled').each(this.activateCell.bind(this));
};

ActivitiesCalendar.prototype = {
  activateCell: function(i) {
    var mc = MouseController.find(i);
    
    if (!mc) {
      mc = new MouseController(i);
    }
    
    mc.onOver.add(this.onCellOverD);
    mc.onOut.add(this.onCellOutD);
    
    if (this.editor) {
      var dayOff = i.down('.day_off_icon a').first();
      
      dayOff && (dayOff.onclick = (dayOff.hasClass('revert') ? this.onRevertDayOffDC : this.onDayOffDC));
    }
  },
  
  onCellOver: function(e, mc) {
    var element = mc.element;
    
    if (element.hasClass('active')) {
      this.updateDetails(element);
    }
    else if (this.editor) {
      element.down('.day_off_icon').first().show();
    }
  },
  
  onCellOut: function(e, mc) {
    var element = mc.element;
    
    if (element.hasClass('active')) {
      if (!e.relatedTarget.descendantOf(this.details, true)) {
        this.hideDetails();
      }
      else {
        this.detailsCell = element;
      }
    }
    else if (this.editor) {
      element.down('.day_off_icon').first().hide();
    }
  },
  
  onDetailsOut: function(e, mc) {
    if (e.relatedTarget != this.detailsCell) {
      this.hideDetails();
    }
      
    this.detailsCell = null;
  },
  
  hideDetails: function() {
    this.details.setContent('');
    this.details.hide();
  },
  
  updateDetails: function(cell) {
    this.details.setContent(cell.getContent());
    
    var content = this.details.down('.content').first();
    
    if (this.editor) {
      content.down('.activity').each(this.initActivityActionsDC);
    }
    
    content.show();
    this.details.setPosition(cell.getPosition().add(cell.getSize().times(0.6)));
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
    var body = ajax.getResponseText();
    
    if (body.empty()) {
      app.flash.show('error', "Couldn't edit that activity");
    }
    else {
      newActivity.onEdit($P(body));
    }
  },
  
  onDeleteSuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    
    if (json.success) {
      var e = $('activity_' + activity.id);
      
      e.remove();
      
      app.flash.show('info', 'Activity successfully deleted!');
    }
    else {
      app.flash.show('error', "Couldn't delete activity!");
    }
  },
  
  onNewActivitySuccess: function(activity) {
    var cell = $(activity.date);
    
    if (cell) {
      var activities = cell.down('.activities').first();
      var e = this.template.firstElement().putAtBottom(activities);
      
      this.updateData(e, activity);
      this.updateDom(e, activity);
      this.updateCell(cell);
    }
  },
  
  onEditActivitySuccess: function(activity) {
    var e = $('activity_' + activity.id);
    var cell = e.up('.cell');
    var date = cell.id;
    
    this.updateData(e, activity);
    
    if (activity.date != date) {
      var targetCell = $(activity.date);
      
      if (targetCell) {
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
  
  updateData: function(e, activity) {
    var project = e.down('.project').first();
    var comments = e.down('.comments').first();
    
    project.down('.name').first().setContent(activity.project.name);
    project.down('.time').first().setContent(activity.time_spent);
    comments.setContent(activity.comments);
  },
  
  updateCell: function(cell, day_off_tag) {
    this.updateTotal(cell);
    
    if (cell.down('.activity').empty()) {
      cell.removeClass('active');
      
      var icon = cell.down('.day_off_icon').first();
      
      this.dayOffTag.putAtBottom(icon).onclick = this.onDayOffDC;
    }
    else {
      var a = cell.down('.day_off_icon a').first();
      
      a && a.remove();
      
      cell.addClass('active');
      cell.removeClass('day_off');
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
  
  onDayOff: function(e) {
    var a = e.currentTarget;
    
    $post(a.href, {date: a.up('td').id, user_id: this.userId}, this.onDayOffSuccessD);
    
    return false;
  },
  
  onDayOffSuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    var cell = $(json.date); 
    
    cell.addClass('day_off');
    
    this.revertDayOffTag.replace(this.cellDayOffLink(cell)).onclick = this.onRevertDayOffDC;
  },
  
  onRevertDayOff: function(e) {
    var a = e.currentTarget;
    
    $del(a.href, {date: a.up('td').id, user_id: this.userId}, this.onRevertDayOffSuccessD);
    
    return false;
  },
  
  onRevertDayOffSuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    var cell = $(json.date);
    
    cell.removeClass('day_off');
    
    this.dayOffTag.replace(this.cellDayOffLink(cell)).onclick = this.onDayOffDC;
  },
  
  cellDayOffLink: function(cell) {
    return cell.down('.day_off_icon').first().firstElement();
  }
};

Application.onLoad.add($D(null, function() {
  this.activitiesCalendar = new ActivitiesCalendar();
  this.newActivity && (this.newActivity.controller = this.activitiesCalendar);
}));
