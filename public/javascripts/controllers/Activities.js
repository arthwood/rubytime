var Activities = function() {
  this.onEditDC = this.onEdit.bind(this);
  this.onRemoveDC = this.onRemove.bind(this);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.listing = $$('.listing').first();
  $$('.listing td.actions').each(this.initActions.bind(this));
  this.filterUserSelect = $('activity_filter_user_id');
  this.filterUserSelect.onchange = this.onUserSelect.bind(this);
  this.filterProject = $('activity_filter_project_id');
  this.onProjectsD = $D(this, this.onProjects);
  this.filterDateFrom = $('activity_filter_from');
  this.filterDateTo = $('activity_filter_to');
  this.period = $('activity_filter_period');
  this.period.onchange = this.onPeriod.bind(this);
};

Activities.prototype = {
  initActions: function(i) {
    var elements = i.elements();
    var edit = elements.first();
    var remove = elements.second();
    
    edit.onclick = this.onEditDC;
    remove.onclick = this.onRemoveDC;
  },
  
  onEdit: function(e) {
    $get(e.currentTarget.href, null, this.onEditSuccessD);
    
    return false;
  },
  
  onRemove: function(e) {
    if (confirm('Really remove this role?')) {
      $del(e.currentTarget.href, null, this.onDeleteSuccessD);
    }
    
    return false;
  },
  
  onEditSuccess: function(ajax) {
    newActivity.onEdit($P(ajax.getResponseText()));
  },
  
  onDeleteSuccess: function(ajax) {
    this.listing.innerHTML = ajax.getResponseText();
    
    app.flash.show('info', 'Activity successfully deleted!');
  },
  
  onUserSelect: function(e) {
    var select = e.currentTarget;
    
    app.helper.onProjectsLoad.add(this.onProjectsD);
    app.helper.getProjects(e.currentTarget.value);
  },
  
  onProjects: function(projects) {
    this.filterProject.innerHTML = projects;
    app.helper.onProjectsLoad.remove(this.onProjectsD);
  },
  
  onPeriod: function(e) {
    var select = e.currentTarget;
    
    if (select.selectedIndex > 0) {
      var arr = select.value.split('/');
    
      this.filterDateFrom.value = arr.first();
      this.filterDateTo.value = arr.second();
    }
  }
};

Application.onLoad.add($D(null, function() {
  this.activities = new Activities();
}));
