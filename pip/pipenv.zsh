export PIPENV_PYPI_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple
#export PIPENV_VENV_IN_PROJECT=1

# set temp folder into ram disk
if [[ -e /Volumes/RAM ]]; then
    mkdir -p /Volumes/RAM/Cache/Pipenv
    export PIPENV_CACHE_DIR=/Volumes/RAM/Cache/Pipenv
fi