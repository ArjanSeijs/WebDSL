taskkill /f /im java.exe
docker stop webdsl_mysql
docker rm webdsl_mysql
docker run --name webdsl_mysql -p 3306:3306 -e MYSQL_DATABASE=webdsldb -e MYSQL_USER=mysql -e MYSQL_PASSWORD=password -e MYSQL_ALLOW_EMPTY_PASSWORD=true -d mysql:5.7
webdsl run