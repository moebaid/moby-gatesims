import sys
args = sys.argv
organ = args[1]
num_splits = int(args[2])


f=open('mobysplitsim.sh')
bash = f.read()
f.close()


for i in range(1, num_splits + 1):
	number_split = str(i)
	#changes to macro
	new_macro = 'main_normalized_' + str(number_split) + '.mac'
	new_bash = bash.replace('main_normalized_x.mac', new_macro)

	new_bash = new_bash.replace('organ', organ)

	# save
	name_bash = 'mobysplitsim_' + number_split + '.sh'

	fileID = open(name_bash, 'w')
	fileID.write(new_bash)
	fileID.close()

