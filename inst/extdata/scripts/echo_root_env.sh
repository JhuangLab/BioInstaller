echo export ROOTSYS=${1} >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOTSYS}/lib' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOTSYS}/lib/root' >> ~/.bashrc
