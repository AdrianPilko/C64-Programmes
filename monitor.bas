1 dim f%(8)
3 poke 53280,0 rem set border colour to black
4 poke 53281,0 rem set background colour to black
5  print "{clear}ade's: machine code monitor"
8  print "==========================="
10 print "1 - peek "
20 print "2 - poke "
25 print "3 - scroll(u:up,d:down,x exit,e edit)"
30 input c
40 if c=1 goto 50
45 if c=2 goto 80
48 if c=3 goto 130
50 print "enter location?":input a
60 print "enter number of bytes?": input b
70 for i=a to a+b-1:l=peek(i):n=1:for j=0to7:f(j)=sgn(l and n):n=n+n:next j
72 print i":"f(0)f(1)f(2)f(3)f(4)f(5)f(6)f(7)
75 next i 
77 print "press enter to continue...":input c 
78 goto 5
80 print "enter location?":input a
90 print "enter number of bytes?": input b
95 print "enter value":input v
100 for i=a to a+b-1:pokei,v:next i
110 print "memory poked " b " bytes with " v:print"press enter to continue":input c
120 goto 5 
130 print "enter start location?":input a:p=0
131 for i=a to a+23:l=peek(i):n=1:for j=7 to 0 step -1:f(j)=sgn(l and n):n=n+n:next
132 if p=i-a then pp$="<="
133 if p<>i-a then pp$=" " 
135 print i":"f(0)f(1)f(2)f(3)f(4)f(5)f(6)f(7)pp$:next
140 get d$
145 if d$="u" then p=p-1:print"{clear}":goto 155 
150 if d$="d" then p=p+1:print"{clear}":goto 155
152 if d$="x" then goto 5
153 if d$="e" then goto 1000 rem edit the value
154 goto 140
155 if p>=23 then p=23:a=a+1
156 if p<0 then p=0:a=a-1
157 if a<0 then a=0
160 goto 131
1000 print "enter new value for "p+a:input ed$ 
1002 h=val(ed$)   
1010 poke p+a,h
1050 goto 131
