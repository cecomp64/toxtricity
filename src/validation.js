//###############################################
//  Validation Library
//###############################################

//Validate role name/emoji pairs when using tb! roles command
exports.validate_pairs = (words) => {
  var emoji, errorMessages, i, j, name, ne_pairs, pair, pairs, ref;

  errorMessages = [];
  ne_pairs = [];

  console.log("Words: " + words);

  // Separate string into pairs
  pairs = words.map((word) => {
    return word.trim();
  }).join(" ").split(",");

  // Process each role
  pairs.forEach(_pair => {
    pair = _pair.trim().split(" ");
    name = pair[1].trim();
    emoji = pair[0].trim();

    if (name === void 0 || emoji === void 0) {
      errorMessages.push("Null values are not accepted");
    }

    //if (emoji != undefined && emoji.charCodeAt(0) <= 255) # Unicode at least...
    //    errorMessages.push("Invalid emoji '#{emoji}'")
    
    ne_pairs.push({
      name: name,
      emoji: emoji
    });
  });

  // Report errors
  if (errorMessages.length > 0) {
    console.log("Error Validating Roles: " + errorMessages);
  } else {
    if (name !== null && emoji !== null) {
      console.log("Name: " + name + "emoji" + emoji);
    }
  }
  
  return ne_pairs;
};

