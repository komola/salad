var fs = require("fs");
var path = require("path");

var root = path.join(__dirname, "lib/server/salad.js");

if(fs.existsSync(root))
{
  module.exports = require(root);
}
else
{
  require("coffee-script/register");
  root = path.join(__dirname, "src/server/salad");
  module.exports = require(root);
}
