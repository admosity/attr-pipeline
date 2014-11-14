# Attribute Pipeline

Easy to use no frills object validation/object transformations.

## Quick start

`npm install attr-pipeline`

```javascript
var ap = require('attr-pipeline');

var validator = new ap.Validator({
  attr1: {required: true},
  // attribute with pipeline
  // will only apply if the attribute is present in the object
  attr2: {
    // pipeline functions executed in order and only if attribute exists
    // if required is not supplied
    pipe: [
      // single argument functions must return a boolean (for success/failure)
      function(value) {
        return typeof value === 'string';
      },
      // transformations must have a callback
      function(value, callback) {
        return callback(null, value + " World!");
      }
    ]
  }
});

// EXAMPLES

// with callbacks

validator.validate({}, function(err, object) {
  // error here attr1 is required
});

validator.validate({attr1: "anything"}, function(err, object) {
  console.log(object); // {attr1: "anything"}
});

validator.validate({attr1: "anything", attr2: 1}, function(err, object) {
  // error here attr2 is not a string
});

validator.validate({attr1: "anything", attr2: "Hello"}, function(err, object) {
  console.log(object); // {attr1: "anything", attr2: "Hello World!"}
});

// as promises

validator.validate({})
  .then(function(object) {
    // does not execute
  })
  .catch(function(err) {
    // error here attr1 is required
  })
  .done();

validator.validate({attr1: "anything"})
  .then(function(object) {
    console.log(object); // {attr1: "anything"}
  })
  .catch(function(err) {
    // does not execute
  })
  .done();

validator.validate({attr1: "anything", attr2: 1})
  .then(function(object) {
    // does not execute
  })
  .catch(function(err) {
    // error here attr2 is not a string
  })
  .done();

validator.validate({attr1: "anything", attr2: "Hello"})
  .then(function(object) {
    console.log(object); // {attr1: "anything", attr2: "Hello World!"}
  })
  .catch(function(err) {
    // does not execute
  })
  .done();
```