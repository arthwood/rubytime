var Projects = function() {
  this.onEditDC = $DC(this, this.onEdit);
  this.onRemoveDC = $DC(this, this.onRemove);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.listing = $$('.listing').first();
  this.sideForm = $$('.side_form').first();
  $$('.listing td.actions').each($DC(this, this.initActions));
}

Projects.prototype = {
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
    if (confirm('Really remove this project?')) {
      $del(e.currentTarget.href, null, this.onDeleteSuccessD);
    }
    
    return false;
  },
  
  onEditSuccess: function(ajax) {
    this.sideForm.innerHTML = ajax.getResponseText();
  },
  
  onDeleteSuccess: function(ajax) {
    this.listing.innerHTML = ajax.getResponseText();
    
    app.flash.show('info', 'Project successfully deleted!');
  }
};

Application.onLoad.add($D(null, function() {
  this.projects = new Projects();
}));
