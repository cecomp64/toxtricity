################################################
#
#  Validation Library
#
################################################

#Validate role name/emoji pairs when using tb! roles command
exports.validate_pairs = (pairs) =>
  errorMessages = []
  console.log("PAIRS: "+pairs)
  # Process each role
  for i in [0..pairs.length-1]
    pair = pairs[i].split(",")
    name = pair[0]
    emoji = pair[1]
    if(name == undefined || emoji == undefined)
      errorMessages.push("Null values are not accepted")
    if (emoji != undefined && emoji.charCodeAt(0) <= 255) # Unicode at least...
        errorMessages.push("Invalid emoji '#{emoji}'")

  return errorMessages