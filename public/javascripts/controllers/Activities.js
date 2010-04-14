var Activities = function() {
  this.onEditDC = $DC(this, this.onEdit);
  this.onRemoveDC = $DC(this, this.onRemove);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.listing = $$('.listing').first();
  $$('.listing td.actions').each($DC(this, this.initActions));
  this.filterUserSelect = $('filter_user_id');
  this.filterUserSelect.onchange = $DC(this, this.onUserSelect);
  this.onProjectsSuccessD = $D(this, this.onProjectsSuccess);
  this.filterProject = $('filter_project_id');
  this.projectToOptionDC = $DC(this, this.projectToOption);
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
    $get(e.currentTarget.href, this.onEditSuccessD);
    
    return false;
  },
  
  onRemove: function(e) {
    if (confirm('Really remove this role?')) {
      $del(e.currentTarget.href, null, this.onDeleteSuccessD);
    }
    
    return false;
  },
  
  onEditSuccess: function(ajax) {
  },
  
  onDeleteSuccess: function(ajax) {
    this.listing.innerHTML = ajax.getResponseText();
    
    app.flash.show('info', 'Activity successfully deleted!');
  },
  
  onUserSelect: function(e) {
    $get('projects.json', {user_id: e.currentTarget.value}, this.onProjectsSuccessD);
  },
  
  onProjectsSuccess: function(ajax) {
    this.filterProject.innerHTML = this.buildProjectOptions(eval(ajax.getResponseText()));
  },
  
  buildProjectOptions: function(data) {
    return data.map(this.projectToOptionDC).join('');
  },
  
  projectToOption: function(i, idx) {
    return $B('option', {value: i.id}, i.name);
  }
};

Application.onLoad.add($D(null, function() {
  this.activities = new Activities();
}));
