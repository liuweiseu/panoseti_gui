#this would be for the server

import socket

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(10)


s.bind(('192.168.1.100',60000))

while 1:

      msg, cAdr = s.recvfrom(2048)
      print("got one", cAdr)

      msg2 = msg.decode().upper().encode()

      s.sendto(msg2, cAdr)