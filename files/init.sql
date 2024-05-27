{{range .}}
CREATE USER {{.user}} with password '{{.password}}';
CREATE DATABASE {{.db}} OWNER {{.user}};
grant all privileges on database {{.db}} to {{.user}};
{{end}}
