################################################
#
#  Validation Library
#
################################################

#Validate role name/emoji pairs when using tb! roles command
exports.validate_pairs = (words) =>
  errorMessages = []
  ne_pairs = []
  console.log("Words: " + words)
  pairs = words.map((word) => 
    return word.trim()
  ).join(" ").split(",")

  # Process each role
  for i in [0..pairs.length-1]
    pair = pairs[i].trim().split(" ")
    name = pair[1].trim()
    emoji = pair[0].trim()

    if(name == undefined || emoji == undefined)
      errorMessages.push("Null values are not accepted")
    #if (emoji != undefined && emoji.charCodeAt(0) <= 255) # Unicode at least...
    #    errorMessages.push("Invalid emoji '#{emoji}'")

    ne_pairs.push({name: name, emoji: emoji})

  if(errorMessages.length > 0)
    console.log("Error Validating Roles: "+errorMessages)
  else
    console.log("Name: " + name + "emoji" + emoji) if(name != null && emoji != null)
  
  return ne_pairs