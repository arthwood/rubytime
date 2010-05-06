var Users = $E(Resources, function() {
  arguments.callee.super('user');
  
  this.initForm();
  this.updateSelect();
}, {
  initForm: function() {
    this.userType = $('user_group');
    this.userRole = $('user_role_id');
    this.userRoleItem = this.userRole.up('.item');
    this.client = $('user_client_id');
    this.clientItem = this.client.up('.item');
  
    this.selects = [{item: this.userRoleItem, input: this.userRole}, {item: this.clientItem, input: this.client}];

    this.userType.onchange = this.onUserTypeChange.bind(this);
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
  
  doRemove: function(e) {
    this.listing = e.currentTarget.up('.listing');
    
    $del(e.currentTarget.href, null, this.onDeleteSuccessD);
  },
  
  onEditSuccess: function(ajax) {
    arguments.callee.super(ajax);
    
    this.initForm();
    this.updateSelect();
  },

  onAddNewSuccess: function(ajax) {
    arguments.callee.super(ajax);

    this.initForm();
    this.updateSelect();
  }
});

Application.onLoad.add($D(null, function() {
  this.users = new Users();
}));
