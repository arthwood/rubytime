var Activities = function() {
  this.onEditDC = $DC(this, this.onEdit);
  this.onRemoveDC = $DC(this, this.onRemove);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.listing = $$('.listing').first();
  $$('.listing td.actions').each($DC(this, this.initActions));
  this.filterUserSelect = $('filter_user_id');
  this.filterUserSelect.onchange = $DC(this, this.onUserSelect);
  this.filterProject = $('filter_project_id');
  this.onProjectsD = $D(this, this.onProjects);
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
    app.helper.onProjectsLoad.add(this.onProjectsD);
    app.helper.getProjects(e.currentTarget.value);
  },
  
  onProjects: function(projects) {
    this.filterProject.innerHTML = projects;
    app.helper.onProjectsLoad.remove(this.onProjectsD);
  }
};

Application.onLoad.add($D(null, function() {
  this.activities = new Activities();
}));
