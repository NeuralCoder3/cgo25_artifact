#!/bin/bash

docker build -t sort_enum .
docker run -it -v $(pwd):/app/enum sort_enum /bin/bash -c "cd /app && source venv/bin/activate && cd enum && ./exec.sh --no-gpu"
