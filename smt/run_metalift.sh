#!/bin/bash

docker build -f Dockerfile_metalift -t sort_smt .
docker run -it -v $(pwd):/app/smt sort_smt /bin/bash -c "cd /app && source venv/bin/activate && cd smt && ./exec_metalift.sh"
# docker run -it -v $(pwd):/app/smt sort_smt /bin/bash
