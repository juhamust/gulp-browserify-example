$ = require 'jquery'
Backbone = require 'backbone'

# Simple model example
MyModel = Backbone.Model.extend
  defaults:
    name: 'World'

# Even more simple view
MyView = Backbone.View.extend
  el: '#main'
  render: () ->
    return @.$el.html('Hello, ' + @.model.get('name') + '!')

# Combine model with view and render the output
$(document).ready () ->
  myModel = new MyModel
    name: 'Stranger'

  myView = new MyView
    model: myModel

  myView.render()

