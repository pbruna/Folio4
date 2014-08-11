## Instalación fresca

### Configuración de Servicios

#### 1. Assets en S3

Crear archivo ```config/asset_sync.yml```

#### 2. Attachments en S3

Crear archivo ```config/aws.yml```

#### 3. Envío de correos con Mailgun

Crear archivo ```config/initializers/smtp_config.rb```

#### 4. Configuración de NGinx
Algo así en ```/etc/nginx/conf.d/folio_nginx.conf```

```nginx
upstream folio_old {
  server unix:/tmp/unicorn.folio.sock fail_timeout=0;
}

upstream folio4 {
  server docker01.itlinux.cl:8080;
}

server {
  listen 80 deferred;
  server_name itlinux.folio.cl;
  root /home/folio/APP/folio/public;
  try_files $uri/index.html $uri @folio_old;
  location @folio_old {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://folio_old;
  }

  client_max_body_size 4G;
  keepalive_timeout 10;
}

server {
  server_name *.folio.cl;
  try_files $uri/index.html $uri @folio4;
  location @folio4 {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://folio4;
  }

  client_max_body_size 4G;
  keepalive_timeout 10;
}
```

###¢ 5. Configurar base de datos
Ejecutar:

```bash
RUN RAILS_ENV=production rake db:migrate
RUN RAILS_ENV=production rake db:seed
RUN RAILS_ENV=production rake assets:precompile 
RUN rake assets:sync RAILS_ENV=production # se los lleva a S3
RUN RAILS_ENV=production rake tmp:create
```

La base de datos está en krusty

#### Notas
Parece que ```unicorn``` escucha en el puerto 8080