
==================
Using Nim Channels
==================

Recently I refactored the code to a small command line utility that is part of my shell prompt, called "`coven`_". This utility runs multiple commands in parallel, and will display something based on the output of the given command. I originally created this tool to help notify me when I recieved new email from a background task (launchd/cron job) fetched new email, or new to-do tasks were added to my calendar. Running each of these commands sequentially would have me waiting a couple of seconds for my shell prompt to redraw each time, so I collapsed them into running simultaeniously.

.. _coven: https://github.com/samdmarshall/coven


To start, what are Channels in Nim? Channels are a method of communicating between threads. The Channel has a type that describes the messages it can send and recieve:

.. code-block:: nim
  :number-lines: 0

  type CommandOutput = object
    idx: int
    output: string

  var channel: Channel[CommandOutput]
  channel.open()

After that, the individual worker threads can be created.

.. code-block:: nim
  :number-lines: 0

  type ParallelCommand = object
    idx: int
    command: string
    status: string
    completed: bool

.. code-block:: nim
  :number-lines: 0

  var commands = [
    ParallelCommand(idx: 1, command: "notmuch count tag:unread", status: "!", completed: false),
    ParallelCommand(idx: 2, command: "notmuch count tag:flagged", status: "@", completed: false),
    ParallelCommand(idx: 3, command: "todo list --due 1", status: "?", completed: false)
  ]

  proc execParallelCommand(arg: ParallelCommand) =
    let output_raw = execProcess(arg.command)
    let msg = CommandOutput(idx: arg.idx, output: output_raw)
    channel.send(msg)

  for command in commands:
    var worker: Thread[ParallelCommand]
    createThread(worker, execParallelCommand, command)
    worker.joinThread()

Once all of the worker threads are created, all that is left is to wait for the messages that are delivered over the channel.

.. code-block:: nim
  :number-lines: 0

  # While there is a command that hasn't finished running yet, keep monitoring for new messages
  while commands.anyIt(it.completed == false):

    # Check to see if there is new messages to read
    let tried = channel.tryRecv()

    # Truthy when there are unread messages
    if tried.dataAvailable:

      # Get the CommandOutput object
      let response = tried.msg

      var lines = response.output.strip(chars = Whitespace + Newlines)
      if not (len(lines) > 0 and lines != "0"):
        commands[response.idx].status = ""
      commands[response.idx].completed = true

    # Blocking while waiting for new messages
    sleep(50)


