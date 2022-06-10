# PostgreSQL Dockerfiles

PostgreSQL Dockerfiles for CentOS 7 

Requirements                                                                    
------------                                                                    
- docker - https://docs.docker.com/engine/install/ubuntu/                       
- docker-compose - https://docs.docker.com/compose/install/                     
                                                                                
Usage                                                                           
-----                                                                           
- container 생성

  	docker-compose build --no-cache  
	
- container 구동 

	docker-compose up -d        
	
- container 소멸 

	docker-compose down      
	
- container를 유지하면서 사용
 
	docker-compose [start, stop, restart]        


Creating a database at launch
-----------------------------

You can create a postgresql superuser at launch by specifying POSTGRES_USER, POSTGRES_PASSWORD and POSTGRES_DB in docker-compose.yml

also, you can create a superuser through the docker command specified below.

	docker run --name postgresql -d \
		-e 'POSTGRESQL_USER=username' \
		-e 'POSTGRESQL_PASSWORD=ridiculously-complex_password1' \
		-e 'POSTGRESQL_DATABASE=my_database' \


TO connect your database with your newly create user

	psql -U username -h $(docker inspect --format {{.NetworkSettings.IPAddress}} postgresql)
