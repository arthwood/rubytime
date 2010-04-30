var Resources = function(name, plural) {
  this.name = name;
  this.plural = plural;
  this.onEditDC = this.onEdit.bind(this);
  this.onRemoveDC = this.onRemove.bind(this);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.onAddNewDC = this.onAddNew.bind(this);
  this.initActionsDC = this.initActions.bind(this);
  this.onAddNewSuccessD = $D(this, this.onAddNewSuccess);
  this.listing = $$('.listing').first();
  this.sideForm = $$('.side_form').first();
  this.init();
};

Resources.prototype = {
  init: function() {
    $$('.listing td.actions').each(this.initActionsDC);
  },
  
  initActions: function(i) {
    var elements = i.elements();
    var edit = elements.first();
    var remove = elements.second();
    
    edit && (edit.onclick = this.onEditDC);
    remove && (remove.onclick = this.onRemoveDC);
  },
  
  onEdit: function(e) {
    $get(e.currentTarget.href, null, this.onEditSuccessD);
    
    return false;
  },
  
  onRemove: function(e) {
    if (confirm('Really remove this ' + this.name + '?')) {
      this.doRemove(e);
    }
    
    return false;
  },
  
  doRemove: function(e) {
    $del(e.currentTarget.href, null, this.onDeleteSuccessD);
  },
  
  onEditSuccess: function(ajax) {
    this.sideForm.setContent(ajax.getResponseText());
    this.initAddNewLink();
  },
  
  onDeleteSuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    var name = this.name.capitalize();
    
    if (json.success) {
      this.listing.setContent(json.html);
      
      app.flash.show('info', name + ' successfully deleted!');
    }
    else {
      app.flash.show('error', "Couldn't delete " + name + "!");
    }
  },
  
  initAddNewLink: function() {
    this.sideForm.down('h2 span a').first().onclick = this.onAddNewDC;
  },
  
  onAddNew: function(e) {
    $get(e.currentTarget.href, null, this.onAddNewSuccessD);
    
    return false;
  },
  
  onAddNewSuccess: function(ajax) {
    this.sideForm.setContent(ajax.getResponseText());
  }
};
