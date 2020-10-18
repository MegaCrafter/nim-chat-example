import net
import sharedlist
import locks

let server = newSocket()
server.bindAddr(Port(8080))
server.listen()

type 
    Client = object
        name: string
        socket: Socket
        address: string

var room: SharedList[Client]
room.init()
# room.add(Client(name: "MegaCrafter", socket: server, address: "localhost"))

proc broadcast(sender: Client, message: string) =
    for cl in room.items():
        cl.socket.send("(" & sender.name & "): " & message & "\0")

var client: Socket
var address = ""

var stdoutLock: Lock
stdoutLock.initLock()

proc handleClient(args: tuple[socket: Socket, address: string]) {.thread.} =
    var client: Client
    var init = false
    var message: string = ""

    let socket = args.socket
    let address = args.address

    while true:
        let ch = socket.recv(1)
        if ch == "\0": # end of message
            if not init: # first message is the name
                client = Client(name: message, socket: socket, address: address)
                room.add(client)
                init = true
            else:
                stdoutLock.acquire()
                stdout.writeLine("(" & client.name & "): " & message)
                stdoutLock.release()
                
                client.broadcast(message)

            message = ""
        else:
            message = message & ch


while true:
    server.acceptAddr(client, address)
    echo "[LOG] Client connected from: ", address

    var thread: Thread[tuple[socket: Socket, address: string]]
    thread.createThread(handleClient, (client, address))
