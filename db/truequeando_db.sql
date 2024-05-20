DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_database
      WHERE datname = 'truequeando_db'
   ) THEN
      PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE truequeando_db
          WITH
          OWNER = postgres
          ENCODING = ''UTF8''
          LC_COLLATE = ''Spanish_Spain.1252''
          LC_CTYPE = ''Spanish_Spain.1252''
          LOCALE_PROVIDER = ''libc''
          TABLESPACE = pg_default
          CONNECTION LIMIT = -1
          IS_TEMPLATE = False');
   END IF;
END
$$;

-- Conectar a la base de datos truequeando_db
\c truequeando_db

CREATE TABLE IF NOT EXISTS rols (
    id SMALLSERIAL PRIMARY KEY NOT NULL CHECK (id >= 0),
    name VARCHAR NOT NULL CHECK (name <> ''),
    state BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY NOT NULL,
	user_id INT NOT NULL CHECK (user_id >= 0),
    user_name VARCHAR NOT NULL CHECK (user_name <> ''),
	--change_password BOOLEAN DEFAULT FALSE NOT NULL,
    user_state BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS passwords (
    id SMALLSERIAL PRIMARY KEY NOT NULL,
	users_id INT NOT NULL REFERENCES users(id) CHECK (users_id >= 0),
    password JSONB NOT NULL,
    state BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS rols_users (
    id SERIAL PRIMARY KEY NOT NULL,
	rols_id INT NOT NULL REFERENCES rols(id) CHECK (rols_id >= 0),
	user_id INT NOT NULL REFERENCES users(id) CHECK (user_id >= 0),
    state BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS types_document_identification (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS type_gener (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS country (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS states (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	country_id INT REFERENCES country(id) NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS city (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	states_id INT REFERENCES states(id) NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS persons (
	id SERIAL PRIMARY KEY NOT NULL,
	number_identification INT NOT NULL CHECK (number_identification > 0) UNIQUE,
	types_document_identification_id INT REFERENCES types_document_identification(id) NOT NULL,
	photo BYTEA DEFAULT NULL,
	first_name VARCHAR NOT NULL,
	last_name VARCHAR NOT NULL,
	first_surname VARCHAR NOT NULL,
	last_surname VARCHAR NOT NULL,
	date_of_birth DATE NOT NULL,
	-- nationatily
	type_gener_id INT NOT NULL REFERENCES type_gener(id),
	-- residence_city
	email VARCHAR NOT NULL,
	validated_email BOOLEAN NOT NULL DEFAULT FALSE,
	number_phone INT DEFAULT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE opinions (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE brands (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE type_products (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE type_states_products (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	state BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE products (
	id SERIAL PRIMARY KEY NOT NULL,
	name VARCHAR NOT NULL,
	brand_id INT REFERENCES brands(id) NOT NULL,
	seller_id INT REFERENCES persons(id) NOT NULL,
	description VARCHAR NOT NULL,
	price INT NOT NULL CHECK (price > 0),
	quantity INT NOT NULL CHECK (quantity >= 0),
	characteristics JSONB NOT NULL,
	new BOOLEAN DEFAULT TRUE,
	type_products_id INT REFERENCES type_products(id) NOT NULL,
	type_states_products_id INT REFERENCES type_states_products(id) NOT NULL DEFAULT 1
);