# Закройте все окна VS Code
killall code 2>/dev/null

# Откройте проект через workspace файл
code project.code-workspace

project.code-workspace              # Общие настройки (без интерпретатора)
├── backend/
│   ├── .venv/                      # Своё окружение
│   └── .vscode/
│       └── settings.json           # Указывает на backend/.venv
├── frontend/
│   ├── .venv/                      # Своё окружение  
│   └── .vscode/
│       └── settings.json           # Указывает на frontend/.venv
└── docs/