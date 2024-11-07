FROM ubuntu:latest

RUN apt-get update && apt-get install -y python3 python3-pip python3-venv \
    python-is-python3 cmake build-essential z3 m4 libgmp-dev 
COPY ./cvc5 /app/cvc5
WORKDIR /app/cvc5
RUN ./configure.sh --auto-download && mkdir -p build && cd ./build && make && make install
WORKDIR /app
RUN python -m venv venv && . venv/bin/activate && \
    pip install z3-solver numpy
