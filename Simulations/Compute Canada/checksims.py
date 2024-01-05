import os

prompt = "Give source organ: "
sourceorgan = input(prompt)

prompt = "Give number of particles to simulate: "
N_particles = input(prompt)

prompt = "Give number of splits: "
N_splits = input(prompt)

path = 'scratch/mobysplitsims/' + sourceorgan + '/output'

os.chdir(path)

files = os.listdir()
statfiles = [f for f in files if 'stat-SPLIT_' in f]

i = 0
for fname in statfiles:
    f = open(fname)
    stats = f.readlines()
    if N_particles in stats[1]:
        i += 1

print('Completed simulations = ', str(i))

if i != N_splits:
    print('Incomplete simulations = ', str(len(statfiles) - i))
    print('Missing simulations = ', str(N_splits - len(statfiles)))