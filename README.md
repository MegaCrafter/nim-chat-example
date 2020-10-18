# Nim Chat Example

Just a really basic chatting app in Nimlang. IP's are set for localhost:8080 on server and client. The ease of sockets, locks and threads is just insane.

## Note

This app uses Nim's threading library. Because of this, you must compile the files with `--threads:on` arguments.

### Example

`nim c --threads:on server.nim`
