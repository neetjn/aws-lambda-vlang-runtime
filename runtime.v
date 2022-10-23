import http

GET := 'GET'
POST := 'POST'

struct LambdaRuntime {
  mut url string
  mut functionCodePath string
  mut response string
  // TODO: investigate struct for event data
  mut rawEventData Response
  // TODO: investigate struct for event payload
  mut eventPayload string
  // TODO: investigate fn for handler
  mut handler string
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
  rt.rawEventData = http.get('/2018-06-01/runtime/invocation/next')
  eventData := rt.rawEventData.text
  requestId := rt.rawEventData.header.data['lambda-runtime-aws-request-id'][0]
  if (!requestId) {
    rt.reportError(
      'MissingEventData',
      'Event data is absent. EventData: $eventData'
    )
    return {
      error: true,
    }
  }
  rt.requestId = requestId
  rt.eventPayload = eventData
  return rt.rawEventData
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
