/*
private $url;
	private $functionCodePath;
	private $requestId;
	private $response;
	private $rawEventData;
	private $eventPayload;
	private $handler;
*/

GET := 'GET'
POST := 'POST'

struct LambdaRuntime {
  url string
  functionCodePath string
  response string
  // TODO: investigate struct for event data
  rawEventData string
  // TODO: investigate struct for event payload
  eventPayload string
  // TODO: investigate fn for handler
  handler string
}

// fn init
