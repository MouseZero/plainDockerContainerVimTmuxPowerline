docker stop test
docker rm test
docker build -t test .
docker run -p 2223:22 --name test test
