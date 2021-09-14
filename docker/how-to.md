# to build the container
docker build --tag=mec_optim:latest --tag=mec_optim:stable -f /path-to-dockerfile/mec_optim.Dockerfile /path-to-dockerfile/

# to run the container
docker run -it --rm -p 8888:8888 -v //c/path-of-local-dir:/src/notebooks/my-work -v //c/path-to-gurobi-licence-file/gurobi.lic:/opt/gurobi/gurobi.lic:ro mec_optim

# to retrieve from dockerhub:
docker pull alfredgalichon/mec_optim:2021-01

