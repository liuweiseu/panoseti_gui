#this would be for the client
import socket

c = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
c.settimeout(10)

msg = 'Hello World!'

c.sendto(msg.encode(),('192.168.1.100', 10000))

msg2, sAdr = c.recvfrom(2048)

print(msg2)

c.close()