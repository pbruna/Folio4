### Instalación fresca

#### 1. Configurar base de datos
Ejecutar:

```bash
RUN RAILS_ENV=production rake db:migrate
RUN RAILS_ENV=production rake db:seed
RUN RAILS_ENV=production rake assets:precompile
RUN RAILS_ENV=production rake tmp:create
```