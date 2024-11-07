FROM ubuntu:latest

# install python
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv \
    python-is-python3 minizinc cmake build-essential
COPY minizinc/chuffed /app/chuffed
WORKDIR /app/chuffed
RUN cmake -B build -S . && cmake --build build --target install
WORKDIR /app
RUN python -m venv venv && . venv/bin/activate && \
    pip install z3-solver mip gurobipy numpy
