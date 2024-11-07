#!/bin/bash

docker build -t sort_cp .
docker run -it -v $(pwd):/app/cp sort_cp /bin/bash -c "cd /app && source venv/bin/activate && cd cp && ./exec.sh"

echo "If you have Gurobi, manually install gurobipy and run cp/mip/sort_gurobi.py"