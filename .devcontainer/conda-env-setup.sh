#! /bin/bash

# conda prefix, defined in devcontainer dockerfile
conda_prefix="/opt/conda"

# initiatlize conda
eval "$(conda shell.bash hook)"

# script to install additional conda environment stuff.  Most often executed
# as part of the dev_tools script run in container builds.

# assumes that desired channel priority is defined in the ~/.condarc
# channel priority probably needs to be conda-forge first given what is
# typically installed

# first update the base install to be up-to-date
#echo "updating base conda environment"
#mamba update -n base -y --all

# now create a clone of base environment
#echo "creating a clone of base environment named 'altair'"
#mamba create --name altair --clone base

# make sure the clone is up-to-date
#echo "updating 'altair' environment"
#mamba update -n altair -y --all

# install additional packages in the new cloned env
#echo "installing additional packages in 'altair' environment"
#mamba install -n altair -y altair vega_datasets altair_viewer jupyterlab jupyter

# install requirements for the project and install in that env
echo $DEVCONTAINER_WORKSPACE_PATH
if [[ -f $DEVCONTAINER_WORKSPACE_PATH/environment.yml ]]; then
    echo "installing project requirements in new conda environment"
    mamba env create -f $DEVCONTAINER_WORKSPACE_PATH/environment.yml
else
    echo "no environment.yml file found in $DEVCONTAINER_WORKSPACE_PATH"
fi

# define alternate environment and install packages, if needed
alt_env="chatgpt"
# install conda-forge packages needed, separated by spaces
list_additional_packages="pytest mock"
# install pip packages needed, separated by spaces
list_additional_pip_packages="git+https://github.com/mmabrouk/chatgpt-wrapper"
# create the new environment
conda create --name $alt_env -y
# get the python version
python_version=$(conda list -n $alt_env | grep "^python\s" | awk '{print $2}' | awk '{print substr($0,0,4);}')
# install conda-forge packages needed
mamba install -n $alt_env -y -c conda-forge python $list_additional_packages
# get the target pip directory, which now exists since python was installed in the env
target_pip_dir="$conda_prefix/envs/$alt_env/lib/python$python_version/site-packages"
# install pip packages needed
conda activate $alt_env
pip install $list_additional_pip_packages
conda deactivate
