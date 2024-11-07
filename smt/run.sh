#!/bin/bash

docker build -t sort_smt .
docker run -it -v $(pwd):/app/smt sort_smt /bin/bash -c "cd /app && source venv/bin/activate && cd smt && ./exec.sh"
