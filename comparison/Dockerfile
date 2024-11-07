FROM rust:latest

RUN apt-get update && apt-get install -y python3 python3-pip python3-venv \
    llvm python-is-python3 cmake clang build-essential
WORKDIR /app
RUN python -m venv venv && . venv/bin/activate && \
    pip install plotly pandas numpy matplotlib xed
