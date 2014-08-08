### Instalación fresca

#### 1. Configurar base de datos
Ejecutar:

```bash
RUN RAILS_ENV=production rake db:migrate
RUN RAILS_ENV=production rake db:seed
RUN RAILS_ENV=production rake assets:precompile 
RUN rake assets:sync RAILS_ENV=production # se los lleva a S3
RUN RAILS_ENV=production rake tmp:create
```

#### Notas
Parece que ```unicorn``` escucha en el puerto 8080