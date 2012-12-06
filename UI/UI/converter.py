import binascii

def convert():
    f=open("/afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI/strings","r")
    data=f.read()
    f.close()
    
    strings=data.split(';')

  
    strings=strings[:len(strings)-1]
    final=strings[:]
    lengths=strings[:]


    for i in range(len(final)):
        final[i-1]=None
        

    for s in strings:
        final[strings.index(s)]=binascii.hexlify(s)
        lengths[strings.index(s)]=len(s) ##get length of each string

    ##lengths of each string
    f=open("/afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI/lengths","w")
    for i in lengths:
        f.write(str(i) + "\n")

    f.close()

##    final=final[:len(final)-1]

    
    
    
    ##actual hex for .coe file
    f=open("/afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI/hex.coe","w")

    ##write initialization for beginning of file
    f.write("memory_initialization_radix = 16;\nmemory_initialization_vector =\n");
    
    for i in final:
        every_2=[i[j:j+2] for j in range(0,len(i),2)]
        for e in every_2:
            if e!='0a':
                f.write(str(e) + "\n")
        f.write("\n")

    f.write(";")
    f.close()

    f=open("/afs/athena.mit.edu/user/n/b/nbugg/FPGA_Telephony/UI/UI/addresses","w")

    current=0
    f.write(str(0) + "\n")
    
    ##addresses for beginning of each string
    for i in strings:
        if (strings.index(i)>0):
            f.write(str(len(strings[strings.index(i)-1]) + current) + "\n")
            current+=len(strings[strings.index(i)-1])


    f.close()

    
        
    

    
    

    
