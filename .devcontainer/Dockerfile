# image source here: https://github.com/devcontainers/images/tree/main/src/miniconda
FROM mcr.microsoft.com/devcontainers/miniconda

# Optional to install a different version of Python
# RUN conda install -y python=3.6 \
#     && pip install --no-cache-dir pipx \
#     && pipx uninstall pipx \
#     && pipx reinstall-all

# can install pip packages using pipx, which won't touch the global environment
# prefer to install in conda env instead though so don't conflict with conda or conda-forge solutions
# RUN pipx install prospector

# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
# COPY environment.yml* .devcontainer/noop.txt /tmp/conda-tmp/
# RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
#     && rm -rf /tmp/conda-tmp

# Install mamba and use that instead for environment.yml
# updating all so the codespace prebuild has done this in advance
USER vscode
RUN /opt/conda/bin/conda install -n base -c conda-forge -y mamba
RUN mamba update -n base -c conda-forge -y mamba
RUN mamba update -n base -c conda-forge -y --all
USER root
COPY .devcontainer/environment.yml .devcontainer/noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/mamba env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp
# assumes environment.yml file exists in workspace root, if not this will fail
COPY environment.yml .devcontainer/noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/mamba create --name project --clone base && /opt/conda/bin/mamba env update -n project -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git screenfetch bash-completion \
    xsel xclip fonts-powerline tmux build-essential cmake gdb vim-nox npm jq shellcheck \
    python3-dev autotools-dev autoconf automake pkg-config python3-docutils \
    libseccomp-dev libjansson-dev libyaml-dev libxml2-dev fish figlet global postgresql \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
