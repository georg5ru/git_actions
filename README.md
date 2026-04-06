## Проект DRF (деплой + CI/CD)

### Эндпоинты
- **API**: `http://<server-ip>:8000/api/`
- **Админка**: `http://<server-ip>:8000/admin/`
- **JWT**: `http://<server-ip>:8000/api/token/`
- **JWT refresh**: `http://<server-ip>:8000/api/token/refresh/`

### Быстрый старт на сервере (docker-compose)
1) Клонировать репозиторий и перейти в ветку деплоя:

```bash
git clone <your-repo-url>
cd DRF
git checkout develop
```

2) Создать `.env` по шаблону:

```bash
cp .env.example .env
nano .env
```

3) Запуск:

```bash
docker-compose up -d --build
docker ps
docker-compose logs --tail=100 backend
```

### Безопасность (минимум по домашке)
- **SSH-ключи**: подключаться к серверу по ключу, парольный вход отключить.
- **Порты**: открыть только нужные (обычно 22/tcp, 80/tcp, 443/tcp; при запуске на 8000 — только на время отладки).
- **UFW**:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose
```

### Автозапуск деплоя (systemd)
Если нужно, чтобы приложение поднималось после перезагрузки сервера, можно создать systemd unit:

```bash
sudo nano /etc/systemd/system/drf.service
```

Содержимое:

```ini
[Unit]
Description=DRF docker-compose app
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/DRF
ExecStart=/usr/bin/docker-compose up -d --build
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Далее:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now drf.service
sudo systemctl status drf.service
```

### CI/CD (GitHub Actions)
Workflow лежит в `.github/workflows/ci_cd.yml` и запускается на каждый `push`.

- **Tests job**: устанавливает зависимости и запускает `python manage.py test`.
- **Deploy job**: выполняется **только для ветки `develop`** и **только после успешных тестов**.

#### Secrets (GitHub → Settings → Secrets and variables → Actions)
Нужно добавить:
- **SSH_HOST**: IP сервера
- **SSH_USER**: пользователь (например `ubuntu`)
- **SSH_PRIVATE_KEY**: приватный ключ (с переносами строк)
- **PROJECT_DIR**: папка проекта на сервере (например `/home/ubuntu/DRF`)

После этого любой push в `develop` запустит тесты и при успехе задеплоит проект на сервер.