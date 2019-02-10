# You have to be connected as user with enough privileges (root).

# Create AGRAF database:
create database grafana;

# Create main AGRAF user:
create user grafana identified by 'Agraf2019#';
grant all privileges on grafana.* to `grafana`@`%`;
grant file on *.* to `grafana`@`%`;

