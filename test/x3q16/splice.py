file = open("program.bin", "r").read()
newout = ""
print("Splicing...")
for i in range(len(file)//4):
    newout += file[i*4:i*4+4] + "\n"

#print("SPLICE:")
#print(newout)
#print("")

file = open("program.bin", "w")
file.write(newout)
file.close()

print("Spliced!\n")

