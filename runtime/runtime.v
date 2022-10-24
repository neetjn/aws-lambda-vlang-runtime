import http

struct LambdaRuntime {
  mut:
    url string
    functionCodePath string
    response string
    rawEventData Response
    eventPayload string
    handler string
}

fn (rt LambdaRuntime) resetResponse () {
  rt.response = ""
}

fn (rt LambdaRuntime) addToResponse (response) {
  this.response = response
}

fn (rt LambdaRuntime) flushResponse () {
  requestId := rt.requestId
  response := rt.response
  http.post('/2018-06-01/runtime/invocation/$requestId/response', response)
  rt.resetResponse()
}

fn (rt LambdaRuntime) getNextEventData () ?Response {
  rawEventData = http.get('/2018-06-01/runtime/invocation/next')
  eventData := rt.rawEventData.text
  requestId := rt.rawEventData.header.data['lambda-runtime-aws-request-id'][0]
  if (!requestId) {
    rt.reportError(
      'MissingEventData',
      'Event data is absent. EventData: $eventData'
    )
    return error('Event data is absent')
  }
  rt.rawEventData = rawEventData
  rt.requestId = requestId
  rt.eventPayload = eventData
  return rawEventData
}

fn (rt LambdaRuntime) reportError (errorType string, errorMessage string) {
  requestId := rt.requestId
  errorArray := {
    errorType,
    errorMessage,
  }
  errorPayload := ""
  http.post('/2018-06-01/runtime/invocation/$requestId/error', errorPayload)
}

fn (rt LambdaRuntime) reportInitError (errorType string, errorMessage string) {
  errorArray := {
    errorType,
    errorMessage,
  }
  errorPayload := ""
  http.post('/2018-06-01/runtime/init/error', errorPayload)
}

fn main () {
  runtimeApi := $env('AWS_LAMBDA_RUNTIME_API')
  functionCodePath := $env('LAMBDA_TASK_ROOT')
  handler := $env('_HANDLER')

  lambdaRuntime := LambdaRuntime{
    url: 'http://$runtimeApi',
    functionCodePath,
    handler,
  }

  handlerParts := handler.split('.')
  handlerFile := handlerParts[0]
  handlerFunction := handlerParts[1]

  while(true) {
    data := lambdaRuntime.getNextEventData()
    eventPayload := lambdaRuntime.getEventPayload()
    // TODO: figure out how to dynamically pull in handler
    handlerResponse := handler.handler(eventPayload)
    /*
    //Check if there was an error that runtime detected with the next event data
	if(isset($data["error"]) && $data["error"]) {
		continue;
	}

	//Process the events
	$eventPayload = $lambdaRuntime->getEventPayload();
	//Handler is of format Filename.function
	//Capture stdout
	ob_start();
	//try catch to capture any exceptions that may get thrown by the handler
	try{
		//Execute handler
		$functionReturn = $handlerFunction($eventPayload);
		$out = ob_get_clean();
		$lambdaRuntime->addToResponse($functionReturn);
		$lambdaRuntime->addToResponse($out);
		//Report result
		$lambdaRuntime->flushResponse();
	} catch (Exception $e) {
		//capture the output generated till the error is caught
		$out = ob_get_clean();
		//get the exception message
		$message = $e->getMessage();
		//construct the error message
		$lambdaRuntime->addToResponse(" exceptionMessage: $message");
		if($out !== "") {
			$lambdaRuntime->addToResponse(" stdout: $out");
		}
		//get the exception type
		$errorType = get_class($e);
		//report error to lambda
		$lambdaRuntime->reportError($errorType, trim($lambdaRuntime->getResponse()));

		//reset the response string
		$lambdaRuntime->resetResponse();
    */
  }
}
