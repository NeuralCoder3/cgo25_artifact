import subprocess
import time
import os
import sys

domain_file = "meta/sequential/domain.pddl"
problem_file = "meta/sequential/problem.pddl"
destination = "seq_plan.txt"
expected_cost = 77
timeout = 30

if len(sys.argv) >= 2:
    domain_file = sys.argv[1]
if len(sys.argv) >= 3:
    problem_file = sys.argv[2]
if len(sys.argv) >= 4:
    destination = sys.argv[3]
if len(sys.argv) >= 5:
    expected_cost = int(sys.argv[4])
if len(sys.argv) >= 6:
    timeout = int(sys.argv[5])



cmd = "docker run --privileged -v $(pwd):/root/app local_planning planutils run lama " + domain_file + " " + problem_file
print(cmd, file=sys.stderr)
def cond():
    # exists a file called "sas_plan.*" that contains "cost = 77"
    for file in os.listdir("."):
        if file.startswith("sas_plan."):
            with open(file) as f:
                content = f.read()
            if "cost = "+str(expected_cost) in content:
                # copy the plan to destination
                with open(destination, "w") as f:
                    f.write(content)
                return True
    return False
    

# start process cmd 
# run until cond() evaluates to true or timeout
# then kill the process and report the runtime

# clean up all sas_plan.* files
for file in os.listdir("."):
    if file.startswith("sas_plan."):
        os.remove(file)

start = time.time()
proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
while not cond():
    if time.time() - start > timeout:
        proc.kill()
        print("timeout")
        sys.exit(1)
    time.sleep(1)
proc.kill()
print(f"{time.time() - start:.2f}")
