var Users = function() {
  this.onEditDC = $DC(this, this.onEdit);
  this.onRemoveDC = $DC(this, this.onRemove);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.editedListing = null;
  this.sideForm = $$('.side_form').first();
  this.initForm();
  this.updateSelect();
  
  $$('.listing td.actions').each($DC(this, this.initActions));
}

Users.prototype = {
  initForm: function() {
    this.userType = $('user_group');
    this.userRole = $('user_role_id');
    this.userRoleItem = this.userRole.up('.item');
    this.client = $('user_client_id');
    this.clientItem = this.client.up('.item');
  
    this.selects = [{item: this.userRoleItem, input: this.userRole}, {item: this.clientItem, input: this.client}];

    this.userType.onchange = $DC(this, this.onUserTypeChange);
  },
  
  onUserTypeChange: function(e) {
    this.updateSelect();
  },

  updateSelect: function() {
    var value = parseInt(this.userType.value);
    var showSelect = this.selects[value];
    var hideSelect = this.selects[(value + 1) % 2];
    
    hideSelect.input.disable();
    hideSelect.item.hide();
    showSelect.input.enable();
    showSelect.item.show();
  },
  
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
    if (confirm('Really remove this user?')) {
      this.editedListing = e.currentTarget.up('.listing');
      $del(e.currentTarget.href, null, this.onDeleteSuccessD);
    }
    
    return false;
  },
  
  onEditSuccess: function(ajax) {
    this.sideForm.innerHTML = ajax.getResponseText();
    this.initForm();
    this.updateSelect();
  },
  
  onDeleteSuccess: function(ajax) {
    this.editedListing.innerHTML = ajax.getResponseText();
  }
};

Application.onLoad.add($D(null, function() {
  this.users = new Users();
}));
