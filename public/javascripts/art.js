var ArtJs_version = {};

ArtJs_version['Microsoft Internet Explorer'] = 'ie';
ArtJs_version['Netscape'] = 'ff';

var ArtJs_package = ArtJs_version[window.navigator.appName];

document.write('<script src="/javascripts/art.' + ArtJs_package + '.js" type="text/javascript"></script>');
