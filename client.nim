import net
import locks

let socket = newSocket()
socket.connect("localhost", Port(8080))

var init = false

var stdoutLock: Lock
stdoutLock.initLock()

proc handleServer(socket: Socket) {.thread.} =    
    var message = ""

    while true:
        let ch = socket.recv(1)
        if ch == "\0":
            stdoutLock.acquire()
            stdout.writeLine message
            stdoutLock.release()
            message = ""
        else:
            message = message & ch

var readerThread: Thread[Socket]
readerThread.createThread(handleServer, socket)

while true:
    stdoutLock.acquire()

    if not init:
        stdout.write "Username: "
        init = true

    stdoutLock.release()

    let message = stdin.readLine()
    socket.send(message & "\0")