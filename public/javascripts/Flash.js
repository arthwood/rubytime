var Flash = function() {
  this.flash = $('flash');
  this.image = this.flash.down('img').first();
  this.span = this.flash.down('span').first();
  
  this.content = this.span.innerHTML;
  this.fade = new Fade(this.flash, 1, 0, 0.2);
  this.fade.onFinish.add(new Delegate(this, this.onFadeFinish));
  
  var visible = !this.content.empty();
  
  this.flash.setVisible(visible);
  this.flash.centerH();
  
  var instances = arguments.callee.instances;

  this._id = instances.length;
  
  instances.push(this);
  
  if (visible) {
    this.hide();
  }
};

Flash.findById = function(id_) {
  this.found.id = id_;
  
  return ArtJs.ArrayUtils.detect(this.instances, this.found);
};

Flash.found = function(i) {
  return arguments.callee.id == i.getId();
};

Flash.prototype = {
  show: function(type, message) {
    this.image.src = '/images/' + type + '.png';
    this.span.innerHTML = message;
    this.flash.show();
    this.flash.centerH();
    this.flash.style.opacity = 1;
  },
  
  hide: function() {
    var code = 'Flash.findById(' + this._id + ').startHiding()';
    
    this._intervalId = setInterval(code, 5000);
  },
  
  startHiding: function() {
    this.fade.start();
  },
  
  doHide: function() {
    this.flash.hide();
  },
  
  getId: function() {
    return this._id;
  },
  
  onFadeFinish: function(arg) {
    p('onFadeFinish');
    p(arg);
    this.doHide();
  }
};

Flash.instances = new Array();
