import socket

UDP_PORT = 60000
IP_ADDR = '192.168.1.10'

sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
                     
sock.settimeout(4)
sock.bind(('', UDP_PORT))

while True:
    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
    print ("received message:", data)