var Clients = function() {
  this.onEditDC = $DC(this, this.onEdit);
  this.onRemoveDC = $DC(this, this.onRemove);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.onAddNewDC = $DC(this, this.onAddNew);
  this.onAddNewSuccessD = $D(this, this.onAddNewSuccess);
  this.listing = $$('.listing').first();
  this.sideForm = $$('.side_form').first();
  $$('.listing td.actions').each($DC(this, this.initActions));
}

Clients.prototype = {
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
    if (confirm('Really remove this client?')) {
      $del(e.currentTarget.href, null, this.onDeleteSuccessD);
    }
    
    return false;
  },
  
  onEditSuccess: function(ajax) {
    this.sideForm.innerHTML = ajax.getResponseText();
    this.initAddNewLink();
  },
  
  onDeleteSuccess: function(ajax) {
    this.listing.innerHTML = ajax.getResponseText();
    
    app.flash.show('info', 'Client successfully deleted!');
  },
  
  initAddNewLink: function() {
    this.sideForm.down('h2 span a').first().onclick = this.onAddNewDC;
  },
  
  onAddNew: function(e) {
    $get(e.currentTarget.href, null, this.onAddNewSuccessD);
    
    return false;
  },
  
  onAddNewSuccess: function(ajax) {
    this.sideForm.innerHTML = ajax.getResponseText();
  }
};

Application.onLoad.add($D(null, function() {
  this.clients = new Clients();
}));
