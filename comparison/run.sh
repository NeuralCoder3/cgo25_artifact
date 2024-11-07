#!/bin/bash

docker build -t sort_comp .
docker run -it -v $(pwd):/app/comparison sort_comp /bin/bash -c "cd /app && source venv/bin/activate && cd comparison && ./exec.sh"