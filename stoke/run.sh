#!/bin/bash

docker build -t cstoke .
# docker run -it cstoke /home/stoke/stoke/bin/stoke
docker run -v $(pwd):/home/stoke/app -it cstoke bash -c "cd /home/stoke/app && ./init.sh"
docker run -v $(pwd):/home/stoke/app -it cstoke bash -c "cd /home/stoke/app && ./sym/run.sh"