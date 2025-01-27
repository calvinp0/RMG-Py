# RMG Dockerfile 
# The parent image is the base image that the Dockerfile builds upon.
# The RMG installation instructions suggest Anaconda for installation by source, however, we use micromamba for the Docker image due to its smaller size and less overhead.
# https://hub.docker.com/layers/mambaorg/micromamba/1.4.3-jammy/images/sha256-0c7c97be938c5522dcb9e1737bfa4499c53f6cf9e32e53897607a57ba8b148d5?context=explore
# We are using the sha256 hash to ensure that the image is not updated without our knowledge. It considered best practice to use the sha256 hash
FROM --platform=linux/amd64 mambaorg/micromamba@sha256:0c7c97be938c5522dcb9e1737bfa4499c53f6cf9e32e53897607a57ba8b148d5

# Set the user as root
USER root

# Create a login user named rmguser
ARG NEW_MAMBA_USER=rmguser
ARG NEW_MAMBA_USER_ID=1000
ARG NEW_MAMBA_USER_GID=1000
RUN usermod "--login=${NEW_MAMBA_USER}" "--home=/home/${NEW_MAMBA_USER}" \
        --move-home "-u ${NEW_MAMBA_USER_ID}" "${MAMBA_USER}" && \
    groupmod "--new-name=${NEW_MAMBA_USER}" \
             "-g ${NEW_MAMBA_USER_GID}" "${MAMBA_USER}" && \
    # Update the expected value of MAMBA_USER for the
    # _entrypoint.sh consistency check.
    echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
    :

# Set the environment variables
ARG MAMBA_ROOT_PREFIX=/opt/conda
ENV MAMBA_USER=$NEW_MAMBA_USER
ENV BASE=$MAMBA_ROOT_PREFIX

# Install system dependencies
#
# List of deps and why they are needed:
#  - make, gcc, g++ for building RMG
#  - git for downloading RMG respoitories
#  - libxrender1 required by RDKit
# Clean up the apt cache to reduce the size of the image
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    make \
    libgomp1\
    libxrender1 \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Change user to the non-root user
USER $MAMBA_USER

# Make directory for RMG-Py and RMG-database
RUN mkdir -p /home/rmguser/code

# Change working directory to code
WORKDIR /home/rmguser/code

# Clone the RMG base and database repositories. The pulled branches are only the main branches.
RUN git clone --single-branch --branch main --depth 1 https://github.com/ReactionMechanismGenerator/RMG-Py.git \ 
    && git clone --single-branch --branch main --depth 1 https://github.com/ReactionMechanismGenerator/RMG-database.git

# cd into RMG-Py
WORKDIR /home/rmguser/code/RMG-Py

# Install RMG-Py and then clean up the micromamba cache
RUN micromamba create -y -f environment.yml && \
    micromamba clean --all -f -y

# Activate the RMG environment
ARG MAMBA_DOCKERFILE_ACTIVATE=1
ENV ENV_NAME=rmg_env

# Set environment variables
# These need to be set in the Dockerfile so that they are available to the build process
ENV PATH /opt/conda/envs/rmg_env/bin:$PATH
ENV PYTHONPATH /home/rmguser/code/RMG-Py:$PYTHONPATH
ENV PATH /home/rmguser/code/RMG-Py:$PATH

# Build RMG
RUN make \
    && echo "export PYTHONPATH=/home/rmguser/code/RMG-Py" >> ~/.bashrc \
    && echo "export PATH=/home/rmguser/code/RMG-Py:$PATH" >> ~/.bashrc

# Create the link between Julia and RMG-Py.
# We do not use the command in Julia 'using ReactionMechanismSimulator' because the command is only for determining if the package is installed.
# The command does not actually install the package but instead increases the build time, therefore not required.
# Install RMS
# The extra arguments are required to install PyCall and RMS in this Dockerfile. Will not work without them.
# Final command is to compile the RMS during Docker build - This will reduce the time it takes to run RMS for the first time
RUN touch /opt/conda/envs/rmg_env/condarc-julia.yml
RUN CONDA_JL_CONDA_EXE=/bin/micromamba julia -e 'using Pkg;Pkg.add(PackageSpec(name="PyCall", rev="master")); Pkg.build("PyCall"); Pkg.add(PackageSpec(name="ReactionMechanismSimulator", rev="main"))' \
    && python -c "import julia; julia.install(); import diffeqpy; diffeqpy.install()" \
    && python-jl -c "from pyrms import rms"

# RMG-Py should now be installed and ready - trigger precompilation and test run
# and then delete the results, preserve input.py
RUN python-jl rmg.py examples/rmg/minimal/input.py \
    && mv examples/rmg/minimal/input.py . \
    && rm -rf examples/rmg/minimal/* \
    && mv input.py examples/rmg/minimal/

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash", "--login"]
