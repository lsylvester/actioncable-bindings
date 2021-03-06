withContent = (content)->
  contentElement = document.getElementById('content')
  unless contentElement
    contentElement = document.createElement("div"); 
    contentElement.setAttribute("id", "content")
    document.querySelector('body').appendChild(contentElement)
  contentElement.innerHTML = content

test "it should create subscritions for action-cable-subscription elements in the dom", 2, (assert)->
  withContent """
    <action-cable-subscription channel="Chat5Channel"></action-cable-subscription>
  """
  equal document.querySelector('action-cable-connection').cable.subscriptions.findAll("{\"channel\":\"Chat5Channel\"}").length, 1

  withContent ""
  done = assert.async()
  requestAnimationFrame(->
    equal document.querySelector('action-cable-connection').cable.subscriptions.findAll("{\"channel\":\"Chat5Channel\"}").length, 0
    done()
  ,100)

test "it should trigger events on the elements for messages received through the channel", ->
  withContent """
    <action-cable-subscription id='event-test' channel='Chat4Channel'>
  """
  document.getElementById("event-test").addEventListener "cable:received", (event)->
    deepEqual event.data, {"message": "Hello"}

  document.querySelector('action-cable-connection').cable.subscriptions.notify("{\"channel\":\"Chat4Channel\"}","received", {"message": "Hello"})

test "it should perform actions when 'cable:perform' events are triggered on the element", (assert)->
  done = assert.async()
  withContent """
    <action-cable-subscription id='action-test' channel='Chat2Channel'>
    </action-cable-subscription>
  """

  subscription = document.querySelector('action-cable-connection').cable.subscriptions.findAll("{\"channel\":\"Chat2Channel\"}")[0]
  subscription.perform = (action, data)->
    equal action, 'doAction'
    done()
  document.getElementById("action-test").perform("doAction")


test "it should trigger events on the on the element that caused the subscription to be created", ->
  expect 2
  withContent """
    <action-cable-subscription id='test1' channel='Room1Channel'>
    </action-cable-subscription>
    <action-cable-subscription id='test2' channel='Mention1Channel'>
    </action-cable-subscription>
  """
  document.getElementById("test1").addEventListener "cable:received", (event)->
    equal event.data, 1

  document.getElementById("test2").addEventListener "cable:received", (event)->
    equal event.data, 2

  document.querySelector('action-cable-connection').cable.subscriptions.notify("{\"channel\":\"Room1Channel\"}","received", 1)
  document.querySelector('action-cable-connection').cable.subscriptions.notify("{\"channel\":\"Mention1Channel\"}","received", 2)

test "it should use the named cable", ->
  expect 1
  withContent """
    <action-cable-connection name='specialCable'></action-cable-connection>
    <action-cable-subscription id='test1' channel='Room1Channel' cable="specialCable">
    </action-cable-subscription>
  """
  equal document.querySelector('[name="specialCable"]').cable, document.getElementById("test1").getCable()
