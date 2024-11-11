FROM rust:latest

RUN apt-get update && apt-get install -y opencl-headers clinfo ocl-icd-libopencl1 intel-opencl-icd ocl-icd-opencl-dev \
    python3 python3-pip python3-venv python-is-python3 

RUN cmake -B build -S . && cmake --build build --target install
WORKDIR /app
RUN python -m venv venv && . venv/bin/activate && \
    pip install matplotlib plotly numpy pandas seaborn scikit-learn tqdm
