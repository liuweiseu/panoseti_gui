#this would be for the client
import socket

c = socket.socket(socket.AF_INET, socket.SOCK_DGRAM,socket.IPPROTO_UDP)
c.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
c.settimeout(10)
c.bind(('',60001))
#msg = 'Hello World!'

#Send to the known address of the server
#No need to bind() or connect()
#c.sendto(msg.encode(),('192.168.1.10', 60001))

msg2, sAdr = c.recvfrom(2048)

print(msg2)

c.close()