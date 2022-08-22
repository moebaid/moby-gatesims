import sys
args = sys.argv

organ = args[1]
no_splits = int(args[2])
totalevents = float(args[3])
start_sim = int(args[4])
end_sim = int(args[5])

no_events_split = int(totalevents/no_splits)

# read macro file
path = 'mobysplitsims/' + organ
macro_path =  path + '/main_normalized-SPLIT.mac'
f=open(macro_path)
macro = f.read()



for i in range(start_sim, end_sim + 1):
	number_split = str(i)
	#changes to macro
	new_macro = macro.replace('XXX', str(no_events_split))

	mhd_name = 'Source_normalized_' + organ + '.mhd'
	new_macro = new_macro.replace('xxx.mhd', mhd_name)
	
	name_file = 'distrib-SPLIT_' + number_split + '.mhd'
	new_macro = new_macro.replace('distrib-SPLIT.mhd', name_file)

	name_stat = 'stat-SPLIT_' + number_split + '.txt'
	new_macro = new_macro.replace('stat-SPLIT.txt', name_stat)

	# save
	name_macro = path + '/main_normalized_' + number_split + '.mac'

	fileID = open(name_macro, 'w')
	fileID.write(new_macro)
	fileID.close()

