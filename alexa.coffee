### Basic app template for AWS Lambda function for the
    Alexa appkit ###

#entry point
exports.handler = (event, context) ->
	try
	  console.log "event.session.application.applicationID=#{event.session.application.applicationID}"
	  ###
       * Uncomment this if statement and replace application.id with yours
       * to prevent other voice applications from using this function.
      ### 
	  ###if event.session.application.applicationId is not "amzn1.echo-sdk-ams.app.[unique-value-here]")
          context.fail("Invalid Application ID")
	  ###
	  
	  #new session
	  if event.session.new
	    onSessionStarted({requestId: event.request.requestId}, event.session)
	  
	  #Launch Event
	  if event.request.type is "LaunchRequest"
        onLaunch event.request,
                 event.session,
                 callback = (sessionAttributes, speechletResponse) ->
                   context.succeed(buildResponse(sessionAttributes, speechletResponse))
      
	  #Intent Request             
      else if event.request.type is "IntentRequest"
        onIntent event.request,
                 event.session,
                 callback = (sessionAttributes, speechletResponse) ->
                   context.succeed(buildResponse(sessionAttributes, speechletResponse))
      
	  #Session Ended              
      else if event.request.type is "SessionEndedRequest"
        onSessionEnded(event.request, event.session)
        context.succeed()
	  
	catch e
	    context.fail("Exception:#{e}")
		
###
  Called when the session starts.
###
onSessionStarted = (sessionStartedRequest, session) ->
  console.log("onSessionStarted requestId=#{sessionStartedRequest.requestId}, sessionId=#{session.sessionId}")


###
  Called when the user launches the app without specifying what they want.
###
onLaunch = (launchRequest, session, callback) ->
  console.log("onLaunch requestId=#{launchRequest.requestId}, sessionId=#{session.sessionId}")
  helloAlexa(callback);

### 
  Called when the user specifies an intent for this application.
###
onIntent = (intentRequest, session, callback) ->
  console.log("onIntent requestId=#{intentRequest.requestId}, sessionId=#{session.sessionId}")
	  
  intent = intentRequest.intent
  intentName = intentRequest.intent.name;
  if "SayHelloIntent" is intentName
    sayHello(intent, session, callback)
  else
	throw "Invalid intent"
	
###
  Called when the user ends the session.
  Is not called when the app returns shouldEndSession=true.
###
onSessionEnded = (sessionEndedRequest, session) ->
  console.log("onSessionEnded requestId=#{sessionEndedRequest.requestId}, sessionId=#{session.sessionId}")
    #Add cleanup logic here

###
  Helpers that build all of the responses.
###
buildSpeechletResponse = (title, output, repromptText, shouldEndSession) ->
  result =
    outputSpeech:
      type: "PlainText"
      text: output
    card:
      type: "Simple",
      title: "SessionSpeechlet - #{title}"
      content: "SessionSpeechlet - ${output}"
    reprompt:
      outputSpeech:
        type: "PlainText"
        text: repromptText
    shouldEndSession: shouldEndSession
    
buildResponse = (sessionAttributes, speechletResponse) ->
  result = 
    version: "1.0"
    sessionAttributes: sessionAttributes
    response: speechletResponse
	
#Place holder code
helloAlexa = (callback) ->
  sessionAttributes = {}	
  cardTitle = "Welcome"
  speechOutput = "Hello, what is your name?" 
  repromptText = "I'm sorry, I didn't hear you.  What is your name?"
  shouldEndSession = false
  
  callback(sessionAttributes, buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession))

sayHello = (intent, session, callback) ->
  cardTitle = "Hello #{intent.slots.Name}"
  nameSlot = intent.slots.Name
  repromptText = ""
  sessionAttributes = {}
  shouldEndSession = false
  speechOutput = ""
  
  if nameSlot
    speechOutput = "Hello #{nameSlot}, nice to meet you."
    sessionAttributes = {nameSlot: nameSlot}
    shouldEndSession = true
  else
    speechOutput = "I'm sorry, I didn't catch that.  What is your name?"
    repromptText = "I'm sorry, I didn't catch that.  What is your name?" 
  
  callback(sessionAttributes, buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession))