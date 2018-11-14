
libs=interface math simple indicator overlay

PSQL=docker exec -i tap-postgres psql -U postgres
DATABASE=tap


start:
	docker start tap-postgres

stop:
	docker stop tap-postgres


init:
	docker run --name tap-postgres -e POSTGRES_PASSWORD=qwerty -p 6543:5432 -d postgres
	until ${PSQL} -c '\q' > /dev/null 2>&1; do sleep 1; done
	echo "CREATE DATABASE ${DATABASE};" | ${PSQL}




test-data:
	echo 'DROP SCHEMA public CASCADE' | ${PSQL} ${DATABASE};
	echo 'CREATE SCHEMA public' | ${PSQL} ${DATABASE};
	$(foreach lib,$(libs),cat ./$(lib)/*.sql | ${PSQL} ${DATABASE};)
	cat ./interface/impl/test/test.data.sql ./interface/impl/test/test.sql | ${PSQL} ${DATABASE} > /dev/null
	echo Done




clean: stop
	docker rm tap-postgres

