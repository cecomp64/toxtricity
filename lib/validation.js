// Generated by CoffeeScript 2.7.0
(function() {
  //###############################################

  //  Validation Library

  //###############################################

  //Validate role name/emoji pairs when using tb! roles command
  exports.validate_pairs = (pairs) => {
    var emoji, errorMessages, i, j, name, pair, ref;
    errorMessages = [];
    console.log("PAIRS: " + pairs);
// Process each role
    for (i = j = 0, ref = pairs.length - 1; (0 <= ref ? j <= ref : j >= ref); i = 0 <= ref ? ++j : --j) {
      pair = pairs[i].split(",");
      name = pair[0];
      emoji = pair[1];
      if (name === void 0 || emoji === void 0) {
        errorMessages.push("Null values are not accepted");
      }
      if (emoji !== void 0 && emoji.charCodeAt(0) <= 255) { // Unicode at least...
        errorMessages.push(`Invalid emoji '${emoji}'`);
      }
    }
    return errorMessages;
  };

}).call(this);