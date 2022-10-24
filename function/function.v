pub fn handler() string {
  return 'Hello World'
}

pub fn exception_handler() string {
  println('invoking exception_handler')
  return error('Error processing request')
}
