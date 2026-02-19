ARG IMAGE=intersystemsdc/irishealth-community
FROM $IMAGE

USER root

# 1. Install system dependencies & libgomp1
# libgomp1 is critical to prevent OpenMP crashes in background jobs
RUN apt-get update && apt-get install -y \
    python3-pip \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 2. Set Environment variables
# We force single-threading at the OS level to protect the IRIS Kernel
ENV OMP_NUM_THREADS=1 \
    MKL_NUM_THREADS=1 \
    PYTHONPATH=/usr/irissys/mgr/python \
    PATH="/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

# 3. Install AI libraries using irispython
# We pin transformers and add optimum-onnx to stop the Signal 11 crash
RUN /usr/irissys/bin/irispython -m pip install --target /usr/irissys/mgr/python \
    "transformers<4.58.0" \
    "optimum-onnx[onnxruntime]" \
    sentence-transformers \
    numpy==1.26.4

# 4. Fix permissions so the IRIS user can write to the python folder
# This prevents the 'Permission denied' errors during runtime weight loading
RUN chown -R irisowner:irisowner /usr/irissys/mgr/python && \
    chmod -R 775 /usr/irissys/mgr/python

WORKDIR /home/irisowner/dev

# 5. Copy and fix permissions for dev folder
COPY --chown=irisowner:irisowner . ./

# 6. Build IRIS
USER irisowner

RUN iris start IRIS \
    && sleep 5 \
    && iris session IRIS < iris.script > /tmp/build.log 2>&1 \
    && iris stop IRIS quietly

# 7. Startup
ENTRYPOINT ["/bin/sh", "-c", "iris start IRIS && tail -f /usr/irissys/mgr/messages.log"]